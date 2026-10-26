"""Headless DSH Desktop policy checks; never use the user's HOME or real npm.

Set DSH_DESKTOP_EXE to the packaged raw ELF to additionally exercise the same
pre-Tauri initialization used by direct launches and process restarts.
"""
import fcntl
import json
import os
from pathlib import Path
import select
import shlex
import subprocess
import sys
import tempfile
import textwrap
import unittest

REPOSITORY = Path(__file__).resolve().parents[1]
HELPER = Path(os.environ.get("RUNTIME_HELPER", REPOSITORY / "scripts/dsh-desktop-runtime.py"))
MANAGED_PATCH = Path(os.environ.get("MANAGED_PATCH", REPOSITORY / "config/dsh-desktop/managed-runtime.patch"))
KAENIX_INIT_SOURCE = Path(os.environ.get("KAENIX_INIT_SOURCE", REPOSITORY / "config/dsh-desktop/kaenix.rs"))
VERSION = "0.2.1-rc.2"
PACKAGE = "@deepseek-ai/dsh"
PRIVATE = Path(".local/share/dsh-desktop-isolated")

MOCK_NODE = r'''
import json, os, signal, sys
from pathlib import Path
with open(os.environ["MOCK_NODE_LOG"], "a") as stream:
    stream.write(json.dumps({"arguments": sys.argv[1:], "environment": dict(os.environ)}) + "\n")
if sys.argv[2:] == ["--version"]:
    print(os.environ.get("MOCK_NODE_VERSION", "0.2.1-rc.2"))
elif sys.argv[2:] == ["--hold"]:
    print("BACKEND_READY", flush=True)
    signal.pause()
else:
    print(json.dumps({"arguments": sys.argv[2:], "environment": dict(os.environ)}))
'''

MOCK_NPM = r'''
import json, os, sys
from pathlib import Path
with open(os.environ["MOCK_NPM_LOG"], "a") as stream:
    stream.write(json.dumps({"arguments": sys.argv[1:], "environment": dict(os.environ),
                             "cwd": os.getcwd()}) + "\n")
mode = os.environ.get("MOCK_NPM_MODE", "ok")
if mode == "hold":
    print("NPM_READY", flush=True)
    sys.stdin.read(1)
prefix = Path(sys.argv[sys.argv.index("--prefix") + 1])
(prefix / "npm-started").write_text("owned staging only")
if mode == "fail":
    print("mock npm failure", file=sys.stderr)
    sys.exit(19)
package = prefix / "node_modules/@deepseek-ai/dsh"
(package / "lib").mkdir(parents=True)
(package / "package.json").write_text(json.dumps({"name": "@deepseek-ai/dsh", "version": "0.2.1-rc.2"}))
(package / "lib/bin.js").write_text("console.log('0.2.1-rc.2');\n")
'''


class RuntimeFixture(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="kaenix desktop tests ")
        self.addCleanup(self.temporary.cleanup)
        self.work = Path(self.temporary.name)
        self.home = self.work / "isolated home with spaces"
        self.home.mkdir()
        self.root = self.home / PRIVATE
        self.runtime = self.root / "runtime"
        self.tools = self.work / "mock tools"
        self.tools.mkdir()
        self.node = self.executable("node", MOCK_NODE)
        self.npm = self.executable("npm", MOCK_NPM)
        self.node_log = self.work / "node calls.jsonl"
        self.npm_log = self.work / "npm calls.jsonl"
        self.env = dict(os.environ)
        # A check must not even try to connect to the active graphical session.
        for key in ("DISPLAY", "WAYLAND_DISPLAY", "DBUS_SESSION_BUS_ADDRESS"):
            self.env.pop(key, None)
        self.env.update({
            "HOME": str(self.home),
            "DSH_HOME": str(self.home / ".dsh"),
            "DSH_AGENTS_HOME": str(self.home / "old agents"),
            "DSH_BIN": "/hostile/backend",
            "XDG_CONFIG_HOME": str(self.home / "old config"),
            "XDG_DATA_HOME": str(self.home / "old data"),
            "XDG_CACHE_HOME": str(self.home / "old cache"),
            "XDG_STATE_HOME": str(self.home / "old state"),
            "npm_config_prefix": str(self.home / ".npm-global"),
            "NPM_CONFIG_CACHE": str(self.home / ".npm"),
            "NpM_CoNfIg_UsErCoNfIg": str(self.home / ".npmrc"),
            "NPM_CONFIG_GLOBAL": "true",
            "npm_config_registry": "https://hostile.invalid",
            "MOCK_NODE_LOG": str(self.node_log),
            "MOCK_NPM_LOG": str(self.npm_log),
        })
        # Both existing standalone DSH state and npm roots are out of scope.
        for relative in (".dsh/sentinel", ".npm/sentinel", ".npm-global/sentinel", ".npmrc"):
            path = self.home / relative
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text("existing user data: " + relative)
        self.original = self.outside_private()

    def executable(self, name, source):
        path = self.tools / name
        path.write_text("#!" + sys.executable + "\n" + textwrap.dedent(source))
        path.chmod(0o700)
        return path

    def command(self, operation, *arguments):
        return [sys.executable, str(HELPER), "--node", str(self.node), "--npm", str(self.npm),
                "--pnpm-bin", str(self.tools), "--backend-launcher", str(self.tools / "backend launcher"),
                operation, *arguments]

    def run_helper(self, operation, *arguments, success=True, extra_env=None):
        env = dict(self.env)
        env.update(extra_env or {})
        result = subprocess.run(self.command(operation, *arguments), env=env,
                                capture_output=True, text=True, timeout=15)
        if success:
            self.assertEqual(result.returncode, 0, result.stderr)
        else:
            self.assertNotEqual(result.returncode, 0, result.stdout)
        return result

    def calls(self, path):
        return [json.loads(line) for line in path.read_text().splitlines()] if path.exists() else []

    def outside_private(self):
        result = {}
        ancestors = {Path(".local"), Path(".local/share")}
        for path in self.home.rglob("*"):
            relative = path.relative_to(self.home)
            if relative == PRIVATE or PRIVATE in relative.parents or relative in ancestors:
                continue
            result[str(relative)] = ("directory" if path.is_dir() else path.read_bytes())
        return result

    def assert_outside_untouched(self):
        self.assertEqual(self.original, self.outside_private())

    def context(self):
        return json.loads(self.run_helper("context").stdout)

    def populate(self, runtime=None, version=VERSION):
        self.context()
        runtime = runtime or self.runtime
        package = runtime / "node_modules/@deepseek-ai/dsh"
        (package / "lib").mkdir(parents=True, exist_ok=True)
        (package / "package.json").write_text(json.dumps({"name": PACKAGE, "version": version}))
        (package / "lib/bin.js").write_text("console.log(" + json.dumps(version) + ");\n")
        return package

    def snapshot(self, directory):
        return {str(path.relative_to(directory)): path.read_bytes()
                for path in directory.rglob("*") if path.is_file()}

    def start_helper(self, operation, *arguments, extra_env=None):
        env = dict(self.env)
        env.update(extra_env or {})
        process = subprocess.Popen(self.command(operation, *arguments), env=env,
                                   stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                                   stderr=subprocess.PIPE, text=True)

        def stop():
            if process.poll() is None:
                # Release a mock npm waiting on input before terminating its owner.
                if operation == "setup":
                    try:
                        process.stdin.write("x")
                        process.stdin.flush()
                        process.communicate(timeout=5)
                        return
                    except (BrokenPipeError, subprocess.TimeoutExpired):
                        pass
                process.terminate()
                try:
                    process.communicate(timeout=5)
                except subprocess.TimeoutExpired:
                    process.kill()
                    process.communicate(timeout=5)
            else:
                process.communicate(timeout=5)
        self.addCleanup(stop)
        return process

    def ready(self, process, expected):
        readable, _, _ = select.select([process.stdout], [], [], 10)
        self.assertTrue(readable, "mock child did not signal readiness")
        self.assertEqual(process.stdout.readline().strip(), expected)


class RuntimeTests(RuntimeFixture):
    def test_context_overrides_hostile_state_and_npm_configuration(self):
        context = self.context()
        environment = context["environment"]
        for key, child in (("DSH_HOME", "dsh"), ("DSH_AGENTS_HOME", "agents"),
                           ("XDG_CONFIG_HOME", "config"), ("XDG_DATA_HOME", "data"),
                           ("XDG_CACHE_HOME", "cache"), ("XDG_STATE_HOME", "state"),
                           ("npm_config_prefix", "npm"), ("PNPM_HOME", "pnpm")):
            self.assertEqual(environment[key], str(self.root / child))
        self.assertEqual(environment["DSH_BIN"], str(self.tools / "backend launcher"))
        self.assertEqual(environment["npm_config_userconfig"], "/dev/null")
        self.assertEqual(environment["npm_config_globalconfig"], str(self.root / "config/npm-globalrc"))
        self.assertEqual(environment["npm_config_registry"], "https://registry.npmjs.org")
        self.assertEqual(environment["npm_config_cache"], str(self.root / "cache/npm"))
        self.assertEqual(environment["PNPM_CONFIG_STORE_DIR"], str(self.root / "cache/pnpm"))
        self.assertEqual(context["lock"], str(self.root / "runtime.lock"))
        self.assertEqual(self.root.stat().st_mode & 0o777, 0o700)
        self.assertFalse(self.runtime.exists())
        self.assertEqual(self.calls(self.node_log), [])
        self.assertEqual(self.calls(self.npm_log), [])
        self.assert_outside_untouched()

    def test_management_operations_reject_extra_arguments_before_side_effects(self):
        for operation in ("context", "check", "setup"):
            with self.subTest(operation=operation):
                result = self.run_helper(operation, "--prefix", "/hostile/prefix", success=False)
                self.assertIn("accepts no additional arguments", result.stderr)
        self.assertFalse(self.root.exists())
        self.assertEqual(self.calls(self.npm_log), [])
        self.assertEqual(self.calls(self.node_log), [])
        self.assert_outside_untouched()

    def test_missing_runtime_fails_before_any_backend_or_npm_execution(self):
        for operation in ("check", "backend"):
            with self.subTest(operation=operation):
                result = self.run_helper(operation, success=False)
                self.assertIn("Private backend is absent", result.stderr)
        self.assertEqual(self.calls(self.node_log), [])
        self.assertEqual(self.calls(self.npm_log), [])
        self.assert_outside_untouched()

    def test_setup_uses_exact_local_install_and_sanitized_environment(self):
        self.run_helper("setup")
        call, = self.calls(self.npm_log)
        arguments = call["arguments"]
        self.assertEqual(arguments[0], "install")
        self.assertNotIn("-g", arguments)
        self.assertNotIn("--global", arguments)
        self.assertEqual(arguments[-1], PACKAGE + "@" + VERSION)
        self.assertIn("--save-exact", arguments)
        self.assertIn("--package-lock=true", arguments)
        prefix = Path(arguments[arguments.index("--prefix") + 1])
        self.assertEqual(prefix.parent, self.root)
        self.assertTrue(prefix.name.startswith("runtime.new-"))
        self.assertEqual(call["cwd"], str(prefix))
        environment = call["environment"]
        self.assertEqual(environment["DSH_HOME"], str(self.root / "dsh"))
        self.assertEqual(environment["DSH_BIN"], str(self.tools / "backend launcher"))
        for key in ("NPM_CONFIG_GLOBAL", "NPM_CONFIG_CACHE", "NpM_CoNfIg_UsErCoNfIg"):
            self.assertNotIn(key, environment)
        self.assertEqual(environment["npm_config_prefix"], str(self.root / "npm"))
        self.assertEqual(environment["npm_config_userconfig"], "/dev/null")
        self.assertEqual(environment["npm_config_globalconfig"], str(self.root / "config/npm-globalrc"))
        self.assertEqual(environment["npm_config_registry"], "https://registry.npmjs.org")
        self.assertEqual(json.loads((self.runtime / "node_modules/@deepseek-ai/dsh/package.json").read_text()),
                         {"name": PACKAGE, "version": VERSION})
        self.assertFalse(list(self.root.glob("runtime.new-*")))
        self.assert_outside_untouched()

    def test_setup_is_idempotent_and_preserves_existing_state(self):
        self.run_helper("setup")
        sentinel = self.runtime / "preserve me"
        sentinel.write_text("never replace an existing backend")
        before = self.snapshot(self.runtime)
        result = self.run_helper("setup")
        self.assertIn("nothing changed", result.stdout)
        self.assertEqual(len(self.calls(self.npm_log)), 1)
        self.assertEqual(before, self.snapshot(self.runtime))
        self.assert_outside_untouched()

    def test_wrong_existing_runtime_is_rejected_without_replacement(self):
        self.populate(version="9.9.9")
        before = self.snapshot(self.runtime)
        result = self.run_helper("setup", success=False)
        self.assertIn("refusing replacement", result.stderr)
        self.assertEqual(before, self.snapshot(self.runtime))
        self.assertEqual(self.calls(self.npm_log), [])
        self.assertEqual(self.calls(self.node_log), [])
        self.assert_outside_untouched()

    def test_failed_setup_removes_only_its_own_staging(self):
        self.context()
        unrelated = self.root / "runtime.new-preserve"
        unrelated.mkdir()
        (unrelated / "sentinel").write_text("not this invocation's staging")
        result = self.run_helper("setup", success=False, extra_env={"MOCK_NPM_MODE": "fail"})
        self.assertIn("mock npm failure", result.stderr)
        self.assertFalse(self.runtime.exists())
        self.assertEqual(list(self.root.glob("runtime.new-*")), [unrelated])
        self.assertEqual((unrelated / "sentinel").read_text(), "not this invocation's staging")
        self.assert_outside_untouched()

    def test_failed_version_validation_does_not_publish_staging(self):
        self.run_helper("setup", success=False, extra_env={"MOCK_NODE_VERSION": "wrong"})
        self.assertFalse(self.runtime.exists())
        self.assertFalse(list(self.root.glob("runtime.new-*")))
        self.assert_outside_untouched()

    def test_backend_forwards_arguments_exactly_including_spaces(self):
        self.populate()
        arguments = ["plugin", "--profile", "web", "add", "local folder with spaces", "", "--", "a'b;$x"]
        result = self.run_helper("backend", *arguments)
        payload = json.loads(result.stdout)
        self.assertEqual(payload["arguments"], arguments)
        self.assertEqual(payload["environment"]["DSH_HOME"], str(self.root / "dsh"))
        self.assertNotIn("NPM_CONFIG_GLOBAL", payload["environment"])
        calls = self.calls(self.node_log)
        self.assertEqual(calls[0]["arguments"][1:], ["--version"])
        self.assertEqual(calls[1]["arguments"][1:], arguments)
        self.assertEqual(self.calls(self.npm_log), [])
        self.assert_outside_untouched()

    def test_setup_exclusive_lock_refuses_check_backend_and_second_setup(self):
        self.populate()
        lock = self.root / "runtime.lock"
        with lock.open("w") as descriptor:
            fcntl.flock(descriptor, fcntl.LOCK_EX | fcntl.LOCK_NB)
            for operation in ("check", "backend", "setup"):
                with self.subTest(operation=operation):
                    self.assertIn("running", self.run_helper(operation, success=False).stderr)
        self.assertEqual(self.calls(self.node_log), [])
        self.assertEqual(self.calls(self.npm_log), [])

    def test_real_backend_process_retains_shared_lock_until_exit(self):
        self.populate()
        child = self.start_helper("backend", "--hold")
        self.ready(child, "BACKEND_READY")
        self.assertIn("running", self.run_helper("setup", success=False).stderr)
        self.run_helper("check")  # Another reader is safe while the backend lives.
        self.assertIsNone(child.poll())
        child.terminate()
        child.communicate(timeout=5)
        self.run_helper("setup")
        self.assertEqual(self.calls(self.npm_log), [])

    def test_real_setup_process_holds_exclusive_lock_during_npm(self):
        child = self.start_helper("setup", extra_env={"MOCK_NPM_MODE": "hold"})
        self.ready(child, "NPM_READY")
        for operation in ("check", "backend", "setup"):
            with self.subTest(operation=operation):
                self.assertIn("running", self.run_helper(operation, success=False).stderr)
        child.stdin.write("x")
        child.stdin.flush()
        _, error = child.communicate(timeout=10)
        self.assertEqual(child.returncode, 0, error)
        self.run_helper("check")

    def test_symlink_root_and_ancestor_are_rejected(self):
        for relative in (Path(".local"), PRIVATE):
            with self.subTest(relative=relative), tempfile.TemporaryDirectory(dir=self.work) as scratch:
                home = Path(scratch) / "home"
                home.mkdir()
                target = Path(scratch) / "target"
                target.mkdir()
                link = home / relative
                link.parent.mkdir(parents=True, exist_ok=True)
                link.symlink_to(target, target_is_directory=True)
                self.run_helper("context", success=False, extra_env={"HOME": str(home)})
                self.assertEqual(list(target.iterdir()), [])

    def test_symlink_private_descendant_and_runtime_are_rejected(self):
        for child in ("dsh", "agents", "config", "npm", "runtime"):
            with self.subTest(child=child), tempfile.TemporaryDirectory(dir=self.work) as scratch:
                home = Path(scratch) / "home"
                home.mkdir()
                root = home / PRIVATE
                root.mkdir(parents=True, mode=0o700)
                target = Path(scratch) / "target"
                target.mkdir()
                (root / child).symlink_to(target, target_is_directory=True)
                self.run_helper("context", success=False, extra_env={"HOME": str(home)})
                self.assertEqual(list(target.iterdir()), [])

    def test_symlink_and_hardlinked_lock_are_rejected(self):
        self.populate()
        target = self.work / "lock target"
        target.write_text("do not change")
        lock = self.root / "runtime.lock"
        for kind in ("symlink", "hardlink"):
            with self.subTest(kind=kind):
                if kind == "symlink":
                    lock.symlink_to(target)
                else:
                    os.link(target, lock)
                self.run_helper("check", success=False)
                self.assertEqual(target.read_text(), "do not change")
                lock.unlink()
        self.assertEqual(self.calls(self.node_log), [])

    def test_redirected_backend_manifest_or_entry_is_rejected(self):
        package = self.populate()
        for relative in ("package.json", "lib/bin.js"):
            with self.subTest(relative=relative):
                path = package / relative
                content = path.read_bytes()
                target = self.work / ("external " + path.name)
                target.write_bytes(content)
                path.unlink()
                path.symlink_to(target)
                self.run_helper("check", success=False)
                path.unlink()
                path.write_bytes(content)
        self.assertEqual(self.calls(self.node_log), [])

    def test_nonprivate_root_permissions_are_rejected(self):
        self.context()
        self.root.chmod(0o755)
        self.assertIn("0700", self.run_helper("context", success=False).stderr)


@unittest.skipUnless(os.environ.get("DSH_DESKTOP_EXE"), "packaged raw ELF not supplied")
class CompiledDesktopTests(RuntimeFixture):
    def run_desktop(self, success):
        executable = Path(os.environ["DSH_DESKTOP_EXE"])
        with executable.open("rb") as stream:
            self.assertEqual(stream.read(4), b"\x7fELF", "DSH_DESKTOP_EXE must name the raw ELF")
        result = subprocess.run([str(executable), "--kaenix-check-runtime"], env=self.env,
                                capture_output=True, text=True, timeout=30)
        self.assertEqual(result.returncode == 0, success, result.stderr)
        self.assert_outside_untouched()
        return result

    def test_missing_private_runtime_fails_before_tauri(self):
        result = self.run_desktop(False)
        self.assertIn("absent", result.stderr)
        self.assertFalse(self.runtime.exists())
        self.assertEqual(self.calls(self.npm_log), [])

    def test_direct_raw_elf_initialization_and_inherited_overrides(self):
        self.populate()
        result = self.run_desktop(True)
        self.assertIn("isolated runtime is ready", result.stdout)
        self.assertEqual(self.calls(self.npm_log), [])
        self.assertEqual(self.calls(self.node_log), [])  # The ELF uses packaged Node, not this mock.

    def test_raw_elf_rejects_wrong_existing_backend_without_replacement(self):
        self.populate(version="9.9.9")
        before = self.snapshot(self.runtime)
        self.assertIn("refusing replacement", self.run_desktop(False).stderr)
        self.assertEqual(before, self.snapshot(self.runtime))

    def test_raw_elf_rejects_setup_lock(self):
        self.populate()
        with (self.root / "runtime.lock").open("w") as descriptor:
            fcntl.flock(descriptor, fcntl.LOCK_EX | fcntl.LOCK_NB)
            self.assertIn("setup is running", self.run_desktop(False).stderr)


@unittest.skipUnless(os.environ.get("DSH_DESKTOP_PACKAGE"), "packaged resources not supplied")
class PackagedResourcesTests(unittest.TestCase):
    def test_bundled_plugin_resources_present_without_runtime_installers(self):
        resources = Path(os.environ["DSH_DESKTOP_PACKAGE"]) / "share/dsh-desktop/resources"
        presets = json.loads((resources / "preset-plugins.json").read_text())
        self.assertTrue(any(item.get("spec") == "bundled:plugin" for item in presets))
        manifest = json.loads((resources / "plugin/package.json").read_text())
        self.assertEqual(manifest["name"], "dsh-desktop-signal")
        self.assertTrue((resources / "plugin/lib").is_dir())
        self.assertTrue((resources / "plugin/LICENSE").is_file())
        self.assertFalse((resources / "install-deps.sh").exists())
        self.assertFalse((resources / "install-deps.ps1").exists())

    def test_desktop_entry_targets_packaged_desktop_not_backend_or_setup(self):
        package = Path(os.environ["DSH_DESKTOP_PACKAGE"])
        entries = list((package / "share/applications").glob("*.desktop"))
        self.assertTrue(entries, "desktop integration must be installed")
        for entry in entries:
            commands = [line.removeprefix("Exec=") for line in entry.read_text().splitlines()
                        if line.startswith("Exec=")]
            self.assertTrue(commands, str(entry))
            for command in commands:
                executable = shlex.split(command)[0]
                self.assertIn(executable, (str(package / "bin/dsh-desktop"), "dsh-desktop"))


class PolicySourceTests(unittest.TestCase):
    def test_policy_patch_records_exact_base_and_early_initialization(self):
        patch = MANAGED_PATCH.read_text()
        self.assertIn("e9dc7283846f31ec9f3215525c4e9deeacaf0f9b", patch)
        self.assertIn("+    kaenix::init();", patch)
        self.assertIn("+mod kaenix;", patch)
        self.assertIn('@kaenixResources@', patch)
        self.assertIn("+    Err(MANAGED_NOTE.to_string())", patch)
        self.assertIn("+pub fn check_quietly(_app: &AppHandle) {}", patch)
        self.assertIn("+    let mut command = Command::new(crate::kaenix::backend());", patch)
        self.assertNotIn("+++ b/src-tauri/src/plugins.rs", patch)
        self.assertNotIn("+++ b/src-tauri/src/panel.rs", patch)
        self.assertNotIn("+++ b/src-tauri/src/remote/", patch)

    def test_pre_tauri_initializer_exposes_only_headless_validation_path(self):
        source = KAENIX_INIT_SOURCE.read_text()
        self.assertIn("--kaenix-check-runtime", source)
        self.assertIn("O_NOFOLLOW", source)
        self.assertRegex(source, r"RUNTIME_LOCK\s*\.set\(file\)")
        self.assertIn('helper("check")', source)
        self.assertNotIn('helper("setup")', source)


if __name__ == "__main__":
    unittest.main(verbosity=2)
