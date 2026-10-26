"""Check brightness command arguments without contacting a live DMS session."""
import json
from pathlib import Path
import subprocess
import sys
import tempfile


bindings = [
    line.split("=", 1)[1].split(",", 3)
    for line in Path(sys.argv[1]).read_text().splitlines()
    if line.startswith("bind") and "=" in line
]

with tempfile.TemporaryDirectory() as temporary:
    root = Path(temporary)
    stub = root / "dms"
    stub.write_text(
        f"#!{sys.executable}\n"
        "import json, sys\n"
        "print(json.dumps(sys.argv[1:]))\n"
    )
    stub.chmod(0o755)
    environment = {"PATH": str(root), "HOME": str(root), "XDG_CONFIG_HOME": str(root / ".config")}

    for key, operation in [
        ("XF86MonBrightnessUp", "increment"),
        ("XF86MonBrightnessDown", "decrement"),
    ]:
        commands = [
            fields[3]
            for fields in bindings
            if len(fields) == 4 and fields[1] == key and fields[2] == "spawn"
        ]
        assert len(commands) == 1, (key, commands)
        result = subprocess.run(
            [sys.argv[2], "--noprofile", "--norc", "-c", commands[0]],
            env=environment,
            check=True,
            capture_output=True,
            text=True,
        )
        actual = json.loads(result.stdout)
        assert actual == ["ipc", "call", "brightness", operation, "5", ""], (key, actual)

print("Both Mango brightness commands preserve the step and empty device arguments")
