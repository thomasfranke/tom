# Wikilinks

Link between documents with `[[document]]` syntax, with autocomplete while typing and working navigation on click.

**Status:** Shipped · Milestone M3

## Rules

- Typing `[[` offers autocomplete over the documents in the space — **except inside code**, a fenced block or an inline span, where `[[` is the text it looks like, as the preview reads it.
- **Pressing an ambiguous link lists its candidates**: a menu under the link, one row per document sharing the name, by its path; choosing one opens it. Two names for one link is a question only the writer can answer, so nothing is opened on a guess.
- Clicking a wikilink in the preview navigates to the linked document.
- `[[document#heading]]` opens the document with that heading at the top of the preview — matched the way GitHub names a heading's anchor, so `#Enforcement` and `#enforcement` are one heading and a repeat is `#setup-1`.
- An anchor that names no heading opens the document at its top, and says nothing — the document is still the right one.
- `[[#heading]]`, with no document before the `#`, scrolls the document it is written in to that heading, shown as the heading's words unless it has a label; one that names no heading leaves the preview where it is.
- A wikilink that points at a document that does not exist is visibly distinguished from one that resolves.

## Mocks

- **wikilinks** — resolved, missing (with the tip that offers to create it) and ambiguous (with the count) in one paragraph. [light](../../design/screens/desktop/editor-links-export/wikilinks-light.svg) · [dark](../../design/screens/desktop/editor-links-export/wikilinks-dark.svg).
- **linking a document** — the list `[[` opens under the caret. [light](../../design/screens/desktop/editor-links-export/linking-a-document-light.svg) · [dark](../../design/screens/desktop/editor-links-export/linking-a-document-dark.svg).
- **ambiguous link** — the candidates a link two documents share, listed under it by name and folder. [light](../../design/screens/desktop/editor-links-export/ambiguous-link-light.svg) · [dark](../../design/screens/desktop/editor-links-export/ambiguous-link-dark.svg).

---

*See also: [about.md](../../about.md) · [roadmap.md](../../roadmap.md)*
