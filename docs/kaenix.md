# Kaenix — project context and local documentation

Updated: 21 October 2026. Kaenix is a personal NixOS configuration for host `syrup`, user `kaede`, platform `x86_64-linux`, and time zone `Asia/Jakarta`, located at `/home/kaede/Kaenix`.

## Purpose and documentation ownership

Start here, then read `AGENTS.md`, the [latest changelog](../CHANGELOG.md), the relevant guides, and the actual implementation. For routine use, see the [public README](../README.md).

Agents may update `docs/` and the changelog to reflect repository changes. Only the user may edit the root README; see `AGENTS.md` for the full rules.

English is the default language for project content and communication with the user, unless the user explicitly requests another language.

## Active guides

| Document | Purpose |
| --- | --- |
| [Kaenix context](kaenix.md) | Starting point and local documentation index |
| [Configuration](CONFIGURATION.md) | Module categories, file ownership, applications, writable GUI settings, and flake input updates |
| [mpv and PlayKit main](MPV.md) | English UI, shortcuts, optional shaders, video defaults, and writable state |
| [Validation](VALIDATION.md) | Commands, check coverage, review/validation/debugging skills, and evidence limits |
| [Reinstallation and adaptation](MIGRATION.md) | Moving the configuration to another installation or device |
| [Backup](BACKUP.md) | Selected data, the backup skill, copy verification, and recovery guidance |

## Configuration context

The configuration uses six categories and 25 features, each in one `.nix` file containing NixOS and Home Manager settings where needed. Imports are explicit; system, user, and font package lists are centralized in `modules/packages.nix`. The desktop uses Niri, DankMaterialShell, and DankGreeter, with AMD rendering and NVIDIA available through PRIME offload.

Alacritty and Nushell are selected through `globals.defaultTerminal` and `globals.defaultShell`; Kitty and Fish remain available. The 17 seed files are copied only when their targets are absent, keeping GUI settings writable. Existing `Mod+T` bindings require a [one-time migration](CONFIGURATION.md#choosing-alacritty-or-kitty).

`installation.nix` contains systemd-boot, `hardwareReady = true`, and both state versions set to `26.05`. Preserve the installation's state versions. Check the repository configuration and active generation separately; evaluation or builds do not prove GUI or hardware behavior.

## Documentation storage

`docs/`, `CHANGELOG.md`, and the root `AGENTS.md` are intended for version control and are not ignored by Git. They become part of repository history and GitHub only after being added, committed, and pushed. Include uncommitted and untracked documentation in complete working-directory backups. The changelog holds change history and dated validation results.
