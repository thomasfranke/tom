# When it cannot be opened

The status row, what it says stands in the way, and the two cases where nothing
is offered at all.

**Status:** Planned · Milestone M3

## Rules

- **The status row is the screen's own chrome, in the space the tabs had.** It says whether the pull request can be opened and what stands in the way — commits not pushed, work not committed, one already open — in the colour that state already has in the app.
- **It carries an action only when the action can happen where it stands.** `Push` can, because nothing has to change on screen; `Commit` cannot, because committing is the changes panel and this screen gave that column to the pull request. A band that would have to replace the screen under the person who pressed it says the sentence and stops there.
- **The screen carries no `Push`, `Fetch` or `Pull` of its own.** A row that says *3 commits pushed, nothing left to publish* makes a push button a control with no work; and when there *is* something to publish, the status row says so and carries the push, because the action belongs to the thing that named the problem.
- **It is offered only when there is something to propose.** On the remote's default branch there is no branch to open, and no control is drawn at all.
- **Uncommitted work blocks the opening, and that is a guard rather than a limit.** Git allows it and the host would too — the edit simply would not be in the branch. It is refused because the people this tool is for do not think in commits, and somebody who proposes a change while holding an unsaved one has almost certainly forgotten to include it. So the status row names the consequence, `They would not be in this pull request`, rather than claiming an impossibility, and **both actions go unavailable** — a guard with a second door beside it is not a guard.

Two states the status row will carry and nobody has drawn: **commits not
pushed**, in `modified` and offering `Push`; and **one already open**, in
`accent` with the number as the link.

## Mocks

- **cannot open yet** — [light](../../../../design/screens/desktop/git-pull-request/cannot-open-yet-light.svg) · [dark](../../../../design/screens/desktop/git-pull-request/cannot-open-yet-dark.svg).

---

*See also: [pull-request/](../README.md) · [opening it](../opening-it/doc.md) · [when it fails](../../push-pull/when-it-fails/doc.md)*
