# Source-mode editing

Edit the raw markdown text with a live preview alongside — deliberately not a rich-text editor.

**Status:** Planned · Milestone M0

## Rules

- Source and preview are shown side by side; there is no WYSIWYG mode, now or later.
- Edits appear in the preview as they are typed, with no manual refresh step.
- A document with unsaved edits is clearly marked as different from the file on disk.
- Saving writes the buffer to the file on disk. The file on disk is always the true copy — the app holds no state a reload of the file could not reconstruct.

## Mocks

- [unsaved-changes](mocks/unsaved-changes.excalidraw) — the gap between the buffer and the file on disk.
- The split view itself is shown in the [shell](../../workspace/mocks/shell.excalidraw) layout.

---

*See also: [product.md](../../../product/product.md) · [roadmap.md](../../../product/roadmap.md) · [Decision 3](../../../decisions/003-editor-is-source-plus-preview.md)*
