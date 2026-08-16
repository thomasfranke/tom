# File tree

Navigate the space's markdown files, including the documentation a team hands to its own tools.

**Status:** Planned · Milestone M0 (desktop) · Exploratory, Phase 3 post-1.0 (mobile, as "documents")

## Rules — desktop

- The tree shows every `.md` file in the space, including dotfolders such as `.claude/` and `.github/`.
- Only `.git/` is hidden — nothing else is filtered out of the tree by default.
- The tree's width and position stay the same across every screen the app shows.

## Rules — mobile ("documents")

- The document list is the entry screen — on a phone the tree *is* the first screen, there is no separate sidebar.
- Opening a document pushes onto a navigation stack; there is no split view.
- The list can be filtered by typing, without leaving the screen.

## Mocks

- Desktop: shown as part of the [shell](../../workspace/mocks/shell.excalidraw) layout; no dedicated wireframe yet.
- Mobile: [documents](mocks/documents-mobile.excalidraw) — the space as a list.

---

*See also: [product.md](../../../product/product.md) · [roadmap.md](../../../product/roadmap.md) · [Decision 8](../../../decisions/008-monorepo-with-pure-dart-core.md)*
