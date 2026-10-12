# Finding in the open document

The other half of the search column: the words in the document on screen,
rather than the documents in the space.

**Status:** Shipped · Milestone M3

## Rules

- **What is searched is the buffer, not the file on disk** — the text on screen, including what was typed and not saved. The same rule the [rendered diff](../../diff/rendered-diff/what-is-compared/doc.md) already follows, because two surfaces answering about one document must answer about the same text.
- **Occurrences are recomputed whenever the buffer changes**, never carried across an edit. A position found before a keystroke is a position that has moved, and acting on a stale one does not miss the target — it writes into the middle of something else.
- The scope is chosen by `This file · Whole space`, always visible under the box, and which one is chosen is said by the control rather than guessed from where the cursor is.
- An occurrence is its line, with the words that matched marked in it, under the heading it sits beneath — the same three facts a whole-space hit gives, for a document instead of a space.
- **Clicking an occurrence goes to it**: the document scrolls there and the caret lands on it — a list of positions that cannot be gone to is half a search.
- **In `Preview` alone there is no caret to land**, so the preview scrolls to the block holding the occurrence and tints it.
- The count names the document: `3 occurrences in visual-language.md`, because the scope is one file and the file has a name.
- **What the column says when it has no occurrence to list depends on why**:

| Why | The column says |
|---|---|
| No document is open | `Open a document to search inside it.` |
| Nothing is typed yet | `Type to search this document.` |
| The words are not in it | `Nothing in visual-language.md says that.` |

- **The two scopes answer about different moments, and that is said rather than hidden.** `This file` is now; `Whole space` is the index, which is as current as the last save ([staying current](../full-text-search/staying-current/doc.md)).

## Mocks

- **searching the open file** — [light](../../../design/screens/desktop/search/searching-in-the-open-file-light.svg) · [dark](../../../design/screens/desktop/search/searching-in-the-open-file-dark.svg).

---

*See also: [search/](../README.md) · [replacing](../replacing/doc.md) · [source mode](../../editor/source-mode/doc.md)*
