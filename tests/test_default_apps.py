"""Exercise pinned Home Manager link cleanup and writable app-default seeds."""
import configparser
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile


targets = (".config/mimeapps.list", ".config/xdg-terminals.list")
legacy = ".local/share/applications/mimeapps.list"
entries = json.loads(Path(os.environ["manifest"]).read_text())
defaults = [entry for entry in entries if entry["target"] in targets]
assert sorted(entry["target"] for entry in defaults) == sorted(targets)
assert json.loads(os.environ["managedDefaultApps"]) == [False, False, False]


def seed(home, manifest):
    subprocess.run(
        [sys.executable, os.environ["seedScript"], "--home", str(home), "--manifest", str(manifest)],
        check=True,
    )


def link_generation(home, old, new):
    # Run the actual pinned linkGeneration node, never the full activation script.
    env = dict(os.environ, HOME=str(home), oldGenPath=str(old), newGenPath=str(new))
    # Home Manager tests presence, not contents, of its dry-run flag.
    env.pop("DRY_RUN", None)
    env.pop("VERBOSE", None)
    env["VERBOSE_ARG"] = ""
    subprocess.run(
        ["bash", "-e", "-c", '_i() { :; }; source "$linkGenerationScript"'],
        env=env,
        check=True,
    )


with tempfile.TemporaryDirectory(prefix="kaenix-default-apps-") as temporary:
    root = Path(temporary)
    manifest = root / "manifest.json"
    manifest.write_text(json.dumps(defaults))
    old = root / "old-generation"
    old.mkdir()
    old_files = Path(os.environ["oldDefaultAppsFiles"])
    (old / "home-files").symlink_to(old_files)
    new = root / "new-generation"
    (new / "home-files").mkdir(parents=True)

    for state in ("fresh", "managed-symlinks", "gui-regular-files"):
        home = root / state
        home.mkdir()
        saved = {}
        if state != "fresh":
            for relative in (*targets, legacy):
                target = home / relative
                target.parent.mkdir(parents=True, exist_ok=True)
                if state == "gui-regular-files":
                    saved[relative] = f"existing GUI data for {relative}\n"
                    target.write_text(saved[relative])
                else:
                    target.symlink_to(old_files / relative)
        backup = home / ".config/mimeapps.list.pre-kaenix"
        backup.parent.mkdir(parents=True, exist_ok=True)
        backup.write_text("preserved earlier backup\n")

        link_generation(home, old, new)
        seed(home, manifest)
        for entry in defaults:
            relative = entry["target"]
            target = home / relative
            assert target.is_file() and not target.is_symlink(), (state, target)
            assert target.stat().st_mode & 0o200, target
            expected = saved.get(relative)
            if expected is None:
                assert target.read_bytes() == Path(entry["source"]).read_bytes()
            else:
                assert target.read_text() == expected
        if state == "managed-symlinks":
            assert not (home / legacy).exists()
            assert not (home / legacy).is_symlink()
        if state == "gui-regular-files":
            assert (home / legacy).read_text() == saved[legacy]

        mime = home / targets[0]
        terminal = home / targets[1]
        mime.write_text("[Default Applications]\ninode/directory=org.gnome.Nautilus.desktop;\ntext/plain=dev.zed.Zed.desktop;\n")
        terminal.write_text("Alacritty.desktop\n")
        for _ in range(2):
            link_generation(home, old, new)
            seed(home, manifest)
            parsed = configparser.ConfigParser(interpolation=None)
            parsed.read(mime)
            assert parsed["Default Applications"]["inode/directory"] == "org.gnome.Nautilus.desktop;"
            assert parsed["Default Applications"]["text/plain"] == "dev.zed.Zed.desktop;"
            assert terminal.read_text() == "Alacritty.desktop\n"
            assert not mime.is_symlink() and not terminal.is_symlink()
            assert backup.read_text() == "preserved earlier backup\n"

print("Default-app seeds: fresh home, pinned link cleanup, GUI files, repeated edits, and backups preserved")
