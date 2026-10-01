# Decision 31 — Where a footnote's text goes

**Status:** accepted. It answers the choice [Decision 19](019-blocks-come-from-the-markdown-package.md) left open, on the maintainer's rule: **if GitHub's markdown has it, this has it.**

## Context

Decision 19 named footnotes *the one construct* that a block-by-block preview breaks, listed three ways out and decided none of them: render footnote-bearing blocks with the document in scope, keep a document-level footnote map beside the reference map, or declare footnotes out of scope. It said the choice belongs to M2 with a failing test. Neither happened, and the app has shipped two milestones since.

What was missing was not an opinion but numbers. These were measured against the real parser and the real renderer, and each one changes what the options cost.

**The definition lines produce no block at all.** The `markdown` package moves every referenced definition into a `<section class="footnotes">` it synthesises at the end, so the `li` is no longer a top-level node and [`MarkdownPackageParserImpl`](../../../src/packages/infra/lib/src/markdown_parser/markdown_package/markdown_package_parser_impl.dart) never emits a span for it. A document ending in `[^a]: The note itself.` reports `heading 0..0`, `paragraph 2..2`, `paragraph 4..4` — and nothing for line 6.

**Which means the rendered diff is blind to footnotes.** `BlockDifferService` compares blocks; lines that are in no block are in no comparison. **Rewriting a footnote's text today shows up as no change whatsoever** — which is a worse defect than the one this is filed under, and it is the reason this is worth deciding rather than leaving.

**What the renderer actually draws**, asked of `flutter_markdown_plus` directly:

| Given | Drawn |
|---|---|
| `A claim.[^a]` alone | `A claim.[^a]` — the literal text, which is the bug as reported |
| `A claim.[^a]` **and** `[^a]: The note itself.` | `A claim.¹`, then an ordered list: `1. The note itself. ↩` |
| `[^a]: The note itself.` alone | nothing at all |

So the definitions travelling with the block **do** resolve the marker — the same trick `linkDefinitions` already plays, which Decision 19 predicted would not work and which the measurement contradicts. What comes with it is the note's text, drawn under that block.

**The synthesised section can be suppressed.** `MarkdownBody` takes a `builders` map keyed by tag; a builder for `section` returning an empty widget drops it. So "resolve the marker but draw no note" is reachable.

## Decision

**The marker stays in the prose and the notes go to the foot, which is what every markdown renderer does.** The document carries them; the preview draws them.

```
FootnoteValueObject        label · number · text          (domain)
  ↑ MarkdownFootnoteDto    what a parse reports            (data)
  ↑ MarkdownParser         the capability's contract      (infra)
      FootnoteRefSyntaxImpl      the marker, in a block    (app)
      PreviewFootnotesWidget     the notes, at the foot    (app)
```

- **The number belongs to the document, not to the block.** It is the order the notes are first cited in, and the package assigns it from *the text it was handed* — so a block rendered alone would call every note it cites number one. The parser counts them once, over the whole document, and the block is handed the answer.
- **The marker is drawn rather than parsed.** An inline syntax of the app's own replaces `[^label]`, and the package's footnote handling never runs: its own reference carries an anchor, and every block being a widget of its own leaves nowhere to jump to.
- **It is not `sup`.** The renderer raises that with the `sups` font feature, which the serif face the prose is set in does not carry — measured, and the number came out on the baseline reading as a typo. The app raises and shrinks it itself.
- **A marker with no definition is left exactly as written.** `[^a]` alone is not a footnote, and rewriting it would invent one.
- **The foot is skipped while a conflict is on screen.** A document holding both sides of a merge would assemble its notes from two.

## Consequences

- `ParsedDocumentValueObject` carries the notes structured, where `linkDefinitions` is a string: a definition is appended to a block and parsed again, while a note is **drawn**, and drawing needs the parts apart.
- `markdown` becomes a direct dependency of the desktop app — not a second parser, but the type `flutter_markdown_plus` takes its extension points in, the way `re_highlight` is the type its highlighter takes.
- **The diff can now see a footnote change**, because the definition's text reaches the model. It still produces no *block*, so the change is not decorated: that is the next thing this touches, and it is not this decision's.
- The foot carries no link back to the citation, for the reason the marker carries no anchor.

## Revisit when

The preview stops being one container per block, which is the constraint every line above answers to. The measurements were taken against `markdown` 7.3.1 and `flutter_markdown_plus` 1.0.12; a bump to either is the one thing that would need them taken again.
