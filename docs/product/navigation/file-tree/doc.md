# File tree

Navigate the space's markdown files, including the documentation a team hands to its own tools.

**Status:** Planned · Milestone M0 (desktop) · Exploratory, Phase 3 post-1.0 (mobile, as "documents")

## Rules — desktop

- The tree shows every `.md` file in the space, including dotfolders such as `.ai/` and `.github/`.
- Only `.git/` is hidden — nothing else is filtered out of the tree by default.
- A file the editor cannot open is still shown, and clicking it does nothing: the tree describes the folder the user has, not a filtered version of it. That is every file that is not markdown, and every symbolic link — a link may point outside the space or at nothing, and the tree never follows one to find out.
- Folders open and close, and a space opens with them open: what it holds is visible without a click.
- The document that is open is marked in the tree, so the tree also answers *where am I*.
- The tree's width and position stay the same across every screen the app shows.

## Rules — mobile ("documents")

- The document list is the entry screen — on a phone the tree *is* the first screen, there is no separate sidebar.
- Opening a document pushes onto a navigation stack; there is no split view.
- The list can be filtered by typing, without leaving the screen.

## Mocks

- Desktop: shown as part of the [shell](../../workspace/mocks/shell.excalidraw) layout; no dedicated wireframe yet. Visual design: [light](../../workspace/mocks/shell-light.svg) · [dark](../../workspace/mocks/shell-dark.svg).
- Mobile: [documents](mocks/documents-mobile.excalidraw) — the space as a list.

---

*See also: [about.md](../../../about.md) · [roadmap.md](../../../roadmap.md) · [Decision 8](../../../technical/decisions/008-monorepo-with-pure-dart-core.md)*
