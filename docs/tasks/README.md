# Tasks — the queue

**What is being worked on, and in which order.** One file per task, named by id
(`TASK-001.md`), never renamed, never moved. Status, priority and dependencies
live in front-matter — the full schema and the selection algorithm are in
[`technical/README.md`](../technical/README.md#task-schema).

A task is the **request**: what to do, when, what blocks it. It holds no
technical detail — scope, steps and acceptance criteria belong to its spec(s)
in [`specs/`](../specs/README.md). The task always exists before its specs.

## Current state — the queue is empty

There are no `TASK-NNN.md` files yet. Work is still selected from
[`roadmap.md`](roadmap.md), which lists the milestone items for M0–M3 with a
link to each one's `doc.md` under [`product/`](../product/README.md).

That is a transitional state, and a known gap: a roadmap checklist does not
carry the **Proposed changes** contract a spec does, so nothing mechanically
forces a feature's `doc.md` to be updated in the same change that ships the
behaviour. Converting the roadmap's items into real tasks — each with a
`milestone`, a `product_ref`, and a spec where the brief needs one — is the
step that closes it. Recorded in
[`technical/README.md`](../technical/README.md#divergences-from-writrun).

Until then, `roadmap.md` lives here rather than in `product/` or `technical/`
for one reason: it describes a **plan**, and a permanent doc describes the
system as it is today. A plan belongs on the ephemeral side, next to the queue
it will become.

## What earns a task

Work that justifies tracking: a behaviour change, a new subsystem, anything a
future reader might reasonably ask "why was this done" about. A typo or a
one-line fix is a commit, not a task — forcing trivial work through the queue
cheapens what the queue is for.

## For agents

Do not choose work by reading this file top to bottom, or by directory listing
order. Run the [selection
algorithm](../technical/README.md#task-selection-algorithm): resume
`in-progress` first, then filter, sort, and take the first. Read every
referenced spec and product anchor before writing code.

When a task's `spec_ref` is empty and its body plus `product_ref` do not add up
to a brief you could implement without guessing, **stop and ask** whether to
draft a spec first. Do not improvise scope to keep moving — see the gates table
in [`AGENTS.md`](../../AGENTS.md).

---

*See also: [roadmap.md](roadmap.md) · [specs/](../specs/README.md) · [product/](../product/README.md)*
