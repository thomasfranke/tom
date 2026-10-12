# When it fails

A push the remote refuses, and a remote that will not answer.

**Status:** Shipped · Milestone M1

## Rules

- **News from the remote is a band above the document, never a panel.** It spans the document area, is overlaid by the side columns, and pushes the document down rather than covering it.
- **The right column keeps working**, message box and commit button included. Taking them away because a push failed costs more than the news is worth, and the next commit is written there.
- The band carries the sentence and its remedy inline at the right — `Pull` for a rejection, `Try again` for a failure — and before the remedy `Show the command`, which opens the [commands panel](../../../workspace/commands/doc.md) on what git said and changes nothing.
- **A refusal wears `modified` and a failure `removed`** — refused, nothing broke and there is something to do; failed, something did not work.
- **The action is offered only when taking it could answer differently.** A missing git, or a folder outside a repository, will answer the same way forever; offering to try again would be promising something.
- **A push the remote rejects is a named failure, not a silent no-op.** The wording says who got there first, what to do about it, and — the part that actually worries people — that **nothing they committed has been lost**.
- **A branch the remote protects is named too**: `The remote refused this branch. Nothing was published, and nothing you committed has been lost.` It wears `modified`, carries no `Try again` — which would answer the same for ever — and offers `Show the command` and `Pull request`, the way into a protected branch ([the control](../../pull-request/the-control/doc.md)); `Pull request` shows only while one can be opened.
- **A failure with no remedy is still said.** A push that cannot reach the remote, or that it refuses for a reason the app has no name for, raises the same band and offers to try again.
- **The sentence says what the failed action did not manage to do** — nothing arrived, nothing changed here, nothing was published — because the three cost different things.
- **A failure the app has no name for says what was refused, never why.** "Git refused the pull" is honest where "the remote could not be reached" would be a guess about a remote that may have answered perfectly.
- **A pull in flight says so on the button that was pressed**, not in the band ([while a request runs](../while-a-request-runs/doc.md)). The band is where the *outcome* lands; the column is where the request is.

- **A pull git refuses because it would overwrite uncommitted work is a named failure** — the one someone writing documentation meets most often. The band names the file when there is one and counts them when there are more, says nothing changed here, and gives the remedy: commit them, then try again. It wears `modified`, the refusal's colour, because nothing failed and there is something to do; `Try again` stays, because after the commit the same press answers differently.

A pull that *starts* and stops is a different subject:
[when a pull conflicts](../when-a-pull-conflicts/doc.md).

"YOUR COMMITS" under a rejection is Phase 2 and has no board yet
([not drawn yet](../../../../design/screens/not-drawn-yet.md)).

## Mocks

- **push rejected** — the remote moved first, said in the band with `Pull`. [light](../../../../design/screens/desktop/git-push/push-rejected-light.svg) · [dark](../../../../design/screens/desktop/git-push/push-rejected-dark.svg).
- **push failed** — the remote could not be reached: the same band, `Try again`, nothing published. [light](../../../../design/screens/desktop/git-push/after-a-push-the-band-states-light.svg) · [dark](../../../../design/screens/desktop/git-push/after-a-push-the-band-states-dark.svg).
- **push rejected** — the whole window with the band. [light](../../../../design/screens/desktop/git-push/push-rejected-light.svg) · [dark](../../../../design/screens/desktop/git-push/push-rejected-dark.svg).
- **after a push — the band** — it worked · rejected · refused, the branch is protected · failed. [light](../../../../design/screens/desktop/git-push/after-a-push-the-band-states-light.svg) · [dark](../../../../design/screens/desktop/git-push/after-a-push-the-band-states-dark.svg).
- **after a pull or a fetch — the band** — its states refused over uncommitted work, failed, and a fetch that failed. [light](../../../../design/screens/desktop/git-pull/after-a-pull-or-a-fetch-the-band-states-light.svg) · [dark](../../../../design/screens/desktop/git-pull/after-a-pull-or-a-fetch-the-band-states-dark.svg).

---

*See also: [push-pull/](../README.md) · [feedback](../../../workspace/feedback/doc.md) · [the message](../../commit/the-message/doc.md)*
