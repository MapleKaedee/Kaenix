---
name: kaenix-git
description: "Inspect Kaenix Git state and perform requested staging, commits, pushes, fetches, branch creation/switching, and fast-forward synchronization. Use for repository Git operations; not configuration implementation, pull requests, releases, or destructive/history-rewriting operations."
---

# Kaenix Git

## Establish the operation and repository state

Follow [shared context loading](../../../AGENTS.md#understand-the-context-first).
Identify the requested operation and any file, branch, remote, or message choices
already supplied. Inspection alone does not authorize staging, committing,
switching branches, integration, or publication. A commit request permits preparing
its selected index; a push request does not authorize creating a commit, and a
commit request does not authorize pushing. Honor an existing commit-and-push
request without asking again. Fetch only when requested or needed to establish
the remote state for an authorized operation; it updates remote-tracking refs,
not the working tree.

Inspect status, staged/unstaged diffs, relevant untracked files, the current
branch, upstream, and relevant push configuration. Check for an unfinished merge,
rebase, cherry-pick, or revert before mutations; do not continue or abort it
implicitly. Resolve Git metadata paths with Git itself for linked worktrees,
rather than assuming `.git` is a directory. Report local tracking information as
potentially stale when the remote has not been checked.

Infer scope and destinations from the request and verified configuration. Do not
hardcode `main` or `origin`, expose credential-bearing remote URLs, or invent a
branch when HEAD is detached. Ask only when an unresolved choice would change
what is committed, integrated, or published. Git operations do not authorize
editing source, documentation, configuration, or the lockfile to improve a diff.

## Prepare and create the requested commit

Follow the canonical [commit-message standard](../../../docs/CONFIGURATION.md#commit-message-standard)
for format, types, all-pending-changes scope, and explicit-message overrides.
Default to all reviewed staged, unstaged, and untracked changes, including changes
that predate this chat. Explicit paths or staged-only requests take precedence.
Do not automatically split commits or force-add ignored files. Exclude credentials
and private data; report an unresolved inclusion rather than publishing it.

Review the selected diff and new file contents before staging, then stage only
the verified selection, including intended deletions. For staged-only requests,
do not re-add files: preserve partially staged files' unstaged hunks. For narrowed
file scopes, keep unrelated index entries and working changes intact; ensure they
will not be included by an ordinary index-wide commit. Use a path-limited commit
when it matches the requested full-file selection; if a safe selection remains
unclear, ask instead of resetting or discarding the user's index.

Do not edit the root README. Existing user-authored README changes may be included
when they are in the authorized commit scope. Reuse relevant validation evidence;
when additional checks are needed, use [Kaenix Validate](../kaenix-validate/SKILL.md)
for proportionate, non-rewriting checks. Inspect the final staged diff and run
whitespace checks, accounting for newly selected files. Do not build the entire
system merely to commit documentation, and disclose checks not performed.

Create a new commit with the supplied exact message or a description derived from
the actual selected changes. A matching earlier title is not a reason to amend.
Use a temporary message file with `git commit --file` for multiline/literal text,
without shell interpolation. If nothing is selected, report that no commit is
needed; do not create an empty commit. Do not invent a release version, amend,
add tags, or bypass hooks/signing as a retry. If a hook fails or modifies files,
inspect and report the resulting state rather than discarding or automatically
staging its changes. Verify the resulting commit's message and changed paths.

## Manage branches and fast-forward synchronization

Create or switch branches only when requested. Respect an exact supplied name;
use `codex/` for a generated new branch name. Verify an existing branch/ref and
the intended starting point before switching or creating. Preserve pending work
and stop if a switch would overwrite it. Do not force the switch, automatically
stash changes, or delete branches.

For a requested pull/synchronization, require a clean working tree and index,
resolve the intended upstream, fetch the relevant remote, and inspect ancestry.
Integrate only by fast-forward, using an explicit verified target and
`git merge --ff-only` or an equivalent fast-forward-only command. If already equal
or ahead, report that state without inventing incoming changes. On divergence or
conflicts, preserve local work and explain what needs a separate decision; do not
automatically merge, rebase, stash, commit, reset, or force-push to continue.

## Push only the requested branch and destination

Resolve the source branch, push remote, and destination ref from explicit
instructions and verified upstream/push configuration. Inspect all outgoing
commits, including earlier unpushed commits; report their inclusion and resolve
any unclear publication scope. For a new branch, establish tracking only when
the requested remote/branch destination is unambiguous. Do not change remotes or
invent destinations to make a push succeed.

Use a normal push with an explicit branch refspec, not a broad matching/all-ref
push. A dirty working tree does not itself prevent pushing existing commits;
leave uncommitted work untouched. Verify success from the push result and check
the destination ref when available. A local commit or cached tracking ref alone
does not prove publication. A rejected push leaves the local commit intact: do
not automatically pull, rewrite history, or force-push. Report the actual result
if remote verification is unavailable.

## Handle failures and report what happened

Use Kaenix's existing [GitHub authentication setup](../../../docs/CONFIGURATION.md#github-cli-authentication).
Do not rewrite Home Manager-managed or global Git settings, expose tokens,
disable TLS verification, or bypass signing/hooks to conceal a failure. Preserve
work on authentication, network, permission, or Git-state failures; retry only
with new evidence or changed conditions. When sandbox access is blocked, use
permitted access mechanisms or report the blocker without changing protections.

Pull requests, releases, tags, branch deletion, history rewriting, destructive
cleanup, and forced operations are outside this skill's scope. A routine Git
request does not authorize deployment, configuration activation, or service
restarts. Do not add dependencies, hooks, or configuration enforcement.

Report completed operations, commit hashes/messages and included scope, branch
and destination, push/synchronization outcome, checks actually performed, and
remaining staged/unstaged/untracked changes. Distinguish inspection, staging,
local commits, and remote publication. Do not claim a clean tree or successful
push without checking, and do not write repository reports/changelog entries
merely to record a Git operation unless requested.
