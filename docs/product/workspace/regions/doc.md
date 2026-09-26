# Regions

What the window is divided into, and what belongs in each part.

**Status:** Planned · Milestone M0

## Rules

- The window is four regions: the left column, the document area, the right column, and the status bar. The document area and the status bar are always on screen.
- **The left column is navigation and search** — the file tree and the search, box and results together.
- **The right column is git** — changes and history. Nothing in one column belongs in the other.
- The columns keep the same width on every screen that shows them. A panel narrower on one screen than another is a bug, not a variant.
- A new panel is added to one of these regions, never bolted on as a separate window or a new top-level mode.

## Mocks

- **shell** — the four regions at once. [light](../../../design/screens/desktop/workspace/shell-light.svg) · [dark](../../../design/screens/desktop/workspace/shell-dark.svg).

---

*See also: [workspace/](../README.md) · [Decision 12](../../../technical/decisions/012-shell-is-extensible-via-compile-time-modules.md)*
