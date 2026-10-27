# Configuration backup checklist

Updated: 27 October 2026. This checklist covers Kaenix dotfiles and desktop
settings to preserve before migrating to Arch Linux, and for future backups.
Paths were checked on this date; recheck them before each backup. An unchecked
item is a reminder, not evidence that a backup exists.

## Configuration sources

- [ ] `/home/kaede/Kaenix/` — copy the complete working directory, including
  `.git/`, hidden files, `flake.lock`, `modules/`, `config/`, `scripts/`,
  `collection/`, documentation, and uncommitted/untracked/ignored files.
- [ ] `/home/kaede/Projects/mpv-configs/` — preserve the separate mpv source
  repository, including its hidden files and local changes.

A Git clone alone does not preserve uncommitted or untracked files. Keep these
sources even when also exporting the active application configs below: some
settings are declared in Nix rather than stored as plain dotfiles in this repo.

## Current desktop settings

These live files can contain GUI changes newer than the repository baselines.

- [ ] `/home/kaede/.config/dms/` — DMS settings, plugin settings, plugins, and themes.
- [ ] `/home/kaede/.local/state/dms/` — DMS session state.
- [ ] `/home/kaede/.config/niri/` — main config and writable `dms/` fragments.
- [ ] `/home/kaede/.config/mango/` — main config and writable `dms/` fragments.
- [ ] `/home/kaede/.config/kitty/` — terminal config, `dank-theme.conf`, and
  `dank-tabs.conf`.
- [ ] `/home/kaede/.config/alacritty/` — terminal config and `dank-theme.toml`.
- [ ] `/home/kaede/Pictures/Wallpapers/` — wallpaper images and videos.
- [ ] `/home/kaede/.config/mimeapps.list` — selected default applications.
- [ ] `/home/kaede/.config/xdg-terminals.list` — selected default terminal.
- [ ] `/home/kaede/.config/user-dirs.dirs` — personal folder locations.
- [ ] `/home/kaede/.config/gtk-3.0/` — GTK 3 appearance settings.
- [ ] `/home/kaede/.config/gtk-4.0/` — GTK 4 appearance settings.

Use the canonical `dms` directories above. Older `DankMaterialShell` paths may
only be compatibility symlinks. DMS also writes compositor fragments and terminal
themes outside its own directory, so the DMS directory alone is insufficient.

## Shell and CLI application settings

- [ ] `/home/kaede/.config/fish/` — shell config, functions, and plugin integration.
- [ ] `/home/kaede/.config/nushell/` — shell config, environment, and login scripts.
- [ ] `/home/kaede/.config/starship.toml` — prompt settings.
- [ ] `/home/kaede/.config/fastfetch/` — settings and custom artwork.
- [ ] `/home/kaede/.config/yazi/` — file manager settings.
- [ ] `/home/kaede/.config/helix/` — editor settings.
- [ ] `/home/kaede/.config/btop/` — system monitor settings.
- [ ] `/home/kaede/.config/mpv/` — player config, scripts, script options, and assets.
- [ ] `/home/kaede/.config/git/` — Git settings; review the credential-helper path
  when adapting to Arch.

## Optional application settings and custom assets

Back up the items you use and want to retain.

- [ ] `/home/kaede/.config/obs-studio/` — scenes, profiles, and settings.
- [ ] `/home/kaede/.config/zed/` — editor settings.
- [ ] `/home/kaede/.config/MangoHud/` — gaming overlay settings.
- [ ] `/home/kaede/.config/goverlay/` — overlay tool settings.
- [ ] `/home/kaede/.config/udiskie/` — removable-drive settings.
- [ ] `/home/kaede/.local/bin/` — personal launchers and scripts; inspect links and
  Nix-specific wrappers before reuse.
- [ ] `/home/kaede/.local/share/icons/` — custom icons and cursors.

## NixOS-to-Arch portability

Several active configs are symlinks into `/nix/store`, including the main Niri,
Mango, Kitty, Alacritty, Fish, Nushell, Git, and mpv configs, plus Starship and
user-directory settings. Some Fish/mpv assets, DMS plugins, and a wallpaper are
also store-linked. Preserving only those links will not preserve usable contents
after removing NixOS.

- [ ] Keep an original backup that preserves symlinks and Linux metadata.
- [ ] Prepare a separate portable export containing actual file contents and
  assets for the selected Nix-managed files. Inspect link targets deliberately;
  do not blindly dereference every link in the home directory.
- [ ] Review exported files for `/nix/store/`, `/run/current-system/`,
  `/etc/profiles/`, and Home Manager startup hooks. Adapt executable paths,
  shell login setup, plugin loading, and service integration for Arch.
- [ ] Record the applications, fonts, themes, and plugins needed by the exported
  configs. Use the Kaenix modules and lockfile as references; dotfiles alone do
  not install those dependencies.

## Before considering the backup complete

- [ ] Choose a private destination outside this repository and confirm that the
  intended external drive is actually mounted, if using one.
- [ ] Use a new dated backup name; preserve earlier copies.
- [ ] Close relevant applications and stop DMS before the final settings copy so
  the selected files are not being rewritten during backup.
- [ ] Preserve Linux permissions, timestamps, and symlinks. For exFAT/NTFS, use
  an archive that records Linux metadata rather than relying on a plain copy.
- [ ] Verify selected-file coverage, regular-file checksums, symlink targets,
  and archive readability. A successful copy or archive checksum alone does not
  establish that all selected source files were captured.
- [ ] Keep the backup until recovery has been verified. Restore selectively,
  with the relevant applications stopped and existing destination files saved.

This is a configuration checklist, not a complete personal-data backup. Game
data, documents, browser profiles, credentials, and chat histories require their
own explicit selection. See [the backup guide](docs/BACKUP.md) for existing
selections and backup procedures. This document does not create a backup or
record a completed copy.
