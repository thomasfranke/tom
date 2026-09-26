# Confirming

What the app says while it commits, and once it has.

**Status:** Planned · Milestone M1

## Rules

- **While the commit runs, the button says so and shows it.** It carries the verb in progress and a spinner, and the rows it is about to change are dimmed. A control that only goes quiet leaves somebody wondering whether the click landed.
- **A commit that worked says so.** An emptied list is not a confirmation: it looks the same as a space where nothing had changed.
- The band above the document names the message that was just recorded and says how many commits are now waiting, with `Push` as its one action.
- **The confirmation quotes the message, not the sha** — the message is what somebody just wrote, and the sha is what history is for.
- It names no branch. The branch is already in the top bar and in the status bar.

## Mocks

- **commit in progress** — [light](../../../../design/screens/desktop/git-commit/commit-in-progress-light.svg) · [dark](../../../../design/screens/desktop/git-commit/commit-in-progress-dark.svg).
- **commit succeeded** — [light](../../../../design/screens/desktop/git-commit/commit-succeeded-light.svg) · [dark](../../../../design/screens/desktop/git-commit/commit-succeeded-dark.svg).

---

*See also: [commit/](../README.md) · [feedback](../../../workspace/feedback/doc.md) · [push-pull](../../push-pull/README.md)*
