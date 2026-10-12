# The message

Every commit carries one, and the box is not taken away lightly.

**Status:** Shipped · Milestone M1

## Rules

- **A commit requires a message.** Committing with nothing staged is disabled.
- **The box holds a summary and an optional description**, the summary on the first line and the description under it. What is required is the summary; a description, when there is one, follows it after a blank line, which is how git tells the two apart. Enter in the summary moves to the description.
- **`⌘Enter` commits** (`Ctrl+Enter` off macOS); Enter alone does not, because in the summary it moves down.
- **Committing with the repository on no branch is refused**, and the refusal says so where it was asked for, above the message box: `Not on a branch — switch to one to commit.` The button reads `Commit`, with no branch to name, and is unavailable. Git itself would allow it, onto no branch, and the commit would be reachable from nothing the moment `HEAD` moved — which is the one outcome this product promises never happens.
- The refusal is the app's policy, not git's answer, so it costs no round trip: the branch is already on the session from the last reading.
- **The message box is never taken away**, not because git is working and not because a push stands refused. Working on something else is not a reason to interrupt a sentence, and the refusal is a band above the document — the column it would have replaced is where the next commit is written.
- **A merge in progress fills the box rather than emptying it**, with the message git already wrote, editable like any other: concluding a merge is a commit ([when a pull conflicts](../../push-pull/when-a-pull-conflicts/doc.md)).

## Mocks

- **committing** — the summary and the description over `Commit to <branch>`. [light](../../../../design/screens/desktop/git-commit/committing-light.svg) · [dark](../../../../design/screens/desktop/git-commit/committing-dark.svg).
- **the git column while a commit runs** — its states `Nothing staged` and `Not on a branch`. [light](../../../../design/screens/desktop/git-commit/the-git-column-while-a-commit-runs-states-light.svg) · [dark](../../../../design/screens/desktop/git-commit/the-git-column-while-a-commit-runs-states-dark.svg).

---

*See also: [commit/](../README.md) · [confirming/](../confirming/doc.md) · [when a push fails](../../push-pull/when-it-fails/doc.md)*
