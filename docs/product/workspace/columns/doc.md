# Columns and their controls

Hiding a column, and the controls in the top bar that do it.

**Status:** Shipped · Milestone M0

## Rules

- Either column can be hidden, and both are hidden from the same pair of controls at the right of the top bar. The document area takes the room that is freed; nothing else moves.
- **A third toggle sits between the two**, its strip along the bottom: it opens and closes the [panel under the document](../commands/doc.md), which starts closed.
- A hidden column is a column, not a mode: what was on screen comes back unchanged, and hiding one never changes what the document area is showing.
- **A hidden column keeps its gutter, at the window's edge.** The gutter that widens a column is the same gutter that brings a closed one back — a drag on it opens the column — so hiding one never hides the way to undo it, and the toggle in the bar stops being the only way. Nothing is drawn on the gutter; the cursor says it can be dragged.
- **A toggle always draws its full outline and the divider inside it.** The strip is filled when that column is open and empty when it is closed — an outline with nothing in it says which column the control belongs to, and an outline with nothing at all says nothing.
- **The gear that opens [preferences](../../preferences/the-popover/doc.md) comes after the toggles**, drawn in their grammar so they read as one set; **[the account](../the-account/doc.md) is the bar's last control**, on Home too. The bar has no theme toggle — the theme is inside the popover.
- **The `Source · Split · Preview` control sits in the top bar, before the column toggles.** It is a choice about the whole window, like opening a column, so it lives with the controls that are — and the row above the document keeps its room for the [formatting bar](../../editor/formatting-shortcuts/doc.md).
- **The right column shows one git panel at a time, chosen by a `Git · History` switch at its head.** The switch stands where a caption would, because a caption says what you are looking at and the switch says that and what else there is.
- **The `Git` tab carries a count**: how many files have changed.
- Which panel is showing is the column's own state, not the document's. Opening another file does not change it.

Stacking the git panels was the earlier arrangement and it does not survive a
third: a share of the height is not always enough panel to read, and the bottom
one ends up below the fold on the window the app opens at.

## Mocks

- **shell** — the right column closed, the toggles at the right of the bar, and the closed column's gutter at the window's edge. [light](../../../design/screens/desktop/workspace-shell/shell-reading-and-editing-light.svg) · [dark](../../../design/screens/desktop/workspace-shell/shell-reading-and-editing-dark.svg).
- **committing** — both columns open, which is what the same controls look like the other way. [light](../../../design/screens/desktop/git-commit/committing-light.svg) · [dark](../../../design/screens/desktop/git-commit/committing-dark.svg).
- The diff screens are drawn with the left column closed: [rendered-diff](../../diff/rendered-diff/README.md).

---

*See also: [workspace/](../README.md) · [regions/](../regions/doc.md) · [components/controls.md](../../../design/components/controls.md)*
