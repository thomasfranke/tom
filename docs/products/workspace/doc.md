# Workspace

How the panels sit together on screen: the explorer, the editor/preview, and the status bar, all present at once.

**Status:** Planned · Milestone M0

## Rules

- The explorer, the document area, and the status bar are always on screen together — there is no full-screen takeover that hides the tree while editing.
- The explorer keeps the same width on every screen that shows it. A panel narrower on one screen than another is a bug, not a variant.
- New panels (e.g. full-text search, arriving M2) are added to this layout, not bolted on as a separate window or a new top-level mode.

## Mocks

- [shell](mocks/shell.excalidraw) — the composite view: explorer, source and preview side by side.

---

*See also: [product.md](../../product/product.md) · [roadmap.md](../../product/roadmap.md) · [Decision 12](../../decisions/012-shell-is-extensible-via-compile-time-modules.md)*
