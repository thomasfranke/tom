# Decision 30 — Export renders what the preview draws, through one capability

**Status:** proposed — **draft, not accepted.** The licences below were read from pub.dev and are current; what is still the maintainer's is the second question at the foot.

## Context

[Export](../../product/export/doc.md) is the one M3 product with no package chosen and no board drawn. [Decision 13](013-stack-is-flutter-and-dart.md) already flagged it: PDF is a separate problem in Flutter, and it said to budget for it rather than assume it.

Three things constrain the answer before any package is compared.

**The document is already rendered, twice over.** The preview draws one container per block from `ParsedDocumentValueObject`, and the rendered diff decorates the same containers. An export that parsed the markdown again would be a third renderer, and the first day the three disagreed would be a bug nobody could locate.

**HTML and PDF are not one problem.** HTML is a string this repository can write with the `markdown` package it already has — `markdown` renders to HTML out of the box, which is what it was written for. PDF is a layout engine. Treating them as one feature is what makes the whole item look like it needs a dependency.

**Rule 1 forbids a copyleft dependency.** Read today: [`pdf`](https://pub.dev/packages/pdf) is **Apache-2.0**, 3.13.1; [`printing`](https://pub.dev/packages/printing) is **Apache-2.0**. Both are compatible with MIT and neither is a blocker. `printing` is a Flutter plugin with platform channels; `pdf` is pure Dart and does not need Flutter.

## Decision

**Export is one capability, `document_exporter`, with one implementation per format. HTML is written from the AST the app already has; PDF is `pdf`'s own widget tree, built from the same AST.**

```
tom_infra/lib/src/document_exporter/
  document_exporter.dart          the contract: a parsed document and a format in, bytes out
  document_exporter_failure.dart  cannot write · unsupported · too large
  markdown_html/                  the `markdown` package, already in the stack
  pdf_widgets/                    the `pdf` package
```

- **The source is `ParsedDocumentValueObject`, never the file.** One parse, one block list, and an export that says what the preview says. A document being exported mid-edit exports the buffer, for the same reason the preview renders the buffer.
- **`pdf` and not `printing`.** What M3 needs is a file on disk; a print dialog is a different product decision and a Flutter plugin. `pdf` alone keeps the capability pure Dart, which is what lets `tom_infra` hold it ([Decision 14](014-each-layer-is-its-own-package.md)).
- **The marks are not exported.** A diff is a reading of two versions and an export is one document; carrying `added` into a PDF would export a state rather than a file.
- **Where it goes is the user's answer**, through the file picker the app already uses for a folder, and the default name is the document's with the format's extension.

## Rationale

**Rendering from the AST is the only version that cannot drift.** The alternative — screenshotting the preview — ties the export to a window size and to whatever was scrolled into view, and it produces an image where a reader expects text.

**Two implementations rather than one exporter with a switch**, because the two share nothing: one walks blocks emitting tags, the other builds a widget tree and lays it out. One folder per dependency is what [Decision 24](024-a-capability-is-a-folder.md) already says a capability looks like.

**`pdf` carries its own widget vocabulary**, which is a cost worth naming: `pw.Text` is not `Text`, so the export's typography is written once more. That is also what makes it work without a Flutter engine, and therefore testable in `dart test` like everything else in `tom_infra`.

## Consequences

- `pdf` enters the stack, Apache-2.0 under [rule 1](../../../AGENTS.md), recorded in [`stack/`](../stack/README.md) with the rest.
- The three IBM Plex faces `tom_ui` vendors have to reach the PDF too, since `pdf` embeds its own fonts and will otherwise fall back to Helvetica ([fonts](../stack/fonts.md)).
- `ExportDocumentUseCase` over the usual mixin, and a sealed `ExportFailure` beside the others.
- **Nothing here is drawn.** [Rule 13](../../../AGENTS.md) holds: there is no board for an export control, a format choice or a progress state, and no screen is written before there is one.

## What this does not decide

**Where the control lives.** The document's own row is full — seventeen formatting buttons, the modes and the `Diff` chip — and the top bar carries no action on a file. A menu is the obvious answer and the app has no menus, so adding one is a shape decision rather than a placement.

**Whether a PDF paginates or scrolls.** `pdf`'s `MultiPage` breaks a document into pages, which is right for printing and wrong for a document somebody reads on a screen; a single long page is the opposite trade. This is settled when the surface is designed, because the answer depends on what the export is for.

## Revisit when

A document needs something `pdf` cannot lay out — a table that has to break across pages is the first candidate. Until then the cost of a second engine is not paid by anything.
