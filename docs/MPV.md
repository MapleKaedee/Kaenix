# mpv_PlayKit main in Kaenix

Updated: 19 October 2026. This integration uses native mpv from Kaenix's nixpkgs and selected assets from the **main** branch, commit `4921c6796620a13c2c03266f368d59d354a67b72`, rather than the lite preset or Windows binaries.

## Configuration and installation

The `modules/apps/mpv.nix` feature enables mpv through Home Manager and installs configuration from `config/mpv/`. `modules/packages.nix` notes installation through the module; there is no duplicate mpv package list, new flake input, or lockfile change. Sources, original hashes, licenses, and local adjustments are recorded in the [asset provenance](../config/mpv/UPSTREAM.md).

The player uses `gpu-next` with native Wayland, Vulkan preferred over EGL, `hwdec=auto-safe`, and PipeWire audio with PulseAudio fallback. It does not force NVIDIA, change driver configuration, or interpolate automatically. Three optional shaders are available: FSR1, Adaptive Sharpen Lite, and hdeband. No shader is active at startup, including after a preset has been saved.

The UI uses the main branch's uosc fork with uosc_addones for shader, subtitle, and property menus. Thumbnails use the FFmpeg backend already available in Kaenix. Statistics use mpv's built-in script. All 122 uosc language keys have English overrides; companion script labels/messages and configuration comments are also in English. Vendor code comments, identifiers, media filenames, fonts, shaders, and license text are preserved.

The Windows installer, AI/VapourSynth pipeline, automatic updater, and subtitle search/download through external helpers are excluded. Local subtitles can still be loaded. Mandarin preferences, placeholder paths, and demonstration image-flipping filters are not enabled.

## Opening videos

After rebuilding, open **mpv** through the DMS launcher or run `mpv "path/video.mkv"`. MP4, Matroska, WebM, QuickTime, AVI, MPEG, MPEG-TS, Ogg video, FLV, and WMV default to mpv through `mpv.desktop`. Browser, audio, and image associations are unchanged.

To apply this checkout, the user can run:

```bash
sudo nixos-rebuild switch --flake path:/home/kaede/Kaenix#syrup
```

The agent has not run this command. Before activation, the presence of repository configuration does not prove that mpv is available in the active profile. Configuration file conflicts follow Home Manager's `.pre-kaenix` backup protection; do not delete user settings to resolve conflicts automatically.

## Main controls

| Key | Action |
| --- | --- |
| Right-click | uosc menu |
| Space / `f` | Play/pause / fullscreen |
| Left/Right / Shift+Left/Right | Seek 5 seconds / 1 second precisely |
| `q` / `Q` | Quit / quit and save position |
| Tab / Ctrl+O | Playlist / file browser |
| Ctrl+S / Ctrl+A | Load local subtitles / select audio track |
| Ctrl+G | Shader menu; select a shader or preset explicitly |
| Ctrl+J / Ctrl+P | Subtitle lines / property inspector |
| Ctrl+T | Toggle thumbnails |
| `i` / `I` | Show statistics briefly / toggle statistics |

Other shortcuts follow mpv or are listed in `config/mpv/input.conf`. The Video menu also provides **Clear shaders**. Audio/subtitle language preferences follow automatic selection; an English UI does not force the media language.

## State ownership

Home Manager manages configuration, scripts, UI fonts, and shaders as read-only files through recursive file mapping. Scripts do not store state in the configuration directory.

| Data | Standard location |
| --- | --- |
| Global volume/mute | `$XDG_STATE_HOME/mpv/saved-props.json` |
| Saved shader presets | `$XDG_STATE_HOME/mpv/saved-glsl-list.json` |
| Per-file resume position | `$XDG_STATE_HOME/mpv/watch_later/` |
| Shader/ICC cache | `$XDG_CACHE_HOME/mpv/shaders/` and `icc/` |
| Temporary thumbnails | `$XDG_RUNTIME_DIR/kaenix-mpv-thumb-<PID>…`; fallback to TMPDIR or `/tmp` |

XDG state/cache fallbacks are `~/.local/state` and `~/.cache`, respectively. Thumbnail paths include the PID so multiple players do not share output. No new seed files are added; the existing 16 desktop/tablet seeds are unchanged. Rebuilds do not delete mpv state, and generation rollback does not restore these writable preferences.

## Validation

Run the dedicated check with:

```bash
nix build --no-link path:.#checks.x86_64-linux.mpv-config
```

The check uses a temporary home and read-only configuration, without a display or audio device. It covers the English locale, video MIME defaults, script startup, optional shaders, writable presets/volume/resume state, and FFmpeg thumbnails from two instances. Its fixture uses synthetic video, not the user's collection.

Headless checks do not prove uosc/font appearance, GPU shader rendering or performance, hardware decoding, Wayland clipboard behavior, audio, or opening videos from Nautilus. Test these after activation in a Niri session. See the [validation guide](VALIDATION.md) and [changelog](../CHANGELOG.md) for results that were actually obtained.
