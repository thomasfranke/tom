# How a change is drawn

What a marked block looks like, in each pane.

**Status:** Shipped · Milestone M2

## Rules

- A changed block carries a **letter as well as a tint** — `A`, `D`, `M` for a block that arrived, went or was rewritten — because colour is never the only signal.
- **The letters mean what they mean in the lists**: a removed block is `D`, as a deleted file is, and `R` is kept for a rename, which only a file can be ([change marks](../../../navigation/file-tree/change-marks/doc.md)) — one letter, one meaning.
- **A removed block is still rendered**, struck through, where it used to be. Reading what was deleted is the point of showing it at all.
- **In split view both panes are marked.** Which pane somebody is looking at is not a statement about whether they want to see the change.
- **In the source pane a removed block is a seam, not text.** It is not in the buffer, so drawing it there would put characters in front of somebody that typing cannot reach; a mark between the two lines it used to sit between says the same thing truthfully.
- **The tint starts 44 from the pane's edge**, before the line numbers and under them.
- The mark is the `Status mark` component ([controls](../../../../design/components/controls.md)).

## Mocks

- **comparing** — split, the left column closed: a modified and an added block marked in both panes. [light](../../../../design/screens/desktop/git-diff/comparing-light.svg) · [dark](../../../../design/screens/desktop/git-diff/comparing-dark.svg).
- **how a change is drawn — each pane** — the tint, the gutter letters and the seam in the source; `M`, `A` and a removed block struck through with `D` in the preview. [light](../../../../design/screens/desktop/git-diff/how-a-change-is-drawn-each-pane-states-light.svg) · [dark](../../../../design/screens/desktop/git-diff/how-a-change-is-drawn-each-pane-states-dark.svg).

---

*See also: [rendered-diff/](../README.md) · [what-is-compared/](../what-is-compared/doc.md) · [source-mode](../../../editor/source-mode/doc.md)*
