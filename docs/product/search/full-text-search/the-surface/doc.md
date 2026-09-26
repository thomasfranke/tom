# The surface

Where the search lives, and what a result looks like.

**Status:** Planned · Milestone M2 — see [known-divergence](../known-divergence/doc.md)

## Rules

- **The search lives in the left column, box and results together**: what was typed, the scope it applies to, how many matched, and the matches themselves, in one place.
- The right column is git's. **Search never puts anything in it.**
- Typing shows the results as they arrive. There is nothing to press and nothing to wait for.
- A **`This file · Whole space`** choice sits under the box and is always visible, never revealed by focus. Which one is chosen is said by the control, not guessed from where the cursor is.
- A result is the file's name, the folder it is in, and the stretch of text that matched, with the typed words marked inside it. Clicking one opens the document, the way a row of the tree does.
- While the space is still being read the panel says so, rather than saying nothing was found. Words typed meanwhile are kept and searched as soon as there is an index.

---

*See also: [full-text-search/](../README.md) · [regions](../../../workspace/regions/doc.md) · [file-tree](../../../navigation/file-tree/README.md)*
