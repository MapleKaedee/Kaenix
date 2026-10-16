"""Create writable initial configuration, never replace existing user state."""
import argparse
import json
import os
from pathlib import Path
import shutil
import tempfile


def seed_files(home: Path, entries: list[dict]) -> None:
    for entry in entries:
        relative = Path(entry["target"])
        if relative.is_absolute() or ".." in relative.parts or not relative.parts:
            raise ValueError(f"Target must be relative to home: {relative}")
        target = home / relative
        # Refuse parent symlinks: an old out-of-store directory must not redirect writes.
        parent = home
        for part in relative.parts[:-1]:
            parent = parent / part
            if parent.is_symlink():
                raise ValueError(f"Replace the legacy directory symlink before seeding: {parent}")
        if target.exists() or target.is_symlink():
            print(f"keep: {relative}")
            continue
        target.parent.mkdir(parents=True, exist_ok=True)
        # Publish a complete file atomically, without overwriting even if DMS races us.
        descriptor, temporary = tempfile.mkstemp(prefix=".kaenix-seed-", dir=target.parent)
        try:
            with os.fdopen(descriptor, "wb") as output, open(entry["source"], "rb") as source:
                shutil.copyfileobj(source, output)
            try:
                os.link(temporary, target)
                print(f"seed: {relative}")
            except FileExistsError:
                print(f"keep: {relative}")
        finally:
            os.unlink(temporary)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--home", required=True, type=Path)
    parser.add_argument("--manifest", required=True, type=Path)
    args = parser.parse_args()
    seed_files(args.home, json.loads(args.manifest.read_text()))
