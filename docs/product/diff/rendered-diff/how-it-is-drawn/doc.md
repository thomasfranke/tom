# How a change is drawn

What a marked block looks like, in each pane.

**Status:** Shipped · Milestone M2

## Rules

- A changed block carries a **letter as well as a tint** — A, R, M for a block that arrived, went or was rewritten — because colour is never the only signal.
- **A removed block is still rendered**, struck through, where it used to be. Reading what was deleted is the point of showing it at all.
- **In split view both panes are marked.** Which pane somebody is looking at is not a statement about whether they want to see the change.
- **In the source pane a removed block is a seam, not text.** It is not in the buffer, so drawing it there would put characters in front of somebody that typing cannot reach; a mark between the two lines it used to sit between says the same thing truthfully.

The letters come from the same alphabet as the changes column and the
[file tree](../../../navigation/file-tree/change-marks/doc.md), and the mark is the
`Status mark` component ([controls](../../../../design/components/controls.md)).

---

*See also: [rendered-diff/](../README.md) · [what-is-compared/](../what-is-compared/doc.md) · [source-mode](../../../editor/source-mode/doc.md)*
