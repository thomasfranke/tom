---
id: spec-0007
task_ref: task-0003
status: draft
created: 2026-09-19T21:41:46Z
---

# spec-0007 — Stage and commit from the working tree

**References:** [task-0003](../tasks/task-0003-m1-git-workflow.md)

- **Goal:** Show what changed, let it be staged whole or file by file, and record it with a message — leaving the list clean afterwards.

## Scope

In: reading status; staging everything or one file; unstaging; committing with a message; refreshing the list. All of it through `GitClient` over the system binary.

Out: hunk-level staging, which `product/git-workflow/commit/doc.md` rules out by name. Amend, signing and push are not here — push is `spec-0008`.

## Steps

1. Extend `GitClient` with status, stage, unstage and commit.
2. Implement over `Process.run` with an argument vector, never a shell string.
3. Parse `--porcelain=v2` into `GitStatus`, distinguishing modified, added, deleted and renamed.
4. Write the commit use case in application, with inline try/catch returning `Result`.
5. Register the changes panel as a descriptor; disable committing while nothing is staged.

## Acceptance criteria (EARS)

- When the working tree has changes, the system shall list them as modified, new or deleted before anything is staged.
- When nothing is staged, the system shall disable committing.
- When a commit is attempted with an empty message, the system shall refuse it with a named failure.
- When a commit succeeds, the system shall refresh the list to show a clean working tree.

## Edge cases

- A rename, which porcelain reports as one entry with two paths.
- A path holding spaces, quotes or non-ASCII — git quotes these in its output.
- A file deleted outside the app between the listing and the commit.
- An empty repository with no `HEAD` yet, and a merge already in progress.
- A commit hook that exits non-zero.

## Tests required

Unit tests for the porcelain parser, one per case above, driven by captured real output rather than invented strings. Use-case tests over a fake `GitClient`. One integration test over a temp repository, exercising status → stage → commit → status.

## Definition of Done

- [ ] A rename shows as a rename, not as a delete plus an add.
- [ ] A non-ASCII path round-trips.
- [ ] Every git failure crosses the boundary as a named `GitFailure`, never as an exception.

## Proposed product changes

- `product/git-workflow/commit/doc.md` — move the desktop half off Planned and reconcile the mock with what shipped.

## Proposed technical changes

- `technical/flows.md#one-serialized-queue-per-space` — record how status, stage and commit serialize against each other.

## Outcome

_(fill after execution)_
