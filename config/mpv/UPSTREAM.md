# mpv_PlayKit main adaptation

Source: <https://github.com/hooke007/mpv_PlayKit/tree/4921c6796620a13c2c03266f368d59d354a67b72>

- Branch: **main** (not lite).
- Pinned commit: `4921c6796620a13c2c03266f368d59d354a67b72`.
- Imported: 19 October 2026.
- Native player: the existing pinned nixpkgs `mpv`, currently 0.41.0.

The scripts `uosc`, `uosc_addones`, `thumb_engine`, and `save_global_props`,
the two UI fonts, and the three shaders come from that snapshot. The compact
configuration and input files adapt the documented main-branch examples for
Kaenix; they are not a copy of the lite preset or the Windows binary bundle.

## Local changes

- Use native Wayland (Vulkan, then EGL), automatic safe hardware decoding, and
  PipeWire/PulseAudio. Omit Windows backends and illustrative flip/rotation,
  placeholder shader, VapourSynth, and AI-interpolation configuration.
- Keep all 122 uosc locale keys covered by the English override. Translate UI
  strings in companion scripts and all local configuration comments. Retain
  vendor comments, identifiers, font assets, shader code, and license text.
- Remove the unused online subtitle downloader and its bundled API credentials,
  automatic updater, and Ziggy integration. Keep local subtitle loading.
  Clipboard operations use mpv's native API with the existing Wayland tools as
  fallback. No accounts or credentials are supplied by this configuration.
- Request uosc's version with a bounded retry so companion initialization does
  not depend on the order of independent script contexts.
- Use the FFmpeg thumbnail backend with direct WinAPI I/O disabled. The output
  filename includes the player's PID and uses XDG_RUNTIME_DIR, TMPDIR, or /tmp.
  The executable is substituted from nixpkgs by the Home Manager module.
- Add `xdg` as a local setting for the global-property and shader-preset state
  directories. Resolve it to `$XDG_STATE_HOME/mpv/`, falling back to
  `$HOME/.local/state/mpv/`, and create that directory on demand. Handle a
  missing/unreadable global-properties file without a Lua exception.
- Cache and resume data use mpv's writable XDG locations. Configuration assets
  remain read-only. Startup never applies a shader automatically.
- Normalize imported Lua text line endings to LF.

The optional shader selection is FSR1 (`AMD_FSR1_RT.glsl`), light adaptive
sharpening (`Adaptive_sharpen_lite_RT.glsl`), and homogeneous-region debanding
(`hdeband.glsl`). Profiles and the shader menu are opt-in. Individual shader
compilation and performance require a real graphics session.

## Attribution and updates

`LICENSE.upstream.md` reproduces the snapshot's repository license notice.
Individual source files retain their original notices and upstream links;
there is no new blanket license for imported files. `upstream-files.json`
records the original hashes of the files brought into this directory, before
the documented adaptations. Preserve those notices when updating the snapshot.

Update deliberately by reviewing a new **main** commit, comparing these local
changes, checking the locale-key coverage, and running `mpv-config`. Do not run
the Windows installer or the in-app updater. No flake input is added.
