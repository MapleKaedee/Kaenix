# Steam gaming

Updated: 21 October 2026. This guide covers the Steam feature on Kaenix host `syrup`. See the [documentation index](kaenix.md) and [validation guide](VALIDATION.md) for configuration context and evidence limits.

## Configuration

`parts/features/apps/steam.nix` enables the NixOS Steam module, Protontricks, Gamescope, and GameMode. Steam supplies `steam-run`, 32-bit graphics/audio integration, and controller udev rules. ProtonPlus, MangoHud, and GOverlay are user packages in `parts/features/packages.nix`; MangoHud, Gamescope, and GameMode are also included in Steam's FHS environment so game launch options can find them. GameMode's packaged launcher references both its 64-bit and 32-bit preload libraries. The existing NVIDIA PRIME offload, LAVD scheduler, power profiles, and Xwayland Satellite integration remain in use.

Gamescope is an optional nested compositor inside Niri. No separate Steam/Gamescope login session, Gamescope privileged scheduling capability, or global overlay/GPU override is enabled. Remote Play, local network transfers, and dedicated-server firewall openings remain disabled; ordinary Steam downloads and online play use the existing firewall. Individual games that host servers may need their own port rules.

## First launch and compatibility tools

1. Activate when ready with `sudo nixos-rebuild switch --flake path:/home/kaede/Kaenix#syrup`, then open Steam from the application launcher and sign in. Let Steam finish its initial runtime downloads. Fully exit and reopen Steam if it was already running during activation.
2. Install a game. Use Valve's Proton through Steam's compatibility settings when needed for Windows titles; enable Steam Play for other titles if your Steam version exposes that setting.
3. For an alternative compatibility tool, close Steam and open **ProtonPlus**. Select the native Steam installation, download the desired tool (for example GE-Proton), and wait for installation to finish. Reopen Steam, then select the downloaded tool in the game's **Properties → Compatibility** settings. Restart Steam after later tool installations or updates as well.
4. Open **GOverlay** to customize and save MangoHud preferences. Enable the overlay per game using the launch options below; leave GOverlay's global-enable option off for this setup. Preferences such as `~/.config/MangoHud/MangoHud.conf` remain writable and are not managed or seeded by Nix. Steam settings, ProtonPlus downloads, game libraries, and Proton prefixes also remain user-managed.

ProtonPlus manages downloaded compatibility tools; it is not itself a replacement compatibility layer. Kaenix does not install a separate Nix-managed GE-Proton copy. Protontricks is available for targeted game fixes, but do not apply blanket prefix modifications. Game compatibility varies, and some anti-cheat implementations do not support Linux/Proton. See [ProtonPlus](https://github.com/Vysp3r/ProtonPlus) and [Valve Proton](https://github.com/ValveSoftware/Proton).

## GameMode

The standard NixOS GameMode module installs the launcher, D-Bus integration, and the `gamemoded.service` user unit. It keeps the module's default renice capability wrapper and generates `/etc/gamemode.ini` without custom settings. No extra group membership, custom power-profile scripts, priority tuning, or GPU overclocking is configured.

Request GameMode per game with `gamemoderun %command%`. Games with built-in GameMode support may request it themselves. With the pinned GameMode defaults, active requests can temporarily switch the CPU governor to `performance`, raise I/O priority, and inhibit the screensaver where supported. The previous governor is restored after the last request ends; no power-profiles-daemon profile is selected by a custom hook. LAVD remains enabled with `--autopower` and continues following the desktop's selected power profile. Changing that profile during a GameMode request can also affect governor state, so check the result after the game exits. See [GameMode usage](https://github.com/FeralInteractive/gamemode#requesting-gamemode) and the [pinned defaults](https://github.com/FeralInteractive/gamemode/blob/1.8.2/example/gamemode.ini).

Keep `~/.config/gamemode.ini` and any game-local overrides user-managed; they take precedence over system defaults for supported settings. Existing overrides may change the behavior described here. Performance improvements depend on the game and hardware and require measurement.

## Per-game launch options

Set these in Steam's **Properties → General → Launch Options**. Leave the field empty for normal GPU selection without an overlay or nested compositor.

| Purpose | Launch options |
| --- | --- |
| NVIDIA offload | `nvidia-offload %command%` |
| MangoHud | `mangohud %command%` |
| NVIDIA and MangoHud | `nvidia-offload mangohud %command%` |
| GameMode | `gamemoderun %command%` |
| NVIDIA, GameMode, and MangoHud | `nvidia-offload gamemoderun mangohud %command%` |
| Gamescope fullscreen | `gamescope --backend sdl --force-grab-cursor -f -- %command%` |
| NVIDIA and Gamescope | `nvidia-offload gamescope --backend sdl --force-grab-cursor -f -- %command%` |
| NVIDIA, Gamescope, and game overlay | `nvidia-offload gamescope --backend sdl --force-grab-cursor -f -- mangohud %command%` |
| NVIDIA, Gamescope, GameMode, and game overlay | `nvidia-offload gamescope --backend sdl --force-grab-cursor -f -- gamemoderun mangohud %command%` |

The SDL backend and cursor-grab flags follow [Niri's fullscreen-game guidance](https://github.com/niri-wm/niri/wiki/Application-Issues#fullscreen-games). For explicit resolutions, add `-w WIDTH -h HEIGHT` for the game and `-W WIDTH -H HEIGHT` for the output before `--`, replacing the placeholders with your desired dimensions. Keep these choices per game rather than imposing one resolution or backend on every application. The MangoHud command inside Gamescope targets the game; its behavior still needs runtime verification for the chosen renderer.

## Runtime verification

After activation, check that Steam starts under Niri, ProtonPlus detects it, and a representative native or Proton game launches with audio and controller input if used. For NVIDIA launch options, run `nvidia-smi` while the game runs and confirm the game process uses the discrete GPU. Check Gamescope fullscreen behavior, relative mouse movement, and focus/return to Niri. Verify MangoHud appears only when requested, and that changes saved in GOverlay survive closing/reopening GOverlay and restarting the game.

For a game using GameMode, record the selected power profile and CPU governors before launch:

```bash
powerprofilesctl get
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

While the game runs, check GameMode registration and continued LAVD operation:

```bash
gamemoded -s
systemctl --user status gamemoded.service
journalctl --user -b -u gamemoded.service --no-pager
systemctl status scx.service
cat /sys/kernel/sched_ext/state
cat /sys/kernel/sched_ext/root/ops
```

Expect GameMode to be active and LAVD to remain attached. After closing all games that requested GameMode, use `gamemoded -s` again and compare the governors and selected power profile with the pre-game values. The user service can stay running while GameMode is inactive. Investigate registration errors or unexpected governor restoration in its journal; keep power-profile changes outside this comparison for a reproducible test.

Successful evaluation and package builds do not prove game compatibility, working GPU offload, controller behavior, overlay injection, or improved performance. Report these separately from the checks in [validation](VALIDATION.md).

