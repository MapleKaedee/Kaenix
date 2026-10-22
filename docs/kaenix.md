# Kaenix — project context and local documentation

Updated: 22 October 2026. Kaenix is a personal NixOS configuration for host `syrup`, user `kaede`, platform `x86_64-linux`, and time zone `Asia/Jakarta`, located at `/home/kaede/Kaenix`.

## Purpose and documentation ownership

Follow [AGENTS.md](../AGENTS.md#understand-the-context-first) for context loading, ownership, and action boundaries. Use the task routes below to select relevant sections and implementation. For routine use, see the [public README](../README.md).

## Active guides

| Task | Guide and implementation |
| --- | --- |
| Modules and packages | [Configuration ownership](CONFIGURATION.md#modules-by-category); `modules/`, `modules/packages.nix` |
| Documentation lookup and version support | [Kaenix Docs](../.agents/skills/kaenix-docs/SKILL.md); relevant pinned sources, overrides, and vendored provenance |
| Git workflow, conventions, and authentication | [Kaenix Git](../.agents/skills/kaenix-git/SKILL.md), [commit-message standard](CONFIGURATION.md#commit-message-standard), and [GitHub authentication](CONFIGURATION.md#github-cli-authentication) |
| Terminal and shell selection | [Terminal](CONFIGURATION.md#choosing-alacritty-or-kitty), [shell](CONFIGURATION.md#choosing-nushell-or-fish), and [binding migration](CONFIGURATION.md#one-time-migration-after-first-activation); shared globals and `modules/shell/` / `modules/apps/` |
| Niri, DMS, and GUI baselines | [Writable settings](CONFIGURATION.md#writable-files-and-one-time-seeding); `modules/desktop/`, `config/`, `modules/system/home-manager.nix`, `scripts/seed-files.py` |
| Scheduling and input updates | [LAVD](CONFIGURATION.md#lavd-cpu-scheduling) and [flake updates](CONFIGURATION.md#updating-flake-inputs); `modules/services/scx.nix`, `flake.nix` |
| Video and gaming | [mpv](MPV.md) and [Steam](steam.md); owning modules in `modules/apps/` |
| Validation, reviews, and debugging | [Validation](VALIDATION.md); `tests/` and the linked project skills |
| Reinstallation or another device | [Migration](MIGRATION.md); installation and hardware configuration |
| Backups and recovery guidance | [Backup](BACKUP.md); selected repository and writable user data |

Agent guidance is checked with [behavioral scenarios](../tests/agents/README.md); the review skill owns the [documentation checklist](../.agents/skills/kaenix-review/SKILL.md#documentation-and-comment-checklist).

## Documentation storage

See [AGENTS.md](../AGENTS.md#documentation-and-reporting) for documentation policy and the [changelog](../CHANGELOG.md) for dated results. [Complete working-directory backups](BACKUP.md#complete-repository-copy) include uncommitted and untracked documentation as well as Git metadata.
