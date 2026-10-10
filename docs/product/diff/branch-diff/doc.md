# Branch diff

Compare a file with what it was when the branch left the one it came from, the same rendered way as the working-tree diff.

**Status:** Shipped · Milestone M2 — the base made automatic on 2026-10-08

## Rules

- A file is compared against **the branch the current one came from**, using the same rendered (not raw-text) diff as [rendered-diff](../rendered-diff/README.md). ~~A file can be compared between any two branches, or between any two commits.~~ — revoked 2026-10-08: nobody chooses the base.
- **The diff shows what changed since the branch left its base**, like a pull request's files changed: the document is read at the commit where the branch left the base (`git merge-base`), never at the base's tip. Work that landed on the base after the branch was started is the base's, and never reads as removed or changed here. A merge of the base into the branch moves that point forward, and the diff follows.
- The comparison is scoped to one file at a time.
- **The base is recorded when TOM starts a branch**: the branch it was started from is written into the repository's own git config, beside the branch's upstream, so it is rebuildable and goes with the branch when git renames or deletes it.
- **A branch started outside TOM has its base deduced**: among the other local and remote-tracking branches, the one `HEAD` has come the least way from since they last shared a commit. A tie goes to the remote's default branch, then to a local branch over a remote's copy. The branch's own upstream, its copy on a remote, a branch that already holds all of it and more (one started *from* it), and a branch with an unrelated history are never the base.
- **On the base branch itself the diff is the uncommitted work**: on the remote's default branch, when no other branch is there to have come from, and on a detached `HEAD`, the working copy is compared against the last commit.
- The base is read again whenever the branch changes, whether the switch was made in TOM or anywhere else.
- **The base is named beside the `Diff` chip** by the branch, as `Compared to <branch>` — the point it was left at is not a name anybody reads — at the end of the bar above the document ([turning it off](../rendered-diff/turning-it-off/doc.md)). ~~Choosing what to compare against lives inside the `Diff` chip~~ — revoked 2026-10-08: the chip only turns the marks off and on.
- ~~It offers the repository's branches and the commits that touched *this* file, filtered by one box.~~ ~~A commit is offered with the same three facts the file history shows.~~ ~~There is one way back, and it returns to the default.~~ — revoked 2026-10-08 with the choice itself.
- **Comparing is reading.** Nothing is checked out, no branch moves, and the document on screen stays the working copy — only what it is measured against changes.
- The base outlives the open document. Comparing a branch is done one file at a time, so clicking the next file keeps the comparison.
- **A past version opened from the file history is never compared** ([what is compared](../rendered-diff/what-is-compared/doc.md)). ~~Once a base is chosen, two commits are compared against each other.~~ — revoked 2026-10-08.
- **The pull request starts from the same base** ([the right column](../../git-workflow/pull-request/the-right-column/doc.md)): one answer to "where did this branch come from", in both places.

## Mocks

- Desktop: **comparing** — split view, the marks in both panes, and the base named beside the chip at the end of the bar. [light](../../../design/screens/desktop/git-diff/comparing-light.svg) · [dark](../../../design/screens/desktop/git-diff/comparing-dark.svg).
- Turning the decoration off is [rendered-diff](../rendered-diff/turning-it-off/doc.md)'s, and it has no board of its own.
- It is the one screen that was built before its board existed, which is what [AGENTS.md](../../../../AGENTS.md) rule 13 now prevents.

---

*See also: [about.md](../../../about.md) · [roadmap.md](../../../roadmap.md)*
