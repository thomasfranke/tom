# When it fails

A push the remote refuses, and a remote that will not answer.

**Status:** Planned · Milestone M1

## Rules

- **News from the remote is a band above the document, never a panel.** It spans the document area, is overlaid by the side columns, and pushes the document down rather than covering it.
- **The right column keeps working**, message box and commit button included. Taking them away because a push failed costs more than the news is worth, and the next commit is written there.
- The band carries the sentence and its one action inline at the right — `Pull` for a refusal, `Try again` for a failure — and nothing else.
- **The action is offered only when taking it could answer differently.** A missing git, or a folder outside a repository, will answer the same way forever; offering to try again would be promising something.
- **A push the remote rejects is a named failure, not a silent no-op.** The wording says who got there first, what to do about it, and — the part that actually worries people — that **nothing they committed has been lost**.
- **A failure with no remedy is still said.** A push that cannot reach the remote, or that it refuses for any reason other than a moved branch, raises the same band and offers to try again.
- **The sentence says what the failed action did not manage to do** — nothing arrived, nothing changed here, nothing was published — because the three cost different things.
- **A failure the app has no name for says what was refused, never why.** "Git refused the pull" is honest where "the remote could not be reached" would be a guess about a remote that may have answered perfectly.
- **A pull in flight says so on the button that was pressed**, not in the band ([while a request runs](../while-a-request-runs/doc.md)). The band is where the *outcome* lands; the column is where the request is.

A pull git refuses before it starts, because local changes would be
overwritten, is the nameless one today — and it is the failure someone writing
documentation meets most often, so it is the next to earn a sentence. A pull
that *starts* and stops is a different subject:
[when a pull conflicts](../when-a-pull-conflicts/doc.md).

"YOUR COMMITS" under a rejection has no board yet
([not drawn yet](../../../../design/screens/not-drawn-yet.md)).

## Mocks

- **push rejected** — [light](../../../../design/screens/desktop/git-remote/push-rejected-light.svg) · [dark](../../../../design/screens/desktop/git-remote/push-rejected-dark.svg).
- **push failed** — [light](../../../../design/screens/desktop/git-remote/push-failed-light.svg) · [dark](../../../../design/screens/desktop/git-remote/push-failed-dark.svg).

---

*See also: [push-pull/](../README.md) · [feedback](../../../workspace/feedback/doc.md) · [the message](../../commit/the-message/doc.md)*
