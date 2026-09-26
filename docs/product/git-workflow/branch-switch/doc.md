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

The switcher, and each of the three answers it can give.

- **branch switcher** — the branches, filtered by one box. [light](../../../design/screens/desktop/git-branches/branch-switcher-light.svg) · [dark](../../../design/screens/desktop/git-branches/branch-switcher-dark.svg).
- **starting a branch** — naming a new one from the current branch. [light](../../../design/screens/desktop/git-branches/branch-switcher-new-branch-light.svg) · [dark](../../../design/screens/desktop/git-branches/branch-switcher-new-branch-dark.svg).
- **unsaved work** — the question, inside the switcher, naming the document and offering stay. [light](../../../design/screens/desktop/git-branches/branch-switcher-unsaved-work-light.svg) · [dark](../../../design/screens/desktop/git-branches/branch-switcher-unsaved-work-dark.svg).
- **git refused** — what git said, said where it was asked, with the list still on screen. [light](../../../design/screens/desktop/git-branches/branch-switcher-git-refused-light.svg) · [dark](../../../design/screens/desktop/git-branches/branch-switcher-git-refused-dark.svg).

---

*See also: [about.md](../../../about.md) · [roadmap.md](../../../roadmap.md)*
