# Regions

What the window is divided into, and what belongs in each part.

**Status:** Shipped · Milestone M0

## Rules

- The window is four regions: the left column, the document area, the right column, and the status bar. The document area and the status bar are always on screen.
- **A fifth, the panel under the document, is closed until somebody opens it** — it sits under the document column only, and the columns keep their full height ([commands](../commands/doc.md)).
- **Each column is a container with its own edge**, separated from the next by a gutter rather than sharing a hairline. A shared line says the two are one surface split in half; two edges with a gap say they are two things, which is what they are.
- **Each column is an island on the window**: its own fill and its full edge, a gutter in from the window's sides and running from the top bar to the status bar. ~~The edge is drawn only in the gutter~~ — revoked by the 1b restyle, where a column told apart by its own edge needs no line between the bars and it.
- **The document area is two rows of chrome and then the document**: the [tabs](../../editor/tabs/doc.md) on the first row, the tools and the `Diff` chip on the next, and the document under them. ~~And the view~~ — `Source · Split · Preview` is the top bar's since 2026-10-07 ([columns](../columns/doc.md)). Both rows belong to the area and move with it, so opening a column never leaves a control pointing at the wrong place.
- **The left column is navigation and search** — the file tree and the search, box and results together.
- **The right column is git** — `Git` and `History`, switched between rather than stacked. Nothing in one column belongs in the other.
- **`Git` is the whole outbound flow in one place**: what changed, the message, the commit, and then fetch and push at its foot. It is not called `Changes`, because the list is the first thing it shows and no longer the only thing it holds.
- **The left column's width is the reader's**, dragged from the divider between it and the document area. It opens at a width the tree reads well at, and somebody reading search results widens it. It stops at a width the tree can still be read in and at one that would take the document's place; **the width lasts as long as the window**, not longer. **The right column's width is the reader's too**, dragged the same way from its own divider; it stops where `Fetch` and `Pull` no longer fit side by side.
- **A gutter that can be dragged says so through the cursor.** ~~With three dots at its middle~~ — revoked by the 1b restyle: every board leaves the gutter empty, and the islands' own edges are what say where a column ends.
- A board is drawn at whatever width suits what it is showing, so two boards differing in column width are **not** in conflict — `shell` at 220 and the search screens at 360 are the same column, dragged.
- A new panel is added to one of these regions, never bolted on as a separate window or a new top-level mode.

## Mocks

- **committing** — the four regions at once, each column its own container with the gutters between them. [light](../../../design/screens/desktop/git-commit/committing-light.svg) · [dark](../../../design/screens/desktop/git-commit/committing-dark.svg).
- **shell** — the same window with the right column closed: two islands, and the gutter that brings the third back at the window's edge. [light](../../../design/screens/desktop/workspace-shell/shell-light.svg) · [dark](../../../design/screens/desktop/workspace-shell/shell-dark.svg).

---

*See also: [workspace/](../README.md) · [Decision 12](../../../technical/decisions/012-shell-is-extensible-via-compile-time-modules.md)*
