---
id: task-0002
status: backlog
blocked_reason: null
taken_by: null
spec_ref: [spec-0003, spec-0004, spec-0005, spec-0006]
doc_ref: tasks/roadmap.md#phase-1--mvp
origin: rule
priority: high
depends_on: [task-0001]
milestone: m0
created: 2026-09-19T21:40:23Z
queued: null
completed: null
merged: null
provenance: []
---

# Stand up the workspace shell, the home screen and the markdown editor

**References:** [tasks/roadmap.md#phase-1--mvp](../../docs/tasks/roadmap.md#phase-1--mvp) · [spec-0003](../specs/spec-0003-workspace-shell.md) · [spec-0004](../specs/spec-0004-home-open-space.md) · [spec-0005](../specs/spec-0005-file-tree.md) · [spec-0006](../specs/spec-0006-markdown-preview.md)

The shell a user actually opens: a window whose panels are registered
rather than hardcoded, a home screen that opens a folder and remembers
recent spaces, a file tree over that folder, and the markdown editor in
its two modes — rendered preview and source.

None of this is the differentiator, and all of it is what the
differentiator stands on. It is also the first slice that runs as an
application: until M0 lands there is nowhere to show a diff, and nothing
to try on a real repository.
