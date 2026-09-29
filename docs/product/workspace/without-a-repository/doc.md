# A folder that is not a repository

What the app does with a folder git knows nothing about.

**Status:** Planned · Milestone M3

## Rules

- **A folder outside any git repository opens.** It is a space like any other: the tree lists it, documents open, the preview renders, search finds, and a save writes. Nothing about reading and editing markdown needs git.
- **The right column says so, and it is the only thing that says it.** A glyph, the fact in the column's centre — *This folder is not inside a Git repository* — and under it, smaller and quieter, the two sentences that follow from it: *Reading and editing work as usual. Nothing here is versioned.* No button offers to make one — [TOM never creates a repository on the user's behalf](../../home/opening-a-space/doc.md).
- **What still works is said before what does not**, because this screen is not a failure. A column that opened with *nothing here is versioned* would read as one.
- **A control that cannot work is not drawn.** No `Git · History` switch, no changes list, no message box, no commit, fetch or push, and no branch in the breadcrumb — an unavailable control says *later*, and this is *never, in this folder*.
- **The `Diff` chip goes with them**, and the tree carries no change marks, for the same reason: both are answers git would have to give.
- **The `Pull request` row is the one exception, and it is drawn unavailable.** It belongs to the explorer rather than to the git column, and a shortcut that vanishes is a shortcut somebody hunts for — dim says *not from this folder* without moving anything.
- **The breadcrumb and the status bar drop what git answered for, and only that** — the branch, the counts, the branch menu's chevron. The folder, the open document and the cursor's position stay, because none of the three is git's to answer.
- **This revokes the earlier rule that opening such a folder is a named failure.** Refusing the folder was the app deciding that a space without history is not worth opening, which is the opposite of *a space is a folder, not a repository* ([rule 12](../../../../AGENTS.md)).

## Mocks

- **no repository** — the workspace on a folder git knows nothing about, the message alone in the right column. [light](../../../design/screens/desktop/git-not-git/no-repository-light.svg) · [dark](../../../design/screens/desktop/git-not-git/no-repository-dark.svg).

---

*See also: [workspace/](../README.md) · [regions/](../regions/doc.md) · [opening a space](../../home/opening-a-space/doc.md)*
