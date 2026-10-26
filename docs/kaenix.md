# Kaenix — project context and local documentation

Updated: 26 October 2026. Kaenix is a personal NixOS configuration for host `syrup`, user `kaede`, platform `x86_64-linux`, and time zone `Asia/Jakarta`, located at `/home/kaede/Kaenix`.

## Purpose and documentation ownership

Follow [AGENTS.md](../AGENTS.md#understand-the-context-first) for context loading, ownership, and action boundaries. Use the task routes below to select relevant sections and implementation. For routine use, see the [public README](../README.md).

## Active guides

| Task | Guide and implementation |
| --- | --- |
| Modules, bundles, packages, boot splash, and system memory/I/O policy | [Configuration ownership](CONFIGURATION.md#modules-by-category), [ZRAM, VM memory, and I/O scheduling](CONFIGURATION.md#zram-vm-memory-and-io-scheduling); `modules/bundles/`, leaf categories, `modules/packages.nix`, `modules/system/boot.nix`, `modules/system/base.nix`, and `modules/hosts/syrup.nix` |
| Kaenix management, monitored builds, updates, and help | [kae](CONFIGURATION.md#kaenix-management-with-kae); `scripts/kae.nu`, `lib/kae.nix` |
| User defaults and host identity | [Ownership and metadata](CONFIGURATION.md#dendritic-features-and-flake-outputs); `modules/users/kaede.nix`, `modules/hosts/syrup.nix`, `installation/` |
| Home Manager file conflicts and automatic backup rotation | [Activation and conflict backups](CONFIGURATION.md#one-time-migration-after-first-activation); `modules/system/home-manager.nix` |
| Persistent GUI app and terminal defaults | [DMS default applications](CONFIGURATION.md#default-applications-managed-through-dms); `modules/system/home.nix`, `modules/desktop/niri.nix` |
| Flake structure and dendritic features | [Feature registration and host selection](CONFIGURATION.md#dendritic-features-and-flake-outputs); `flake.nix`, host → bundle → feature wiring under `modules/` |
| Default system builds and build monitoring | [Default build target and nom](CONFIGURATION.md#monitoring-nix-builds); `modules/outputs.nix` |
| Documentation lookup and version support | [Kaenix Docs](../.agents/skills/kaenix-docs/SKILL.md); relevant pinned sources, overrides, and vendored provenance |
| Git workflow, conventions, and authentication | [Kaenix Git](../.agents/skills/kaenix-git/SKILL.md), [commit-message standard](CONFIGURATION.md#commit-message-standard), and [GitHub authentication](CONFIGURATION.md#github-cli-authentication) |
| Terminal and shell selection | [Terminal](CONFIGURATION.md#choosing-alacritty-or-kitty), [shell](CONFIGURATION.md#choosing-nushell-or-fish), and [binding migration](CONFIGURATION.md#existing-terminal-binding-migration); `modules/users/kaede.nix`, assembled globals, `modules/shell/`, `modules/apps/`, and `modules/apps/kitty.nix` |
| Manual TUIOS sessions | [TUIOS](CONFIGURATION.md#manual-tuios-sessions); package in `modules/packages.nix` |
| Nix package and option search | [ns wrapper and nix-search-tv with fzf](CONFIGURATION.md#nix-package-and-option-search); packages in `modules/packages.nix` |
| Terminal utilities | [btop, Helix, and Yazi](CONFIGURATION.md#btop-helix-and-yazi); `modules/apps/` and `modules/shell/common.nix` |
| Niri and MangoWM sessions, DMS path migration, and GUI baselines | [Desktop sessions](CONFIGURATION.md#niri-and-mangowm-sessions), [Mango brightness migration](CONFIGURATION.md#existing-home-mango-brightness-migration), [writable settings and DMS path migration](CONFIGURATION.md#writable-files-and-one-time-seeding); `modules/desktop/`, `config/`, `modules/system/seed-files.nix`, `scripts/seed-files.py` |
| Scheduling and input updates | [LAVD](CONFIGURATION.md#lavd-cpu-scheduling) and [flake updates](CONFIGURATION.md#updating-flake-inputs); `modules/services/scx.nix`, `flake.nix` |
| Removable-media automount and udiskie build failures | [Automount and the udiskie test workaround](CONFIGURATION.md#removable-media-automount-and-the-udiskie-test-workaround); `modules/services/automount.nix` |
| Image viewing, audio, video, and gaming | [Loupe, OBS Studio, and package lists](CONFIGURATION.md#centralized-package-lists), [Global low-latency audio](CONFIGURATION.md#global-low-latency-tuning), [Steam](steam.md), and the `mpv-configs` flake input; `modules/packages.nix`, `modules/services/audio.nix`, and owning modules in `modules/apps/` |
| Validation, reviews, and debugging | [Validation](VALIDATION.md); `tests/` and the linked project skills |
| Reinstallation or another device | [Migration](MIGRATION.md); `installation/`, `modules/hosts/syrup.nix`, and `modules/users/kaede.nix` |
| Backups and recovery guidance | [Backup](BACKUP.md); selected repository and writable user data |

Agent guidance is checked with [behavioral scenarios](../tests/agents/README.md); the review skill owns the [documentation checklist](../.agents/skills/kaenix-review/SKILL.md#documentation-and-comment-checklist).
Scenarios include scoped validation context, partial staging, root lock-graph
research, exact-pin updates, external mpv ownership, and Mango baseline imports;
see [agent validation](VALIDATION.md#agent-behavioral-scenarios).

## Documentation storage

See [AGENTS.md](../AGENTS.md#documentation-and-reporting) for documentation policy and the [changelog](../CHANGELOG.md) for dated results. [Complete working-directory backups](BACKUP.md#complete-repository-copy) include uncommitted and untracked documentation as well as Git metadata.
