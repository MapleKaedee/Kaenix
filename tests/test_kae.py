"""Acceptance tests using injected executables; never run real system maintenance."""

import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


def stub(mode, args):
    with open(os.environ["KAE_TEST_LOG"], "a") as log:
        log.write(json.dumps({"mode": mode, "argv": args, "cwd": os.getcwd()}) + "\n")
    fail_key = mode + (":" + args[0] if args and mode == "nix" else "")
    if os.environ.get("KAE_TEST_FAIL") == fail_key:
        print("injected failure", file=sys.stderr)
        return int(os.environ.get("KAE_TEST_EXIT", "37"))
    if mode == "nix" and args[:1] == ["eval"]:
        print(os.environ.get("KAE_TEST_CHECKS", '["alpha", "beta", "kae"]'))
    elif mode == "sudo":
        return subprocess.call(args)
    elif mode == "nix" and args[:1] == ["fmt"] and os.environ.get("KAE_TEST_REAL_FMT"):
        return subprocess.call([os.environ["KAE_TEST_FORMATTER"], "--tree-root", ".", *args[args.index("--") + 1 :]])
    elif mode == "formatterCheck" and os.environ.get("KAE_TEST_REAL_FMT"):
        return subprocess.call([os.environ["KAE_TEST_CHECK_FORMATTER"], *args])
    else:
        print("stub stdout")
        print("stub stderr", file=sys.stderr)
    return 0


class KaeTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="kae acceptance ")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.repo = self.root / "repo with spaces"
        self.repo.mkdir()
        (self.repo / "flake.nix").write_text("{ outputs = _: {}; }\n")
        self.outside = self.root / "outside"
        self.outside.mkdir()
        self.log = self.root / "calls.jsonl"
        self.env = dict(os.environ, KAE_REPO=str(self.repo), KAE_TEST_LOG=str(self.log))
        for key in ("KAE_TEST_FAIL", "KAE_TEST_EXIT", "KAE_TEST_REAL_FMT", "KAE_TEST_CHECKS"):
            self.env.pop(key, None)
        config = self.root / "config" / "nushell"
        config.mkdir(parents=True)
        for name in ("config.nu", "env.nu"):
            (config / name).write_text('error make {msg: "user configuration loaded"}\n')
        self.env["XDG_CONFIG_HOME"] = str(config.parent)

    def run_kae(self, *args, code=0):
        self.log.unlink(missing_ok=True)
        result = subprocess.run(
            [os.environ["KAE_TEST_BIN"], *args], cwd=self.outside,
            env=self.env, text=True, capture_output=True,
        )
        if code is None:
            self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        else:
            self.assertEqual(result.returncode, code, result.stdout + result.stderr)
        self.calls = [json.loads(line) for line in self.log.read_text().splitlines()] if self.log.exists() else []
        return result

    def assert_calls(self, expected, repo=True):
        self.assertEqual([(call["mode"], call["argv"]) for call in self.calls], expected)
        if repo:
            self.assertTrue(all(call["cwd"] == str(self.repo) for call in self.calls), self.calls)

    @property
    def ref(self):
        return "path:" + str(self.repo)

    def discovery(self):
        return ("nix", ["eval", "--json", "--no-update-lock-file", self.ref + "#checks.x86_64-linux", "--apply", "builtins.attrNames"])

    def test_help_does_not_need_repository_or_load_user_config(self):
        self.env["KAE_REPO"] = str(self.root / "missing")
        commands = ("check", "test", "build", "switch", "gc", "optimize", "fmt")
        for args in [(), ("help",), ("--help",), *[("help", c) for c in commands], *[(c, "--help") for c in commands]]:
            with self.subTest(args=args):
                result = self.run_kae(*args)
                self.assertTrue(result.stdout.strip() or result.stderr.strip())
                self.assert_calls([])

    def test_check(self):
        result = self.run_kae("check")
        self.assert_calls([("nix", ["flake", "check", "--no-build", "--no-update-lock-file", self.ref])])
        self.assertIn("stub stdout", result.stdout)
        self.assertIn("stub stderr", result.stderr)
        self.assertGreater(len(result.stderr.splitlines()), 1, "operation announcement missing")

    def test_discovered_checks_are_built(self):
        self.run_kae("test")
        self.assert_calls([self.discovery(), ("nix", ["build", "--no-link", "--no-update-lock-file", *[self.ref + "#checks.x86_64-linux." + n for n in ("alpha", "beta", "kae")]])])

    def test_selected_checks(self):
        self.run_kae("test", "beta", "alpha")
        self.assert_calls([self.discovery(), ("nix", ["build", "--no-link", "--no-update-lock-file", self.ref + "#checks.x86_64-linux.beta", self.ref + "#checks.x86_64-linux.alpha"])])

    def test_unknown_check_rejected_before_build(self):
        self.run_kae("test", "alpha", "missing", code=None)
        self.assert_calls([self.discovery()])

    def test_check_discovery_is_dynamic(self):
        self.env["KAE_TEST_CHECKS"] = '["new-check"]'
        self.run_kae("test", "new-check")
        self.assert_calls([self.discovery(), ("nix", ["build", "--no-link", "--no-update-lock-file", self.ref + "#checks.x86_64-linux.new-check"])])

    def test_empty_discovery_rejected_before_build(self):
        self.env["KAE_TEST_CHECKS"] = "[]"
        self.run_kae("test", code=None)
        self.assert_calls([self.discovery()])

    def test_duplicate_check_names_are_built_once(self):
        self.run_kae("test", "alpha", "alpha")
        self.assert_calls([
            self.discovery(),
            ("nix", ["build", "--no-link", "--no-update-lock-file",
                     self.ref + "#checks.x86_64-linux.alpha"]),
        ])

    def test_build_and_switch(self):
        for command in ("build", "switch"):
            with self.subTest(command=command):
                self.run_kae(command)
                args = [command, "--flake", self.ref + "#syrup", "--no-update-lock-file"]
                if command == "switch":
                    args += ["--elevate", "sudo"]
                self.assert_calls([("rebuild", args)])

    def test_fmt_arguments(self):
        for args, forwarded in [((), []), (("nested file.nix", "other.nix"), ["nested file.nix", "other.nix"]), (("--check",), ["--ci"]), (("--check", "nested file.nix"), ["--ci", "nested file.nix"])]:
            with self.subTest(args=args):
                self.run_kae("fmt", *args)
                if "--check" in args:
                    self.assert_calls([("formatterCheck", ["--ci", "--tree-root", str(self.repo), *forwarded[1:]])])
                else:
                    self.assert_calls([("nix", ["fmt", "--no-update-lock-file", "--override-flake", ".", self.ref, "--", *forwarded])])

    def test_maintenance_needs_no_repository(self):
        self.env["KAE_REPO"] = str(self.root / "missing")
        for command, args in [("gc", ["store", "gc"]), ("optimize", ["store", "optimise"])]:
            with self.subTest(command=command):
                self.run_kae(command)
                self.assert_calls([("nix", args)], repo=False)

    def test_retention_gc_runs_user_then_root(self):
        self.run_kae("gc", "--older-than", "14d")
        collect = os.environ["KAE_TEST_COLLECT_GARBAGE"]
        self.assert_calls([("collectGarbage", ["--delete-older-than", "14d"]), ("sudo", [collect, "--delete-older-than", "14d"]), ("collectGarbage", ["--delete-older-than", "14d"])], repo=False)

    def test_retention_gc_needs_no_repository(self):
        self.env["KAE_REPO"] = str(self.root / "missing")
        self.run_kae("gc", "--older-than", "1d")
        self.assertEqual([c["mode"] for c in self.calls], ["collectGarbage", "sudo", "collectGarbage"])

    def test_rejects_invalid_arguments_without_commands(self):
        for args in [("unknown",), ("help", "unknown"), ("check", "--bad"), ("build", "--bad"), ("switch", "--bad"), ("gc", "--bad"), ("optimize", "--bad"), ("fmt", "--bad"), ("test", "--bad"), ("check", "extra"), ("build", "extra"), ("switch", "extra"), ("optimize", "extra"), ("gc", "extra"), ("gc", "--older-than")]:
            with self.subTest(args=args):
                self.run_kae(*args, code=None)
                self.assert_calls([])
        for value in ("0d", "-1d", "14", "1w", "1.5d", "d", "", "14d extra"):
            with self.subTest(retention=value):
                self.run_kae("gc", "--older-than", value, code=None)
                self.assert_calls([])

    def test_missing_repository_stops_repository_commands(self):
        self.env["KAE_REPO"] = str(self.root / "missing")
        for command in ("check", "test", "build", "switch", "fmt"):
            with self.subTest(command=command):
                self.run_kae(command, code=None)
                self.assert_calls([])

    def test_default_repository_used_without_override(self):
        self.env.pop("KAE_REPO")
        self.run_kae("check", code=None)
        self.assert_calls([])

    def test_failure_codes_preserved(self):
        for args, failure in [(('check',), 'nix:flake'), (('test',), 'nix:eval'), (('test', 'alpha'), 'nix:build'), (('build',), 'rebuild'), (('switch',), 'rebuild'), (('fmt',), 'nix:fmt'), (('fmt', '--check'), 'formatterCheck'), (('gc',), 'nix:store'), (('optimize',), 'nix:store'), (('gc', '--older-than', '14d'), 'collectGarbage'), (('gc', '--older-than', '14d'), 'sudo')]:
            with self.subTest(args=args, failure=failure):
                self.env['KAE_TEST_FAIL'] = failure
                self.run_kae(*args, code=37)
                if failure in ('nix:eval', 'collectGarbage'):
                    self.assertEqual(len(self.calls), 1)
                if failure == 'sudo':
                    self.assertEqual([c['mode'] for c in self.calls], ['collectGarbage', 'sudo'])

    def test_formatter_changes_only_disposable_fixture(self):
        self.env['KAE_TEST_REAL_FMT'] = '1'
        fixture = self.repo / 'fixture.nix'
        original = '{a=1;}\n'
        fixture.write_text(original)
        self.run_kae('fmt', '--check', 'fixture.nix', code=None)
        self.assertEqual(fixture.read_text(), original)
        self.run_kae('fmt', 'fixture.nix')
        self.assertNotEqual(fixture.read_text(), original)
        self.run_kae('fmt', '--check', 'fixture.nix')


if __name__ == '__main__':
    if sys.argv[1:2] == ['--stub']:
        sys.exit(stub(sys.argv[2], sys.argv[3:]))
    unittest.main(verbosity=2)
