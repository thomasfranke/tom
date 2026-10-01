# Search

Finding words, at two scopes: the documents of the space, and the document on
screen.

**Status:** Whole space shipped (M2) · the open document and replacing, M3

| | |
|---|---|
| [`full-text-search/`](full-text-search/README.md) | Every markdown file in the space, by what is written inside it |
| [`in-the-document/`](in-the-document/doc.md) | The buffer on screen, which is the other half of the same column |
| [`replacing/`](replacing/doc.md) | Changing what was found, in the buffer and never on disk |

- One column, one box, and a `This file · Whole space` control that says which of the two is answering.
- **The two read different things on purpose**: the space is the index, current as of the last save; the document is the buffer, current as of the last keystroke.

---

*See also: [product/](../README.md) · [regions](../workspace/regions/doc.md)*
