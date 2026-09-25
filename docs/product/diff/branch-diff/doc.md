# Branch / commit diff

Compare a file between two branches, or between two commits, the same rendered way as the working-tree diff.

**Status:** Shipped · Milestone M2

## Rules

- A file can be compared between any two branches, or between any two commits, using the same rendered (not raw-text) diff as [rendered-diff](../rendered-diff/doc.md).
- The comparison is scoped to one file at a time.
- **Choosing what to compare against is one control, beside the document.** It offers the repository's branches and the commits that touched *this* file, filtered by one box — because those are the two things the product compares against and a name is a name.
- **A commit is offered with the same three facts the file history shows**: what it was called, who wrote it, and how long ago. The same commit reads the same way wherever it appears.
- **Comparing is reading.** Nothing is checked out, no branch moves, and the document on screen stays the working copy — only what it is measured against changes.
- **There is one way back**, and it returns to the default: the working copy against the last commit.
- The base outlives the open document. Comparing a branch is done one file at a time, so clicking the next file keeps the comparison.
- **A past version opened from the file history is compared only when somebody asks.** By default the past is shown undecorated ([rendered-diff](../rendered-diff/doc.md)); once a base is chosen, two commits are compared against each other.

## Mocks

- Desktop: [comparing](mocks/comparing.excalidraw) — the control in the bar above the document, the surface it opens, and the decorated column behind it. It is also the first drawing of the rendered diff's own decoration, which [rendered-diff](../rendered-diff/doc.md) still owes as a screen of its own.

---

*See also: [about.md](../../../about.md) · [roadmap.md](../../../roadmap.md)*
