---
name: kaenix-validate
description: "Select and run validation for Kaenix configuration changes or a requested scope, then report results and evidence limits. Use for change checks, flake evaluation, or comprehensive Kaenix validation; not for configuration fixes or system activation."
---

# Kaenix Validate

## Establish context and scope

This skill applies to the Kaenix repository containing it. The repository root
is three levels above the skill directory. Run commands from that root, not from
the skill directory or another project's checkout.

Read the [project context](../../../docs/kaenix.md), `AGENTS.md`, the latest
`CHANGELOG.md` entries, the [validation guide](../../../docs/VALIDATION.md), and
relevant feature guides. If local documents are unavailable, proceed from the
code and state that limitation. The repository remains the source of project rules.

Inspect `git status --short`, unstaged and staged diffs, and relevant untracked
files. Use `git diff`, `git diff --cached`, and
`git ls-files --others --exclude-standard`; do not change the index. Read the
changes to understand dependencies rather than matching filenames alone.

- If the user specifies files, features, a comparison revision, or another scope,
  use that scope and its affected dependencies.
- For comprehensive validation, select evaluation and every check currently
  defined by the repository.
- Without an explicit scope, use the combined staged, unstaged, and new-file
  changes. Include ignored documentation only when known to have changed or
  requested; do not scan private data outside the scope.
- If there are no changes and no specific scope, run flake evaluation as a basic
  check and explain that no diff was validated.

## Select checks from the actual implementation

Read `flake.nix`, `tests/checks.nix`, the `tests/evaluate.nix` fixture, and relevant
tests to confirm current check names, coverage, and dependencies. The table below
is selection guidance, not a fixed inventory of flake outputs. Combine checks
for mixed changes without running duplicates.

| Change | Selected checks |
| --- | --- |
| Documentation only | Whitespace and changed links/paths; no Nix evaluation or build |
| Skill instructions or metadata only | Structure/frontmatter, YAML, references, and whitespace; no Nix build |
| Nix configuration or package lists | Flake evaluation, non-writing format checks on changed Nix files, and checks for affected features |
| Shell, prompt, greeting, or login environment | `shells`; add `terminals` if terminal shells or shared wiring are affected |
| Terminal or XDG selection | `terminals`; add `niri-config` if launchers or bindings change |
| Writable seed helper, manifest, declarations, or baselines | `seed-files` and `seed-integration`, plus checks for affected consumers |
| Niri KDL, including DMS fragments | `niri-config`; add seed checks if a fragment is a seed baseline |
| mpv configuration, scripts, or Home Manager/MIME mapping | `mpv-config` |

For shell/terminal selection or wiring changes, also evaluate all four
combinations supported by the terminal/shell fixture. Obtain the current command
from the validation guide and inspect the fixture assertions; selection-helper
changes also require checking rejection of invalid values through evaluation
overrides without editing the original configuration. Synthetic disk/boot fixtures
are for evaluation only.

If a feature has no dedicated check, inspect its relevant evaluated options and
state the coverage gap. Do not infer working hardware/GUI behavior from evaluation
alone. Do not run the entire suite merely because one Nix file changed.

## Run without changing configuration

Use `path:.` references to include new files without staging them. Preserve the
lockfile with `--no-update-lock-file` on flake commands that support it.
Basic commands:

```bash
nix flake check --no-build --no-update-lock-file path:.
git diff --check
git diff --cached --check
```

Build each selected check using
`nix build --no-link --no-update-lock-file path:.#checks.x86_64-linux.NAME`,
replacing `NAME` with a verified name. Run checks separately when needed so one
failure does not block independent results. Comprehensive validation includes
all current checks; if needed, discover their names with
`nix eval --json --no-update-lock-file path:.#checks.x86_64-linux --apply builtins.attrNames`.

Git diff checks do not cover the contents of untracked files or ignored
documentation. Check their whitespace and syntax separately according to format.
For Nix files, use the project's formatter in check mode, such as
`nixfmt --check` when available; do not run the rewriting `nix fmt` command.
If a tool is unavailable, use a pinned package where possible without global
installation, or report the blocked check.

Use the temporary homes provided by checks. Do not run the seed helper against
the real home, open GUI applications, fix files, or change user settings as part
of validation. Build the entire system only when explicitly requested; activation
is outside this skill's scope. Follow the other action boundaries in `AGENTS.md`.

If evaluation or a check fails, inspect enough logs to distinguish configuration
problems from daemon, sandbox, network, or tooling limitations. Continue useful
independent checks. Do not retry the same failure without changed conditions or
new evidence. Do not expand validation into configuration fixes or dependency
updates.

## Report evidence

Report in English unless the user explicitly requests another language:

- Briefly state the scope and reasons for the selected checks.
- List actual commands and their status: passed, failed, blocked by the
  environment, or not run. State when Nix results came from cache; do not claim
  tests ran again when only realizing an already available result.
- Describe evidence-supported failure causes, coverage limits, and any remaining
  runtime checks where relevant.

Distinguish evaluation, check/package builds, full system builds, activation,
and runtime. `--no-build` does not build checks; headless checks do not prove GUI
or hardware behavior. Earlier documented results are not results from this
session. Do not write reports to the repository or update documentation when
asked only for validation unless the user also requests recording the results.
