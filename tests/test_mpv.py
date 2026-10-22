"""Exercise the deployed mpv configuration without a display or a real user home."""
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import socket
import subprocess
import tempfile
import time


def quoted_lua_strings(text):
    """Skip Lua comments so vendor documentation is not mistaken for UI text."""
    i = 0
    while i < len(text):
        if text.startswith("--", i):
            block = re.match(r"--\[(=*)\[", text[i:])
            if block:
                closing = "]" + block.group(1) + "]"
                end = text.find(closing, i + block.end())
                i = len(text) if end < 0 else end + len(closing)
            else:
                end = text.find("\n", i)
                i = len(text) if end < 0 else end
        elif text[i] in "\"'":
            start, quote = i, text[i]
            i += 1
            while i < len(text):
                if text[i] == "\\":
                    i += 2
                elif text[i] == quote:
                    i += 1
                    break
                else:
                    i += 1
            yield text[start:i]
        else:
            i += 1


def wait_for(callback, description, timeout=15):
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        value = callback()
        if value:
            return value
        time.sleep(0.05)
    raise AssertionError("Timed out: " + description)


class Player:
    def __init__(self, root, env, media):
        self.socket_path = root / f"ipc-{len(players)}"
        self.log_path = root / f"mpv-{len(players)}.log"
        self.log = self.log_path.open("w")
        self.process = subprocess.Popen(
            ["mpv", "--vo=null", "--ao=null", "--hwdec=no", "--pause=yes",
             "--force-window=no", "--terminal=yes", "--input-terminal=no", "--msg-level=all=info",
             "--input-ipc-server=" + str(self.socket_path), str(media)],
            env=env, stdout=self.log, stderr=subprocess.STDOUT,
        )
        players.append(self)
        wait_for(lambda: self.socket_path.exists() or self.process.poll() is not None,
                 "mpv IPC socket")
        assert self.process.poll() is None, self.log_path.read_text()
        self.connection = socket.socket(socket.AF_UNIX)
        self.connection.settimeout(10)
        self.connection.connect(str(self.socket_path))
        self.reader = self.connection.makefile("rb")
        self.sequence = 0
        wait_for(lambda: self.command("get_property", "video-params").get("data"),
                 "video initialization")

    def command(self, *args):
        self.sequence += 1
        self.connection.sendall((json.dumps({"command": args, "request_id": self.sequence}) + "\n").encode())
        while True:
            line = self.reader.readline()
            assert line, self.log_path.read_text()
            response = json.loads(line)
            if response.get("request_id") == self.sequence:
                if args[0] == "get_property" and response["error"] == "property unavailable":
                    return response
                assert response["error"] == "success", response
                return response

    def stop(self):
        if self.process.poll() is None:
            self.connection.sendall(b'{"command":["quit"]}\n')
            self.process.wait(timeout=10)
        self.log.close()
        assert self.process.returncode == 0, self.log_path.read_text()


players = []
assets = Path(os.environ["mpvAssets"])
mime_defaults = json.loads(Path(os.environ["mimeDefaults"]).read_text())
video_types = ["video/mp4", "video/x-matroska", "video/webm", "video/quicktime",
               "video/x-msvideo", "video/mpeg", "video/mp2t", "video/ogg",
               "video/x-flv", "video/x-ms-wmv"]
assert all(mime_defaults[name] == ["mpv.desktop"] for name in video_types)
assert all("mpv.desktop" not in values for name, values in mime_defaults.items()
           if name.startswith(("audio/", "image/")))
assert mime_defaults["text/html"] == ["brave-browser.desktop"]
han = re.compile(r"[\u3400-\u9fff]")
lang = assets / "scripts/uosc/lib/lang.lua"
expected_keys = set(re.findall(r"^\s*(_\w+)\s*=", lang.read_text(), re.M))
english = (assets / "script-opts/uosc_lang.conf").read_text()
actual_keys = set(re.findall(r"^(_\w+)=", english, re.M))
assert expected_keys == actual_keys, expected_keys ^ actual_keys
for path in assets.rglob("*.conf"):
    assert not han.search(path.read_text()), path
for path in (assets / "scripts").rglob("*.lua"):
    if path == lang:
        continue  # All fallback locale keys are covered by the English override.
    for value in quoted_lua_strings(path.read_text()):
        assert not han.search(value), (path, value)
assert len(list((assets / "shaders").rglob("*.glsl"))) == 3

with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    home = root / "home"
    config = home / ".config/mpv"
    shutil.copytree(Path(os.environ["mpvDeployment"]), config)
    # Exercise the deployed thumbnail executable, not the fixture's FFmpeg on PATH.
    thumbnail_options = dict(
        line.split("=", 1)
        for line in (config / "script-opts/thumb_engine.conf").read_text().splitlines()
        if line and not line.startswith("#")
    )
    for executable in set(thumbnail_options[key] for key in ["binpath", "bat_binpath"]):
        filters = subprocess.run([executable, "-hide_banner", "-filters"],
                                 capture_output=True, text=True, check=True)
        assert re.search(r"^\s*\S+\s+libplacebo\s+", filters.stdout, re.M), (
            "Dolby Vision thumbnails require libplacebo in " + executable
        )
    config.chmod(0o755)
    for p in config.rglob("*"):
        p.chmod(0o755 if p.is_dir() else 0o644)
    env = dict(os.environ, HOME=str(home), XDG_CONFIG_HOME=str(home / ".config"),
               XDG_CACHE_HOME=str(home / ".cache"), XDG_STATE_HOME=str(home / ".local/state"),
               XDG_DATA_HOME=str(home / ".local/share"), XDG_RUNTIME_DIR=str(root / "runtime"))
    env.pop("MPV_HOME", None)
    for name in ["XDG_CACHE_HOME", "XDG_STATE_HOME", "XDG_DATA_HOME", "XDG_RUNTIME_DIR"]:
        Path(env[name]).mkdir(parents=True, exist_ok=True)
    before = {str(p.relative_to(config)): hashlib.sha256(p.read_bytes()).hexdigest()
              for p in config.rglob("*") if p.is_file()}
    for p in config.rglob("*"):
        p.chmod(0o555 if p.is_dir() else 0o444)
    config.chmod(0o555)
    media = root / "sample with spaces.mkv"
    subprocess.run(["ffmpeg", "-nostdin", "-loglevel", "error", "-f", "lavfi",
                    "-i", "testsrc2=size=64x64:rate=2:duration=16", "-c:v", "mpeg4",
                    "-y", str(media)], check=True)
    try:
        first = Player(root, env, media)
        assert first.command("get_property", "glsl-shaders")["data"] == []
        for profile, filename in [("sharpen", "Adaptive_sharpen_lite_RT.glsl"),
                                  ("deband", "hdeband.glsl"), ("fsr1", "AMD_FSR1_RT.glsl")]:
            first.command("apply-profile", profile)
            shaders = first.command("get_property", "glsl-shaders")["data"]
            assert len(shaders) == 1 and shaders[0].endswith(filename), shaders
            assert Path(shaders[0].replace("~~/", str(config) + "/")).is_file(), shaders
        first.command("script-message-to", "uosc_addones", "shader-menu-event",
                      json.dumps({"type": "activate", "value": "preset:1", "action": "save"}))
        preset = home / ".local/state/mpv/saved-glsl-list.json"

        def save_preset():
            if preset.exists():
                return True
            first.command("script-message-to", "uosc_addones", "shader-menu-event",
                          json.dumps({"type": "activate", "value": "preset:1", "action": "save"}))
        wait_for(save_preset, "shader preset saved outside configuration")
        assert json.loads(preset.read_text())[0]["list"]
        first.command("apply-profile", "no-shaders")
        cleared = first.command("get_property", "glsl-shaders")["data"]
        assert cleared == [], cleared
        first.command("set_property", "volume", 41)
        first.command("set_property", "mute", True)
        first.command("seek", 2, "absolute+exact")
        first.command("write-watch-later-config")
        second = Player(root, env, media)
        for player in [first, second]:
            thumbnail = Path(env["XDG_RUNTIME_DIR"]) / f"kaenix-mpv-thumb-{player.process.pid}.bgra"

            def request_thumbnail():
                player.command("script-message-to", "thumb_engine", "thumb", "2", "0", "0")
                return thumbnail.exists() and thumbnail.stat().st_size > 0
            wait_for(request_thumbnail, "FFmpeg thumbnail for each player instance")
        second.stop()
        first.stop()  # Save this player's volume last.
        saved = json.loads((home / ".local/state/mpv/saved-props.json").read_text())
        assert saved["volume"] == 41 and saved["mute"] is True, saved
        assert list((home / ".local/state/mpv/watch_later").glob("*"))
        third = Player(root, env, media)
        assert third.command("get_property", "volume")["data"] == 41
        assert third.command("get_property", "mute")["data"] is True
        assert third.command("get_property", "glsl-shaders")["data"] == []
        third.stop()
        after = {str(p.relative_to(config)): hashlib.sha256(p.read_bytes()).hexdigest()
                 for p in config.rglob("*") if p.is_file()}
        assert before == after, "Read-only configuration changed"
        for player in players:
            log = player.log_path.read_text()
            assert not re.search(r"Lua error|stack traceback|Error parsing|Error loading|did not become ready|script stopped|module .* not found", log, re.I), log
        print("mpv: deployed files, English UI, MIME, startup, shaders, state/resume, read-only config, and concurrent FFmpeg thumbnails passed")
    except Exception:
        for player in players:
            player.log.flush()
            print(player.log_path.read_text(), flush=True)
        raise
    finally:
        for player in players:
            if player.process.poll() is None:
                player.process.terminate()
                player.process.wait(timeout=10)
            player.log.close()
        for p in config.rglob("*"):
            if p.is_dir():
                p.chmod(0o755)
        config.chmod(0o755)
