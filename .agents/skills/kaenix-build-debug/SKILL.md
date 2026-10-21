---
name: kaenix-build-debug
description: "Diagnose Kaenix Nix evaluation, fetch, dependency build, and configuration-check failures from commands and logs; implement narrow fixes when requested. Use for failed evaluations or builds, not routine validation, new features, or live GUI/hardware troubleshooting."
---

# Kaenix Build Debug

## Establish the failure and authorized scope

Follow [shared context loading](../../../AGENTS.md#understand-the-context-first)
and inspect the failing implementation.

Identify the original failing command, target, relevant log or error, and whether
the user requested diagnosis or a fix. Diagnosis-only requests do not authorize
editing repository files, documentation, the lockfile, or live configuration.
Diagnostic evaluation/builds may write Nix caches/store outputs within the task's
scope. When fixes are requested, make only changes supported by the evidence.

Establish whether the failure refers to the current working tree and pinned
inputs. Record relevant revisions, derivation paths, and changed source files
when available. Do not treat a historical log as proof of a current failure. If
the failing command or necessary evidence is missing, inspect available evidence
first, then ask only for the missing information needed to proceed.

## Trace the first actionable cause

When diagnosis needs documentation lookup or pinned-version support evidence,
consult [Kaenix Docs](../kaenix-docs/SKILL.md) for research within this workflow.

Separate the phase that failed from the final top-level error. A message that a
dependency failed usually points to an earlier error rather than its cause.

| Failure phase | Evidence to inspect |
| --- | --- |
| Source visibility | Missing imports/assets and the original flake reference; check whether Git filtering excluded an untracked source |
| Nix evaluation | Relevant error/trace, option definitions in pinned inputs, types, recursion, and NixOS versus Home Manager module scope |
| Fetching/substitution | Source identity, pinned revision/hash, transport/cache errors, and whether failure occurs before building |
| Dependency build | The failing derivation's own log, build phase/hooks, tests, and expected outputs |
| Configuration check | The assertion and actual generated configuration or isolated fixture it examines |
| Environment/tooling access | Daemon access, filesystem permissions, sandbox limits, network/cache access, and required tool availability |

Use `nix log` on the relevant installable or store derivation when a build log is
available. Use `nix derivation show` when selected derivation details help trace
inputs, outputs, or build attributes. Inspect targeted fields/excerpts rather
than dumping complete derivations, environments, or unrelated logs. Capture broad
logs privately if necessary and show only relevant excerpts without credentials
or private data. State when logs are unavailable.

Treat daemon, sandbox, permission, network, and cache-access errors as environment
constraints until evidence establishes a configuration fault. Use permitted
access mechanisms when available; do not disable protections, alter trust/TLS
settings, or patch configuration merely to conceal an access failure. A source
hash mismatch requires checking the intended source, not blindly substituting
the reported hash.

## Reproduce the smallest relevant target

Prefer the existing failing check or package over a full system build. Resolve
packages through the host's actual pinned package set, including its overlays,
rather than an unrelated registry or a newer nixpkgs. Inspect the current command
interface when needed instead of assuming flags or derivation JSON layouts.

Use `path:.` to include new sources without staging. Preserve the lockfile with
`--no-update-lock-file` on commands that support it. Use `--no-link` for builds;
add `--print-out-paths` when concrete outputs are needed for inspection. Diagnostic
traces or temporary expressions must not rewrite the user's configuration. Keep
configuration checks in their temporary homes, not the real user's home.

Full system builds require a user request covering that build. A supplied system
build log alone is not an instruction to rebuild the entire system. Do not use
activation or deployment commands as a reproduction step. Synthetic disk/boot
fixtures remain evaluation-only.

## Apply a narrow fix only when requested

Form one evidence-based hypothesis, choose a check that can distinguish it, and
make the smallest change in the owning configuration or a narrowly scoped package
override. Follow current module patterns and package scopes. Do not disable the
requested feature, skip failing tests, remove required outputs, or replace the
application just to obtain a successful build.

Preserve pinned inputs, versions, source identity, unrelated user changes, and
writable GUI state. Do not update the lockfile or introduce a dependency update
as an implicit repair. If evidence shows the requested solution needs a change
outside the authorized scope, explain the concrete tradeoff before proceeding.

Retest the original failure condition and inspect the required outputs. For a
missing manual output, for example, verify that output and its expected artifact;
successful evaluation alone does not establish a successful package build. Use
the repository's actual package and confirm that its corrected derivation is the
one selected by Kaenix. Historical workarounds, including the documented
[khal example](../../../docs/CONFIGURATION.md#dms-calendar-and-the-khal-build-workaround),
are evidence to recheck, not universal fixes to copy.

Use [Kaenix Validate](../kaenix-validate/SKILL.md) for relevant regression checks
after a fix; consult [the validation guide](../../../docs/VALIDATION.md) if the
skill is unavailable. Update relevant local documentation and the changelog for
implemented fixes according to project rules. Diagnosis-only work does not write
those files unless the user also requests recording the findings.

## Stop and report with bounded evidence

Retry only to test a new hypothesis or a changed condition. Do not repeat the
same failing command without new evidence, force rebuilds merely to repeat cached
results, or broaden to the entire suite without a reason. If access or missing
evidence prevents progress, complete useful independent checks and report the
specific blocker and next action.

Report the command/target, failure phase, evidence-supported cause or remaining
hypothesis, changes if authorized, verification results, and unresolved limits.
Distinguish cached or substituted results from builds/tests actually executed,
evaluation from successful builds, and
builds from activation/runtime. Do not claim an unavailable original failure has
been reproduced or fixed solely from static reasoning.

Diagnosis and fixes do not authorize activation or service/machine restarts;
the shared action boundaries also apply.
