# Order and shape

How rows are sorted, and where the tree sits.

**Status:** Shipped · Milestone M0

## Rules

- **Folders come before files at every level**, each group in name order. A folder is a place to go and a file is a thing to open, so the two never interleave.
- **Name order ignores case and accents** — `Ácido.md` sorts with the `a`s, not after `zebra.md`.
- **The space's own folder is not a row.** Its children are the tree's top level, and the breadcrumb is what names the space.
- Folders open and close, and a space opens with them open: what it holds is visible without a click.
- The chevron is the set's own, at 16, aligned by its ink rather than its box ([icons](../../../../design/components/icons.md)).
- The tree keeps its place across every screen the app shows; its width is the reader's ([regions](../../../workspace/regions/doc.md)).

## Mocks

- **shell** — folders first, open, the tree in the left column. [light](../../../../design/screens/desktop/workspace-shell/shell-reading-and-editing-light.svg) · [dark](../../../../design/screens/desktop/workspace-shell/shell-reading-and-editing-dark.svg).

---

*See also: [file-tree/](../README.md) · [change-marks/](../change-marks/doc.md)*
