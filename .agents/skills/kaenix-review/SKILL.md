---
name: kaenix-review
description: "Review Kaenix changes for actionable defects, regressions, configuration ownership conflicts, and migration gaps. Use for read-only change reviews; not implementing fixes, routine check execution, or live session troubleshooting."
---

# Kaenix Review

## Establish the review scope

Follow [shared context loading](../../../AGENTS.md#understand-the-context-first)
and inspect the affected implementation.

Establish the intended behavior and requested scope before judging changes. Read
`git status --short`, staged and unstaged diffs, and relevant untracked files.
Without an explicit scope, review the combined working-tree changes against
`HEAD`, including relevant new files; do not report an intermediate staged change
as a defect if the final working tree already corrects it. Honor a staged-only
request or explicit files/comparison revisions. Resolve supplied refs locally
and state the actual comparison; do not invent a base branch or switch checkouts.
For branch reviews, use a verified merge base when the requested comparison calls
for changes introduced on the branch. Ask only when a meaningful scope ambiguity
cannot be resolved from the request or repository.

Read affected consumers, imports, helpers, and tests beyond the diff as needed.
Include ignored documentation only when relevant and known to have changed or
explicitly requested; avoid unrelated private data. When there are no changes and
no explicit scope, report that fact and ask what to review rather than starting
an unsolicited repository audit or default evaluation.

## Trace behavior and ownership

When a finding depends on documentation or version compatibility, consult
[Kaenix Docs](../kaenix-docs/SKILL.md) for research within this read-only review.

Use [configuration ownership](../../../docs/CONFIGURATION.md), actual module
wiring, pinned option definitions, and generated configuration where needed.
Treat documentation and previous results as context, not proof that the reviewed
change works or has been activated. Focus on the implications of the requested
change rather than applying a universal checklist to unrelated files.

| Area affected | Review questions |
| --- | --- |
| Module wiring | Is discovery restricted to `parts/`, is each registered NixOS feature explicitly selected exactly once by the host, and are moved asset/helper paths valid? Are options in the correct flake-parts, registered NixOS, or inline Home Manager context, with lower-level globals preserved for fixture overrides? |
| Package ownership | Are explicit packages in the centralized lists and in the intended system/user/font scope? Does a new explicit declaration unnecessarily duplicate a module-installed package, or is there a concrete reason for both scopes? |
| Shared choices | Do login shell and terminal consumers follow the shared globals, retaining supported alternatives and forwarding arguments correctly? |
| Writable settings | Do seeds preserve existing files and avoid competing writers/store symlinks? Does an intended change for existing homes need a documented targeted migration? |
| Services and desktop | Are user/system unit scope and startup ownership correct, without duplicate instances, conflicting writers, or unintended environment/MIME changes? |
| Compatibility and boundaries | Do the actual pins support the options/APIs used? Are dependency, hardware, boot, state-version, and public README changes intended and authorized? |

Verify a suspected issue by tracing a concrete affected path or scenario. Check
whether it is introduced by the reviewed change, is already handled elsewhere,
or depends on an unverified assumption. Include pre-existing defects only when
the user requests a broader audit that covers them. Do not treat intentional
behavior, justified package scopes, or seed preservation by itself as a defect.
For example, a changed seed needs migration only when existing homes are meant
to receive that change; copy-once behavior is intentional.

Report actionable correctness, regression, or substantive project-rule issues
with evidence. Avoid speculative risks presented as bugs, stylistic preferences,
unrelated refactoring, and mechanical complaints without a meaningful consequence.
Do not require another test merely because code changed: identify the behavior
or regression that existing coverage fails to establish.

## Documentation and comment checklist

Apply this checklist only to documentation and comments within the review scope:

- Check claims against the relevant implementation, contracts, and dated evidence.
  Distinguish configured values, available build outputs, active configuration,
  and observed runtime behavior; do not assume code settles an unclear contract.
- Preserve dates and outcomes together, uncertainty, safety constraints,
  attribution, compatibility limits, upstream references, and workaround reasons.
  Missing records do not prove an event failed or never happened.
- Read from the top without conversation context or explanations supplied later.
  Check links and paths for usability, stating access limits when necessary.
  Identify conflicting copies of current facts without rewriting dated history
  as if it described the present.
- Report a concrete factual, contractual, or usability defect and its evidence.
  Accurate content needs no rewrite, reflow, or invented finding. Shortening must
  retain procedure prerequisites, purpose, ordering, and completion conditions.
- Keep review-only work report-only. Suggested corrections do not authorize file
  edits, implementation changes, or executing documented commands.

## Resolve uncertainty without implementing changes

Use [Kaenix Validate](../kaenix-validate/SKILL.md) for targeted checks when they
help resolve a finding, or [the validation guide](../../../docs/VALIDATION.md)
if unavailable. Inspect what tests actually cover; passing evaluation/checks do
not prove desktop, GPU, audio, or device runtime behavior. Keep checks in isolated
homes and use supported lock-preserving flags, `path:.`, and `--no-link` where
applicable. Full system builds require an explicit request covering that build.

Keep the review read-only: preserve repository files, lockfile, Git index, and
live settings. Do not rewrite formatting, apply fixes, update inputs, activate
configurations, restart services, or open applications to test the live session.
Diagnostic checks may write normal caches/store outputs within scope. When a
check is blocked by daemon, network, sandbox, or tooling access, complete useful
independent inspection and distinguish the constraint from a configuration bug.

This skill does not implement fixes. If the user explicitly requests fixes as
well, finish the review and then use the appropriate existing workflow within
that authorization: [Kaenix Feature](../kaenix-feature/SKILL.md) for feature edits,
[Kaenix Update](../kaenix-update/SKILL.md) for input compatibility changes,
[Kaenix GUI Baseline](../kaenix-gui-baseline/SKILL.md) for selected GUI imports,
[Kaenix Build Debug](../kaenix-build-debug/SKILL.md) for build failures, or
[Kaenix Runtime Debug](../kaenix-runtime-debug/SKILL.md) for live failure diagnosis.
A review request alone does not authorize those fixes or other actions.

## Report actionable findings first

Lead with findings ordered by severity. For each, give a concise title, verified
file/line location, concrete trigger or affected consumer, consequence, supporting
evidence, and brief remediation guidance. Use `[P0]` for an unconditional critical
blocker, `[P1]` for urgent/high-impact defects, `[P2]` for normal actionable issues,
and `[P3]` for low-impact issues worth fixing. Do not inflate priority to compensate
for uncertainty; place unresolved assumptions outside the confirmed findings.

Keep locations tight and anchor change-review findings in the reviewed diff
where possible; do not invent lines for deleted or moved code. Use absolute local
file links and inline code comments for actionable findings where supported,
following the host's directive format. Keep inline and summary descriptions
consistent and avoid duplicate findings for the same underlying cause.

After findings, briefly state inspected scope/base, checks actually run, unresolved
questions, and coverage limits. If no actionable findings are found, say so
explicitly without claiming that the change is proven correct. Separate static
reasoning, evaluation, builds/cached outputs, and observed runtime evidence.
Do not write a review report, edit documentation,
or add a changelog entry during review unless the user requests recording it.
