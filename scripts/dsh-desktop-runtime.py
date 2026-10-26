"""Private npm backend for Kaenix's source-patched DSH Desktop.

Only `setup` downloads packages. Neither setup nor validation starts dsh web.
The desktop calls `context` before Tauri, then holds the shared runtime lock.
"""
import argparse
import contextlib
import fcntl
import json
import os
from pathlib import Path
import shutil
import stat
import subprocess
import sys
import tempfile

VERSION = "0.2.1-rc.2"
PACKAGE = "@deepseek-ai/dsh"
ROOT_PARTS = (".local", "share", "dsh-desktop-isolated")


class RuntimeError_(Exception):
    pass


def directory(path: Path) -> None:
    """Create a private directory, refusing redirects and foreign ownership."""
    try:
        path.mkdir(mode=0o700)
    except FileExistsError:
        pass
    info = path.lstat()
    if not stat.S_ISDIR(info.st_mode) or info.st_uid != os.getuid():
        raise RuntimeError_(f"Not an owned, non-symlink directory: {path}")


def prepare(args):
    home = Path(os.environ.get("HOME", ""))
    if not home.is_absolute() or home == Path("/") or not home.is_dir():
        raise RuntimeError_("HOME must name an existing absolute user home")
    root = home
    # Refuse even an ancestor symlink, rather than redirecting into existing data.
    for part in ROOT_PARTS:
        root = root / part
        directory(root)
    if stat.S_IMODE(root.stat().st_mode) & 0o077:
        raise RuntimeError_(f"Isolation root must have mode 0700: {root}")
    for relative in ("dsh", "agents", "config", "data", "cache", "state", "npm", "pnpm"):
        directory(root / relative)
    runtime = root / "runtime"
    if runtime.exists() or runtime.is_symlink():
        directory(runtime)
    lock = root / "runtime.lock"
    environment = {
        "DSH_HOME": str(root / "dsh"),
        "DSH_AGENTS_HOME": str(root / "agents"),
        "DSH_BIN": args.backend_launcher,
        "XDG_CONFIG_HOME": str(root / "config"),
        "XDG_DATA_HOME": str(root / "data"),
        "XDG_CACHE_HOME": str(root / "cache"),
        "XDG_STATE_HOME": str(root / "state"),
        "npm_config_cache": str(root / "cache" / "npm"),
        "npm_config_prefix": str(root / "npm"),
        "npm_config_userconfig": "/dev/null",
        # npm refuses loading the same path for both user and global config.
        "npm_config_globalconfig": str(root / "config" / "npm-globalrc"),
        "npm_config_registry": "https://registry.npmjs.org",
        "npm_config_store_dir": str(root / "cache" / "pnpm"),
        "PNPM_HOME": str(root / "pnpm"),
        "PNPM_CONFIG_STORE_DIR": str(root / "cache" / "pnpm"),
        "PATH": os.pathsep.join((str(Path(args.node).parent), args.pnpm_bin,
                                 os.environ.get("PATH", ""))),
    }
    return root, runtime, lock, environment


@contextlib.contextmanager
def locked(path: Path, exclusive: bool):
    descriptor = os.open(path, os.O_RDWR | os.O_CREAT | os.O_NOFOLLOW, 0o600)
    try:
        info = os.fstat(descriptor)
        if not stat.S_ISREG(info.st_mode) or info.st_uid != os.getuid() or info.st_nlink != 1:
            raise RuntimeError_(f"Unsafe runtime lock: {path}")
        try:
            fcntl.flock(descriptor, (fcntl.LOCK_EX if exclusive else fcntl.LOCK_SH) | fcntl.LOCK_NB)
        except BlockingIOError as error:
            raise RuntimeError_("DSH Desktop or backend setup is running; quit it and retry") from error
        yield descriptor
    finally:
        os.close(descriptor)


def backend(runtime: Path) -> Path:
    package = runtime / "node_modules" / "@deepseek-ai" / "dsh"
    manifest = package / "package.json"
    entry = package / "lib" / "bin.js"
    for path in (manifest, entry):
        if not path.is_file() or not path.resolve().is_relative_to(runtime.resolve()):
            raise RuntimeError_("Private backend is absent or redirected; run dsh-desktop-setup")
    try:
        metadata = json.loads(manifest.read_text())
    except (ValueError, OSError) as error:
        raise RuntimeError_("Cannot read private backend metadata; preserve it and inspect manually") from error
    if metadata.get("name") != PACKAGE or metadata.get("version") != VERSION:
        raise RuntimeError_(f"Private backend must be {PACKAGE}@{VERSION}; refusing replacement")
    return entry


def checked(args, runtime: Path, environment) -> Path:
    entry = backend(runtime)
    result = subprocess.run([args.node, str(entry), "--version"], env=environment,
                            capture_output=True, text=True, timeout=15, check=True)
    if result.stdout.strip() != VERSION:
        raise RuntimeError_("Private backend version check failed; no runtime chooser will be opened")
    return entry


def setup(args, root, runtime, lock, environment):
    with locked(lock, exclusive=True):
        if runtime.exists():
            checked(args, runtime, environment)
            print(f"Private DSH {VERSION} is already ready; nothing changed.")
            return
        staging = Path(tempfile.mkdtemp(prefix="runtime.new-", dir=root))
        try:
            # A local install, never npm -g and never the user's npm cache/prefix.
            subprocess.run([args.npm, "install", "--prefix", str(staging), "--save-exact",
                            "--package-lock=true", "--no-audit", "--no-fund", f"{PACKAGE}@{VERSION}"],
                           cwd=staging, env=environment, check=True)
            checked(args, staging, environment)
            # No other sanctioned writer can publish while the exclusive lock is held.
            # Refuse uncoordinated targets too; never merge into an existing runtime.
            if runtime.exists() or runtime.is_symlink():
                raise RuntimeError_("Private runtime appeared during setup; refusing replacement")
            staging.rename(runtime)
        finally:
            # Only remove the exact temporary directory made by this invocation.
            if staging.exists():
                shutil.rmtree(staging)
        print(f"Private DSH {VERSION} is ready. Launch dsh-desktop separately.")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--node", required=True)
    parser.add_argument("--npm", required=True)
    parser.add_argument("--pnpm-bin", required=True)
    parser.add_argument("--backend-launcher", required=True)
    parser.add_argument("operation", choices=("context", "check", "setup", "backend"))
    parser.add_argument("arguments", nargs=argparse.REMAINDER)
    args = parser.parse_args()
    if args.operation != "backend" and args.arguments:
        parser.error(f"{args.operation} accepts no additional arguments")
    os.umask(0o077)
    root, runtime, lock, updates = prepare(args)
    # npm treats environment keys case-insensitively on some paths. Remove all
    # inherited npm settings so a global prefix/cache/config cannot win by case.
    environment = {key: value for key, value in os.environ.items()
                   if not key.lower().startswith("npm_config_")}
    environment.update(updates)
    if args.operation == "context":
        # Only the trusted executable consumes this pipe; never log the JSON.
        print(json.dumps({"environment": updates, "lock": str(lock)}))
    elif args.operation == "setup":
        setup(args, root, runtime, lock, environment)
    else:
        with locked(lock, exclusive=False) as descriptor:
            entry = checked(args, runtime, environment)
            if args.operation == "check":
                print(f"Private DSH {VERSION} is ready.")
            else:
                # Keep the shared lock through Node execution, also for CLI use.
                os.set_inheritable(descriptor, True)
                os.execve(args.node, [args.node, str(entry), *args.arguments], environment)


if __name__ == "__main__":
    try:
        main()
    except (RuntimeError_, OSError, subprocess.SubprocessError) as error:
        print(f"dsh-desktop: {error}", file=sys.stderr)
        sys.exit(1)
