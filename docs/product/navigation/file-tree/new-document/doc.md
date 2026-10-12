# New document

What the `+` at the head of the explorer does.

**Status:** Shipped · Milestone M3

## Rules

- **`+` creates a markdown document, and nothing else.** A folder is the [explorer menu](../explorer-menu/doc.md)'s; a file that is not markdown is not this product's to create.
- **The name is asked for in the tree, not in a dialog**: a field row appears inside the folder of the open document — at the space's root with nothing open — with `untitled.md` already in it and the name selected, so typing replaces it. VS Code's reading, so nobody has to learn it.
- **Enter creates the file and opens it**, in source mode, with the caret on the first line; Escape takes the row away and creates nothing. A name without an extension gets `.md`.
- **A name already in that folder is refused in place** — the row stays, the field turns `removed`, and nothing on disk changes.
- The new file is **untracked**, so the tree marks it `N` at once and the git column lists it, which is the same reading as a file dropped into the folder from outside.

## Mocks

- **new document** — the field row inside `tasks`, the name selected. [light](../../../../design/screens/desktop/workspace-tree/naming-a-new-entry-states-light.svg) · [dark](../../../../design/screens/desktop/workspace-tree/naming-a-new-entry-states-dark.svg).
- **naming a new entry, a name already taken** — its third state, a name already in that folder, the field outlined `removed`; the same board as above. [light](../../../../design/screens/desktop/workspace-tree/naming-a-new-entry-states-light.svg) · [dark](../../../../design/screens/desktop/workspace-tree/naming-a-new-entry-states-dark.svg).

---

*See also: [file-tree/](../README.md) · [explorer menu](../explorer-menu/doc.md) · [change marks](../change-marks/doc.md)*
