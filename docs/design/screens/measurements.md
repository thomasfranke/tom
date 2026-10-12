# Measurements

The numbers every board shares, and which of them a board is allowed to differ
on. What a board may carry is [`conventions.md`](conventions.md).

**Normative.** A board that disagrees with a number here is stale, not a
variant — unless the number is one of the two the reader controls.

## The shell

- **Every board draws the shell the same way**: the window is `surface`, and each column is an island on it — `surface_raised`, a 1px `border` edge, radius 10 — 6 from the window's sides and 6 from the next island.
- **The two bars are 40 and 32**, on the window's own fill with no rule under or over them. The islands run from one to the other: `y` 40 to 868 on a 900 window.
- **Nothing is drawn in the gap between two islands.** It is still what the reader drags; a board that draws a grip or a full-height hairline there is stale.
- **The top bar's right end is fixed**: the modes at 1046, then the left, bottom and right toggles at 1278 · 1308 · 1338, the gear at 1368 and the account button at 1402, on a 1440 window. The branch control is centred on the window.

## The column's foot

- **The git column's content is 14 in from its island's edges**: 254 wide at `1166` when the column is at the width it opens at.
- **The commit button is 254 × 32 and `Push` 254 × 30 under it; `Fetch` and `Pull` are 123 + 123 on the row below, 8 apart.** Each button's glyph and label are centred as one group, not each on its own ([the controls](../../product/git-workflow/push-pull/the-controls/doc.md)).
- **The foot group moves as one**, and the line that says where the branch stands sits under it.

## The column's head

- **A request in flight draws a 3-point bar across the top of the git column**, the column's full width, above everything in it, `accent` over `accent_soft` ([while a request runs](../../product/git-workflow/push-pull/while-a-request-runs/doc.md)).
- **A column's `⋮` is centred 15.5 from its island's edge**, in both columns.

## The row above the document

- **It is 36 tall, on the document island's own `surface_raised`**, the width of the island — the toolbar's buttons are flat glyphs on it, with no tile of their own.
- **It is measured from the island, not from the window.** The `Diff` chip's right edge sits **12** inside the document island's right edge, so it travels when a column opens.
- **It holds the tools and the `Diff` chip; the modes are in the top bar** and never move, whether the formatting bar is shown or hidden.

## What the reader controls

- **A column's width is the reader's, so boards differ on it deliberately.** The left column opens at 256 and the right at 282; a board draws either wider where what it holds is the subject — search results, for one.
- **Whether a column is open is the reader's too.**
- **Everything the reader cannot drag is the same on every board** — bar heights, insets, the document measure — and a board that disagrees about *those* is wrong, not the app.

---

*See also: [screens/](README.md) · [conventions](conventions.md) · [components/controls.md](../components/controls.md)*
