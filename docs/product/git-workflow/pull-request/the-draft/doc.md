# The draft

A file on disk, one per branch, and how long it lives.

**Status:** Shipped · Milestone M3

## Rules

- **The draft is a document, and it is a file.** It is opened, edited and left half-written as many times as anything else in the space, so it survives closing the window — which it can only do by being on disk ([files are the truth](../../../../about.md)).
- **One draft per branch, in `.git/tom/pull-request/<branch>.md`.** Per branch because the draft describes *this* branch and switching branches must not show another one's; inside `.git/` because a file in the worktree shows up in `git status`, lands in the changes list beside real documents, and can be committed into the very diff it describes. Git keeps its own messages there for the same reason. A branch name's slashes are folders, and the collision they suggest cannot happen: git already refuses to hold `feat` and `feat/x` at once.
- **A draft stays.** Coming back to a half-written one is the point, so nothing is cleared on close, and nothing deletes one afterwards: opening the pull request keeps it — it stays what the pull request was opened with ([opening it](../opening-it/doc.md)).
- **Leaving the page saves the draft, without asking.** It is the one document nobody is asked about: there is no tab to hold it unsaved, and a description half-written is what the file is for.

---

*See also: [pull-request/](../README.md) · [writing it](../writing-it/doc.md) · [the control](../the-control/doc.md)*
