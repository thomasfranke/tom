# Branch switch

Move between branches, or start a new one, and watch the documents update — without a terminal.

**Status:** Planned · Milestone M1

## Rules

- The current branch name is always visible — the status bar carries it from the moment a space is open, and a detached `HEAD` is named as that rather than left blank.
- Switching branches updates every open document to the version on the new branch.
- A new branch can be created starting from the current one, and the app switches to it immediately.
- Switching is blocked if it would silently discard unsaved changes; the user is asked to save or discard first. The question names the document, and offers the third answer too — staying where you are. Closing the surface *is* staying, so the question can never be left standing behind something nobody can see.
- The question is asked in the switcher itself, not in a dialog over the window: it belongs to the control that raised it, and nothing else is blocked while it waits.

## Mocks

- [branch-switcher](mocks/branch-switcher.excalidraw) — switch branches, or start one. Visual design: [light](mocks/branch-switcher-light.svg) · [dark](mocks/branch-switcher-dark.svg).

Two faces of the switcher are built and **not drawn yet**: naming a new branch, and the question about unsaved work.

---

*See also: [about.md](../../../about.md) · [roadmap.md](../../../roadmap.md)*
