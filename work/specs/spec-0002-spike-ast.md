---
id: spec-0002
task_ref: task-0001
status: draft
created: 2026-09-19T21:41:34Z
---

# spec-0002 — Decide whether the markdown AST can carry the block diff

**References:** [task-0001](../tasks/task-0001-editor-ast-spikes.md)

- **Goal:** Answer whether the `markdown` package's `Node`/`Element` AST carries enough — source positions, block granularity — to align two versions of a document, and produce the shape of `Block`.

## Scope

In: parsing two sibling markdown files; aligning their block sequences; classifying each block unchanged, added, removed or modified; whether a single block renders in isolation; every question `technical/domain-model.md` raises under `Block`.

Out: implementing `BlockDiffer` in `src/`, the diff UI, and the similarity threshold that separates *modified* from *removed plus added* — all of which are M2, and none of which can be designed before this reports.

## Steps

1. Parse two versions of one document with `markdown` and dump the AST.
2. Record per node: its type, its source span where one exists, and whether the original text is recoverable from it.
3. Align the two block sequences and classify every pair.
4. Render one block alone through `flutter_markdown_plus` and see whether it stands without its document.
5. Answer every question `technical/domain-model.md` lists under `Block`.
6. Write the shape of `Block`, or name the fallback — our own parser, or post-processing the AST — with its cost.

## Acceptance criteria (EARS)

- When two versions of a document are parsed, the spike shall report for every block whether its source span is recoverable from the AST.
- When a block is rendered outside its document, the spike shall record whether constructs needing document context — link definitions, footnotes — survive.
- When the AST cannot supply a source span, the spike shall name the post-processing that would, and what it costs.
- When the shape of `Block` is written, `technical/domain-model.md` shall carry it out of Open.

## Edge cases

- Nested lists, and a list item holding a fenced block.
- Fenced code whose content is itself markdown.
- Tables, setext headings, and raw HTML blocks.
- A document ending without a trailing newline.

## Tests required

None merged — this is a probe. Code that survives arrives with M2 under its own spec, with its own tests.

## Definition of Done

- [ ] Every question under `Block` in `technical/domain-model.md` has an answer.
- [ ] `Block`'s shape is written, or the fallback is named with its cost.
- [ ] Whether a block renders in isolation is answered yes or no, with evidence.
- [ ] Spike B is checked off in `docs/tasks/roadmap.md`.

## Proposed product changes

- none — a spike decides; it ships no behaviour.

## Proposed technical changes

- `technical/domain-model.md#settled` — carry `Block` out of Open and into Settled with its shape, or state why it stays open.

## Outcome

_(fill after execution)_

> If the answer contradicts `technical/flows.md#the-preview-is-assembled-block-by-block`, amend this spec before completing it. The delta gate reads the promise above, not the intent.
