---
id: spec-0005
task_ref: task-0002
status: draft
created: 2026-09-19T21:41:38Z
---

# spec-0005 — List the space's files in a tree

**References:** [task-0002](../tasks/task-0002-m0-foundation.md)

- **Goal:** Show every markdown file in the space as a tree — dotfolders included, `.git/` the only thing hidden — and open a document when one is chosen.

## Scope

In: recursive listing behind the filesystem contract; the tree in the explorer panel; selection handing the document to the space session; the empty state.

Out: filtering and search, which is M2. Live refresh when the disk changes: the roadmap builds this on `dart:io` listing alone, and the watcher arrives with its own work.

## Steps

1. Extend the filesystem contract with a recursive markdown listing.
2. Implement it over `dart:io` and `path`, excluding `.git/` and nothing else.
3. Sort folders before files, each alphabetically.
4. Render the tree inside the explorer panel the workspace module registers.
5. Selecting a file asks the space session to open that document.

## Acceptance criteria (EARS)

- When a space is open, the system shall list every `.md` file under its root, including those inside dotfolders such as `.ai/` and `.github/`.
- When the tree is built, the system shall exclude `.git/` and no other path.
- When a file is selected, the system shall open that document in the document area.
- When the space holds no markdown file, the system shall show a named empty state rather than a blank panel.

## Edge cases

- Deep nesting, and a space holding thousands of files.
- A symlink loop — the walk must terminate.
- A subfolder the process cannot read.
- A file removed between the listing and the open.

## Tests required

Unit tests over a temp-directory fixture covering the dotfolder rule, the `.git/` exclusion, the symlink loop and the unreadable subfolder. A widget test asserting selection reaches the session.

## Definition of Done

- [ ] `.ai/` and `.github/` appear; `.git/` does not.
- [ ] A symlink loop cannot hang the listing.
- [ ] Selecting a file opens it.

## Proposed product changes

- `product/navigation/file-tree/doc.md` — move the desktop half off Planned.

## Proposed technical changes

- none — no technical chapter changes.

## Outcome

_(fill after execution)_
