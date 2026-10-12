# Decision 39 — The rendered document is set in Public Sans

**Status:** accepted (2026-10-11), on the maintainer's call after comparing eight faces in Penpot.

## Context

The preview set a document's prose, headings and footnotes in IBM Plex Serif, beside Plex Sans for the interface and Plex Mono for code. Read against real documentation, the serif read as a book where the product is a reference; the eight faces compared were Plex Serif, Source Serif 4, Literata, Newsreader, Inter, Source Sans 3, Plex Sans and Public Sans.

## Decision

**The rendered document is set in Public Sans**; code stays IBM Plex Mono and the interface IBM Plex Sans.

- **Four static cuts**: 400, 400 italic, 600 and 700 — cut with `fonttools` from Google Fonts' variable files, the same way the Plex faces are static instances, and vendored in `src/packages/ui/fonts/` with `PublicSans-OFL.txt`.
- **Reached as `TomFonts.reading`**, the one name the preview and the PDF and HTML export ask for; `TomFonts.serif` and the three Plex Serif files are gone.
- **The licence is SIL OFL 1.1**, like the Plex faces — permissive, compatible with the project's MIT ([Decision 1](001-license-is-mit.md)).

## Consequences

- The boards that show a document are exported again, when the maintainer asks for it, with the new face ([rule 13](../../../AGENTS.md)).
- The footnote's raised number stays the app's own drawing, not a font feature ([Decision 31](031-where-a-footnotes-text-goes.md)).

## Revisit when

- A face the maintainer prefers is measured against the same documents.
