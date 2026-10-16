import importlib.util
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location("seed", Path(__file__).parents[1] / "scripts/seed-files.py")
seed = importlib.util.module_from_spec(spec)
spec.loader.exec_module(seed)


class SeedFilesTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.home = self.root / "home"
        self.home.mkdir()
        self.source = self.root / "source.json"
        self.source.write_text('{"theme":"initial"}')
        self.entries = [{"target": ".config/dms/settings.json", "source": str(self.source)}]

    def test_initial_files_are_writable_and_gui_changes_survive_reactivation(self):
        seed.seed_files(self.home, self.entries)
        target = self.home / self.entries[0]["target"]
        self.assertFalse(target.is_symlink())
        self.assertEqual(target.read_bytes(), self.source.read_bytes())
        self.assertEqual(target.stat().st_mode & 0o777, 0o600)
        target.write_text('{"theme":"gui"}')
        self.source.write_text('{"theme":"new-baseline"}')
        seed.seed_files(self.home, self.entries)
        self.assertEqual(target.read_text(), '{"theme":"gui"}')

    def test_existing_symlink_is_not_overwritten(self):
        target = self.home / "existing"
        target.symlink_to(self.root / "missing")
        seed.seed_files(self.home, [{"target": "existing", "source": str(self.source)}])
        self.assertTrue(target.is_symlink())

    def test_parent_symlink_cannot_redirect_writes(self):
        (self.home / ".config").symlink_to(self.root)
        with self.assertRaises(ValueError):
            seed.seed_files(self.home, self.entries)
        self.assertFalse((self.root / "dms").exists())

    def test_target_cannot_escape_home(self):
        for target in ["../outside", "/tmp/outside", "."]:
            with self.subTest(target=target), self.assertRaises(ValueError):
                seed.seed_files(self.home, [{"target": target, "source": str(self.source)}])


if __name__ == "__main__":
    unittest.main()
