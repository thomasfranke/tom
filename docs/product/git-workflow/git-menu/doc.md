# Git menu

What the `⋮` at the head of the git column offers.

**Status:** Shipped · Milestone M3

## Rules

- **Three actions, then one apart**: `Reload`, `Open in terminal`, `Open repository in Finder`; a divider; `Discard all changes` in `removed`. The one that loses work sits alone and wears the colour that says so.
- **`Reload` asks git again** — status, branch and drift — for when something changed outside TOM. It also forgets what the last request said about [the link](../push-pull/when-the-link-is-broken/doc.md), so the requests are offered again.
- **`Open in terminal` opens the platform's terminal at the repository's root**, because the thing this product does not do is still a `git` command away.
- **`Open repository in Finder` opens the repository's folder**, not the space's — the git column is the repository's ([a space is a folder, not a repository](../../workspace/README.md)). The verb follows the platform, as in the [explorer menu](../../navigation/file-tree/explorer-menu/doc.md).
- **`Discard all changes` asks first**, through the dialog every destructive action uses, naming how many documents go back to the last commit; it never touches untracked files, which git did not record and so cannot restore. **An added file is kept too**, taken out of the index and left untracked with its content — it was never committed, so going back would lose it.
- After it, git is read again and the document on screen is read off the disk.
- **It is not offered when there is nothing to put back**, not mid-merge, where [`Abort the pull`](../push-pull/when-a-pull-conflicts/doc.md) is the way back, and not before the first commit, when there is no commit to go back to.
- **Asked for anyway — over a menu drawn before the state changed — it is refused, and nothing is discarded**: `A merge is in progress — resolve it first.` or `There is no commit to go back to yet.`, above the message box. Git is read again first, and the document on screen keeps its unsaved edit.
- The menu is a [popover](../../../design/components/controls.md) hanging from the `⋮`, 220 wide, and closes on a choice, on a click outside, or on Escape.

## Mocks

- **git menu** — the four under the `⋮`, over the committing screen. [light](../../../design/screens/desktop/git-commit/the-git-menu-states-light.svg) · [dark](../../../design/screens/desktop/git-commit/the-git-menu-states-dark.svg).
- **the git menu** — its second state, with nothing to put back or mid-merge: three rows and no divider. [light](../../../design/screens/desktop/git-commit/the-git-menu-states-light.svg) · [dark](../../../design/screens/desktop/git-commit/the-git-menu-states-dark.svg).
- **the discard question — four wordings** — the fourth is `Discard all changes?`, the safe answer first. [light](../../../design/screens/desktop/git-discarding/the-discard-question-four-wordings-states-light.svg) · [dark](../../../design/screens/desktop/git-discarding/the-discard-question-four-wordings-states-dark.svg).

---

*See also: [git-workflow/](../README.md) · [commit](../commit/README.md) · [explorer menu](../../navigation/file-tree/explorer-menu/doc.md)*
