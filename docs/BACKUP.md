# Backing up Kaenix and user data

Updated: 22 October 2026. The data selection follows the user's choices on 16 October, with an optional note about the Alacritty theme. The backup destination is an external hard drive. Its mount point and the success of any current copy have not been verified.

## Local backup skill

Use [Kaenix Backup](../.agents/skills/kaenix-backup/SKILL.md), for example `$kaenix-backup prepare a backup plan for my selected Kaenix data`, for its copy/verification procedure and action boundaries. Planning or verification does not authorize copying; restoration is guidance-only. Closing applications or stopping services needs authorization. Keep private backups outside the repository and preserve the selections below.

## Selected data

| Content | Source |
| --- | --- |
| Personal data | User-selected folders/files |
| All osu!lazer data, including the database | `/home/kaede/.local/share/osu/` |
| DMS settings, plugins, and themes | `/home/kaede/.config/dms/` |
| DMS state | `/home/kaede/.local/state/dms/` |
| Niri fragments written by DMS | `/home/kaede/.config/niri/dms/` |
| Kitty themes written by DMS | `/home/kaede/.config/kitty/dank-theme.conf` and `/home/kaede/.config/kitty/dank-tabs.conf` |
| Alacritty theme written by DMS (optional) | `/home/kaede/.config/alacritty/dank-theme.toml` |
| Entire repository, assets, wallpapers, lockfile, documentation, and Git metadata | `/home/kaede/Kaenix/` |

These sources are guidance, not evidence that all data has been copied. Adjust them before copying if the checkout or data locations change. Updated DMS moves the former `DankMaterialShell` directories to `dms` and leaves compatibility symlinks; back up the canonical directories containing the data, not just the old symlinks. See [DMS path migration](CONFIGURATION.md#writable-files-and-one-time-seeding).

Active terminal themes are outside the DMS directory; copy those files too if you want to preserve their colors after recovery.

## Complete repository copy

Copy the entire working directory, including hidden files and `.git/`. `docs/`, `CHANGELOG.md`, and the root `AGENTS.md` are eligible for version control; clones and `git archive` include their committed contents, but do not preserve uncommitted changes or untracked files. A complete working-directory backup preserves those files and Git metadata as well.

Keep application data, accounts, and credentials out of public repositories. Follow the repository's tracking rules for documentation; creating a local backup does not require staging or force-adding files.

## Consistency and recovery

Close osu! before the final copy to keep its database consistent. Stop DMS before the final desktop state copy. Include Niri fragments and Kitty themes because DMS writes outside its own directory.

If the destination uses exFAT/NTFS, use an archive that preserves Linux metadata and symlinks, then verify that it can be read. A completed copy command alone does not prove a successful backup.

The repository stores baselines; state backups preserve GUI changes made after seeding. Rolling back a NixOS generation does not replace backups of writable data. Restore state while the relevant applications are stopped and check file ownership before restarting them.

## Chat context and application backups

[Kaenix context and the documentation index](kaenix.md) provide the starting point for continued work. Earlier backup choices also included conversations; the old repository transcript was removed during documentation cleanup.

On 16 October, local Codex data was found at `/home/kaede/.codex/` and its application profile at `/home/kaede/.config/Codex/`; these locations have not been verified again. For a raw backup, close all application processes and copy the complete data directories, including database/WAL companion files. Keep backups that may contain authentication data or other conversations private and outside the repository. Restoring native history across versions has not been tested; signing in again may be necessary.

## Data previously excluded

Brave profiles, keyrings, active ASUS/tablet profiles, editors/scripts outside the repository, and network connections were excluded by the 16 October decision. Brave passwords/bookmarks were reported as backed up separately at that time; those copies have not been checked again. Tablet baselines and scripts within the repository remain part of the complete repository copy.

## Copy verification

- Open several personal files directly from the destination drive.
- Confirm that osu! data is complete, including the database, not just the `files/` subdirectory.
- Confirm that the repository copy contains `.git/`, `flake.lock`, `docs/`, `CHANGELOG.md`, and videos in `collection/`.
- Verify that archives can be read and keep the copies until data recovery has been verified.

This document does not perform backups or change the user's data selection.
