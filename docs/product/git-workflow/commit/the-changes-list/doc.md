# The changes list

What is about to be committed, and how it gets staged.

**Status:** Shipped · Milestone M1 — Planned: the `TO RESOLVE` section, which the boards draw and the app does not

## Rules

- Modified, new and deleted files show up as a visible list before anything is committed.
- **The list is the repository's, not the space's.** A commit records the index, so a file staged outside the space would go in whether or not it were drawn, and a list that hid it would be worse than a long one.
- Each row says what happened with a **letter as well as a colour**, in the same alphabet the [file tree](../../../navigation/file-tree/change-marks/doc.md) uses.
- **Pressing a row opens it with the diff on** — pressing a change is asking to see it. **Every row opens**: a document as a document, any other file in a text tab with the diff by line ([opening a change](../opening-a-change/doc.md)). It holds in both sections: a staged row opens like any other.
- **Every row ends in a ↶ that puts the file back, always drawn** — a control that appears on hover is one nobody finds. It asks first, through the dialog every destructive action uses, naming the file.
- **A row in `CHANGES` goes back to what is staged**: `Discard changes to <name>?` — everything not staged is lost, what is already staged stays.
- **A row in `STAGED` goes back to the last commit**: `Discard changes to <name>?` — everything since the last commit is lost, staged or not, and the row leaves the list.
- **A file git never committed is deleted**: `Delete <name>?` — untracked or added, it was never committed, so nothing can bring it back.
- **Git is asked at the moment of deleting whether the last commit holds the file.** One that was committed since its row was drawn is not deleted: `<name> is in the last commit, so it was not deleted. The list has been read again.` — the file, its tab and its unsaved edit stay, and the row is redrawn as what it now is.
- **A conflicted row draws no ↶** — resolving it is the way out, and `Abort the pull` the way back.
- After a discard, git is read again; a file that went back is read off the disk in its tab, and a file that was deleted loses its tab.
- **The list is read from git whether or not the column is open**, and again after every save, so the tree's marks and the status bar are right with the column shut.
- **The list is two sections, `STAGED` and `CHANGES`**, each with its count — what goes into the next commit apart from what does not.
- **While a merge is in progress the conflicted documents are a section of their own, `TO RESOLVE`**, with its count, at the head of the list ([when a pull conflicts](../../push-pull/when-a-pull-conflicts/doc.md)).
- **`Unstage all` heads `STAGED` and `Stage all` heads `CHANGES`** — the two bulk actions, one per section.
- **With nothing changed the list says so** — `Nothing has changed since the last commit.` — rather than standing empty.
- **A row is one line: the file's name, and the folder it is in beside it.** A documentation repository is full of files called `doc.md`, and a column of them names nothing until the folder is there.
- **A line under the commit button counts what is going in** — `2 of 3 staged` — and is absent when nothing changed, because `0 of 0` is read twice and ignored.
- **The commit button names the branch**: `Commit to <branch>`. Where a commit lands is the one thing about it that cannot be undone by editing the message.
- Staging is simplified: everything at once, or one file at a time. **There is no partial (hunk-level) staging.**
- After a commit, the list reflects that the working tree is clean again.
- An operation git refused says so where it was asked for, above the message box, without the list going away — what was refused has to still be on screen. A refusal the app has a name for says its own sentence ([the message](../the-message/doc.md), [when a pull conflicts](../../push-pull/when-a-pull-conflicts/doc.md)); any other says `Git could not do that.`

## Mocks

- **committing** — stage, describe, commit: both sections, the count under the button. [light](../../../../design/screens/desktop/git-commit/committing-light.svg) · [dark](../../../../design/screens/desktop/git-commit/committing-dark.svg).
- **the git column while a commit runs** — ready to commit · committing · nothing staged · git refused · not on a branch. [light](../../../../design/screens/desktop/git-commit/the-git-column-while-a-commit-runs-states-light.svg) · [dark](../../../../design/screens/desktop/git-commit/the-git-column-while-a-commit-runs-states-dark.svg).
- **discarding a change** — the dialog over the list. [light](../../../../design/screens/desktop/git-discarding/discarding-a-change-light.svg) · [dark](../../../../design/screens/desktop/git-discarding/discarding-a-change-dark.svg).
- **the discard question — four wordings** — discarding a change · discarding a staged file · deleting a new file · discarding all changes. [light](../../../../design/screens/desktop/git-discarding/the-discard-question-four-wordings-states-light.svg) · [dark](../../../../design/screens/desktop/git-discarding/the-discard-question-four-wordings-states-dark.svg).

---

*See also: [commit/](../README.md) · [the-message/](../the-message/doc.md) · [components/controls.md](../../../../design/components/controls.md)*
