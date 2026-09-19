---
id: task-0003
status: backlog
blocked_reason: null
taken_by: null
spec_ref: [spec-0007, spec-0008, spec-0009, spec-0010]
doc_ref: tasks/roadmap.md#phase-1--mvp
origin: rule
priority: medium
depends_on: [task-0002]
milestone: m1
created: 2026-09-19T21:40:31Z
queued: null
completed: null
merged: null
provenance: []
---

# Ship the essential Git workflow over the system binary

**References:** [tasks/roadmap.md#phase-1--mvp](../../docs/tasks/roadmap.md#phase-1--mvp) · [spec-0007](../specs/spec-0007-commit.md) · [spec-0008](../specs/spec-0008-push-pull.md) · [spec-0009](../specs/spec-0009-branch-switch.md) · [spec-0010](../specs/spec-0010-file-history.md)

Commit, push and pull, branch switch, file history — the four acts that
make TOM a Git client rather than an editor with a preview pane. All four
go through the system binary behind the `GitClient` contract, so no new
dependency enters with them.

They come before the rendered diff on purpose. A diff is read inside a
repository the user can already move around in; shipping the
differentiator on top of a workflow nobody can complete would demonstrate
nothing on a real repository.
