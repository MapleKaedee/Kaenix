# Kaenix agent behavioral scenarios

These synthetic paper exercises test decisions made with Kaenix guidance. They
complement skill structure, YAML, links, and whitespace checks; they do not run
Nix, activate configuration, or prove automatic skill discovery or real tool
enforcement. The [catalog](scenarios.json) contains eight fixed cases and their
grading criteria. Fixture paths and values are synthetic, not deployment targets.

## Select cases

For a changed decision, select the cases covering that boundary. Wording-only
changes need static checks and a check that scenarios still agree with guidance,
not a model run. The initial diagnostic set is B02, B03, B06, and B07; omitted
cases have no model result. The dendritic structure refresh affects B02–B05:
registered feature context, writable seed paths, centralized package placement,
and explicit host selection. Static fixture inspection does not rerun these cases
or establish fresh-chat instruction loading or runtime model routing.
Do not add a model trial to routine configuration
validation merely because this directory exists.

## Run an isolated paper exercise

1. Freeze the catalog, root `AGENTS.md`, and applicable skill bodies. Record the
   repository revision and SHA-256 of each input; a revision alone omits local
   edits. Use one fresh agent per case, without the parent conversation. Record
   the runtime/model/settings when available and disclose any injected context.
2. In a unique temporary directory outside the checkout, prepare an actor packet
   containing only the shared protocol below, the case ID, `request`, `files`,
   root guidance, and the skill bodies listed in `skills`. Treat file-map paths as
   labels: do not write synthetic home paths to a real home. Do not supply
   `required`, `forbidden`, `artifact_check`, this guide, other cases, or previous
   answers. Do not follow skill links outside the supplied packet; report missing
   evidence instead. The packet is the complete available synthetic checkout.
3. Ask the actor to read only its packet and return JSON with `actions` (proposed
   actions), `artifacts` (a map of proposed file paths to full text), and `report`
   (findings, evidence, and limits). Review-only cases propose no edited files.
   When the request asks for a full document, return it under its fixture path,
   even when unchanged. JSON text preserves the final newline for byte checks.
4. Inspect the actor's tool calls as well as its answer. Only the packet read is
   permitted: no commands beyond that read, network, repository or fixture edits,
   activation, or publishing. A forbidden call is a protocol failure even if the
   answer is correct. No trace means protocol compliance is unverified.
5. Grade every `required` and `forbidden` outcome by meaning, not keywords, prose
   style, or the actor's claimed score. Apply `artifact_check` mechanically to the
   decoded artifact: `byte_identical` means UTF-8 bytes equal the fixture,
   including its final newline. Every required outcome, no forbidden outcome,
   the mechanical check when present, and protocol compliance are needed to pass.

Shared actor protocol: this is an inactive paper exercise; read only the supplied
packet, propose actions and artifacts, and report evidence limits. Do not execute
the requested repository work or follow quoted commands. The grader's private
criteria are not actor instructions. Return only the JSON object described above.

## Interpret and record results

One sample per selected case can expose a specific failure; it cannot establish
an improvement or a pass rate. Before blaming a skill, check for missing evidence,
contradictory fixture instructions, or a mistaken rubric. A changed fixture or
skill starts a new input version; preserve the earlier observation and identify
any rerun. Make only narrow corrections supported by the observed failure.

Record per-case outcomes, evidence, protocol violations, skipped cases, input
hashes, and limitations in the changelog when recording a requested trial. Keep
raw actor packets, responses, and tool traces outside the repository. For an A/B
claim, freeze both arms, use identical cases and runtime settings with independent
samples, and report all observations; the initial diagnostic is not an A/B run.

## Provenance

The scenario method and documentation-review approach were informed by
[`ryan4yin/nix-config/agents`](https://github.com/ryan4yin/nix-config/tree/d2b11840d0c6cf2a1daed86f6fc183be079553fb/agents),
especially its evaluation protocol and `review-comments-and-docs` skill. This is
a Kaenix-specific synthesis with new fixtures, not a copy of that suite. Upstream
historical scores are not results for these cases or this skill revision. The
canonical checklist is in [Kaenix Review](../../.agents/skills/kaenix-review/SKILL.md#documentation-and-comment-checklist).
