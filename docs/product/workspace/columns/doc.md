# Columns and their controls

Hiding a column, and the controls in the top bar that do it.

**Status:** Planned · Milestone M0

## Rules

- Either column can be hidden, and both are hidden from the same pair of controls at the right of the top bar. The document area takes the room that is freed; nothing else moves.
- A hidden column is a column, not a mode: what was on screen comes back unchanged, and hiding one never changes what the document area is showing.
- **A toggle always draws its full outline and the divider inside it.** The strip is filled when that column is open and empty when it is closed — an outline with nothing in it says which column the control belongs to, and an outline with nothing at all says nothing.
- **Light and dark are switched from the same group**, by a control beside the two column toggles, drawn in their grammar so the three read as one set rather than as a control that wandered in.
- **The `Source · Split · Preview` control is centred on the window and stays there.** It is fixed to the window's centre, not to the centre of the document area, so it does not move when a column is hidden.
- **The right column shows one git panel at a time, chosen by a `Changes · History` switch at its head.** The switch replaces the caption that used to name the panel, because a caption says what you are looking at and the switch says that and what else there is.
- Which panel is showing is the column's own state, not the document's. Opening another file does not change it.

Stacking the git panels was the earlier arrangement and it does not survive a
third: a share of the height is not always enough panel to read, and the bottom
one ends up below the fold on the window the app opens at.

## Mocks

- **shell** — both columns open, the toggles at the right of the bar. [light](../../../design/screens/desktop/workspace/shell-light.svg) · [dark](../../../design/screens/desktop/workspace/shell-dark.svg).
- The diff screens are drawn with the left column closed: [rendered-diff](../../diff/rendered-diff/README.md).

---

*See also: [workspace/](../README.md) · [regions/](../regions/doc.md) · [components/controls.md](../../../design/components/controls.md)*
