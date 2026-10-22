---
name: kaenix-docs
description: "Find authoritative documentation and verify Kaenix options, packages, application configuration, and version compatibility against pinned sources and local adaptations. Use for documentation lookup or support questions; not editing project documentation, implementing changes, updating dependencies, or diagnosing live failures."
---

# Kaenix Docs

## Identify the question and its owner

Follow [shared context loading](../../../AGENTS.md#understand-the-context-first)
and inspect only the relevant configuration and sources. This is a research-only
workflow; use existing tools and exclude Context7 entirely.

Establish whether the question concerns the checked-out configuration, a proposed
upstream revision, or an installed/running application. Default to the checkout
when unspecified. Identify the owning module, package, or asset and the behavior
to verify before searching. Distinguish NixOS options from Home Manager options,
including modules supplied by other inputs such as DMS.

For requested implementation, updates, reviews, or diagnosis, use this skill only
for needed source/compatibility research within the owning workflow. Research
does not expand that workflow's authorization. Editing project documentation is
not itself a reason to invoke this skill.

## Resolve the sources that actually apply

Read relevant input declarations and resolve names through the lockfile's root
input mapping, then follow the relevant graph edges and `follows` relationships.
Do not select a locked node solely by its name: multiple revisions of the same
repository can coexist. Distinguish branch/release-line declarations from the
exact locked or proposed revision; a moving branch is not a version match.

Trace module imports, configured package selections, overlays, overrides, and
patches. Use the host's actual package set, including Home Manager's package-set
wiring, rather than an unrelated registry or a fresh unoverlaid nixpkgs import.
A matching package version alone does not establish identical behavior: the
local [khal override](../../../parts/features/desktop/dms.nix) changes build attributes.

Include sources outside `flake.lock`. For vendored assets, inspect provenance,
recorded hashes, and the relevant local code and adaptations. For mpv/PlayKit,
start with [its upstream record](../../../config/mpv/UPSTREAM.md) and inspect the
affected repository files; the player's nixpkgs version does not identify its
vendored scripts, and the recorded upstream snapshot does not include local edits.
Treat provenance and historical results as context to cross-check against code.

For installed/running targets, use existing relevant evidence of executable paths,
versions, and loaded configuration when available. Checkout pins do not identify
the active generation or prove what a running process loaded. Route missing live
evidence to [Kaenix Runtime Debug](../kaenix-runtime-debug/SKILL.md); do not start,
relaunch, or restart applications or services as documentation probes.

## Look up matching evidence

Inspect available pinned module definitions, package recipes, patches, and source
files first. If unavailable, use existing GitHub or browser capabilities to
retrieve only the relevant official upstream files at the resolved revision.
Prefer matching official manuals, release notes, and CLI references for
explanations. Check that a reference actually covers the identified version;
search snippets and mutable default-branch links alone do not establish support.

Distinguish declared option availability, effective configuration, package build
attributes, and application behavior. When sources disagree, explain the version
or local adaptation that accounts for the difference, or leave it unresolved.
If matching evidence is inaccessible or no versioned manual exists, state what
the inspected source establishes and what remains unknown. Newer documentation
may provide explicitly labelled context, never substitute evidence of support in
the pinned version. Do not silently change the target to make an example fit.

## Inspect effective values only when necessary

Prefer source inspection; use narrowly targeted evaluation when needed to resolve
effective options or overlaid package attributes. Verify the installed Nix command
interface before selecting flags. Use a local `path:.` reference when needed to
include new files without staging, supported lock-preserving flags, and disable
import-from-derivation for research evaluation so it cannot trigger a build.
Inspect only relevant values; avoid broad configuration/environment dumps.

Normal source fetching and evaluation caches are permitted. Do not build packages
or checks, install tools, update inputs or the lockfile, activate configurations,
or change live settings. Preserve repository files and the Git index during
research. Add no helper scripts, dependencies, global skills, or credentials.

Treat daemon, network, sandbox, and missing-tool failures as evidence limits until
sources establish a configuration defect. Use permitted access when available;
otherwise complete independent source inspection and report the blocked lookup.
Retry only with new evidence or changed conditions. Do not fix configuration or
substitute newer inputs to get past a research blocker.

## Answer with bounded evidence

Give the direct answer, the target version/revision and relevant local changes,
supporting local paths or revision-specific upstream links, and a focused example
when useful. Identify unresolved compatibility questions and unavailable sources.
Separate source inspection, evaluated values, installed-version evidence, and
observed runtime behavior. Evaluation does not prove a package builds, settings
are active, or an application works in the running session.

Keep research report-only, including documentation and changelog edits, unless
recording the findings is separately requested. Implementation and updates remain
with their existing authorized workflows. Follow shared README ownership and
publication boundaries; a researched example is not an applied change.
