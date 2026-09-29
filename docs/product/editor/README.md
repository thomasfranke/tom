# Editor

Reading and writing a document: the source, the preview, the documents that are
open, and the tools above them.

**Status:** Planned · Milestone M1–M3

The editor is deliberately simple — source plus preview, never WYSIWYG
([Decision 3](../../technical/decisions/003-editor-is-source-plus-preview.md)).

| | |
|---|---|
| [`source-mode/`](source-mode/doc.md) | The buffer, saving, and what the mode bar says |
| [`markdown-preview/`](markdown-preview/doc.md) | What the rendered view draws, and what it will not |
| [`tabs/`](tabs/doc.md) | The documents that are open, preview mode, and closing one with edits |
| [`formatting-shortcuts/`](formatting-shortcuts/doc.md) | The seventeen buttons, the row they share with the view |
| [`conflicted-document/`](conflicted-document/doc.md) | Both sides of a merge, in source and in preview |

---

*See also: [product/](../README.md) · [workspace/](../workspace/README.md) · [design/screens/](../../design/screens/README.md)*
