# Source-mode editing

Edit the raw markdown text with a live preview alongside — deliberately not a rich-text editor.

**Status:** Planned · Milestone M0

## Rules

- Source and preview are shown side by side; there is no WYSIWYG mode, now or later.
- Edits appear in the preview as they are typed, with no manual refresh step.
- A document with unsaved edits is clearly marked as different from the file on disk.
- Saving writes the buffer to the file on disk. The file on disk is always the true copy — the app holds no state a reload of the file could not reconstruct.
- The document area offers exactly three ways of looking at it — **Source**, **Split**, **Preview** — and a space opens in Split. The choice belongs to the window, not to the document: it stays put when the next file is opened, because someone reading is still reading.
- The unsaved mark is said in three places, in each one's own words: a dot against the file in the explorer, "Unsaved" beside the modes, and `<document> — unsaved` in the status bar with the shortcut that fixes it. A save that is refused says so differently again ("Not saved"), because a refusal needs doing something about and an unwritten edit only needs the shortcut.
- Saving a document nobody changed does nothing. Pressing the shortcut twice is not an error, and a write nobody needs still moves the timestamp Git reads.

## Mocks

- Desktop: **unsaved changes** — the gap between the buffer and the file on disk. [light](../../../design/screens/desktop/editor/unsaved-changes-light.svg) · [dark](../../../design/screens/desktop/editor/unsaved-changes-dark.svg).
- The split view itself is shown in **shell**. [light](../../../design/screens/desktop/workspace/shell-light.svg) · [dark](../../../design/screens/desktop/workspace/shell-dark.svg).
- How a removed block is drawn in this pane is [rendered-diff](../../diff/rendered-diff/how-it-is-drawn/doc.md)'s: a seam between two lines, never characters the buffer does not hold.

---

*See also: [about.md](../../../about.md) · [roadmap.md](../../../roadmap.md) · [Decision 3](../../../technical/decisions/003-editor-is-source-plus-preview.md)*
