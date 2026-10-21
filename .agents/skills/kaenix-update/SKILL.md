---
name: kaenix-update
description: "Review or update Kaenix flake inputs, inspect upstream changes, and resolve narrow update-related compatibility issues. Use for selected or explicitly requested full dependency updates; not vendored asset refreshes, routine feature changes, or system activation."
---

# Kaenix Update

## Establish the requested update

Follow [shared context loading](../../../AGENTS.md#understand-the-context-first)
and the relevant [input update guidance](../../../docs/CONFIGURATION.md#updating-flake-inputs).

Identify the named inputs, requested revisions/release lines, and whether the
request is review-only or authorizes updates. Infer scope from the request and
repository first; ask when it remains ambiguous. Update all inputs only when the
user explicitly requests a full update. A named-input update does not authorize
unrelated top-level updates. This skill covers flake inputs, including non-flake
plugin inputs; vendored mpv/PlayKit scripts, shaders, and fonts are outside scope.

Inspect staged, unstaged, and relevant untracked changes, including existing
`flake.nix` and `flake.lock` edits. Record their starting state privately so the
task's changes can be distinguished without staging or committing. Preserve user
edits; resolve any genuinely ambiguous overlap before overwriting it.

Review-only requests preserve repository files, including documentation and the
lockfile, unless recording findings is also requested. Use non-writing inspection
and lock-preserving flags where applicable; do not run a lockfile update merely
to discover available revisions. Updating repository inputs does not authorize
system/Home Manager activation, live settings changes, service restarts, logout,
reboot, commit, push, or deployment. Honor explicit authorization already supplied.

## Resolve targets and review upstream changes

When documentation or compatibility evidence needs investigation, consult
[Kaenix Docs](../kaenix-docs/SKILL.md) for the actual old and proposed revisions.

Read the input declarations, root input mapping, relevant locked nodes and
`follows` relationships, and the modules/assets consuming the inputs. Preserve
source repositories, release-line policies, `flake = false`, and shared nixpkgs
relationships unless the requested change requires otherwise.

| Input form | Update handling |
| --- | --- |
| Branch/ref-based input | Resolve the requested target on the existing release line, such as DMS `stable` or nixpkgs `nixos-unstable`; do not silently switch branches |
| Input without an explicit ref | Verify the source repository's actual default target rather than assuming a branch name |
| Exact-commit input | Verify a newer intended revision, update the commit in the declaration, then refresh that input's lock entry; retain an explicit commit pin |

For exact pins such as `cat-widget` and `mpvpaper-plugin`, a lockfile refresh alone
does not advance the declared commit. Establish the intended upstream release
line from the request, repository guidance, and upstream evidence; ask if choosing
between plausible lines would change behavior. Include these inputs when a full
update covers them; report unchanged pins and why rather than claiming they moved.

Use authoritative upstream release notes, commit comparisons, module definitions,
and compatibility guidance for the actual old and proposed revisions. Check
relevant breaking changes, renamed options, package changes, and plugin/API
compatibility. Prefer local pinned sources for existing behavior and fetch current
upstream evidence for proposed targets. Record old/new revisions and useful source
links. State missing evidence instead of inventing compatibility or versions.

## Apply the scoped update and inspect the graph

Verify the installed Nix command interface before selecting update flags. Run
from the repository root with a local flake reference such as `--flake path:.`
when supported, so new files are visible without staging. Name selected inputs
explicitly; a bare all-input update is appropriate only for an authorized full
update. Preserve existing release-line declarations and do not replace exact
commit pins with moving refs or add inputs as an incidental repair.

Inspect the resulting declarations and lock graph against the starting state.
Identify requested root changes, required transitive changes, preserved `follows`
relationships, and any unexpected root/source changes. Explain necessary
transitive changes; investigate unrelated changes before retaining them. If a
solution requires expanding the requested top-level scope or changing the release
policy, explain the concrete choice and ask rather than silently expanding it.
Do not hand-edit fetched hashes or replace a reported hash without verifying the
intended source.

A requested update permits narrow, evidence-supported compatibility edits to the
owning modules. Follow existing module/package ownership and writable-state rules.
Preserve functionality, user preferences, state versions, hardware/boot settings,
and unrelated dependencies. Do not disable features, skip checks, replace apps,
or refresh vendored assets merely to obtain a passing result. Escalate significant
behavior changes as scope decisions; continue useful independent work.

Reassess affected local workarounds against the new inputs. For the documented
[khal override](../../../docs/CONFIGURATION.md#dms-calendar-and-the-khal-build-workaround),
inspect the selected Sphinx hook and package behavior after nixpkgs changes.
Keeping or removing the override needs evidence, including a targeted package
build and its required manual output; successful evaluation alone is insufficient.
If the comparison cannot be completed, report the unresolved workaround decision
and avoid an unsupported removal.

## Validate and report the update

Use [Kaenix Validate](../kaenix-validate/SKILL.md) for checks selected from the actual
changed inputs and consumers, or [the validation guide](../../../docs/VALIDATION.md)
if unavailable. Broad nixpkgs, Home Manager, package-set overlay, or full updates
need comprehensive repository checks, including the current shell/terminal
combination fixtures. Narrow updates need evaluation and checks/evaluated options
for affected consumers, with explicit coverage gaps where no dedicated test exists.
Do not duplicate the check inventory here. After the intended update, preserve
the resulting lockfile during validation with supported lock-preserving flags;
use `path:.` and `--no-link` where applicable. Full system builds require an
explicit request covering that build.

Use [Kaenix Build Debug](../kaenix-build-debug/SKILL.md) for evaluation/build
failures without introducing unrelated updates. Separate configuration failures
from network, daemon, sandbox, or missing-tool constraints. Retry only with new
evidence or changed conditions. Complete independent checks, preserve reviewable
changes, and report blockers; do not discard user edits or automatically reset
the entire lockfile after a failure.

Update relevant local guides and the changelog for implemented updates, including
workaround changes and remaining migration steps. Seed baseline changes do not
replace existing writable files. Report requested scope, actual old/new revisions,
unchanged targets, required transitive changes, compatibility edits, upstream
sources, checks actually performed, and unresolved risks. Distinguish cached
outputs, evaluation, builds, activation, and observed runtime behavior. Passing
checks do not prove that plugins or the desktop work in a real session; use
[Kaenix Runtime Debug](../kaenix-runtime-debug/SKILL.md) when runtime diagnosis is
requested.
