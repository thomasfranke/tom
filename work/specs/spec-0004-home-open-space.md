---
id: spec-0004
task_ref: task-0002
status: draft
created: 2026-09-19T21:41:37Z
---

# spec-0004 — Open a folder as a space from the home screen

**References:** [task-0002](../tasks/task-0002-m0-foundation.md)

- **Goal:** From an empty first screen, let someone choose a folder and get a working space — with the repository resolved separately from the folder, recents offered, and the not-a-repository case named rather than crashed.

## Scope

In: the empty state; choosing a folder; resolving `repositoryRoot` by walking up; constructing `Space` with `root` and `repositoryRoot` separate; recent spaces; the named not-a-repository failure.

Out: cloning by URL, which is M3 and has its own entry on the roadmap. Mobile, which `product/home/doc.md` states is not designed yet.

## Steps

1. Put the folder picker behind an infra contract implemented over `file_selector`.
2. Resolve the repository root by walking up for `.git`, through the `GitClient` contract.
3. Construct `Space` carrying `root` and `repositoryRoot` as separate fields.
4. Persist and read recent spaces behind a contract implemented over `shared_preferences`.
5. Render the empty state, and the not-a-repository case as a named failure of the sealed hierarchy.

## Acceptance criteria (EARS)

- When a folder inside a repository is chosen, the system shall open it as a space whose `root` is that folder and whose `repositoryRoot` is the repository.
- When a folder outside any repository is chosen, the system shall show the named not-a-repository failure, and shall not create a repository.
- When a space is opened, the system shall record it in the recent list.
- When a recent space no longer exists on disk, the system shall offer it as unavailable rather than failing to start.

## Edge cases

- A folder that is itself the repository root.
- A submodule, and a worktree — where `.git` is a file, not a directory.
- A symlinked folder whose real path sits elsewhere.
- A bare repository, and a folder the user cannot read.

## Tests required

Unit tests for the upward walk across each of the four cases above. Failure-path tests asserting the named failure, never an exception crossing the boundary. Fakes for the picker and for preferences, so no test touches the real filesystem outside a temp fixture.

## Definition of Done

- [ ] Opening a `docs/` subfolder of a repository runs git against the repository root.
- [ ] Every failure path returns a named case, and no `catch` rethrows.
- [ ] Recents survive a restart.

## Proposed product changes

- `product/home/doc.md` — move the M0 half off Planned, and correct the not-a-repository copy to what shipped.

## Proposed technical changes

- `technical/domain-model.md#space` — record `Space` as built, with `root` and `repositoryRoot` separate.
- `technical/flows.md#the-space-session-is-the-single-source-of-truth` — record how the session is created and what owns it.

## Outcome

_(fill after execution)_
