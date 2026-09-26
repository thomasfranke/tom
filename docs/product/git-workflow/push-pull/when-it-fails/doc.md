# When it fails

A push the remote refuses, and a remote that cannot be reached.

**Status:** Planned · Milestone M1

## Rules

- **News from the remote is a band above the document, never a panel.** It spans the document area, is overlaid by the side columns, and pushes the document down rather than covering it.
- The right column keeps working. Taking the changes list, the message box and the history away because a push failed costs more than the news is worth.
- The band carries the sentence and its one action inline at the right — `Pull` for a refusal, `Try again` for a failure — and nothing else.
- **A push the remote rejects is a named failure, not a silent no-op.** The wording says who got there first, what to do about it, and — the part that actually worries people — that **nothing they committed has been lost**.
- **A failure with no remedy is still said.** A push that cannot reach the remote, or that it refuses for any reason other than a moved branch, raises the same band, says nothing was published, and offers to try again.

"YOUR COMMITS" under a rejection, and a conflicting pull, have no board yet —
Phase 2 ([not drawn yet](../../../../design/screens/not-drawn-yet.md)).

## Mocks

- **push rejected** — [light](../../../../design/screens/desktop/git-remote/push-rejected-light.svg) · [dark](../../../../design/screens/desktop/git-remote/push-rejected-dark.svg).
- **push failed** — [light](../../../../design/screens/desktop/git-remote/push-failed-light.svg) · [dark](../../../../design/screens/desktop/git-remote/push-failed-dark.svg).

---

*See also: [push-pull/](../README.md) · [feedback](../../../workspace/feedback/doc.md) · [the message](../../commit/the-message/doc.md)*
