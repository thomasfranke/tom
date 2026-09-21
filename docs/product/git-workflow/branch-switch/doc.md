# Branch switch

Move between branches, or start a new one, and watch the documents update — without a terminal.

**Status:** Planned · Milestone M1

## Rules

- The current branch name is always visible.
- Switching branches updates every open document to the version on the new branch.
- A new branch can be created starting from the current one, and the app switches to it immediately.
- Switching is blocked if it would silently discard unsaved changes; the user is asked to save or discard first.

## Mocks

- [branch-switcher](mocks/branch-switcher.excalidraw) — switch branches, or start one. Visual design: [light](mocks/branch-switcher-light.svg) · [dark](mocks/branch-switcher-dark.svg).

---

*See also: [about.md](../../../about.md) · [roadmap.md](../../../roadmap.md)*
