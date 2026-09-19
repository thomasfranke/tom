---
id: spec-0010
task_ref: task-0003
status: draft
created: 2026-09-19T21:41:51Z
---

# spec-0010 — Show a file's commit history

**References:** [task-0003](../tasks/task-0003-m1-git-workflow.md)

- **Goal:** Show the commits that touched the open document, newest first, and let one be opened as that version of the document — rendered, not as raw diff text.

## Scope

In: the log for one path, following renames; author, date and message per entry; reading a file at a revision; rendering it through the preview pipeline.

Out: the diff between two of those versions, which is M2's rendered diff, and blame, which is Phase 2.

## Steps

1. Extend `GitClient` with a per-path log using an explicit, parseable format, and `--follow`.
2. Map entries onto the `Commit` value object.
3. Register the history panel as a descriptor, bound to the open document.
4. Read a file at a revision through the client.
5. Render that content with the preview pipeline `spec-0006` builds.

## Acceptance criteria (EARS)

- When a document is open, the system shall list only the commits that changed that file, most recent first.
- When a history entry is opened, the system shall render that version as markdown rather than as raw diff text.
- When the open file has no history, the system shall show a named empty state.
- When the file was renamed in the past, the system shall follow it across the rename.

## Edge cases

- A path with non-ASCII characters, which git quotes in its output.
- A file deleted in a later commit than the one being viewed.
- A shallow clone, where history is truncated by construction.
- A history of thousands of commits — the panel must not read them all at once.
- A commit message carrying the delimiter the log format uses.

## Tests required

Parser tests for the log format, including a rename and a message containing the delimiter. A fake client for the panel. One integration test over a temp repository holding a renamed file.

## Definition of Done

- [ ] Only commits touching the open file are listed.
- [ ] A renamed file shows its history from before the rename.
- [ ] A long history does not load in one read.

## Proposed product changes

- `product/git-workflow/file-history/doc.md` — move off Planned and state what shipped.

## Proposed technical changes

- none — no technical chapter changes.

## Outcome

_(fill after execution)_
