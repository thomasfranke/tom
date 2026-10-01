# What is compared

Which two things the diff measures, at which moment, and what it does when git
cannot answer.

**Status:** Shipped · Milestone M2

## Rules

- The diff compares the working tree against HEAD and renders both sides as formatted output, never as raw-text `+/-` lines.
- **What is compared is what is on screen**, not what is on disk: an edit is marked as it is typed, before anything is saved.
- Version 1 is a block diff — added, removed and modified paragraphs and headings. Finer-grained (inline word-level) diffing is not required for v1.
- A document with no changes shows no decoration at all. The rendered diff never adds noise to an unmodified file.
- A document git has never seen is every block added. A new file is not an error, and it is not a blank comparison either.
- A comparison git could not make leaves the document undecorated rather than replacing it with an error — what failed is the diff, and the document is readable either way.
- A version opened from the [file history](../../../git-workflow/file-history/doc.md) is not compared against anything *by default*: it is the past, and nothing is being changed against it. Asking to compare it against a revision is [branch-diff](../../branch-diff/doc.md)'s.

---

*See also: [rendered-diff/](../README.md) · [how-it-is-drawn/](../how-it-is-drawn/doc.md)*
