# When it cannot be opened

The status row, what it says stands in the way, and the two cases where nothing
is offered at all.

**Status:** Shipped · Milestone M3

## Rules

- **The status row is the screen's own chrome, in the space the tabs had.** It says whether the pull request can be opened and what stands in the way — commits not pushed, work not committed, one already open — in the colour that state already has in the app.
- **It carries an action only when the action can happen where it stands.** `Push` can, because nothing has to change on screen; `Commit` cannot, because committing is the changes panel and this screen gave that column to the pull request. A band that would have to replace the screen under the person who pressed it says the sentence and stops there.
- **The screen carries no `Push`, `Fetch` or `Pull` of its own.** A row that says *3 commits pushed, nothing left to publish* makes a push button a control with no work; and when there *is* something to publish, the status row says so and carries the push, because the action belongs to the thing that named the problem.
- **The `Pull request` row in the explorer is always drawn** — a control that appears only sometimes teaches nothing about when it will. Where there is nothing to propose it is unavailable — muted, not pressable — with the reason under its name in `text_muted` at 11, and the whole sentence in its tooltip:

| Where it stands | The reason |
|---|---|
| On the remote's default branch | `On main — nothing to propose` |
| On no branch | `Not on a branch` |
| `origin` is not on GitHub, GitLab or Bitbucket | `origin is not on a known host` |
| No remote at all | `No remote to propose to` |
| `origin` names no default branch, and there is no `main` or `master` | `origin names no branch to propose onto` |
| Git did not answer | `git could not be read` |

- While the branch is still being read the row is muted with no reason, so nothing jumps when the answer arrives. The row reads the branch itself rather than waiting for the git column, which may be closed.
- **Uncommitted work blocks the opening, and that is a guard rather than a limit.** Git allows it and the host would too — the edit simply would not be in the branch. It is refused because the people this tool is for do not think in commits, and somebody who proposes a change while holding an unsaved one has almost certainly forgotten to include it. So the status row names the consequence, `They would not be in this pull request`, rather than claiming an impossibility, and **both actions go unavailable** — a guard with a second door beside it is not a guard.

- **A branch with no commits over its base has nothing to propose yet, and says so quietly** — `Nothing to propose yet: this branch has no commits over main.` in `text_muted` on `surface_sunken`, with no glyph, because nothing is wrong; the right column's summary reads `No commits over main` with no commit list, and the one action is drawn unavailable.

- **Commits that are not on the remote yet are said in `modified`**, and the row carries `Push`; a branch that was never published says so the same way.
- **A draft with no title stops the opening**: `The draft has no title — its first line is a # heading.`
- One already open is [opening it](../opening-it/doc.md)'s.

## Mocks

- **cannot open yet** — uncommitted work, the row in `removed`, and the action unavailable. [light](../../../../design/screens/desktop/git-pull-request-not-ready/cannot-open-yet-light.svg) · [dark](../../../../design/screens/desktop/git-pull-request-not-ready/cannot-open-yet-dark.svg).
- **not pushed yet** — the row in `modified`, carrying `Push`; opening waits for it. [light](../../../../design/screens/desktop/git-pull-request-not-ready/not-ready-the-status-row-states-light.svg) · [dark](../../../../design/screens/desktop/git-pull-request-not-ready/not-ready-the-status-row-states-dark.svg).
- **no title yet** — a draft whose first line is not a `#` heading. [light](../../../../design/screens/desktop/git-pull-request-not-ready/not-ready-the-status-row-states-light.svg) · [dark](../../../../design/screens/desktop/git-pull-request-not-ready/not-ready-the-status-row-states-dark.svg).
- **not ready — the status row** — documents not committed · not pushed yet · no title yet · nothing to propose. [light](../../../../design/screens/desktop/git-pull-request-not-ready/not-ready-the-status-row-states-light.svg) · [dark](../../../../design/screens/desktop/git-pull-request-not-ready/not-ready-the-status-row-states-dark.svg).
- **nothing to propose — the right column** — `No commits over main`, no list, the action unavailable. [light](../../../../design/screens/desktop/git-pull-request-not-ready/nothing-to-propose-the-right-column-states-light.svg) · [dark](../../../../design/screens/desktop/git-pull-request-not-ready/nothing-to-propose-the-right-column-states-dark.svg).
- **pull request row — states, in the explorer** — the row in each of its reasons. [light](../../../../design/screens/desktop/git-pull-request-not-ready/pull-request-row-states-light.svg) · [dark](../../../../design/screens/desktop/git-pull-request-not-ready/pull-request-row-states-dark.svg).

---

*See also: [pull-request/](../README.md) · [opening it](../opening-it/doc.md) · [when it fails](../../push-pull/when-it-fails/doc.md)*
