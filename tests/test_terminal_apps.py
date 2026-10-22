import os
import subprocess
import tomllib
from pathlib import Path


def config(variable):
    return tomllib.loads(Path(os.environ[variable]).read_text())


btop = {}
for line in Path(os.environ["btopConfig"]).read_text().splitlines():
    if " = " in line:
        key, value = line.split(" = ", maxsplit=1)
        btop[key] = value.strip().strip('"')
assert btop["color_theme"] == "TTY", btop
assert btop["theme_background"].lower() == "false", btop

helix = config("helixConfig")
assert helix["theme"] == "base16_transparent", helix
assert helix["editor"]["line-number"] == "relative", helix
assert helix["editor"]["color-modes"] is True, helix

yazi = config("yaziConfig")
assert yazi["mgr"]["sort_by"] == "natural", yazi
assert yazi["mgr"]["sort_dir_first"] is True, yazi

for executable in ("btop", "hx", "yazi"):
    result = subprocess.run(
        [executable, "--version"], check=True, capture_output=True, text=True
    )
    assert result.stdout.strip(), (executable, result)
