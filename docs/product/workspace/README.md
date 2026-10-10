# Workspace

How the app sits on screen once a space is open: the columns, the document area
and the status bar, all present at once.

**Status:** Shipped · Milestone M0 — except [a folder that is not a repository](without-a-repository/doc.md), Planned · Milestone M3

| | |
|---|---|
| [`regions/`](regions/doc.md) | The four regions, what each column is for, and how a panel is added |
| [`columns/`](columns/doc.md) | Hiding a column, the toggles, the preferences button, the git switch |
| [`leaving-a-space/`](leaving-a-space/doc.md) | The breadcrumb menu, closing, switching, and the unsaved question |
| [`feedback/`](feedback/doc.md) | What the app says while it works and when it finishes |
| [`without-a-repository/`](without-a-repository/doc.md) | The folder git knows nothing about, and what the right column says instead |
| [`the-account/`](the-account/doc.md) | Who commits, the GitHub login the computer holds, and what it may do here |
| [`commands/`](commands/doc.md) | Every command TOM runs, as it ran it, in a read-only panel under the document |
| [`terminal/`](terminal/doc.md) | The person's own shell, at the repository's root, in the same panel's second tab |

## Mocks

- **shell** — the columns and the document area, drawn with the right column closed. [light](../../design/screens/desktop/workspace-shell/shell-light.svg) · [dark](../../design/screens/desktop/workspace-shell/shell-dark.svg).
- **committing** — all four regions at once, which is what the git column looks like open. [light](../../design/screens/desktop/git-commit/committing-light.svg) · [dark](../../design/screens/desktop/git-commit/committing-dark.svg).
- **closing the space** — the breadcrumb's menu, recent spaces above and **Close space** at the foot. [light](../../design/screens/desktop/workspace-shell/closing-the-space-light.svg) · [dark](../../design/screens/desktop/workspace-shell/closing-the-space-dark.svg).
- **closing with unsaved work** — the same menu, with the question. [light](../../design/screens/desktop/workspace-shell/closing-the-space-unsaved-work-light.svg) · [dark](../../design/screens/desktop/workspace-shell/closing-the-space-unsaved-work-dark.svg).

---

*See also: [product/](../README.md) · [about.md](../../about.md) · [roadmap.md](../../roadmap.md) · [Decision 12](../../technical/decisions/012-shell-is-extensible-via-compile-time-modules.md)*
