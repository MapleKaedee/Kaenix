# Configuration ownership

Updated: 21 October 2026, based on repository modules and evaluation. Use [Kaenix context and the documentation index](kaenix.md) for other guides and [validation](VALIDATION.md) to distinguish repository configuration, check results, and runtime status.

## Modules by category

Configuration is grouped by function, inspired by the organization of [hlissner/dotfiles](https://github.com/hlissner/dotfiles) while retaining standard NixOS and Home Manager APIs.

| Category | Contents |
| --- | --- |
| `modules/desktop/` | Niri, DMS/DankGreeter, font defaults, and cursor |
| `modules/shell/` | Fish, Nushell, Starship/eza, Fastfetch, and Git configuration |
| `modules/apps/` | Alacritty, Brave, Kitty, mpv, and Steam configuration |
| `modules/hardware/` | NVIDIA/PRIME, ASUS, power, tablet, and Bluetooth |
| `modules/services/` | Audio, printing, automount, session services, and SCX scheduling |
| `modules/system/` | Base system settings, users, Nix, and Home Manager infrastructure |

`configuration.nix` imports hardware settings and `modules/default.nix`, then sets the host identity, installation guard, bootloader, and system state version. Each category imports its features explicitly through `default.nix`.

Each feature is one named file, such as `modules/apps/kitty.nix`. There are 27 features across six categories. NixOS settings are at the top level; Home Manager settings, where needed, are in an inline `home-manager.users.${globals.username}` module with its own `config`, `lib`, and `pkgs` arguments. Root `home.nix` only handles identity, state version, XDG, and Home Manager activation. There is no auto-discovery or new enable option.

Add configured features to the relevant category's imports. For applications that only need installation, add their packages to `modules/packages.nix` without creating empty feature modules. Keep assets in `config/`, helpers in `lib/`, scripts in `scripts/`, and wallpapers in `collection/`. Preserve system/user package scope. Use `path:.` when checking new unstaged files.

For implementation, use [Kaenix Feature](../.agents/skills/kaenix-feature/SKILL.md), for example `$kaenix-feature add or update a configured application`.

The `kaenix.seedFiles` infrastructure, including its option definition and activation, is in `modules/system/home-manager.nix`.

## Documentation lookup and version support

Use [Kaenix Docs](../.agents/skills/kaenix-docs/SKILL.md), for example `$kaenix-docs verify whether this option is supported by Kaenix's pinned Home Manager`, for source-based documentation and compatibility research. It accounts for locked input mappings, package overrides, and vendored adaptations; research remains report-only. Feature changes, dependency updates, documentation edits, and live diagnosis stay with their existing workflows.

## Centralized package lists

`modules/packages.nix` is imported by `modules/default.nix` and centralizes three explicit lists: `environment.systemPackages`, `home-manager.users.${globals.username}.home.packages`, and `fonts.packages`. Comments group packages by purpose. Nautilus, Zed, ChatGPT, Discord, Spotify, osu!, ProtonPlus, MangoHud, GOverlay, Nix tools, and CLI utilities use these lists because they only need installation.

The `programs` and `services` options also install packages through their modules. Keep their activation and configuration with the feature; comments in `modules/packages.nix` point to locations such as Brave, Kitty, shells, Niri, and DMS. These references are not a transitive dependency inventory. Kernel/driver choices, cursor packages, and executable references remain with their features. Do not duplicate module-installed packages in the explicit lists.

## LAVD CPU scheduling

`modules/services/scx.nix` enables the standard NixOS `services.scx` service with `pkgs.scx.rustscheds` and `scx_lavd --autopower`. It starts at boot and follows the active power-profiles-daemon profile (performance, balanced, or power saver). All other LAVD settings use upstream defaults. Change the scheduler or its arguments in this module, then rebuild; `scx-loader` is not enabled.

The existing CachyOS kernel provides sched_ext and BPF support; no kernel replacement or extra kernel parameters are needed. The NixOS service checks for `/sys/kernel/sched_ext`, restarts on failure with a start-rate limit, and installs the scheduler package itself. Do not duplicate it in the explicit package lists.

Activate when ready with `sudo nixos-rebuild switch --flake path:/home/kaede/Kaenix#syrup`. The service starts during activation; a reboot is not required when the running kernel already supports sched_ext. After activation, inspect:

```bash
systemctl status scx.service
journalctl -b -u scx.service --no-pager
cat /sys/kernel/sched_ext/state
cat /sys/kernel/sched_ext/root/ops
powerprofilesctl get
```

Expect sched_ext to be enabled with LAVD attached. Confirm the selected power profile in the service logs while changing profiles through the existing desktop controls. Evaluate responsiveness and gaming behavior on the target laptop; successful evaluation and package builds do not prove runtime compatibility or performance.

For a temporary return to the kernel's built-in fair scheduler, run `sudo systemctl stop scx.service`; use `sudo systemctl start scx.service` to resume LAVD. Stopping the service does not change the declarative boot default. To disable it persistently, remove the SCX feature import and rebuild. The kernel also falls back to fair scheduling when the BPF scheduler exits or is aborted after an error; inspect logs if this occurs.

## Declarative configuration through Home Manager

Nix manages Alacritty, Kitty, Nushell, Fish, Starship, Fastfetch, Brave/MIME, base Niri, plugin sources, and wallpaper files. Edit repository modules or assets, then rebuild. Do not edit Home Manager's generated symlinks directly.

Alacritty, Kitty, Nushell, Fish, and Fastfetch use `programs.*` options. Niri uses `xdg.configFile."niri/config.kdl".text` to read repository KDL. This preserves Niri features without depending on an external Niri module schema.

## Choosing Alacritty or Kitty

`globals.defaultTerminal` in `flake.nix` accepts `"alacritty"` or `"kitty"`, with Alacritty as the initial default. `lib/terminal-package.nix` rejects other values. Both applications are always installed through their Home Manager modules; this selection only sets the desktop default and does not remove the other terminal.

The Niri module aligns `$TERMINAL` in the NixOS session with `xdg.terminal-exec.settings.default`. The desktop ID is `Alacritty.desktop` or `kitty.desktop`. Home Manager installs `xdg-terminal-exec` and manages `~/.config/xdg-terminals.list` as read-only configuration. Change the default through Nix and rebuild rather than using the DMS GUI's terminal selector; the pinned DMS GUI tries to write the same file. Other DMS state/settings files remain writable.

The baseline `Mod+T` runs `xdg-terminal-exec`. Applications using this launcher follow the default terminal list; applications reading `$TERMINAL` follow the session environment. Explicit `kitty` or `alacritty` commands still open the named application. After changing the default, rebuild and log out/in to refresh the Niri/DMS environment.

Alacritty uses JetBrainsMono Nerd Font Mono at size 12, 12 px padding, 0.5 opacity, hidden decorations, 3000 lines of scrollback, and a block cursor blinking every 1000 ms. `Ctrl+Shift+N` opens a new window; `Ctrl++`, `Ctrl+-`, and `Ctrl+0` control font size. Kitty tabs and its `Ctrl+T` shortcut remain in Kitty; the terminals do not have identical features.

Alacritty's main configuration follows `globals.defaultShell` through the same shell helper as Kitty, with the `--login` argument. Colors are imported from `~/.config/alacritty/dank-theme.toml`, which is copied only if absent and can then be updated by DMS. The pinned DMS Alacritty template is enabled by default; if previously disabled through the GUI, enable it again in DMS theme settings. `runDmsMatugenTemplates` and `matugenTemplateAlacritty` remain GUI preferences. Do not add colors directly to the main configuration because they would override the imported file.

### One-time migration after first activation

The user activates with `sudo nixos-rebuild switch --flake path:/home/kaede/Kaenix#syrup`. Home Manager uses the `pre-kaenix` backup extension and does not overwrite existing backups. The old `~/.config/xdg-terminals.list` will be backed up as `xdg-terminals.list.pre-kaenix`. If that backup name already exists, save the earlier backup under another unique name before retrying activation.

Seed changes do not modify bindings already present in the home. After activation, back up the binding file and change only the `Mod+T` command from `kitty` to `xdg-terminal-exec`, using the DMS binding editor or a text editor. The following targeted alternative handles an old binding that still exactly matches the baseline. Run `bash` first if the current terminal uses Nushell, then execute this block in Bash:

```bash
(
  set -eu
  binds="$HOME/.config/niri/dms/binds.kdl"
  old='    Mod+T hotkey-overlay-title="Open Terminal" { spawn "kitty"; }'
  if [ "$(grep -Fxc "$old" "$binds")" != 1 ]; then
    echo 'Binding differs or is already migrated; check Mod+T through DMS.' >&2
    exit 1
  fi
  backup=$(mktemp "$binds.pre-terminal.XXXXXX")
  cp -p "$binds" "$backup"
  sed -i 's/^    Mod+T hotkey-overlay-title="Open Terminal" { spawn "kitty"; }$/    Mod+T hotkey-overlay-title="Open Terminal" { spawn "xdg-terminal-exec"; }/' "$binds"
  if ! niri validate -c "$HOME/.config/niri/config.kdl"; then
    cp -p "$backup" "$binds"
    echo "Validation failed; binding restored from $backup" >&2
    exit 1
  fi
  echo "Binding backup: $backup"
)
```

This block preserves other bindings and does not run automatically during rebuilds. Once the binding uses the generic launcher, later changes to `globals.defaultTerminal` need no further migration. Verify `xdg-terminal-exec --print-id`, then test `Mod+T` and application launchers after logging in again. Do not replace the entire binding file or DMS directory with the baseline.

## Choosing Nushell or Fish

`globals.defaultShell` in `flake.nix` accepts `"nushell"` or `"fish"`. Nushell is the initial default. The user's login shell, Alacritty, and Kitty share this selection; other values produce an evaluation error explaining the valid choices. Both shells remain enabled and listed in `/etc/shells`; this selection is independent of `globals.defaultTerminal`.

After changing the selection, rebuild and open a new terminal window. Log out/in so the login shell and `$SHELL` in the new session follow the selection. Existing terminal sessions are not replaced automatically. For a checkout containing new unstaged files, use:

```bash
sudo nixos-rebuild switch --flake path:/home/kaede/Kaenix#syrup
```

`fish` or `nu` opens a nested shell; `exit` returns to the previous shell. `exec fish` or `exec nu` replaces the current shell process without changing the Nix default. Avoid using `chsh` for permanent settings because NixOS manages the user's shell.

Starship and eza are managed by the shared `modules/shell/common.nix` module; the prompt theme is in `config/starship.toml`. Starship integration is enabled for both shells. Fastfetch runs once per interactive startup; noninteractive commands print no greeting. Nushell disables its default banner and uses OSC 7/133 for the working directory and Kitty prompt markers.

Fish aliases still use eza for `ls`. Nushell keeps its built-in `ls` so pipelines such as `ls | where type == file` operate on tables; use `ll` for eza output. The two shells' histories are not merged. No additional external completion plugin or framework is installed.

`login.nu` runs noninteractive Bash to read `/etc/profile` and Home Manager's generated `hm-session-vars.sh` package. The `scripts/import-login-env.nu` helper reads NUL-separated environment values, preserves `=` signs/newlines, and converts PATH to a Nushell list. Working-directory variables and process metadata do not replace Nushell state. A profile-reading failure produces an error rather than a partial environment.

Nushell configuration is Nix-managed and read-only; edit its module and rebuild. History remains writable. Run validation with `nix build --no-link path:.#checks.x86_64-linux.shells`; the `tests/evaluate.nix` fixture accepts `defaultShell` to evaluate both choices without activation.

## DMS calendar and the khal build workaround

The pinned DMS module enables calendar event integration through `khal` by default. `modules/desktop/dms.nix` adds a NixOS overlay specifically for `khal`, with `sphinxBuilders = "html man"`. The pinned Sphinx hook reads the structured-attributes array as a single initial value, so the `[ "html" "man" ]` list only generates HTML and the build fails because the `man` output is missing. The string runs both builders without changing the package version/source or disabling the calendar.

This workaround applies to pinned nixpkgs `09063bd1f2b36fd9fd793c36dfade7bd40a93dfc`. After updating nixpkgs, recheck Sphinx hook compatibility before keeping or removing the override. Test the `khal` build and its manual output; successful evaluation alone does not prove the issue is resolved.

## Writable files and one-time seeding

`kaenix.seedFiles` runs `scripts/seed-files.py` after Home Manager linking and before systemd reload. Nix provides the Python interpreter; global Python is unnecessary. The manifest comes from the Nix store; all 17 seed targets are relative to the user's home.

| Target | Initial source | Owner after activation |
| --- | --- | --- |
| `~/.config/DankMaterialShell/settings.json` | `config/dms/settings.nix` | DMS GUI |
| `~/.config/DankMaterialShell/plugin_settings.json` | `modules/desktop/dms.nix` | DMS plugin GUI |
| `~/.local/state/DankMaterialShell/session.json` | Minimal state without launcher history | DMS |
| `~/.config/DankMaterialShell/themes/catppuccin/theme.json` | `config/dms/catppuccin.json` | DMS |
| `~/.config/niri/dms/*.kdl` | `config/niri/dms/` | DMS/user |
| `~/.config/kitty/dank-*.conf` | `config/kitty/` | DMS theme generator |
| `~/.config/alacritty/dank-theme.toml` | `config/alacritty/dank-theme.toml` | DMS theme generator/user |
| `~/.config/OpenTabletDriver/settings.json` | `config/opentabletdriver/settings.json` | OpenTabletDriver GUI |

Changing a baseline does not replace existing active files, including empty files or symlinks. To reapply one baseline, stop the relevant application, move its active file to a unique backup, then rebuild. Do not move the entire DMS directory because Home Manager manages plugin sources.

If `.config/niri` or a target's parent directory is still an out-of-store symlink from an older configuration, back it up and replace it with a regular directory. The helper refuses to write through directory symlinks rather than following them into an old repository.

NixOS generation rollback restores declarative configuration and plugin sources but not GUI state. Back up writable state separately to roll back appearance or tablet area.

## Bringing GUI changes back into the repository

For selected preference imports, use [Kaenix GUI Baseline](../.agents/skills/kaenix-gui-baseline/SKILL.md), for example `$kaenix-gui-baseline save my selected DMS preferences as repository defaults`.

Export DMS settings with `dms ipc call settings dump`, then translate the desired baseline values into `config/dms/settings.nix`. Do not copy other users' absolute paths, search history, or credentials.

Niri fragments, Kitty themes, and tablet profiles can be copied back to their respective baseline locations after review. `fish_variables` is unnecessary: the module manages the Fish prompt and plugins.

Plugins are pinned in flake inputs. The GUI can change settings, but plugin code must be updated/removed through Nix; see [updating flake inputs](#updating-flake-inputs).

## Updating flake inputs

Use [Kaenix Update](../.agents/skills/kaenix-update/SKILL.md), for example `$kaenix-update update dms and review compatibility`, for selected inputs or an explicitly requested full update. The skill owns the review/update procedure and compatibility-fix boundaries; activation remains separate.

Preserve input release lines and shared nixpkgs relationships. The `cat-widget` and `mpvpaper-plugin` declarations pin exact commits: verify and change the intended commit before refreshing the selected lock entries. A lockfile refresh alone does not advance those declared pins. Reassess affected workarounds, including the [khal override](#dms-calendar-and-the-khal-build-workaround), and distinguish passing configuration checks from real-session plugin compatibility. Vendored mpv/PlayKit assets follow their separate [update guidance](../config/mpv/UPSTREAM.md#attribution-and-updates).

## GitHub CLI authentication

Git is managed by Home Manager, so `~/.config/git/config` is a read-only symlink to the Nix store. `gh auth login` can complete browser authentication but fail at the final step when attempting to write the credential helper to that file.

`modules/shell/git.nix` declares the `gh auth git-credential` helper for GitHub and Gist, including resetting the helper list before selecting the GitHub CLI helper. Tokens are not stored in Nix configuration. The `gh` configuration and accounts remain writable and are not managed through `programs.gh`.

After rebuilding, check:

```bash
gh auth status
git config --get-all 'credential.https://github.com.helper'
```

If the account is already authenticated, there is no need to sign in again or run `gh auth setup-git`. For a new `gh auth login`, choose **No** when asked whether to configure Git with GitHub CLI credentials; the helper is already declared. Avoid `git config --global` for Nix-managed settings; edit `programs.git.settings` and rebuild.

The `wl-clipboard` package provides `wl-copy`/`wl-paste` for copying login codes in a Wayland session. Check browser login results with `gh auth status`.

## Monitoring Nix builds

`pkgs.nix-output-monitor` is installed through `home.packages` in `modules/packages.nix`, from pinned nixpkgs. There is no new flake input or replacement alias for Nix commands.

After rebuilding, user `kaede` can use `nom`, `nom-build`, and `nom-shell` from Nushell or Fish. Check installation with `nom --version`. From the repository root, view build progress, downloads, and dependency trees with:

```bash
nom build --no-link path:.#checks.x86_64-linux.shells
```

`nom build` wraps `nix build`; `nom-build` and `nom-shell` wrap the legacy `nix-build`/`nix-shell` commands. `nixos-rebuild` does not automatically use the monitor: pipe its stdout/stderr to `nom` using the current shell's syntax. JSON mode uses `--log-format internal-json -v` on Nix and `nom --json` on the monitor; see the [upstream guide](https://github.com/maralorn/nix-output-monitor#running).

## Formatting Nix code

`pkgs.nixfmt` is installed through `home.packages` in `modules/packages.nix`, using pinned nixpkgs without a new flake input or lockfile change. After rebuilding, `nixfmt` is available from Nushell and Fish.

The `formatter.x86_64-linux` output in `flake.nix` uses `nixfmt-tree` from the host's package set. `nix fmt` is available before system activation. From the repository root:

```bash
# Format one file
nixfmt modules/packages.nix

# Format every Nix file in the project
nix fmt

# Format only selected files
nix fmt -- modules/packages.nix modules/apps/kitty.nix
```

These commands write changes to files. No Git hook or editor format-on-save setting is installed. Format only the files being changed to limit the diff; formatting the entire repository remains an explicit action. See the [upstream guide](https://github.com/NixOS/nixfmt#installation).

## WhatsApp and Discord

Official Discord is installed through `home.packages` in `modules/packages.nix`, without mods or autostart. WhatsApp uses Brave without a separate client. Accounts, login sessions, and preferences remain writable outside the repository.

## mpv and video defaults

`modules/apps/mpv.nix` enables mpv through Home Manager and makes it the video default. Configuration, controls, writable state, asset provenance, and validation are covered in the [mpv_PlayKit main guide](MPV.md).

## Audio settings

Pavucontrol and EasyEffects are installed through `home.packages` in `modules/packages.nix`. PipeWire and PulseAudio compatibility are configured in `modules/services/audio.nix`. EasyEffects presets remain GUI-selected and writable; the repository enables no additional EasyEffects autostart or service.

Keep physical speakers/headsets/microphones as the default devices; do not select EasyEffects virtual devices as the defaults. This follows [upstream guidance](https://github.com/wwmm/easyeffects).

## Steam gaming

`modules/apps/steam.nix` configures Steam, Protontricks, Gamescope, and GameMode. See the [Steam gaming guide](steam.md) for first launch, ProtonPlus, overlays, per-game launch options, and runtime verification.

## GPU and applications

Niri uses the AMD render node at PCI `0000:05:00.0`. NVIDIA at `0000:01:00.0` is available for selected applications:

```bash
nvidia-offload 'osu!'
```

The NVIDIA VA-API driver is not forced for all applications. If display connector names change after migration, select the wallpaper monitor again in mpvpaper settings; the seed currently uses `eDP-2` from CachyOS.

DMS uses one user service, `dms.service`; automount uses `udiskie.service`. The NixOS module provides `opentabletdriver.service` as a user unit, so it does not appear among Home Manager services. Base Niri contains no `spawn-at-startup` for DMS or OpenTabletDriver; DMS provides the Polkit agent.
