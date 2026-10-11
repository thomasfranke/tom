# What is shown

The tree describes the folder the user has, not a filtered version of it.

**Status:** Shipped · Milestone M0

## Rules

- The tree shows every file in the space, including dotfolders such as `.ai/` and `.github/`.
- **Only `.git/` is hidden.** Nothing else is filtered out by default.
- **Every file opens, as it does from the changes list** — a markdown document as a document, any other file in a text tab, a binary one as the sentence saying so ([opening a change](../../../git-workflow/commit/opening-a-change/doc.md)). One file answering differently in two columns is a surprise nobody needs.
- **A row that is not a markdown document is drawn dimmer**, its name in the muted role like its glyph, so the documents stand out.
- **A symbolic link is shown, gets no mark of its own, and clicking it does nothing.** The tree never follows a link to find out where it goes: it may point outside the space, or at nothing.
- The document that is open is marked, so the tree also answers *where am I*.

## Mocks

- **shell** — the tree with a document open and marked. [light](../../../../design/screens/desktop/workspace-shell/shell-reading-and-editing-light.svg) · [dark](../../../../design/screens/desktop/workspace-shell/shell-reading-and-editing-dark.svg).
- **naming a new entry** — its fourth state, a file that is not markdown and a link, both dimmer than the documents. [light](../../../../design/screens/desktop/workspace-tree/naming-a-new-entry-states-light.svg) · [dark](../../../../design/screens/desktop/workspace-tree/naming-a-new-entry-states-dark.svg).

---

*See also: [file-tree/](../README.md) · [order-and-shape/](../order-and-shape/doc.md)*
