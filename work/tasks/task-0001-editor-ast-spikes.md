---
id: task-0001
status: backlog
blocked_reason: null
taken_by: null
spec_ref: [spec-0001, spec-0002]
doc_ref: tasks/roadmap.md#phase-0--spikes
origin: rule
priority: high
depends_on: []
milestone: phase-0
created: 2026-09-19T21:40:21Z
queued: null
completed: null
merged: null
provenance: []
---

# Decide the editor and the AST before the MVP starts

**References:** [tasks/roadmap.md#phase-0--spikes](../../docs/tasks/roadmap.md#phase-0--spikes) · [spec-0001](../specs/spec-0001-spike-editor.md) · [spec-0002](../specs/spec-0002-spike-ast.md)

Two unknowns sit in front of every M0 product and neither is answerable by
reading: whether `re_editor` can carry source mode on a document of real
size, and whether the `markdown` package's AST carries enough to align
blocks between two versions of a file. Each is timeboxed to about a
weekend, and each has a named fallback, so the outcome is a decision
rather than a half-built feature.

They come first because the rest of the plan leans on them. Source-mode
editing in M0 waits on the first. The whole of M2 waits on the second —
the shape of `Block` is that spike's deliverable, and nothing downstream
can be specified until it reports.
