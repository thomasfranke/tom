# Markdown preview

Render the document as formatted output, not raw text — the primary way anyone who does not edit will ever see it.

**Status:** Shipped · Milestone M0 (desktop) · Exploratory, Phase 3 post-1.0 (mobile)
## Rules — desktop

- The preview renders headings, lists, tables, code blocks (with syntax highlighting), local images and links.
- **How a document's lines end changes nothing it renders.** One saved with Windows line endings is the same headings, lists and tables as the same text saved with Unix ones.
- **No text makes the preview wait on it.** A run of tens of thousands of characters with no space — a pasted key, a minified line — renders like any other paragraph.
- **A link goes where it says.** One to a document in the space opens that document, read from the folder the link is written in, and one that climbs out of the space is not followed. A web or mail address (`http`, `https`, `mailto`) opens in the machine's own browser or mail client; any other scheme does nothing, because the preview is for reading and a link is not a way to run something.
- **A footnote's marker stays in the prose and its text goes to the foot of the document** ([Decision 31](../../../technical/decisions/031-where-a-footnotes-text-goes.md)). A link inside a note goes where any link goes.
- The preview is a first-class reading mode on its own, not just a companion to editing — a document can be opened preview-only. With the pane to itself it is set wider and larger than beside the source: reading is not a lesser mode ([source mode](../source-mode/doc.md) is where the three modes are described).
- **With the preview alone there is no caret, so the formatting buttons have nothing to act on.** The row keeps the whole bar, disabled rather than dropped, with undo and redo still live on the buffer behind it. The row itself stays, because a row that comes and goes moves the document under the reader ([formatting shortcuts](../formatting-shortcuts/doc.md)).
- Rendering quality is treated as product work, not polish: what shows up here is what an audience that never opens the source will judge.

## Rules — mobile ("reading")

- Reading is full-bleed: no split view, no permanent side panel — this is the primary job on a phone, not a companion mode.
- Editing from this screen is not available yet. Editing on touch is an open design question, not just a port of the desktop editor ([roadmap](../../../roadmap.md#phases)).

## Mocks

- Desktop: **reading** — preview only, the default for whoever does not edit. [light](../../../design/screens/desktop/editor/reading-preview-only-light.svg) · [dark](../../../design/screens/desktop/editor/reading-preview-only-dark.svg).
- Desktop, alongside source: shown in **shell**. [light](../../../design/screens/desktop/workspace-shell/shell-reading-and-editing-light.svg) · [dark](../../../design/screens/desktop/workspace-shell/shell-reading-and-editing-dark.svg).
- **what the preview renders** — a table, a coloured fence and an image. [light](../../../design/screens/desktop/editor-formatting/what-the-preview-renders-states-light.svg) · [dark](../../../design/screens/desktop/editor-formatting/what-the-preview-renders-states-dark.svg).
- Mobile: not drawn. Phase 3.

---

*See also: [about.md](../../../about.md) · [roadmap.md](../../../roadmap.md)*
