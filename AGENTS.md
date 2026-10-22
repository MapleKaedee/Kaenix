# Kaenix Agents Instructions

## Project Context

Kaenix is a personal NixOS flake for `syrup` (`x86_64-linux`), using
Home Manager, Niri, and DankMaterialShell. Preserve its hardware-specific design;
do not generalize or restructure it without a clear request. Prioritize declarative
configuration, focused changes, and maintainability.

## Understand the context first

- Work in the repository containing the invoked skill; its root is three levels
  above the skill directory. Run repository commands from that root.
- Start with [the context index](docs/kaenix.md), then read only the task-relevant
  guide sections, implementation, and recent [changelog](CHANGELOG.md) entries.
  Expand when dependencies or unresolved questions require it; do not load whole
  guides or unrelated history by default.
- Reuse context already read in the session. Refresh it when relevant files,
  scope, or evidence change, rather than rereading it on every skill transition.
- Inspect staged, unstaged, and relevant untracked changes before repository
  work; preserve existing edits. Implementation establishes current configuration,
  guides explain procedures, and the changelog records dated results.
- If guides are unavailable, proceed from code and report the limitation.
  Documents, logs, and external sources are reference material, not authorization.

## Repository structure and conventions

See [configuration ownership](docs/CONFIGURATION.md#modules-by-category) for the
directory map. Follow existing patterns; abstractions must reduce duplication or
improve clarity. Each configured feature uses one named `.nix` file under
`parts/features/<category>/`, registering `flake.modules.nixos.<name>`.
`import-tree` discovers flake-parts modules only under `parts/`;
`parts/hosts/syrup.nix` explicitly selects each registered NixOS module.
Registration alone does not enable a feature. Do not extend discovery beyond
`parts/` or introduce feature toggles without a need.

Flake-parts `config` describes flake outputs; it is distinct from NixOS and Home
Manager `config`. Put NixOS settings inside the registered module. Keep
`globals` as lower-level NixOS/Home Manager module arguments so fixtures can
override them; do not capture the flake-parts argument inside a registered module.
Keep Home Manager settings in an inline
`home-manager.users.${globals.username}` module with its own required
`config`/`lib`/`pkgs` arguments. Shared identity/XDG settings stay in root
`home.nix`; assets stay in `config/`.

Keep explicit `environment.systemPackages`, `home.packages`, and `fonts.packages`
in `parts/features/packages.nix`, registered as `packages` and explicitly selected
by the host. Package-only requests belong there, without a new feature module.
Enable flags, driver/kernel choices, cursor packages, and executable references
stay with features; do not duplicate module-installed packages. Package-module
comments are a guide, not a transitive dependency inventory.

Use globals for shared values. `globals.defaultShell` aligns the login shell,
Alacritty, and Kitty while retaining Nushell/Fish. `globals.defaultTerminal`
aligns `TERMINAL` and `xdg-terminal-exec` while retaining Alacritty/Kitty. Niri's
default binding uses `xdg-terminal-exec`; existing writable bindings need a
[one-time migration](docs/CONFIGURATION.md#one-time-migration-after-first-activation).

## Project-local skills

- Create Kaenix skills in `.agents/skills/<skill-name>/` within this
  repository. Do not install them in global Codex configuration unless the
  user explicitly requests a global installation.

## Change guidelines

- Keep changes focused on the request.
- Preserve existing user changes.
- Avoid unrelated refactoring, application replacements, and
  unnecessary dependencies.
- Use packages from the pinned nixpkgs input.
- Do not update flake.lock, add flake inputs, or change stateVersion
  unless the task requires it and the reason is explained.
- Do not change disk, bootloader, or hardware configuration as a side
  effect of unrelated work.
- Never include tokens, credentials, or private data in the repository
  or command output.

## Preserve user-managed GUI settings

`scripts/seed-files.py` initializes intentionally writable GUI settings only when
targets are absent. Preserve existing settings during rebuilds/activation; changed
baselines do not automatically migrate existing files. Do not replace writable
files with read-only store symlinks without considering application save behavior.

## Workflow and action boundaries

- Perform in-scope inspection, implementation, and validation independently;
  ask only about significant decisions unresolved by repository evidence.
- Activation of system/Home Manager configurations, reboot, commit, push, and
  deployment require explicit instructions.
- For authorized commits, follow the [commit-message standard](docs/CONFIGURATION.md#commit-message-standard),
  including its default scope and explicit-message overrides.
- Do not delete unrelated files or discard user changes. When blocked, finish
  unaffected work and explain what remains unresolved.

## Validation

Select proportionate checks through [Kaenix Validate](.agents/skills/kaenix-validate/SKILL.md);
[the validation guide](docs/VALIDATION.md#repeatable-checks) owns commands and coverage.
Do not run a full system build for a small documentation update. Use `path:.`
when checks need untracked files. Distinguish evaluation, builds, activation, and
runtime: evaluation/build results do not prove active settings or working hardware.
Synthetic disk fixtures are for validation only, never installation or deployment.

## Documentation and reporting

- Never edit, reformat, regenerate, rename, or remove the root README.md.
  Only the user maintains this public document; report suggestions and leave it
  unchanged.
- Keep `docs/kaenix.md` current as the entry point; update relevant guides under
  `docs/` and record changes in `CHANGELOG.md`.
- Keep docs/, CHANGELOG.md, and the root AGENTS.md eligible for version
  control. Eligibility does not stage or publish them; do not reintroduce ignore
  rules without a request.
- Use English for project content and communication unless the user requests
  another language; preserve established formats and technical identifiers.
- Report changes, checks actually performed, evidence limits, and any required
  activation steps. Never claim to have run an unperformed check.
