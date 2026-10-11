# The surface

Where the search lives, and what a result looks like.

**Status:** Shipped · Milestone M2

## Rules

- **The search lives in the left column, box and results together**: what was typed, the scope it applies to, how many matched, and the matches themselves, in one place.
- The right column is git's. **Search never puts anything in it.**
- **`⌘K` puts the caret in the box from anywhere in the window** (`Ctrl+K` off macOS), opening the explorer when it is shut; the empty box wears the keycap, so the shortcut is on screen before anybody needs it.
- Typing shows the results as they arrive. There is nothing to press and nothing to wait for.
- A **`This file · Whole space`** choice sits under the box and is always visible, never revealed by focus. Which one is chosen is said by the control, not guessed from where the cursor is.
- A result is the file's name, the folder it is in, and the stretch of text that matched, with the typed words marked inside it. Clicking one opens the document, the way a row of the tree does.
- While the space is still being read the panel says so — `Reading the space…` — rather than saying nothing was found. Words typed meanwhile are kept and searched as soon as there is an index.
- **Nothing found is a sentence, not an empty column**: `No document says that.`

## Mocks

- **searching every document** — the box, the scope, the count and the hits, in the left column. [light](../../../../design/screens/desktop/search/searching-in-every-document-light.svg) · [dark](../../../../design/screens/desktop/search/searching-in-every-document-dark.svg).
- **the search column — nothing to list** — while the space is being read · no document says that · nothing in the open file. [light](../../../../design/screens/desktop/search/the-search-column-nothing-to-list-states-light.svg) · [dark](../../../../design/screens/desktop/search/the-search-column-nothing-to-list-states-dark.svg).

---

*See also: [full-text-search/](../README.md) · [regions](../../../workspace/regions/doc.md) · [file-tree](../../../navigation/file-tree/README.md)*
