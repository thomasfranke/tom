# Regions

What the window is divided into, and what belongs in each part.

**Status:** Planned · Milestone M0

## Rules

- The window is four regions: the left column, the document area, the right column, and the status bar. The document area and the status bar are always on screen.
- **Each column is a container with its own edge**, separated from the next by a gutter rather than sharing a hairline. A shared line says the two are one surface split in half; two edges with a gap say they are two things, which is what they are.
- **The edge is drawn only in the gutter.** A container runs under the bars and past the window's sides, so the only borders on screen are the ones between two containers — an edge against the window frames nothing.
- **The document area is two rows of chrome and then the document**: the tools and the view on one row, the [tabs](../../editor/tabs/doc.md) on the next, and the document under them. Both rows belong to the area and move with it, so opening a column never leaves a control pointing at the wrong place.
- **The left column is navigation and search** — the file tree and the search, box and results together.
- **The right column is git** — `Git` and `History`, switched between rather than stacked. Nothing in one column belongs in the other.
- **`Git` is the whole outbound flow in one place**: what changed, the message, the commit, and then fetch and push at its foot. It is not called `Changes`, because the list is the first thing it shows and no longer the only thing it holds.
- **The left column's width is the reader's**, dragged from the divider between it and the document area. It opens at a width the tree reads well at, and somebody reading search results widens it. It stops at a width the tree can still be read in and at one that would take the document's place; **the width lasts as long as the window**, not longer.
- **A divider that can be dragged says so**, with three dots at its middle. A width nobody can see is a width nobody moves: the rule above was true for months and the divider looked like every other hairline.
- A board is drawn at whatever width suits what it is showing, so two boards differing in column width are **not** in conflict — `shell` at 220 and the search screens at 360 are the same column, dragged.
- A new panel is added to one of these regions, never bolted on as a separate window or a new top-level mode.

## Mocks

- **committing** — the four regions at once, each column its own container with the gutters between them. [light](../../../design/screens/desktop/git-commit/committing-light.svg) · [dark](../../../design/screens/desktop/git-commit/committing-dark.svg).
- **shell** — the same window with the right column closed: two containers, and its grip waiting at the window's edge. [light](../../../design/screens/desktop/workspace/shell-light.svg) · [dark](../../../design/screens/desktop/workspace/shell-dark.svg).

---

*See also: [workspace/](../README.md) · [Decision 12](../../../technical/decisions/012-shell-is-extensible-via-compile-time-modules.md)*
