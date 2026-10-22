"""Check deployed terminal configuration and XDG dispatch without opening a window."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tomllib


def xdg(*args):
    return subprocess.check_output(["xdg-terminal-exec", *args], text=True).splitlines()


config = tomllib.loads(Path(os.environ["alacrittyConfig"]).read_text())
assert config["terminal"]["shell"] == {
    "program": os.environ["shellProgram"],
    "args": [],
}
assert config["general"]["import"] == [os.environ["themePath"]]
assert "colors" not in config, "The main config must not override the writable theme"
theme = tomllib.loads(Path(os.environ["themeSeed"]).read_text())
assert set(theme["colors"]["normal"]) == set(theme["colors"]["bright"])
assert len(theme["colors"]["normal"]) == 8
subprocess.run(
    ["alacritty", "migrate", "--dry-run", "--skip-imports", "--config-file", os.environ["alacrittyConfig"]],
    check=True,
    stdout=subprocess.DEVNULL,
)

root = Path(os.environ["XDG_CONFIG_HOME"])
root.mkdir(parents=True)
terminal_list = root / "xdg-terminals.list"
shutil.copyfile(os.environ["terminalList"], terminal_list)
selected = terminal_list.read_text().strip()
packages = json.loads(os.environ["terminalPackages"])
assert selected in packages
assert xdg("--print-id") == [selected]

# Check both installed desktop entries and preserve command argument boundaries.
for desktop, executable in packages.items():
    terminal_list.write_text(desktop + "\n")
    assert xdg("--print-id") == [desktop]
    command = xdg("--print-cmd", "--", "/bin/echo", "argument with spaces", "")
    assert shutil.which(command[0]) == executable, command
    execution_flag = "-e" if desktop == "Alacritty.desktop" else "--"
    assert command[1:] == [execution_flag, "/bin/echo", "argument with spaces", ""], command

print("Terminal TOML, shell selection, theme import, and both XDG desktop entries passed")
