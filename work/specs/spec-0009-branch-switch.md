---
id: spec-0009
task_ref: task-0003
status: draft
created: 2026-09-19T21:41:50Z
---

# spec-0009 — Switch branches from the shell

**References:** [task-0003](../tasks/task-0003-m1-git-workflow.md)

- **Goal:** Move between branches, and start one, without a terminal — with open documents following the switch and unsaved work never lost silently.

## Scope

In: showing the current branch; listing branches; switching; creating a branch from the current one; the save-or-discard prompt; reloading open documents.

Out: deleting or renaming branches, remote-tracking management, and conflict resolution during a switch.

## Steps

1. Extend `GitClient` with a branch list, the current branch, checkout, and create-and-checkout.
2. Show the current branch in the status bar at all times.
3. Before switching, ask the space session whether any open document is dirty; prompt to save or discard.
4. After the switch, reload every open document from the new branch.
5. Creating a branch from the current one switches to it in the same act.

## Acceptance criteria (EARS)

- When a space is open, the system shall show the current branch name.
- When the user switches branches, the system shall reload every open document from the new branch.
- When unsaved changes exist, the system shall ask to save or discard before switching, and shall not switch silently.
- When a new branch is created from the current one, the system shall switch to it immediately.

## Edge cases

- An open document that does not exist on the target branch — `product/git-workflow/branch-switch/doc.md` does not yet say what happens, and this spec must settle it.
- A branch name that already exists, or that git refuses as malformed.
- Detached `HEAD` as the starting point.
- A checkout git refuses because the working tree would be clobbered.

## Tests required

Use-case tests over a fake client for each of the four criteria. An integration test over a temp repository with two branches whose file sets differ. A widget test for the save-or-discard prompt, including the discard path.

## Definition of Done

- [ ] Switching with a dirty document cannot lose it.
- [ ] A document missing on the target branch resolves the way the product doc — updated here — states.
- [ ] The branch name on screen is never stale after a switch.

## Proposed product changes

- `product/git-workflow/branch-switch/doc.md` — move off Planned, and state what happens to an open document that does not exist on the target branch. That second half is a rule the doc does not carry today, so it passes the human gate on permanent docs before merge.

## Proposed technical changes

- `technical/flows.md#the-space-session-is-the-single-source-of-truth` — record how a switch invalidates and reloads open documents.

## Outcome

_(fill after execution)_
