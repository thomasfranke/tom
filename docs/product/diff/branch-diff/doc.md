# Branch / commit diff

Compare a file between two branches, or between two commits, the same rendered way as the working-tree diff.

**Status:** Shipped · Milestone M2

## Rules

- A file can be compared between any two branches, or between any two commits, using the same rendered (not raw-text) diff as [rendered-diff](../rendered-diff/README.md).
- The comparison is scoped to one file at a time.
- **Choosing what to compare against lives inside the `Diff` chip**, at the end of the bar above the document, which also names the current base as `Compared to <ref>`. The control that says what is being compared and the control that changes it are the same control.
- The chip is fixed at the *end* of the bar, so it keeps its place when the document's name grows and does not drift towards the centred `Source · Split · Preview`.
- It offers the repository's branches and the commits that touched *this* file, filtered by one box — because those are the two things the product compares against and a name is a name.
- **A commit is offered with the same three facts the file history shows**: what it was called, who wrote it, and how long ago. The same commit reads the same way wherever it appears.
- **Comparing is reading.** Nothing is checked out, no branch moves, and the document on screen stays the working copy — only what it is measured against changes.
- **There is one way back**, and it returns to the default: the working copy against the last commit.
- The base outlives the open document. Comparing a branch is done one file at a time, so clicking the next file keeps the comparison.
- **A past version opened from the file history is compared only when somebody asks.** By default the past is shown undecorated ([what is compared](../rendered-diff/what-is-compared/doc.md)); once a base is chosen, two commits are compared against each other.

## Mocks

- Desktop: **comparing** — split view, the marks in both panes, and the base named inside the chip at the end of the bar. [light](../../../design/screens/desktop/git-diff/comparing-light.svg) · [dark](../../../design/screens/desktop/git-diff/comparing-dark.svg).
- Turning the decoration off is [rendered-diff](../rendered-diff/turning-it-off/doc.md)'s **diff off**, drawn on the same page.
- It is the one screen that was built before its board existed, which is what [AGENTS.md](../../../../AGENTS.md) rule 13 now prevents.

---

*See also: [about.md](../../../about.md) · [roadmap.md](../../../roadmap.md)*
