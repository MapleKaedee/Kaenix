"""Exercise desktop startup in disposable PTYs; never start a real TUIOS daemon."""
import errno
import json
import os
from pathlib import Path
import pty
import select
import signal
import subprocess
import sys
import tempfile
import time


def events(path):
    return [json.loads(line) for line in path.read_text().splitlines()] if path.exists() else []


if len(sys.argv) > 1 and sys.argv[1] in ("--probe", "--shell-probe"):
    with open(os.environ["KAENIX_TEST_LOG"], "a") as log:
        log.write(json.dumps({
            "mode": sys.argv[1],
            "args": sys.argv[2:],
            "cwd": os.getcwd(),
            "shell": os.environ.get("SHELL"),
            "login": os.environ.get("KAENIX_TEST_LOGIN"),
            "tty": os.isatty(0) and os.isatty(1),
        }) + "\n")
    sys.exit(int(os.environ.get("KAENIX_TEST_STATUS", "0")) if sys.argv[1] == "--probe" else 0)


launchers = json.loads(os.environ["sessionLaunchers"])
with tempfile.TemporaryDirectory(prefix="kaenix-tuios-") as temporary:
    root = Path(temporary)
    home = root / "home"
    work = root / "work with spaces ' $(touch UNEXPECTED)"
    home.mkdir()
    work.mkdir()
    (home / ".config/fish").mkdir(parents=True)
    (home / ".config/nushell").mkdir(parents=True)
    # Deliberate directory changes check that the launcher restores the cwd
    # after the selected shell has finished its login initialization.
    (home / ".config/fish/config.fish").write_text(
        'if status is-login\n  set -gx KAENIX_TEST_LOGIN ready\n  cd "$HOME"\nend\n'
        'function fish_greeting\nend\n'
    )
    (home / ".config/nushell/config.nu").write_text("$env.config.show_banner = false\n")
    (home / ".config/nushell/login.nu").write_text(
        '$env.KAENIX_TEST_LOGIN = "ready"\ncd $env.HOME\n'
    )
    log = root / "events.jsonl"
    base_env = {
        "HOME": str(home),
        "XDG_CONFIG_HOME": str(home / ".config"),
        "XDG_CACHE_HOME": str(home / ".cache"),
        "XDG_DATA_HOME": str(home / ".local/share"),
        "XDG_STATE_HOME": str(home / ".local/state"),
        "PATH": os.environ["PATH"],
        "TERM": "xterm-256color",
        "KAENIX_TEST_LOG": str(log),
        "PWD": str(work),
    }

    def run(launcher, overrides=None, args=(), terminal=True):
        log.unlink(missing_ok=True)
        env = base_env | (overrides or {})
        if not terminal:
            result = subprocess.run(
                [launcher, *args], cwd=work, env=env, capture_output=True, timeout=15,
            )
            assert result.returncode == 0, result.stderr
            return events(log), result.stdout + result.stderr
        pid, master = pty.fork()
        if pid == 0:
            os.chdir(work)
            os.execve(launcher, [launcher, *args], env)
        output = bytearray()
        sent_exit = False
        exited = False
        deadline = time.monotonic() + 20
        try:
            while time.monotonic() < deadline:
                # A real shell is left after TUIOS exits. Close that shell via
                # its PTY once the stub session has recorded its invocation.
                if not sent_exit and any(e["mode"] == "--probe" for e in events(log)):
                    os.write(master, b"exit\n")
                    sent_exit = True
                ready, _, _ = select.select([master], [], [], 0.05)
                if ready:
                    try:
                        data = os.read(master, 65536)
                    except OSError as error:
                        if error.errno != errno.EIO:
                            raise
                        data = b""
                    output.extend(data)
                done, status = os.waitpid(pid, os.WNOHANG)
                if done:
                    exited = True
                    assert os.waitstatus_to_exitcode(status) == 0, output.decode(errors="replace")
                    return events(log), bytes(output)
            raise AssertionError("Launcher timed out: " + output.decode(errors="replace"))
        finally:
            if not exited:
                os.kill(pid, signal.SIGKILL)
                os.waitpid(pid, 0)
            os.close(master)

    fake = launchers["probe"]["launcher"]
    for variable in (
        "KAENIX_TUIOS_DISABLE", "TUIOS_SESSION", "TUIOS_WINDOW_ID", "TUIOS_PANE_ID",
        "TMUX", "ZELLIJ", "SSH_CONNECTION", "SSH_CLIENT", "SSH_TTY",
    ):
        records, _ = run(fake, {variable: "1"})
        assert [e["args"] for e in records] == [["--login"]], (variable, records)
        assert records[0]["mode"] == "--shell-probe"
    for terminal, overrides in ((False, {}), (True, {"TERM": "dumb"}), (True, {"TERM": ""})):
        records, _ = run(fake, overrides, terminal=terminal)
        assert len(records) == 1 and records[0]["mode"] == "--shell-probe", records
    arguments = ["-c", "printf '%s' 'spaces and $(literal)'", "", "one two"]
    records, _ = run(fake, args=arguments)
    assert records[0]["args"] == ["--login", *arguments], records

    for name in ("fish", "nushell"):
        for status in (0, 23):
            records, output = run(
                launchers[name]["launcher"], {"KAENIX_TEST_STATUS": str(status)},
            )
            assert len(records) == 1, (name, records)
            assert records[0] == {
                "mode": "--probe", "args": ["new"], "cwd": str(work),
                "shell": launchers[name]["shell"], "login": "ready", "tty": True,
            }, (name, records)
            assert (b"opening a login shell" in output) == (status != 0), output
    assert not (home / "UNEXPECTED").exists()
    assert not (work / "UNEXPECTED").exists()

print("TUIOS login startup, cwd, guards, arguments, and fallback passed for Fish/Nushell")
