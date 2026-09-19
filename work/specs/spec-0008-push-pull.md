---
id: spec-0008
task_ref: task-0003
status: draft
created: 2026-09-19T21:41:48Z
---

# spec-0008 — Push and pull against the tracking remote

**References:** [task-0003](../tasks/task-0003-m1-git-workflow.md)

- **Goal:** Keep the local branch and its remote visibly in sync — ahead and behind always on screen, each transfer an explicit act, and a rejection named rather than swallowed.

## Scope

In: fetch, pull and push as three separate actions; the ahead/behind counts; classifying a rejection by cause; refreshing state afterwards.

Out: merge and rebase strategies, conflict resolution (Phase 2), and credential management beyond whatever the user's own git helper already provides.

## Steps

1. Extend `GitClient` with fetch, pull, push, and a read of ahead/behind against the upstream.
2. Show the two counts in the status bar, refreshed after every transfer.
3. Make each of the three a distinct user action — nothing runs on a timer or in the background.
4. Classify failures into named `GitFailure` cases: non-fast-forward rejection, authentication required, remote unreachable.
5. Disable push and pull, with a stated reason, where the branch has no upstream.

## Acceptance criteria (EARS)

- When a branch tracks a remote, the system shall show how many commits it is ahead and behind.
- When the remote rejects a push as non-fast-forward, the system shall show a named failure stating that cause.
- When a fetch completes, the system shall change no file in the working tree.
- When no upstream is configured, the system shall disable push and pull and state why.

## Edge cases

- Detached `HEAD`, and a branch with no upstream.
- A credential helper that prompts interactively — the process must not block the UI indefinitely.
- The network disappearing mid-transfer.
- A pull that would overwrite uncommitted local changes.
- A remote that moved between the ahead/behind read and the push.

## Tests required

Parser tests for the ahead/behind read. Classification tests per failure, driven by captured stderr from a real git rather than invented text. An integration test against a second temp repository acting as the remote, covering the rejected push.

## Definition of Done

- [ ] A rejected push is distinguishable from an auth failure and from a dead network, in the UI and in the type.
- [ ] Fetch provably touches no file.
- [ ] No transfer starts without a user asking for it.

## Proposed product changes

- `product/git-workflow/push-pull/doc.md` — move off Planned and reconcile the push-rejected mock with what shipped.

## Proposed technical changes

- none — no technical chapter changes.

## Outcome

_(fill after execution)_

> If the interactive credential case forces an architectural commitment, it earns a decision file under `docs/technical/decisions/` — amend this spec to promise that path before completing the task, or the delta gate will read it as undeclared.
