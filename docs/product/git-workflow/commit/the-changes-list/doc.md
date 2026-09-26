# The changes list

What is about to be committed, and how it gets staged.

**Status:** Planned · Milestone M1

## Rules

- Modified, new and deleted files show up as a visible list before anything is committed.
- **The list is the repository's, not the space's.** A commit records the index, so a file staged outside the space would go in whether or not it were drawn, and a list that hid it would be worse than a long one.
- Each row says what happened with a **letter as well as a colour**, in the same alphabet the [file tree](../../../navigation/file-tree/change-marks/doc.md) uses.
- Staging is simplified: everything at once, or one file at a time. **There is no partial (hunk-level) staging.**
- After a commit, the list reflects that the working tree is clean again.
- An operation git refused says so where it was asked for, without the list going away — what was refused has to still be on screen.

---

*See also: [commit/](../README.md) · [the-message/](../the-message/doc.md) · [components/controls.md](../../../../design/components/controls.md)*
