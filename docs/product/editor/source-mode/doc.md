# Source-mode editing

Edit the raw markdown text with a live preview alongside — deliberately not a rich-text editor.

**Status:** Shipped · Milestone M0

## Rules

- Source and preview are shown side by side; there is no WYSIWYG mode, now or later.
- Edits appear in the preview as they are typed, with no manual refresh step.
- **The source pane is numbered**, right-aligned in a column of its own so the first character of a line sits at the same place whatever the document's length. A gutter left of the numbers is where a changed block's letter goes.
- A document with unsaved edits is clearly marked as different from the file on disk.
- Saving writes the buffer to the file on disk. The file on disk is always the true copy — the app holds no state a reload of the file could not reconstruct.
- The document area offers exactly three ways of looking at it — **Source**, **Split**, **Preview** — and a space opens in Split. The choice belongs to the window, not to the document: it stays put when the next file is opened, because someone reading is still reading.
- **A save asks the disk first, for every document.** A file that changed on disk under an unsaved edit is never written over: nothing is written, and a band over the document says `<name> changed on disk while you were editing it.`, in `modified`, with `Keep mine` — the next save writes the edit, once — and `Reload`, which reads the file again.
- A file that was deleted on disk under an edit is written again without asking — nothing of anybody's is written over.
- **A save replaces the text and nothing else**: a symbolic link stays a link and the file it points at is written, and the file keeps its permissions.
- **A file nobody may write to refuses the save** and is left as it was — the permission is its owner's word.
- Nothing watches the folder: a change made outside TOM is caught by that save, and by `Reload` in the [explorer menu](../../navigation/file-tree/explorer-menu/doc.md).
- The unsaved mark is said in three places, in each one's own words: a dot against the file in the explorer, **a dot on the document's own tab**, and `Unsaved` in the [status bar](../../workspace/status-bar/doc.md) — `Saving…` while the write runs, `Saved` once it has.
- **The row above the document says nothing about an unwritten edit** — the tab's dot says it closer to the document it is about ([tabs](../tabs/doc.md)). It says `Not saved` when a save was refused, which a dot cannot: a refusal needs doing something about, and an unwritten edit only needs the shortcut.
- **Saving stays explicit, and auto-save was considered and dropped.** The problem it was meant to solve — losing track of an edited document when the next one opens — is answered by the [tabs](../tabs/doc.md), which keep every changed file on screen with its dot. Saving on its own would have made git see a change at every keystroke, which in a git client is a worse trade than pressing a key.
- Saving a document nobody changed does nothing. Pressing the shortcut twice is not an error, and a write nobody needs still moves the timestamp Git reads.

## Mocks

- Desktop: **unsaved changes** — the gap between the buffer and the file on disk. [light](../../../design/screens/desktop/editor/unsaved-changes-light.svg) · [dark](../../../design/screens/desktop/editor/unsaved-changes-dark.svg).
- **saving — what the window says** — unsaved · `Saving…` · saved · `Not saved`, a refused save, in the row above the document. [light](../../../design/screens/desktop/editor/saving-what-the-window-says-states-light.svg) · [dark](../../../design/screens/desktop/editor/saving-what-the-window-says-states-dark.svg).
- **changed on disk — the band** — `Keep mine` and `Reload` over a document with unsaved edits. [light](../../../design/screens/desktop/editor/changed-on-disk-the-band-states-light.svg) · [dark](../../../design/screens/desktop/editor/changed-on-disk-the-band-states-dark.svg).
- The split view itself is shown in **shell**. [light](../../../design/screens/desktop/workspace-shell/shell-reading-and-editing-light.svg) · [dark](../../../design/screens/desktop/workspace-shell/shell-reading-and-editing-dark.svg).
- How a removed block is drawn in this pane is [rendered-diff](../../diff/rendered-diff/how-it-is-drawn/doc.md)'s: a seam between two lines, never characters the buffer does not hold.

---

*See also: [about.md](../../../about.md) · [roadmap.md](../../../roadmap.md) · [Decision 3](../../../technical/decisions/003-editor-is-source-plus-preview.md)*
