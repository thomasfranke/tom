# Wikilinks

Link between documents with `[[document]]` syntax, with autocomplete while typing and working navigation on click.

**Status:** Shipped · Milestone M3

## Rules

- Typing `[[` offers autocomplete over the documents in the space — **except inside code**, a fenced block, an indented one or an inline span, where `[[` is the text it looks like, as the preview reads it.
- **What the offer writes always resolves to the document that was chosen** — a document at the root that shares its name with one in a folder included.
- **A document whose name holds `#` or `|` is not offered** — the link syntax reads both, so no `[[…]]` can name it; it is linked with an ordinary markdown link, `[words](path)`.
- **A leading `/` names the space's root**: `[[/readme]]` is the root document `readme.md` even when a folder holds another one called `readme`, and the offer writes that form for it — a root document sharing its name is otherwise unreachable by name. Typing `[[/` offers the paths from the root.
- **The offer is driven from the keyboard**: the arrows choose, Enter inserts, Escape closes it — and the line under the list says so.
- **A name two documents share is inserted as its path**, so the link the offer wrote is never ambiguous.
- **Pressing an ambiguous link lists its candidates**: a menu under the link, one row per document sharing the name, by its path; choosing one opens it. Two names for one link is a question only the writer can answer, so nothing is opened on a guess.
- Clicking a wikilink in the preview navigates to the linked document.
- `[[document#heading]]` opens the document with that heading at the top of the preview — matched the way GitHub names a heading's anchor, so `#Enforcement` and `#enforcement` are one heading and a repeat is `#setup-1`.
- An anchor that names no heading opens the document at its top, and says nothing — the document is still the right one.
- `[[#heading]]`, with no document before the `#`, scrolls the document it is written in to that heading, shown as the heading's words unless it has a label; one that names no heading leaves the preview where it is.
- A wikilink that points at a document that does not exist is visibly distinguished from one that resolves.
- **A missing link says so and offers the fix**: pointing at it or pressing it raises a tip, `No document called <name>.`, with `Create it`.
- **`Create it` creates the document and opens it, the way the `+` does** ([new document](../navigation/file-tree/new-document/doc.md)): a link written as a path is created where the path says, a bare name beside the document the link is written in. Nothing is created until it is pressed.
- **An ambiguous link carries the count** of the documents it could mean, beside its words.

## Mocks

- **wikilinks** — resolved, missing (with the tip that offers to create it) and ambiguous (with the count) in one paragraph. [light](../../design/screens/desktop/editor-links-export/wikilinks-light.svg) · [dark](../../design/screens/desktop/editor-links-export/wikilinks-dark.svg).
- **linking a document** — the list `[[` opens under the caret. [light](../../design/screens/desktop/editor-links-export/linking-a-document-the-offer-states-light.svg) · [dark](../../design/screens/desktop/editor-links-export/linking-a-document-the-offer-states-dark.svg).
- **ambiguous link** — the candidates a link two documents share, listed under it by name and folder. [light](../../design/screens/desktop/editor-links-export/ambiguous-link-the-candidates-states-light.svg) · [dark](../../design/screens/desktop/editor-links-export/ambiguous-link-the-candidates-states-dark.svg).

---

*See also: [about.md](../../about.md) · [roadmap.md](../../roadmap.md)*
