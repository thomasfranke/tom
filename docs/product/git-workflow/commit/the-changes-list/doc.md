# The changes list

What is about to be committed, and how it gets staged.

**Status:** Shipped · Milestone M1

## Rules

- Modified, new and deleted files show up as a visible list before anything is committed.
- **The list is the repository's, not the space's.** A commit records the index, so a file staged outside the space would go in whether or not it were drawn, and a list that hid it would be worse than a long one.
- Each row says what happened with a **letter as well as a colour**, in the same alphabet the [file tree](../../../navigation/file-tree/change-marks/doc.md) uses.
- **Pressing a row opens its document with the diff on** (2026-10-08) — pressing a change is asking to see it. ~~Only a markdown document inside the space and still on disk opens; a row outside the space, deleted, or not markdown is not pressable, because the list is the repository's and names files the app does not open.~~ **Every row opens** (revised 2026-10-09): a file that is not a document opens in a text tab with the diff by line ([opening a change](../opening-a-change/doc.md)). It holds in both sections: a staged row opens like any other.
- **Every row ends in a ↶ that puts the file back, always drawn** (2026-10-08) — a control that appears on hover is one nobody finds. It asks first, through the dialog every destructive action uses, naming the file.
- **A row in `CHANGES` goes back to what is staged**: `Discard changes to <name>?` — everything not staged is lost, what is already staged stays.
- **A row in `STAGED` goes back to the last commit**: `Discard changes to <name>?` — everything since the last commit is lost, staged or not, and the row leaves the list.
- **A file git never committed is deleted**: `Delete <name>?` — untracked or added, it was never committed, so nothing can bring it back.
- **A conflicted row draws no ↶** — resolving it is the way out, and `Abort the pull` the way back.
- After a discard, git is read again; a file that went back is read off the disk in its tab, and a file that was deleted loses its tab.
- **The list is two sections, `STAGED` and `CHANGES`**, each with its count — what goes into the next commit apart from what does not (revised 2026-10-08).
- **`Unstage all` heads `STAGED` and `Stage all` heads `CHANGES`** — the two bulk actions, one per section (revised 2026-10-08).
- ~~**A row is two lines: the file's name, and the folder it is in underneath.**~~ **A row is one line: the file's name, and the folder it is in beside it** (revised 2026-10-08). A documentation repository is full of files called `doc.md`, and a column of them names nothing until the folder is there.
- **A line under the commit button counts what is going in** — `2 of 3 staged` — and is absent when nothing changed, because `0 of 0` is read twice and ignored.
- **The commit button names the branch**: `Commit to <branch>`. Where a commit lands is the one thing about it that cannot be undone by editing the message.
- Staging is simplified: everything at once, or one file at a time. **There is no partial (hunk-level) staging.**
- After a commit, the list reflects that the working tree is clean again.
- An operation git refused says so where it was asked for, without the list going away — what was refused has to still be on screen.

---

*See also: [commit/](../README.md) · [the-message/](../the-message/doc.md) · [components/controls.md](../../../../design/components/controls.md)*
