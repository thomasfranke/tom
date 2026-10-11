# Export

Get a document out of the app as PDF or HTML — free, always, for every user.

**Status:** Shipped · Milestone M3

## Rules

- Any document can be exported as PDF or as HTML.
- Export is free in every edition of the app; it is never a paid or gated feature. A reader who cannot get a document out of the app is held hostage by it.
- The exported output reflects what the preview shows — the same rendering, not a separate simplified formatter ([Decision 30](../../technical/decisions/030-export-renders-the-preview-not-the-file.md)).
- **What is exported is the buffer, not the file on disk** — the text on screen or held by the tab, unsaved edits included, because the export is the preview's rendering and the preview renders the buffer. A tab holding no edit is read from the disk, which is the same text.
- **It is asked for on the tab.** A right click on a tab opens its menu: `Export as PDF…`, `Export as HTML…`, a rule, `Close tab`. The document's own row is full, and an export is about the document the tab names.
- **It asks where.** Either format asks for a place to save, named after the document — `roadmap.pdf`. Nothing is written beside the source, so the space never gains a file nobody asked git to track.
- **A PDF is paginated.** A4, the preview's rendering cut into pages; a heading never sits alone at a page's foot — it moves to the next page with the start of the block it heads. HTML is one file with its styles and its images inline.
- **A code block of any length exports**, broken across as many pages as it needs — one block never fails the whole document.
- **A heading in the HTML carries the anchor the app follows** — the one a [wikilink](../wikilinks/doc.md) to that heading names, accents kept and a repeated heading numbered, so a link into the document lands the same way in both.
- **An image goes with the document.** Each image the document names from inside the space — PNG, JPEG or SVG — is embedded at its own size, never wider than the page's text; one inside a line, a badge in a link, stays in the line. One that is missing, outside the space, on the web or unreadable leaves its alt text, as the preview does.
- **While it runs, the band says so** — `Exporting roadmap.pdf…`, in the accent and with no action: a long document takes time, and an in-flight band wears the accent ([feedback](../workspace/feedback/doc.md)).
- **It says where it went.** A band in `added` names the file and the folder and offers `Reveal`; it goes when the next thing happens, like every band. A refusal is the same band in `removed`, naming what went wrong and that nothing was written.

## Mocks

- **exporting from the tab** — the tab's menu open over `roadmap.md`. [light](../../design/screens/desktop/editor-links-export/exporting-the-tab-s-menu-states-light.svg) · [dark](../../design/screens/desktop/editor-links-export/exporting-the-tab-s-menu-states-dark.svg).
- **exported** — the band after a PDF was written, with `Reveal`. [light](../../design/screens/desktop/editor-links-export/export-the-band-states-light.svg) · [dark](../../design/screens/desktop/editor-links-export/export-the-band-states-dark.svg).
- **export — the band** — exporting · exported · refused; the same board as above.

---

*See also: [about.md](../../about.md) · [roadmap.md](../../roadmap.md) · [tabs](../editor/tabs/doc.md)*
