# Configuration ownership

Updated: 22 October 2026; configuration claims are based on repository modules and prior evaluation. Use [Kaenix context and the documentation index](kaenix.md) for other guides and [validation](VALIDATION.md) to distinguish repository configuration, check results, and runtime status.

## Modules by category

Configuration is grouped by function, inspired by the organization of [hlissner/dotfiles](https://github.com/hlissner/dotfiles) while retaining standard NixOS and Home Manager APIs.

| Category | Contents |
| --- | --- |
| `parts/features/desktop/` | Niri, DMS/DankGreeter, font defaults, and cursor |
| `parts/features/shell/` | Default login shell, Fish, Nushell, Starship/eza, Fastfetch, and Git configuration |
| `parts/features/apps/` | Alacritty, Kitty, btop, Brave, Helix, mpv, Steam, and Yazi configuration |
| `parts/features/hardware/` | NVIDIA/PRIME, ASUS, power, tablet, and Bluetooth |
| `parts/features/services/` | Audio, printing, automount, session services, and SCX scheduling |
| `parts/features/system/` | Base system settings, users, Nix, and Home Manager infrastructure |

`configuration.nix` imports hardware settings, then sets the host identity, installation guard, bootloader, and system state version. `parts/hosts/syrup.nix` selects the configured features explicitly; category directories have no `default.nix` import lists.

The 30 application, desktop, shell, hardware, service, and system features each register one NixOS module from a named file under `parts/features/<category>/`, such as `parts/features/apps/alacritty.nix`. `parts/features/shell/default-shell.nix` owns the selected user login shell, and `parts/features/packages.nix` owns the centralized package lists, giving 32 registered NixOS modules. NixOS settings belong inside the registered module; Home Manager settings, where needed, are in an inline `home-manager.users.${globals.username}` module with its own `config`, `lib`, and `pkgs` arguments. Root `home.nix` handles identity, state version, XDG, and Home Manager activation.

Add configured features under the relevant category, register them, and explicitly select them in the host. For applications that only need installation, add their packages to `parts/features/packages.nix` without creating empty feature modules. Keep assets in `config/`, helpers in `lib/`, scripts in `scripts/`, and wallpapers in `collection/`. Preserve system/user package scope. Use `path:.` when checking new unstaged files.

For implementation, use [Kaenix Feature](../.agents/skills/kaenix-feature/SKILL.md), for example `$kaenix-feature add or update a configured application`.

The `kaenix.seedFiles` infrastructure, including its option definition and activation, is in `parts/features/system/home-manager.nix`.

## Dendritic features and flake outputs

The root `flake.nix` retains inputs, `nixConfig`, and shared `globals`, then calls `flake-parts.lib.mkFlake`. `import-tree` discovers flake-parts modules only under `parts/`. Keep assets, helpers, tests, scripts, installation fixtures, and `hardware-configuration.nix` outside that discovery boundary. Root `configuration.nix` and `home.nix` remain explicit entrypoints; the former `modules/` import tree has been removed.

| Owner | Responsibility |
| --- | --- |
| `parts/outputs.nix` | Existing `packages.x86_64-linux.default`, `packages.x86_64-linux.kae`, `formatter.x86_64-linux`, and `checks.x86_64-linux` outputs |
| `parts/hosts/syrup.nix` | Construct `nixosConfigurations.syrup`, preserve NixOS/Home Manager wiring, and explicitly select all 32 registered NixOS modules |
| `parts/features/<category>/<name>.nix` | Register `flake.modules.nixos.<name>`, including any inline Home Manager module |
| `parts/features/packages.nix` | Register `flake.modules.nixos.packages` with the centralized explicit package lists |

Existing public output names remain available. The `modules.nixos` output exposes the 32 registered modules. Discovery registers definitions; host selection enables them. Discovery of feature definitions alone must not construct a host. There are no category import files, profiles, or per-feature enable switches.

Flake-parts `config` contains flake configuration and outputs. The registered NixOS module has its own arguments and `config`, and its inline Home Manager module has another `config`; application options belong in those lower-level contexts. Root globals enter flake-parts through `_module.args`, while NixOS `specialArgs` and Home Manager `extraSpecialArgs` preserve the lower-level `globals` arguments. Do not close over flake-parts globals inside a registered feature: `tests/evaluate.nix` must still be able to override shell and terminal choices.

For a configured feature, add `parts/features/<category>/<name>.nix` registering `flake.modules.nixos.<name>`, then select `config.flake.modules.nixos.<name>` in the host's module imports. Choose a unique registration name and verify relative asset/helper paths. Registration alone does not enable a feature. Do not introduce profiles, feature toggles, extra platforms, or discovery outside `parts/` without a separate need.

For changes to this infrastructure, compare baseline and post-change outputs and validate all existing checks through [Kaenix Validate](../.agents/skills/kaenix-validate/SKILL.md). Matching derivations establish equivalence only for those generated outputs; record cached and fresh check execution separately. These checks do not establish activation or desktop runtime behavior.

## Documentation lookup and version support

Use [Kaenix Docs](../.agents/skills/kaenix-docs/SKILL.md), for example `$kaenix-docs verify whether this option is supported by Kaenix's pinned Home Manager`, for source-based documentation and compatibility research. It accounts for locked input mappings, package overrides, and vendored adaptations; research remains report-only. Feature changes, dependency updates, documentation edits, and live diagnosis stay with their existing workflows.

## Centralized package lists

`parts/features/packages.nix` registers `flake.modules.nixos.packages`, selected explicitly by the host, and centralizes three explicit lists: `environment.systemPackages`, `home-manager.users.${globals.username}.home.packages`, and `fonts.packages`. Comments group packages by purpose. Nautilus, Zed, ChatGPT, Discord, Spotify, osu!, ProtonPlus, MangoHud, GOverlay, Nix tools, and CLI utilities use these lists because they only need installation. TUIOS is installed in the user list for manual startup.

The `programs` and `services` options also install packages through their modules. Keep their activation and configuration with the feature; comments in `parts/features/packages.nix` point to locations such as Brave, btop, Helix, Kitty, Yazi, shells, Niri, and DMS. These references are not a transitive dependency inventory. Kernel/driver choices, cursor packages, and executable references remain with their features. Do not duplicate module-installed packages in the explicit lists.

## Removable-media automount and the udiskie test workaround

`parts/features/services/automount.nix` enables UDisks2 and GVfs, plus Home Manager's udiskie service with automounting, notifications, and an automatic tray icon. Its `services.udiskie.package` overrides only the pinned udiskie package's test assertion: after invalidating a synthetic key, lookup must raise either `KeyNotAvailable` (`ENOKEY`) or `KeyRevoked` (`EKEYREVOKED`). The original assertion accepts only `ENOKEY`, but the local build returns `EKEYREVOKED`. Both results deny access to the invalidated key; all 15 package tests remain enabled, and application code is unchanged. See the [kernel key-request documentation](https://www.kernel.org/doc/html/latest/security/keys/request-key.html) for lookup errors.

This workaround is verified for udiskie 2.7.0 from nixpkgs `02c087f3fe673c9e317f206a627cb6b910336dbe`. After updating nixpkgs or udiskie, recheck the assertion and remove the override when upstream handles the result. Build the effective `home-manager.users.kaede.services.udiskie.package` and inspect its test log; evaluation alone does not verify the fix. Package tests do not prove removable-drive mounting in the desktop session.

## LAVD CPU scheduling

`parts/features/services/scx.nix` enables the standard NixOS `services.scx` service with `pkgs.scx.rustscheds` and `scx_lavd --autopower`. It starts at boot and follows the active power-profiles-daemon profile (performance, balanced, or power saver). All other LAVD settings use upstream defaults. Change the scheduler or its arguments in this module, then rebuild; `scx-loader` is not enabled.

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

For a temporary return to the kernel's built-in fair scheduler, run `sudo systemctl stop scx.service`; use `sudo systemctl start scx.service` to resume LAVD. Stopping the service does not change the declarative boot default. To disable it persistently, remove the SCX selection from `parts/hosts/syrup.nix` and rebuild. The kernel also falls back to fair scheduling when the BPF scheduler exits or is aborted after an error; inspect logs if this occurs.

## Declarative configuration through Home Manager

Nix manages Alacritty, Kitty, Nushell, Fish, Starship, Fastfetch, Brave/MIME, base Niri, plugin sources, and wallpaper files. Edit repository modules or assets, then rebuild. Do not edit Home Manager's generated symlinks directly.

Alacritty, btop, Helix, Kitty, Nushell, Fish, Fastfetch, and Yazi use `programs.*` options. Niri uses `xdg.configFile."niri/config.kdl".text` to read repository KDL. This preserves Niri features without depending on an external Niri module schema.

## Choosing Alacritty or Kitty

`globals.defaultTerminal` in `flake.nix` accepts `"alacritty"` or `"kitty"` and currently selects Kitty. `lib/terminal-package.nix` rejects other values. Both applications are always installed through their Home Manager modules; this selection only sets the desktop default and does not remove the other terminal.

The Niri module aligns `$TERMINAL` in the NixOS session with `xdg.terminal-exec.settings.default`. The desktop ID is `Alacritty.desktop` or `kitty.desktop`. Home Manager installs `xdg-terminal-exec` and manages `~/.config/xdg-terminals.list` as read-only configuration. Change the default through Nix and rebuild rather than using the DMS GUI's terminal selector; the pinned DMS GUI tries to write the same file. Other DMS state/settings files remain writable.

The baseline `Mod+T` runs `xdg-terminal-exec`. Applications using this launcher follow the default terminal list; applications reading `$TERMINAL` follow the session environment. Explicit `kitty` or `alacritty` commands still open the named application. After changing the default, rebuild and log out/in to refresh the Niri/DMS environment.

Alacritty uses JetBrainsMono Nerd Font Mono at size 12, 12 px padding, 0.9 opacity, hidden decorations, 3000 lines of scrollback, and a block cursor blinking every 1000 ms. `Ctrl+Shift+N` opens a new window; `Ctrl++`, `Ctrl+-`, and `Ctrl+0` control font size. Kitty tabs and its `Ctrl+T` shortcut remain in Kitty; the terminals do not have identical features.

Alacritty and Kitty start `globals.defaultShell` directly with `--login`. [TUIOS starts manually](#manual-tuios-sessions) when requested from that shell. Colors are imported from `~/.config/alacritty/dank-theme.toml`, which is copied only if absent and can then be updated by DMS. The pinned DMS Alacritty template is enabled by default; if previously disabled through the GUI, enable it again in DMS theme settings. `runDmsMatugenTemplates` and `matugenTemplateAlacritty` remain GUI preferences. Do not add colors directly to the main configuration because they would override the imported file.

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

## Manual TUIOS sessions

TUIOS remains installed for `kaede` from pinned nixpkgs (0.10.0 when added). Kitty and Alacritty open the selected normal login shell; TUIOS has no automatic startup hook, alias, or desktop shortcut. Explicit terminal commands continue to work normally.

Run `tuios new` to create a persistent session when wanted. Detach with `Ctrl+B`, then `d` to return to the invoking shell while the session stays running; quit with `Ctrl+B`, then `q` to end the session. Use `tuios ls` to list sessions and `tuios attach NAME` to return to one. The old `KAENIX_TUIOS_DISABLE` variable is no longer needed.

TUIOS preferences, history, and session data remain writable under its normal XDG locations. Removing automatic startup does not stop an existing daemon or delete sessions. Pane shells retain the daemon's environment and any user-configured preferred shell; rebuilds do not replace running sessions. See the [pinned session documentation](https://github.com/Gaurav-Gosain/tuios/blob/v0.10.0/docs/SESSIONS.md) for persistence and recovery behavior.

After rebuilding with `sudo nixos-rebuild switch --flake path:/home/kaede/Kaenix#syrup`, reopen Kitty and Alacritty and verify normal shell startup in new windows and Kitty tabs. Run `tuios new` manually, then test detach and reattach. These GUI and persistence checks require the activated target session.

## btop, Helix, and Yazi

`parts/features/apps/btop.nix`, `helix.nix`, and `yazi.nix` enable each Home Manager program module, which installs its package and manages its configuration. btop uses its built-in `TTY` colors with a transparent background. Helix uses `base16_transparent`, relative line numbers, and color-coded modes; its `defaultEditor` option sets `EDITOR` and `VISUAL` to `hx`. Yazi sorts names naturally with directories first and leaves other behavior, including hidden-file visibility, at its default. No theme packages, plugins, or language servers are added.

Yazi's `y` wrapper is enabled for Fish and Nushell. It changes the shell's working directory to Yazi's final directory when the file manager exits. Edit the owning feature module and rebuild to change these managed configurations. Validate generated configuration and executable versions with `nix build --no-link path:.#checks.x86_64-linux.terminal-apps`; `shells` checks that both shell integrations load.

## Choosing Nushell or Fish

`globals.defaultShell` in `flake.nix` accepts `"nushell"` or `"fish"`. Nushell is the initial default. The user's login shell, Alacritty, and Kitty share this selection; other values produce an evaluation error explaining the valid choices. Both shells remain enabled and listed in `/etc/shells`; this selection is independent of `globals.defaultTerminal`.

After changing the selection, rebuild and open a new terminal window. Log out/in so the login shell and `$SHELL` in the new session follow the selection. Existing terminal sessions are not replaced automatically. For a checkout containing new unstaged files, use:

```bash
sudo nixos-rebuild switch --flake path:/home/kaede/Kaenix#syrup
```

`fish` or `nu` opens a nested shell; `exit` returns to the previous shell. `exec fish` or `exec nu` replaces the current shell process without changing the Nix default. Avoid using `chsh` for permanent settings because NixOS manages the user's shell.

Starship and eza are managed by the shared `parts/features/shell/common.nix` module; the prompt theme is in `config/starship.toml`. Starship integration is enabled for both shells. Fastfetch runs once per interactive startup; noninteractive commands print no greeting. Nushell disables its default banner and uses OSC 7/133 for the working directory and Kitty prompt markers.

Fish aliases still use eza for `ls`. Nushell keeps its built-in `ls` so pipelines such as `ls | where type == file` operate on tables; use `ll` for eza output. The two shells' histories are not merged. No additional external completion plugin or framework is installed.

`login.nu` runs noninteractive Bash to read `/etc/profile` and Home Manager's generated `hm-session-vars.sh` package. The `scripts/import-login-env.nu` helper reads NUL-separated environment values, preserves `=` signs/newlines, and converts PATH to a Nushell list. Working-directory variables and process metadata do not replace Nushell state. A profile-reading failure produces an error rather than a partial environment.

Nushell configuration is Nix-managed and read-only; edit its module and rebuild. History remains writable. Run validation with `nix build --no-link path:.#checks.x86_64-linux.shells`; the `tests/evaluate.nix` fixture accepts `defaultShell` to evaluate both choices without activation.

## DMS calendar and the khal build workaround

The pinned DMS module enables calendar event integration through `khal` by default. `parts/features/desktop/dms.nix` adds a NixOS overlay specifically for `khal`, with `sphinxBuilders = "html man"`. The pinned Sphinx hook reads the structured-attributes array as a single initial value, so the `[ "html" "man" ]` list only generates HTML and the build fails because the `man` output is missing. The string runs both builders without changing the package version/source or disabling the calendar.

This workaround applies to pinned nixpkgs `09063bd1f2b36fd9fd793c36dfade7bd40a93dfc`. After updating nixpkgs, recheck Sphinx hook compatibility before keeping or removing the override. Test the `khal` build and its manual output; successful evaluation alone does not prove the issue is resolved.

## Writable files and one-time seeding

`kaenix.seedFiles` runs `scripts/seed-files.py` after Home Manager linking and before systemd reload. Nix provides the Python interpreter; global Python is unnecessary. The manifest comes from the Nix store; all 17 seed targets are relative to the user's home.

| Target | Initial source | Owner after activation |
| --- | --- | --- |
| `~/.config/dms/settings.json` | `config/dms/settings.nix` | DMS GUI |
| `~/.config/dms/plugin_settings.json` | `parts/features/desktop/dms.nix` | DMS plugin GUI |
| `~/.local/state/dms/session.json` | Minimal state without launcher history | DMS |
| `~/.config/dms/themes/catppuccin/theme.json` | `config/dms/catppuccin.json` | DMS |
| `~/.config/niri/dms/*.kdl` | `config/niri/dms/` | DMS/user |
| `~/.config/kitty/dank-*.conf` | `config/kitty/` | DMS theme generator |
| `~/.config/alacritty/dank-theme.toml` | `config/alacritty/dank-theme.toml` | DMS theme generator/user |
| `~/.config/OpenTabletDriver/settings.json` | `config/opentabletdriver/settings.json` | OpenTabletDriver GUI |

Changing a baseline does not replace existing active files, including empty files or symlinks. To reapply one baseline, stop the relevant application, move its active file to a unique backup, then rebuild. Do not move the entire DMS directory because Home Manager manages plugin sources.

The pinned DMS revision `9b413296b16721f7679fb62e624cb1ed2433fa58` [migrates its config, state, cache, and data directories](https://github.com/AvengeMedia/DankMaterialShell/blob/9b413296b16721f7679fb62e624cb1ed2433fa58/core/internal/utils/dirs.go) from `DankMaterialShell` to `dms`, leaving compatibility symlinks at the old names. Kaenix seeds the canonical `dms` paths and preserves existing GUI files and compatibility links. Existing theme preferences using the old path still resolve through those links; the baseline for new homes uses `dms/themes/catppuccin/theme.json`. Do not remove or replace these DMS-created links to resolve a seed failure. After correcting older Kaenix seed paths, retry `kae switch`; successful evaluation or a package build alone does not confirm Home Manager activation.

For other legacy out-of-store directory symlinks, such as `.config/niri` pointing into an old repository, back up the directory and replace the link with a regular directory before seeding. The helper continues to refuse writes through symlinked parent directories. If the canonical `dms` directory is itself a symlink, inspect its ownership and target before choosing a migration; the compatibility-link case above assumes `dms` is a regular directory.

NixOS generation rollback restores declarative configuration and plugin sources but not GUI state. Back up writable state separately to roll back appearance or tablet area.

## Bringing GUI changes back into the repository

For selected preference imports, use [Kaenix GUI Baseline](../.agents/skills/kaenix-gui-baseline/SKILL.md), for example `$kaenix-gui-baseline save my selected DMS preferences as repository defaults`.

Export DMS settings with `dms ipc call settings dump`, then translate the desired baseline values into `config/dms/settings.nix`. Do not copy other users' absolute paths, search history, or credentials.

Niri fragments, Kitty themes, and tablet profiles can be copied back to their respective baseline locations after review. `fish_variables` is unnecessary: the module manages the Fish prompt and plugins.

Plugins are pinned in flake inputs. The GUI can change settings, but plugin code must be updated/removed through Nix; see [updating flake inputs](#updating-flake-inputs).

## Kaenix management with kae

`kae` is a standalone Nushell command installed for `kaede` through the centralized user package list. `scripts/kae.nu` owns the logic; `lib/kae.nix` supplies pinned executables and a Nu interpreter that runs without user configuration. The same derivation is exposed as `packages.x86_64-linux.kae`.

| Command | Operation |
| --- | --- |
| `kae`, `kae help`, `kae --help` | Show commands; use `kae help gc` or `kae gc --help` for command help |
| `kae check` | Evaluate the flake without building checks |
| `kae test [checks...]` | Discover available checks, validate names, and build selected checks or all checks by default |
| `kae build` | Build `syrup` through `nom` with monitored progress, without activation; leave `result` in the checkout |
| `kae switch` | Build and activate `syrup`, elevating activation operations through sudo |
| `kae update [inputs...]` | Update all flake inputs by default, or only named inputs; intentionally write `flake.lock` |
| `kae gc` | Collect unreachable store paths while retaining generations |
| `kae gc --older-than 14d` | Prune profiles and collect garbage as the user, then through sudo for system/root profiles |
| `kae optimize` | Deduplicate identical store files with `nix store optimise` |
| `kae fmt [paths...]` | Run the flake's Nix formatter on the whole repository or selected paths |
| `kae fmt --check [paths...]` | Check formatting without modifying source files |

Commands work from any directory. The default checkout is `/home/kaede/Kaenix`; override it with `KAE_REPO` (for example, `with-env {KAE_REPO: "/path/to/checkout"} { kae check }` in Nu). Relative formatting paths are relative to that checkout. Help, garbage collection, and optimization do not require a checkout. Repository flake operations use `path:` references to include untracked files. Only `kae update` intentionally writes the lockfile; other operations preserve it. Each invocation runs only the requested operation and preserves its failure status.

General help lists command forms, checkout defaults, and the `KAE_REPO` override. Both `kae help COMMAND` and `kae COMMAND --help` explain arguments, flags, defaults, effects, and examples in Nu's generated layout. Examples are documentation only: help never executes them and works without a checkout. For example, use `kae help test` to see all-check and selected-check forms, `kae help gc` for generation retention/pruning, and `kae help fmt` for whole-repository, selected-path, and read-only modes.

`kae update` wraps `nix flake update --flake path:REPOSITORY`. Use `kae update nixpkgs` for one input or `kae update nixpkgs dms` for multiple inputs; Nix validates names and resolves required dependency updates. Run it without sudo. It does not automatically check, build, or activate the result. Input declarations, release lines, and exact commit pins remain unchanged; see [updating flake inputs](#updating-flake-inputs) for pin handling and review guidance.

`kae fmt` uses the existing flake formatter, currently pinned `nixfmt-tree`. Its `--ci` flag alone rewrites files before reporting differences, so `kae fmt --check` directly uses a pinned variant of the same package with `nixfmt --check` configured. If the flake formatter is replaced or customized, update this variant alongside it. Formatting covers Nix files, not the Nu script.

The `--older-than` value must be a positive number of days, such as `14d`. Pruning follows Nix's profile discovery and retention rules; deleting generations removes their rollback capability. User cleanup must succeed before system/root cleanup begins; if the second operation fails, user cleanup has already happened. Default `kae gc` does not prune generations. Existing weekly 14-day garbage collection and automatic store optimization remain configured separately.

Before activation, inspect the command from any directory with its absolute flake path. A relative `path:.` refers to the current directory, so use it only from the Kaenix repository root:

```bash
nix run --no-update-lock-file path:/home/kaede/Kaenix#kae -- help
```

Install the command into the active user environment with the usual explicit rebuild: `sudo nixos-rebuild switch --flake path:/home/kaede/Kaenix#syrup`. Thereafter, run `kae` normally; only activation and explicit system/root pruning request sudo. The [validation guide](VALIDATION.md#repeatable-checks) describes the isolated command check and its evidence limits.

## Updating flake inputs

For command-line lockfile updates, use `kae update` for all inputs or `kae update nixpkgs dms` for selected inputs. Review the resulting diff and run relevant validation before choosing to activate it.

Use [Kaenix Update](../.agents/skills/kaenix-update/SKILL.md), for example `$kaenix-update update dms and review compatibility`, for selected inputs or an explicitly requested full update. The skill owns the review/update procedure and compatibility-fix boundaries; activation remains separate.

Preserve input release lines and shared nixpkgs relationships. The `cat-widget` and `mpvpaper-plugin` declarations pin exact commits: verify and change the intended commit before refreshing the selected lock entries. A lockfile refresh alone does not advance those declared pins. Reassess affected workarounds, including the [khal override](#dms-calendar-and-the-khal-build-workaround), and distinguish passing configuration checks from real-session plugin compatibility. Vendored mpv/PlayKit assets follow their separate [update guidance](../config/mpv/UPSTREAM.md#attribution-and-updates).

## Commit-message standard

Use [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/) for future commits:

```text
type(scope): short description

Optional explanation of why the change was needed.

Optional footers.
```

The scope is optional; use a relevant area such as `git`, `skills`, `dms`, `niri`, `mpv`, or `deps`. Write descriptions in English, using an imperative verb and no final period. Aim for a subject of 72 characters or fewer, prioritizing clarity. Add a body when context, migration steps, or validation limits need explanation.

| Type | Purpose | Example |
| --- | --- | --- |
| `feat` | New capability | `feat(git): add repository workflow skill` |
| `fix` | Correct a defect | `fix(dms): preserve existing writable settings` |
| `docs` | Documentation changes | `docs(git): define commit-message conventions` |
| `refactor` | Restructure without changing behavior | `refactor(skills): centralize shared guidance` |
| `test` | Add or improve tests | `test(seed): cover existing symlink preservation` |
| `build` | Dependencies or build configuration | `build(deps): update Home Manager input` |
| `chore` | Other repository maintenance | `chore: remove obsolete development artifacts` |

Use `ci`, `style`, or `perf` when those accurately describe the change. These type choices and writing guidelines are Kaenix conventions within the upstream format. For an actual incompatible change, append `!` immediately before the colon, as in `feat(niri)!: rename legacy bindings`, and include a `BREAKING CHANGE:` footer explaining the impact and any required migration.

For an authorized commit request without a narrower file selection, review and include all pending staged, unstaged, and untracked changes. Honor explicit file selections or staged-only requests. Keep ignored files ignored and exclude credentials/private data. Do not automatically split commits; describe their main purpose in the subject and explain additional changes in the body. Preserve an exact message supplied by the user, even when it overrides this default format.

Use descriptive subjects for ordinary commits instead of version-only titles. Keep release/version changes explicit: this convention does not authorize automatic version bumps, tags, releases, commits, or pushes. Apply it to future commits without rewriting existing history. This is guidance only; no hooks, commitlint dependency, or Git configuration enforcement are installed. [Kaenix Git](../.agents/skills/kaenix-git/SKILL.md) uses this section as the canonical standard.

## Git repository workflow

Use [Kaenix Git](../.agents/skills/kaenix-git/SKILL.md), for example `$kaenix-git commit and push the pending changes`, for requested inspection, staging, commits, pushes, fetches, branch creation/switching, and fast-forward synchronization. The skill owns the operation and verification procedure; the [commit-message standard](#commit-message-standard) owns message conventions and default commit scope. Inspection does not authorize publication. Diverged histories, destructive operations, pull requests, and releases require a separate workflow; existing authentication stays configured as described below.

## GitHub CLI authentication

Git is managed by Home Manager, so `~/.config/git/config` is a read-only symlink to the Nix store. `gh auth login` can complete browser authentication but fail at the final step when attempting to write the credential helper to that file.

`parts/features/shell/git.nix` declares the `gh auth git-credential` helper for GitHub and Gist, including resetting the helper list before selecting the GitHub CLI helper. Tokens are not stored in Nix configuration. The `gh` configuration and accounts remain writable and are not managed through `programs.gh`.

After rebuilding, check:

```bash
gh auth status
git config --get-all 'credential.https://github.com.helper'
```

If the account is already authenticated, there is no need to sign in again or run `gh auth setup-git`. For a new `gh auth login`, choose **No** when asked whether to configure Git with GitHub CLI credentials; the helper is already declared. Avoid `git config --global` for Nix-managed settings; edit `programs.git.settings` and rebuild.

The `wl-clipboard` package provides `wl-copy`/`wl-paste` for copying login codes in a Wayland session. Check browser login results with `gh auth status`.

## Monitoring Nix builds

`pkgs.nix-output-monitor` is installed through `home.packages` in `parts/features/packages.nix`, from pinned nixpkgs. There is no new flake input or replacement alias for Nix commands.

The `packages.x86_64-linux.default` output in `parts/outputs.nix` points to the existing `syrup` system derivation. From the repository root, plain `nom build` or `nix build` builds that full system and creates the `result` symlink without activation or sudo. To explicitly include untracked sources and preserve the lockfile, use:

```bash
nom build --no-update-lock-file path:.
```

The running system stays unchanged until a separate activation through `kae switch` or `nixos-rebuild switch`. The management CLI remains available as `.#kae`. `kae build` uses the pinned `nom` executable with an explicit system target for its configured host, preserves the lockfile, and places `result` in the selected checkout even when invoked elsewhere. `kae switch` continues to use `nixos-rebuild switch` with sudo elevation for activation.

After rebuilding, user `kaede` can use `nom`, `nom-build`, and `nom-shell` from Nushell or Fish. Check installation with `nom --version`. From the repository root, view build progress, downloads, and dependency trees with:

```bash
nom build --no-link path:.#checks.x86_64-linux.shells
```

`nom build` wraps `nix build`; `nom-build` and `nom-shell` wrap the legacy `nix-build`/`nix-shell` commands. `nixos-rebuild` does not automatically use the monitor: pipe its stdout/stderr to `nom` using the current shell's syntax. JSON mode uses `--log-format internal-json -v` on Nix and `nom --json` on the monitor; see the [upstream guide](https://github.com/maralorn/nix-output-monitor#running).

## Formatting Nix code

`pkgs.nixfmt` is installed through `home.packages` in `parts/features/packages.nix`, using pinned nixpkgs without a new flake input or lockfile change. After rebuilding, `nixfmt` is available from Nushell and Fish.

The `formatter.x86_64-linux` output in `parts/outputs.nix` uses `nixfmt-tree` from the host's package set. `nix fmt` is available before system activation. From the repository root:

```bash
# Format one file
nixfmt parts/features/packages.nix

# Format every Nix file in the project
nix fmt

# Format only selected files
nix fmt -- parts/features/packages.nix parts/features/apps/kitty.nix
```

These commands write changes to files. No Git hook or editor format-on-save setting is installed. Format only the files being changed to limit the diff; formatting the entire repository remains an explicit action. See the [upstream guide](https://github.com/NixOS/nixfmt#installation).

## WhatsApp and Discord

Official Discord is installed through `home.packages` in `parts/features/packages.nix`, without mods or autostart. WhatsApp uses Brave without a separate client. Accounts, login sessions, and preferences remain writable outside the repository.

## mpv and video defaults

`parts/features/apps/mpv.nix` enables mpv through Home Manager and makes it the video default. Configuration, controls, writable state, asset provenance, and validation are covered in the [mpv_PlayKit main guide](MPV.md).

## Audio settings

Pavucontrol and EasyEffects are installed through `home.packages` in `parts/features/packages.nix`. PipeWire and PulseAudio compatibility are configured in `parts/features/services/audio.nix`. EasyEffects presets remain GUI-selected and writable; the repository enables no additional EasyEffects autostart or service.

Keep physical speakers/headsets/microphones as the default devices; do not select EasyEffects virtual devices as the defaults. This follows [upstream guidance](https://github.com/wwmm/easyeffects).

## Steam gaming

`parts/features/apps/steam.nix` configures Steam, Protontricks, Gamescope, and GameMode. See the [Steam gaming guide](steam.md) for first launch, ProtonPlus, overlays, per-game launch options, and runtime verification.

## GPU and applications

Niri uses the AMD render node at PCI `0000:05:00.0`. NVIDIA at `0000:01:00.0` is available for selected applications:

```bash
nvidia-offload 'osu!'
```

The NVIDIA VA-API driver is not forced for all applications. If display connector names change after migration, select the wallpaper monitor again in mpvpaper settings; the seed currently uses `eDP-2` from CachyOS.

DMS uses one user service, `dms.service`; automount uses `udiskie.service`. The NixOS module provides `opentabletdriver.service` as a user unit, so it does not appear among Home Manager services. Base Niri contains no `spawn-at-startup` for DMS or OpenTabletDriver; DMS provides the Polkit agent.
