---
id: spec-0006
task_ref: task-0002
status: draft
created: 2026-09-19T21:41:40Z
---

# spec-0006 — Render markdown into the preview pane

**References:** [task-0002](../tasks/task-0002-m0-foundation.md)

- **Goal:** Render a document as formatted output good enough to be the only way someone ever reads it — headings, lists, tables, highlighted code, local images and links.

## Scope

In: parsing with `markdown` behind a contract; rendering through `flutter_markdown_plus`; `re_highlight` for fenced code; local image resolution; opening a document preview-only.

Out: assembling the preview block by block for the diff, which waits on Spike B and belongs to M2. Wikilinks are M3. Editing is `source-mode`'s own work.

## Steps

1. Parse with `markdown` behind the document parsing contract in data.
2. Render the AST through `flutter_markdown_plus` inside the document panel.
3. Wire `re_highlight` for fenced blocks, with a plain-code fallback for unknown languages.
4. Resolve local image paths relative to the document, with a named placeholder where one does not resolve.
5. Offer preview-only as a mode the document area can be opened in.

## Acceptance criteria (EARS)

- When a document containing a table is opened, the system shall render it as a table.
- When a fenced block names a language the highlighter does not know, the system shall render it as plain code rather than failing.
- When an image path does not resolve, the system shall render a named placeholder in its place.
- When a document is opened preview-only, the system shall not construct the source editor.

## Edge cases

- An image path pointing outside the space root, and a remote image URL.
- A document of 10k lines.
- A malformed table, and raw HTML in the source.
- A fenced block that is never closed.

## Tests required

Pure-Dart tests for the parsing contract, one per element kind. Widget tests for the rendered output of tables, code and images, including the missing-image placeholder. A test asserting preview-only builds no editor.

## Definition of Done

- [ ] Every element kind `product/editor/markdown-preview/doc.md` names renders.
- [ ] An unresolvable image degrades visibly, never silently.
- [ ] Preview-only is reachable without the editor in the tree.

## Proposed product changes

- `product/editor/markdown-preview/doc.md` — move the desktop half off Planned and state what shipped.

## Proposed technical changes

- `technical/flows.md#the-preview-is-assembled-block-by-block` — reconcile the chapter with what M0 actually assembles, which is the whole document at once.

## Outcome

_(fill after execution)_
