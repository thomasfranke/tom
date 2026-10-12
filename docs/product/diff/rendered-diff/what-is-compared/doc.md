# What is compared

Which two things the diff measures, at which moment, and what it does when git
cannot answer.

**Status:** Shipped · Milestone M2

## Rules

- The diff shows what changed since the branch left its base — the working tree against the commit where it left the branch it came from, or against HEAD on that branch itself ([branch-diff](../../branch-diff/doc.md)) — and renders both sides as formatted output, never as raw-text `+/-` lines.
- **What is compared is what is on screen**, not what is on disk: an edit is marked as it is typed, before anything is saved.
- Version 1 is a block diff — added, removed and modified paragraphs and headings. Finer-grained (inline word-level) diffing is not required for v1.
- A document with no changes shows no decoration at all. The rendered diff never adds noise to an unmodified file.
- **Line endings are not a change.** A document whose only difference is how its lines end shows no decoration — nobody reading it could see what moved.
- A document git has never seen is every block added. A new file is not an error, and it is not a blank comparison either.
- A comparison git could not make leaves the document undecorated rather than replacing it with an error — what failed is the diff, and the document is readable either way.
- A version opened from the [file history](../../../git-workflow/file-history/doc.md) is not compared against anything: it is the past, and nothing is being changed against it.
- **A block that moved is a removal and an addition** — the diff does not recognise a move.
- **A footnote whose text was rewritten is seen by the diff and carries no mark** — its text belongs to no block.

## Mocks

- **comparing** — the working copy against the branch it came from, the base named beside the chip. [light](../../../../design/screens/desktop/git-diff/comparing-light.svg) · [dark](../../../../design/screens/desktop/git-diff/comparing-dark.svg).
- **a document git has never seen** — every block `A`, in both panes. [light](../../../../design/screens/desktop/git-diff/a-document-git-has-never-seen-states-light.svg) · [dark](../../../../design/screens/desktop/git-diff/a-document-git-has-never-seen-states-dark.svg).

---

*See also: [rendered-diff/](../README.md) · [how-it-is-drawn/](../how-it-is-drawn/doc.md)*
