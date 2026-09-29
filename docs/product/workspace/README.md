# Workspace

How the app sits on screen once a space is open: the columns, the document area
and the status bar, all present at once.

**Status:** Planned · Milestone M0

| | |
|---|---|
| [`regions/`](regions/doc.md) | The four regions, what each column is for, and how a panel is added |
| [`columns/`](columns/doc.md) | Hiding a column, the toggles, the preferences button, the git switch |
| [`leaving-a-space/`](leaving-a-space/doc.md) | The breadcrumb menu, closing, switching, and the unsaved question |
| [`feedback/`](feedback/doc.md) | What the app says while it works and when it finishes |
| [`without-a-repository/`](without-a-repository/doc.md) | The folder git knows nothing about, and what the right column says instead |

## Mocks

- **shell** — the columns and the document area, drawn with the right column closed. [light](../../design/screens/desktop/workspace/shell-light.svg) · [dark](../../design/screens/desktop/workspace/shell-dark.svg).
- **committing** — all four regions at once, which is what the git column looks like open. [light](../../design/screens/desktop/git-commit/committing-light.svg) · [dark](../../design/screens/desktop/git-commit/committing-dark.svg).
- **closing the space** — the breadcrumb's menu, recent spaces above and **Close space** at the foot. [light](../../design/screens/desktop/workspace/closing-the-space-light.svg) · [dark](../../design/screens/desktop/workspace/closing-the-space-dark.svg).
- **closing with unsaved work** — the same menu, with the question. [light](../../design/screens/desktop/workspace/closing-the-space-unsaved-work-light.svg) · [dark](../../design/screens/desktop/workspace/closing-the-space-unsaved-work-dark.svg).

---

*See also: [product/](../README.md) · [about.md](../../about.md) · [roadmap.md](../../roadmap.md) · [Decision 12](../../technical/decisions/012-shell-is-extensible-via-compile-time-modules.md)*
