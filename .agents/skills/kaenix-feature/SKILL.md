---
name: kaenix-feature
description: "Add or modify Kaenix applications, services, and configuration features using the existing package lists and NixOS/Home Manager module structure. Use for feature implementation; route validation-only requests to kaenix-validate and GUI preference imports to kaenix-gui-baseline."
---

# Kaenix Feature

## Establish scope and inspect the existing implementation

Work in the Kaenix repository containing this skill, three levels above its
directory. Read [project context](../../../docs/kaenix.md), `AGENTS.md`, the latest
`CHANGELOG.md` entries, and the relevant parts of
[configuration ownership](../../../docs/CONFIGURATION.md#modules-by-category).
Inspect staged, unstaged, and relevant untracked changes before editing; preserve
existing user work.

Identify the requested capability and check whether it is already implemented.
Read neighboring features, the category imports, package lists, and associated
assets. Extend the existing owner instead of creating a competing module. Ask
only about significant behavior or scope choices that cannot be resolved from
the request and repository.

## Choose the smallest appropriate change

| Request | Implementation |
| --- | --- |
| Install an application/tool without configuration | Add the package to the appropriate explicit list in `modules/packages.nix`; do not create a package-only feature |
| Change an existing configured application or service | Edit its existing feature file and relevant assets |
| Add a configured feature | Add one named `.nix` file in the appropriate existing category and import it explicitly from that category's `default.nix` |
| Save current GUI preferences as defaults | Use [Kaenix GUI Baseline](../kaenix-gui-baseline/SKILL.md) for the selected baseline import; add feature wiring only if the request needs it |

For explicit package lists, distinguish shared system tools, per-user applications,
and fonts using the intended consumer and existing repository patterns. Preserve
the scope of existing packages. Check whether a `programs` or `services` module
already installs the package before adding it explicitly. Module enable flags,
feature-specific package choices, drivers, and executable references stay with
their features; do not centralize those merely to record a dependency.

A simple installation request does not imply autostart, MIME associations,
application replacement, hardware changes, or global environment overrides. Add
such behavior only when requested or necessary for the specified capability,
and explain any required integration rather than silently broadening the task.

## Implement within the pinned configuration

Inspect package attributes and option definitions from the inputs actually pinned
by the repository. Distinguish NixOS options from Home Manager options; do not
assume an upstream example matches the pinned version. Prefer existing local
input sources and evaluated options to guessing names or installing system tools.
If the pinned package or option is unavailable, explain the limitation and
available alternatives. Ask when an alternative changes the requested behavior;
continue independent work where possible. Do not silently update inputs or the
lockfile to make an example work.

Keep NixOS settings at the feature's top level. Put Home Manager settings inside
`home-manager.users.${globals.username}` using an inline module with its own
required `config`, `lib`, and `pkgs` arguments. Obtain other needed arguments
through the existing module wiring rather than changing the flake unnecessarily.
Keep shared identity and XDG infrastructure in root `home.nix`.

Use existing globals for shared choices; preserve alignment among consumers when
changing shell or terminal selection. Follow explicit category imports, without
recursive discovery, new feature-toggle frameworks, or unrelated restructuring.
Keep configuration assets in `config/`; use existing helper/script locations
when the requested feature actually needs them.

Determine who owns each new or changed file before mapping it through Home
Manager. Declarative configuration can be read-only; GUI-writable preferences
need the existing `kaenix.seedFiles` arrangement when initial defaults are
required. Histories, credentials, accounts, caches, and other runtime state do
not belong in configuration assets. Do not introduce duplicate writers or replace
user-managed files with store symlinks. Follow the GUI baseline workflow for
imports, preserving existing targets and explaining any one-time migration.

## Validate, document, and report

Use [Kaenix Validate](../kaenix-validate/SKILL.md) to select checks based on the
actual change and its dependencies. If unavailable, consult the
[validation guide](../../../docs/VALIDATION.md). Use `path:.` for new files without
staging them. Do not duplicate the check inventory here or run a full system build
for every feature. Add focused checks when new behavior needs coverage that the
existing checks do not provide; state remaining runtime gaps.

Update relevant local guides and the changelog for the implemented behavior.
When the module structure changes, update affected feature counts and references
from the actual inventory, not a fixed count in this skill. Keep package-module
references useful without turning them into a transitive dependency list. Follow
documentation ownership and tracking rules from `AGENTS.md`.

Report what changed, why it satisfies the request, checks actually performed,
and any activation or runtime steps still needed. Distinguish evaluation, builds,
activation, and runtime evidence. Follow the project's language rules. A request
to implement a feature does not authorize system/Home Manager activation, reboot,
commit, push, or deployment; follow the explicit action boundaries in `AGENTS.md`.
