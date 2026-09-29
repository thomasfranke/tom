# Measurements

The numbers every board shares, and which of them a board is allowed to differ
on. What a board may carry is [`conventions.md`](conventions.md).

**Normative.** A board that disagrees with a number here is stale, not a
variant — unless the number is one of the two the reader controls.

## The shell

- **Every board draws the shell the same way**: one container per column, each with its own 1px `border` edge and `surface_raised` fill, running under the bars and off both sides of the window so no edge frames the frame.
- **The only line left on screen is the one in a gutter**, and it carries the [`Column grip`](../components/controls.md). A closed column contributes no container and keeps its grip at the window's edge; a board that still draws a full-height hairline is stale.

## The column's foot

- **A column's content ends at 852, sixteen above the status bar.** The containers run under the bars; what sits inside them does not, and a git column whose last button ends at 885 is drawn under the status bar and reads as cut off.
- **The foot group moves as one**, keeping its 12-point gaps.
- **The git column's three remote buttons are 248 and 120 + 120.** `Push` spans the column at `1176,760`; `Fetch` at `1176,812` and `Pull` at `1304,812` share the row under it, eight points apart. Each button's glyph and label are centred as one group, not each on its own ([the controls](../../product/git-workflow/push-pull/the-controls/doc.md)).

## The column's head

- **A request in flight draws a 3-point bar at `1160,52`, 280 wide** — the column's full width, above everything in it, `accent` over `accent_soft` ([while a request runs](../../product/git-workflow/push-pull/while-a-request-runs/doc.md)).

## The row above the document

- **It is measured from the pane, not from the window.** The `Diff` chip's right edge sits **9** inside the document container's right edge, and `Source · Split · Preview` ends **24** before the chip begins — so both travel when a column opens.
- **With the formatting bar hidden the modes go to the window's centre instead**, where they line up with the branch control directly above ([formatting shortcuts](../../product/editor/formatting-shortcuts/doc.md)).

## What the reader controls

- **A column's width is the reader's, so boards differ on it deliberately.** The left column is drawn at 220 where the tree is the subject and at 360 where search results are — one draggable column at two widths, not two screens disagreeing.
- **Everything the reader cannot drag is the same on every board** — bar heights, insets, the document measure — and a board that disagrees about *those* is wrong, not the app.

---

*See also: [screens/](README.md) · [conventions](conventions.md) · [components/controls.md](../components/controls.md)*
