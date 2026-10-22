---
name: kaenix-gui-baseline
description: "Save selected GUI preferences as Kaenix repository baselines for DMS, Niri, terminal themes, or OpenTabletDriver. Use when bringing GUI changes or settings exports back into the configuration; not for installing applications, updating plugin code, or applying settings to the active session."
---

# Kaenix GUI Baseline

## Establish the requested change

Follow [shared context loading](../../../AGENTS.md#understand-the-context-first)
and the relevant parts of
[configuration ownership](../../../docs/CONFIGURATION.md#bringing-gui-changes-back-into-the-repository).

Identify the application, selected preferences, and source: a supplied export,
relevant live settings, or values described by the user. Ask only if missing scope
or values would change the result. A request to save GUI preferences authorizes
repository baseline changes, not a reset of the live home or system activation.

For DMS, use the documented `dms ipc call settings dump` export when available.
Capture broad exports privately in a temporary file and inspect only the requested
properties; do not print entire exports or unrelated settings. If the command is
unavailable, use a supplied export or relevant settings file. If no usable source
exists, explain what is missing and request the needed values/export rather than
inventing a baseline. Continue independent work that does not need those values.

## Find the actual repository owner

Inspect relevant modules, configuration assets, `kaenix.seedFiles` declarations,
and `scripts/seed-files.py`. Use the current implementation rather than assuming
that a GUI file maps directly to a repository file. This table gives starting
points; verify the mapping before editing.

| Selected preference | Repository owner to inspect |
| --- | --- |
| DMS settings | `config/dms/settings.nix`, generated and seeded by `parts/features/desktop/dms.nix` |
| DMS plugin preferences | `pluginSettings` in `parts/features/desktop/dms.nix`; plugin code remains pinned in flake inputs |
| DMS-written Niri fragments | Corresponding files in `config/niri/dms/`, seeded by `parts/features/desktop/niri.nix` |
| Kitty theme or tab colors | Corresponding files in `config/kitty/`, included and seeded by `parts/features/apps/kitty.nix` |
| Alacritty theme colors | `config/alacritty/dank-theme.toml`, imported and seeded by `parts/features/apps/alacritty.nix` |
| OpenTabletDriver preferences | Selected fields in `config/opentabletdriver/settings.json`, seeded by `parts/features/hardware/tablet.nix` |

Distinguish a writable seed from declarative Home Manager configuration and
transient application state. Non-theme terminal preferences belong in the owning
terminal module; shell/default terminal choices follow the existing globals.
Base Niri configuration is distinct from DMS-written fragments. Do not introduce
another writer or a seed that competes with an existing declarative setting.

## Apply only the selected baseline differences

Compare the requested properties with their current baselines and edit only the
relevant fields or lines. If they already match, report that no change is needed.
Do not replace whole files or reserialize unrelated content merely because an
export contains more settings than requested.

- Convert selected DMS JSON values to the existing Nix attribute structure,
  preserving types and unrelated attributes. Preserve existing Nix merges,
  externally managed fields, and `${configHome}` expressions.
- For plugin preferences, preserve wallpaper/home expressions and intentional
  monitor mappings. Translate requested paths into the repository's existing
  parameterized form where applicable, rather than embedding an exported home
  path. Do not alter plugin sources, commits, or the lockfile.
- For Niri, update the matching fragment and preserve unrelated bindings,
  commands, and outputs. Do not copy the entire generated configuration over the
  declarative base.
- For generated terminal themes, keep their writable seed/import arrangement.
  Check where DMS generates the theme and whether a main-configuration override
  would mask it. Explain that DMS may regenerate the active colors; saving a seed
  does not freeze the generator or current theme.
- For tablet profiles, preserve unrelated device/plugin configuration and edit
  only the requested area, rotation, or other preferences. Keep hardware-specific
  values needed for the selected profile; exclude unrelated machine-specific
  paths or settings.

Exclude credentials, account data, search/launcher/clipboard histories, and
transient session state from imports. Preserve deliberately minimal session
baselines instead of replacing them with a live session dump. Do not invent
properties or silently convert missing values into defaults.

Keep user-managed files writable. Do not replace seeds with read-only store
symlinks or change the seed helper to overwrite existing targets. Update relevant
local documentation and the changelog for the actual baseline changes, following
project ownership rules.

## Validate and explain application separately

Use the existing [Kaenix Validate](../kaenix-validate/SKILL.md) skill to select
checks for the affected files and consumers. Check selected export syntax/types
where relevant; follow [the validation guide](../../../docs/VALIDATION.md) if the
validation skill is unavailable. Do not duplicate its check inventory here.

Report the selected preferences, source, repository owners changed, checks
actually run, and any remaining runtime verification.

Explain whether a change affects declarative configuration or only a seed for
absent targets. A rebuild does not replace an existing seed target, including an
empty file or symlink. Repository changes alone do not prove the active GUI has
changed.

When existing homes need the new baseline, provide targeted migration steps:
stop the relevant writer, back up only the affected writable file to a unique
name, and apply or merge the selected changes while retaining other preferences.
Re-seed a whole file only when intentionally resetting that file to its baseline;
explain any loss of other preferences first. Do not replace entire application
or DMS directories. A parent directory symlink requires separate handling before
seeding; do not follow it into an old checkout.

Saving a baseline does not execute these live migration steps. Changes to active
settings, service restarts, or activation require explicit instructions for those
actions within the current task. NixOS rollback does not restore writable GUI
state; retain the relevant backup if live migration is later requested.
