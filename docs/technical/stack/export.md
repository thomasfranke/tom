# Export: PDF and HTML

What a document is written out with, behind the `DocumentExporter` capability
([Decision 30](../decisions/030-export-renders-the-preview-not-the-file.md)).

| Package | License | Role |
|---|---|---|
| `markdown` | BSD-3 | HTML — **in use**, already in the stack ([markdown-and-diff.md](markdown-and-diff.md)). `markdown_html/` renders each block alone with the link definitions appended, as the preview does |
| `pdf` | Apache-2.0 | PDF — **in use**, `^3.13.1`, pure Dart, so it lives in `tom_infra` and runs under `dart test`. `pdf_widgets/` builds `pdf`'s own widget tree from the same blocks. Its dependencies (`archive`, `barcode`, `bidi`, `crypto`, `image`, `path_parsing`, `vector_math`, `xml`) are MIT, BSD-3 or Apache-2.0 |
| ~~`printing`~~ | Apache-2.0 | **Not taken.** A Flutter plugin for a print dialog; what M3 needs is a file |

- **The faces reach the PDF as font files handed to the implementation**, since `tom_infra` cannot see `tom_ui`'s ([fonts.md](fonts.md)). A face not handed in falls back to the PDF's own Times, Helvetica or Courier, which draw nothing outside Latin-1.
- **The HTML names the faces and embeds none**: the page falls back to the reader's own serif.
- **The PDF's `MultiPage` carries `maxPages: 2000`** — `pdf`'s default ceiling for one widget failed the whole export on a fenced block of about twenty pages; a document beyond the new ceiling still fails as *too large*.
- **Every heading in the HTML carries GitHub's id, unique across the document** (`HeadingAnchorService`'s rule, the package's HTML escapes undone first), so an exported link goes where the app's own anchor goes.

---

*See also: [fonts.md](fonts.md) · [markdown-and-diff.md](markdown-and-diff.md)*
