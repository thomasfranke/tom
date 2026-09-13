# Specs — the detail of one change

**Historical record — not a description of the present.** One file per spec,
named by id (`SPEC-001.md`). A spec belongs to exactly one task (`task_ref`)
and inherits its order and priority from it; specs have no sequence of their
own. The full schema is in
[`technical/README.md`](../technical/README.md#spec-schema).

A spec is the **elaboration** of a task's request: scope, steps, EARS
acceptance criteria, edge cases, tests required, Definition of Done — and the
two **Proposed changes** sections that list exactly which permanent docs the
change will touch. That list is the merge contract: the completing diff must
touch everything listed and nothing permanent that isn't.

An orphan spec — one with no task it elaborates — is a structural error, not a
shortcut.

## Lifecycle

`draft → approved → implemented`

- **draft** — written, typically by an agent, for an existing task. Nothing in
  draft status may be treated as authorized to implement.
- **approved** — the gate. In this repo approval is **human only**; an agent
  never self-approves, not even a draft it wrote itself. See the gates table in
  [`AGENTS.md`](../../AGENTS.md).
- **implemented** — set when the task completes and the **Outcome** section
  records what was actually built, including any divergence from the plan.

An implemented spec is never edited to match reality retroactively beyond its
Outcome section — the divergence *is* the record, not something to smooth over.
[`product/`](../product/README.md) and [`technical/`](../technical/README.md)
describe the present; a spec preserves what was intended and what happened.

## Current state — empty

No specs yet. The queue that would produce them is empty too — see
[`tasks/README.md`](../tasks/README.md#current-state--the-queue-is-empty).

---

*See also: [tasks/](../tasks/README.md) · [technical/README.md](../technical/README.md#spec-schema)*
