# Technical documentation

**How TOM is built.** Developer- and agent-facing: the layer graph, the runtime
flows, the domain model, the dependency stack, the development process, the
visual system — and the numbered decision log underneath all of it.

What the project *is* is [`about.md`](../about.md); what each feature *must do*
is [`product/`](../product/README.md). This folder answers *how*, for a reader
who already knows *what*.

## Chapters

| File | Answers |
|---|---|
| [`layers.md`](layers.md) | The package graph, what enforces it, errors across boundaries, testing |
| [`flows.md`](flows.md) | How it behaves at runtime: the git queue, the watcher protocol, the diff pipeline, wiring |
| [`domain-model.md`](domain-model.md) | The entities and value objects — deliberately partial, with the open questions named |
| [`dependencies.md`](dependencies.md) | The stack, package by package, with licenses and what was deliberately excluded |
| [`setup.md`](setup.md) | Getting a development environment running; CI in two levels |
| [`versioning.md`](versioning.md) | The versioning policy |
| [`repository-settings.md`](repository-settings.md) | Branch protection and the settings that are not in code |
| [`decisions/`](decisions/README.md) | The numbered decision log (ADR) — one file per decision, flat and global |
| [`design/`](design/README.md) | The wireframe index, the visual language, and the tooling that generates both |

## The link-don't-restate rule

A technical doc never states a product rule — it links to the `product/`
chapter that owns it and explains the machinery underneath. When the two
disagree, the product chapter states the intent and the technical section is
what is wrong.

One layer deeper, the same rule applies between this folder and the code:
**the canonical form of a rule is the dartdoc of the code that implements
it.** These files state the rule; the code shows it. When those two disagree,
the code is right and the doc is a bug.

## Normative sections

[`layers.md`](layers.md) and its testing section are **normative** — binding on
every change, not merely descriptive of the current one. Deviating from either
requires a new entry in [`decisions/`](decisions/README.md) stating why, in the
same change that deviates. Never a silent exception.

Every other file here describes current practice and carries no such
requirement.

## Where decisions live

TOM uses a **single flat, chronologically numbered ADR log** in
[`decisions/`](decisions/README.md), not one `decisions.md` per subsystem. The
reason is that several decisions belong to no subsystem at all — 001 is about
licensing, 004 about the business model, 013 about the stack — and splitting
the log by subsystem would leave them homeless while destroying both the
continuous numbering and the "that violates 007" shorthand a review depends
on.

A reversed decision is never deleted; it gets the status *superseded by NNN*.

## Task schema

Tasks live in [`../tasks/`](../tasks/README.md), one file per task, named by id
(`TASK-001.md`), never renamed and never moved.

```yaml
---
id: TASK-005                       # immutable identity, never an ordering
status: pending                    # pending | in-progress | blocked | completed
blocked_reason: null               # required non-null when status: blocked; null otherwise
spec_ref: [SPEC-004]               # list — zero, one, or many specs
product_ref: product/git-workflow/commit/doc.md#staging   # null if purely technical
priority: medium                   # high | medium | low
depends_on: [TASK-002]             # real technical blocking, not sequencing taste
milestone: M1                      # per tasks/roadmap.md
created: 2026-08-22
completed: null
---
```

- `id` is identity, never order. Reprioritising never renames a file, and a
  deleted task's id is never reused.
- `spec_ref` is a list because the relationship is 0..N — a task can ship
  without a spec, or span several. An empty list is valid and explicit; never
  omit the field to mean the same thing.
- The task precedes its specs. A spec is created for an existing task, never
  the other way around — an orphan spec is a structural error.
- `product_ref` is a full path **with an anchor, resolved relative to `docs/`**
  — never a bare filename. That is what makes reverse traceability a grep
  rather than a manual search.
- Every field is present, including the ones that are `null`. An omitted
  `blocked_reason` and an explicit `blocked_reason: null` are not the same
  statement.
- Status lives in front-matter, never in folder position — nothing moves
  between directories as work progresses, so `git log` stays readable without
  `--follow`.

### `blocked` vs. `depends_on`

Two different kinds of "can't start", kept structurally apart:

- **`depends_on`** — blocked *by another task in this queue*. Resolves itself:
  selection skips the task until every dependency is `completed`.
  Machine-checkable, no human judgement needed.
- **`status: blocked`** — blocked *by something outside the queue*: an
  unanswered decision, an upstream release, a spike whose result could
  invalidate the plan. Requires a non-null `blocked_reason` stating what
  unblocks it.

A task never uses `blocked` for something `depends_on` can express — if the
blocker is a task, it is a dependency.

## Spec schema

Specs live in [`../specs/`](../specs/README.md), one file per spec, named by id
(`SPEC-001.md`).

```yaml
---
id: SPEC-004
task_ref: TASK-005                 # a spec belongs to exactly one task
status: draft                      # draft | approved | implemented
created: 2026-08-22
---
```

A spec's body carries what a task's front-matter must not: scope, steps, EARS
acceptance criteria, edge cases, tests required, Definition of Done, and two
sections that close the loop between the ephemeral work and the permanent
docs:

```markdown
## Proposed product changes
- `product/git-workflow/commit/doc.md#staging` — new rule: staging a
  directory stages every tracked file under it.
(or: "none — no behaviour change")

## Proposed technical changes
- `technical/flows.md#one-serialized-queue-per-space` — document the new
  queue entry point.
- `technical/decisions/017-….md` — new decision: why the queue serializes.
(or: "none — no machinery change")

## Outcome
(filled when the task completes: what was actually built, anything that
diverged from the plan above, and why)
```

The **Proposed changes** sections are the merge contract: the diff that
completes the task must touch every path listed, and must not touch a
permanent doc that isn't listed. That is what turns "update the docs in the
same PR" from a prose reminder into something a reviewer or a script can check
mechanically.

## Task selection algorithm

Deterministic, and independent of file layout on disk:

0. **Resume before selecting.** If any task is `in-progress` with no active
   owner, resume it — do not pick new work while started work sits unfinished.
   Only when no resumable task exists does selection proceed.
1. Read the front-matter of every task.
2. Keep those with `status: pending` — `blocked` is excluded by construction.
3. Keep those whose every `depends_on` entry has `status: completed`.
4. Sort by `priority` — `high`, then `medium`, then `low`.
5. Break ties by `created` ascending, then by `id` ascending.
6. Take the first. Read every entry in `spec_ref` and `product_ref` before
   writing any code.

An agent never picks a task by directory listing order, by filename, or by
"the one that looks easiest".

## Divergences from WritRun

TOM follows [WritRun](https://github.com/thomasfranke/whitrun). Where it takes
a different shape from that standard's defaults, the choice is recorded here
rather than left to be reverse-engineered from the file tree:

| Divergence | Status |
|---|---|
| A single flat, numbered ADR log instead of one `decisions.md` per subsystem | **Documented variant.** WritRun leaves the decisions-log shape open; the reasoning is in [Where decisions live](#where-decisions-live). |
| `product/` organized **by feature** (`<group>/<feature>/doc.md` + `mocks/`) instead of by concept | **Documented variant.** WritRun leaves chapter organization open. Mocks live next to the rules they illustrate, which a per-concept layout could not do. |
| Product rules are atomic "must" statements rather than a closing `## Criteria` block in EARS form | **Open gap**, not a variant. The rules are checkable but not yet EARS-shaped, so they do not map one-to-one onto test names. |
| `tasks/` and `specs/` exist with schemas documented, but hold no entries — work selection still runs off [`tasks/roadmap.md`](../tasks/roadmap.md) | **Adopting, not adopted.** Until the roadmap's milestone items become real tasks with specs, nothing mechanically forces `product/` to be touched in the same change that ships a behaviour. |

The last two are what keeps TOM from claiming full adoption today. They are
tracked as work, not as permanent shape.
