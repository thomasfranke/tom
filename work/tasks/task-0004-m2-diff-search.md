---
id: task-0004
status: blocked
blocked_reason: Specs owed. The rendered diff, the branch diff and search cannot be bounded before spec-0002 reports the shape of Block; designing the differ ahead of that spike is out of bounds.
taken_by: null
spec_ref: []
doc_ref: tasks/roadmap.md#phase-1--mvp
origin: rule
priority: medium
depends_on: [task-0001, task-0003]
milestone: m2
created: 2026-09-19T21:40:32Z
queued: null
completed: null
merged: null
provenance: []
---

# Ship the rendered diff and full-text search

**References:** [tasks/roadmap.md#phase-1--mvp](../../docs/tasks/roadmap.md#phase-1--mvp)

The reason the project exists: a diff that shows the document instead of
its syntax — over the working tree, and between two refs — plus search
across the space so a large documentation repository stays navigable.

This is the slice the launch demonstration is made of, and the one a
reader has to see before the pitch means anything. It cannot start before
the AST spike reports: the shape of `Block` is that spike's output, and
designing the block differ ahead of it is explicitly out of bounds.
