---
name: kaenix-runtime-debug
description: "Diagnose problems in the running Kaenix desktop, services, and hardware integrations; implement narrow repository fixes when requested. Use for live session or device failures, not Nix evaluation/build failures, new features, or GUI baseline imports."
---

# Kaenix Runtime Debug

## Establish the symptom and authorized scope

Follow [shared context loading](../../../AGENTS.md#understand-the-context-first)
and inspect the affected implementation and session.

Establish the failing behavior, expected result, affected application/device,
session, timing, reproduction steps, and whether diagnosis or a fix was requested.
Inspect available evidence before asking for missing information. Diagnosis-only
requests preserve repository files, documentation, and live configuration unless
the user also requests recording findings. Fix requests permit evidence-based,
focused repository edits and the relevant documentation updates.

Live settings changes, service starts/stops/restarts, application relaunches,
system/Home Manager activation, logout, and reboot need explicit instructions
covering those actions. Honor authorization already supplied within the task;
do not ask again for the same action. Diagnosis or a repository fix alone does
not authorize those actions, commit, push, or deployment.

## Distinguish intended configuration from the running session

When documentation or version compatibility needs investigation, consult
[Kaenix Docs](../kaenix-docs/SKILL.md), identifying the installed/running target
separately from checkout pins. Keep live diagnosis in this workflow.

Compare the checkout, the active system generation (`/run/current-system`), the
relevant user configuration, and the affected application's actual inputs.
Do not assume the current checkout was activated or that a running process has
loaded the latest configuration. Check executable/configuration paths and relevant
versions when they help explain a mismatch.

Read [configuration ownership](../../../docs/CONFIGURATION.md) and inspect the
owning modules/assets. Distinguish Nix-managed files from writable seeds and
transient state. Existing seed targets are preserved, so a newer repository
baseline does not prove that the active file changed. Verify system versus user
unit scope: a NixOS module can provide a user service, as OpenTabletDriver does.

Verify that tools can reach the affected user's actual session, user bus, display,
and device. A headless tool environment, different user, missing socket, permission
denial, or inaccessible device is a diagnostic limit until evidence establishes
a configuration fault. Do not fabricate session variables, bypass permissions,
or change configuration to hide the access problem.

## Gather targeted runtime evidence

Discover current unit names and command interfaces from the installed tools,
module definitions, and relevant pinned upstream sources when needed. Use targeted
`systemctl` status/show queries and `journalctl` excerpts in the correct unit
scope, bounded by the affected boot, unit, time window, and line count. Inspect
only relevant session-variable keys; avoid full environment/process dumps or
unrelated logs, account data, clipboard contents, and private histories. Redact
credentials and private details before reporting excerpts.

Use these as starting points, not proof of the current runtime topology:

| Symptom | Evidence and ownership to inspect |
| --- | --- |
| DMS or Niri failure | Relevant user unit, graphical-session target, compositor/session logs, base Niri configuration versus DMS-written fragments; distinguish the greeter from the user's shell |
| Audio failure | PipeWire/Pulse compatibility and session-manager units actually present, device/node availability, selected routes/defaults, and physical versus EasyEffects virtual devices |
| Portals or screen sharing | Actual selected portal backend, desktop/session identification, PipeWire availability, and relevant portal/application logs; a healthy unit alone does not prove capture works |
| Wrong terminal or shell | Active binding command, `xdg-terminal-exec --print-id`, relevant session variables, generated terminal configuration, and the shared globals; inspect the documented one-time binding migration |
| Tablet failure | User-unit status even when NixOS provides it, device access, selected writable OTD profile, and possible competition with osu!'s built-in tablet driver |
| GPU offload or display failure | Actual render device/application renderer, driver/device availability, offload invocation, and relevant logs; distinguish normal AMD desktop rendering from requested NVIDIA offload |

Choose the smallest read-only diagnostic that distinguishes a concrete hypothesis.
Check whether a probe starts a service/application, requests screen capture, wakes
hardware, or otherwise affects the session before using it; obtain the needed
action authorization when it is not already present. Do not repeatedly launch
applications, restart services, reset settings, or rebuild as a generic experiment.
When direct reproduction requires unavailable GUI/device interaction, inspect
independent evidence and request only the specific observation still needed.

## Fix the owning configuration when requested

Trace the evidence-supported cause to its repository owner and make the smallest
appropriate correction. Follow existing NixOS/Home Manager boundaries, package
ownership, shared globals, pinned inputs, and module conventions. Do not add
duplicate autostarts/writers, disable requested functionality, update the lockfile,
or replace applications merely to suppress a symptom.

Preserve writable settings and unrelated preferences. Do not reset whole DMS or
application directories, replace writable seeds with store symlinks, or make the
seed mechanism overwrite existing files. A required live-file migration is a
separate action: describe the targeted change and unique backup first, then
execute it only when authorized. NixOS rollback does not restore writable GUI
state. Keep hardware/boot changes outside unrelated fixes.

Route evaluation/build failures to [Kaenix Build Debug](../kaenix-build-debug/SKILL.md),
new feature work to [Kaenix Feature](../kaenix-feature/SKILL.md), and selected GUI
preference imports to [Kaenix GUI Baseline](../kaenix-gui-baseline/SKILL.md).
Use [Kaenix Validate](../kaenix-validate/SKILL.md) for relevant regression checks
after repository fixes; use [the validation guide](../../../docs/VALIDATION.md)
if the skill is unavailable. Do not duplicate its check inventory or infer runtime
success from a passing build. Full system builds require a request covering them.
Update relevant local documentation and the changelog for implemented fixes.

## Verify and report the evidence limits

Retest the original symptom only within the authorized actions and available
session/device access. Retry when a new hypothesis or changed condition justifies
it. If blocked, finish useful independent inspection and identify the missing
evidence or specific next action instead of repeating the same failed probe.

Report the symptom and affected context, relevant evidence, supported cause or
remaining hypothesis, changes if authorized, checks actually performed, and any
activation/migration/runtime verification still needed. Separate repository,
evaluation/build, active-generation, and observed runtime evidence. A service
being active does not prove that audio, capture, tablet input, or rendering works;
a repository correction without activation and retesting remains runtime-unverified.
Do not claim inaccessible behavior was reproduced or fixed.
