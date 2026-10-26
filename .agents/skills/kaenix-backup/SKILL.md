---
name: kaenix-backup
description: "Prepare, create, and verify explicitly requested backups of selected Kaenix and user data, with restoration guidance. Use for backup planning, copying, and verification; not executing restores, disk management, or configuration activation."
---

# Kaenix Backup

## Establish the requested operation and data

Follow [shared context loading](../../../AGENTS.md#understand-the-context-first)
and [the backup guide](../../../docs/BACKUP.md). If selection guidance is missing,
do not invent the user's personal data choices.

Identify whether the request is planning, creating a copy, or verifying an existing
backup. Planning and verification alone do not authorize copying data or editing
repository documentation. Use documented selections and exclusions as context,
not as permission to copy everything mentioned in an old guide. Honor the current
request and already established choices; ask only for missing source/destination
decisions that affect the task. Do not expand into unrelated personal directories.

Keep private backups and detailed manifests outside the repository. Do not print
file contents, credentials, private histories, or broad personal inventories.
Previously discussed Codex/profile paths and successful copies must be verified
again when relevant; they are historical observations, not current evidence.

This skill never executes restoration, deletes source data, prunes older backups,
formats or mounts drives, or uploads data. A backup request does not authorize
application closure, service stops/restarts, system/Home Manager activation,
logout, reboot, commit, or push. Honor explicit instructions already supplied for
needed application/service actions without asking again. Provide restoration
guidance rather than applying it even when restoration is requested.

## Verify paths and choose the copy format

Inspect only selected sources and the intended destination. Confirm source
existence, readability, size, and relevant file types, distinguishing absent
optional data from missing required data. Resolve path aliases and parent symlinks
enough to detect source/destination overlap, recursion, or an unexpected target;
do not dereference source symlinks indiscriminately.

For an external drive, verify its actual mounted filesystem and device identity
with read-only mount information, not merely the existence of a mount directory.
Check destination filesystem, permissions, available space, and applicable file
size limits. Do not create a backup beneath an absent mount or fall back silently
to the system disk. Recheck the destination before the final write if conditions
have changed. If access, space, or mount identity is unresolved, finish useful
planning/inspection and report the specific blocker.

Use a unique new directory or archive name and refuse collisions rather than
overwriting previous backups. On a filesystem that supports the required Linux
metadata, select a copy tool/mode that preserves applicable permissions,
timestamps, ownership, symlinks, and hard links. On exFAT/NTFS or when preservation
is uncertain, use an archive that records those properties, with ACLs/xattrs when
relevant. Verify tool capabilities and report any unsupported metadata. Obtain
tools from available or pinned project packages without global installation.

Preserve symlinks as links; do not copy their Nix-store targets into the backup.
Explain that a link to `/nix/store` is not a self-contained installation backup
and may need the corresponding declarative configuration rebuilt after recovery.
Do not silently follow external links into data outside the selected scope.

## Prepare complete and consistent selected sources

| Selected source | Required handling |
| --- | --- |
| Kaenix repository | Include hidden files, `.git/`, lockfile, documentation, root agent instructions, uncommitted changes, untracked/ignored files, and assets. A clone or `git archive` alone is insufficient. If Git metadata is indirect, identify what is needed to preserve the selected checkout and report any omitted external metadata. |
| osu!lazer data | Include the whole selected data directory and database, not just its `files/` subdirectory; close osu! for the final consistent copy. |
| Desktop state | Include selected DMS settings/state plus selected DMS-written Niri/Mango fragments and terminal themes outside the DMS directory; stop the relevant writers for the final copy. |
| Private application databases | Only when selected, verify current locations and include database/WAL companions as applicable; close all writers for the final consistent copy and keep the backup private. |
| Personal files | Copy only the selected folders/files; do not infer omitted personal paths from a broad home-directory scan. |

Distinguish [writable state from declarative baselines](../../../docs/CONFIGURATION.md#writable-files-and-one-time-seeding).
Keep the backup guide's excluded categories and optional Alacritty theme choice
unchanged unless the user changes the selection. Do not edit baselines or seed
targets as part of backing them up.

Determine consistency requirements before copying. Check whether writers are
already stopped; do not infer consistency solely from a successful copy command.
When closing an application or stopping a service is required but not authorized,
prepare the concrete final-copy steps and request only the needed action. If a
writer cannot be stopped from this session, provide user-run steps and complete
unaffected work. Do not claim a preliminary copy of changing data is a verified
consistent final backup. Preserve all source files and existing repository edits.

## Copy when requested and verify independently

Carry out only the authorized copy using the verified paths and format. Keep
transfers non-destructive; do not use deletion/move-source options. On interruption
or failure, preserve the source and identify the destination as partial. Do not
replace an older good backup or retry repeatedly without changed conditions.

Verify the destination against the selected source inventory: relative paths,
file types/counts, content checksums for regular files, and relevant metadata and
symlink targets. State whether verification covers all selected files or only a
sample. Detect missing files, read errors, source changes, and checksum mismatches
rather than treating equal sizes/timestamps or a zero copy exit status as proof.

For archives, check readability and entry coverage as well as available archive
integrity checks. An archive's own checksum alone does not prove its contents
match the selected sources. Prefer non-extracting inspection/content comparison;
if isolated extraction is necessary, check entry paths and link traversal first
and prevent archive-controlled writes outside a private temporary directory.
Never extract into the live home or repository for verification. Avoid opening
personal files or applications merely to verify contents when read/checksum
checks suffice.

If sources changed during verification, report the inconsistency and arrange a
consistent final copy within existing authorization. Keep copying success,
content verification, metadata preservation, and application-level recovery as
separate conclusions. Verification does not prove native application history
will restore across versions or that a complete Nix installation was captured.

## Report results and provide recovery guidance

Report the actual operation, sources included/excluded/missing, destination and
format, consistency status, checks actually performed, failures/partial results,
and remaining verification. Use concise relevant paths without exposing private
content. Do not claim a backup exists when only planning was completed.

For recovery guidance, identify the selected target data and relevant stopped
writers, recommend preserving existing destination data before replacement, and
check ownership and declarative versus writable file ownership. Do not recommend
replacing whole Home Manager-managed directories blindly. Explain that NixOS
generation rollback does not restore writable GUI state and refer to
[the migration guide](../../../docs/MIGRATION.md) when reinstallation is involved.
Do not execute restoration, activation, or application/service restarts through
this skill. Keep existing copies until recovery is independently verified.

Planning or verifying a backup does not write reports, change selections, or
update documentation unless the user requests it; when a requested report is
saved, keep private details out of repository content and respect documentation
tracking rules.
