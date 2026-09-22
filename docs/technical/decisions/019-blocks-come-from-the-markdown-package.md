# Decision 19 — Blocks come from the `markdown` package, positions included

**Status:** accepted — this is the verdict of **Spike B** ([roadmap](../../roadmap.md))

## Decision

The `markdown` package (BSD-3) produces TOM's blocks. Neither fallback is taken: no hand-written block parser, no Rust parser over `dart:ffi`.

`BlockValueObject` is **a source span, its text, and its kind** — not a package AST node. The node is re-derived by parsing the span when something needs to render it, because that turns out to be free.

## The five questions, answered by measurement

The evidence was a report under `src/apps/desktop/lib/spikes/spike_b/`, run over this repository's own documentation — 50 documents, 2277 lines, 848 top-level blocks — plus a fixture written to break the things the corpus happens not to use. **The harness is gone**: a spike exists to answer a question, and once the answer is written down the code that produced it is a second entrypoint nobody runs. It is in the history of this file's own commit, and what re-checks the claim is the preview's tests when M0 builds it.

### 0 · Does recording positions change what is parsed?

No: **51 of 51 documents parse identically** to a plain parse, the fixture included. This had to be asked first, because the mechanism below is invasive.

### 2 · Source positions — *recoverable, though the AST has none*

`Element` has no offset field and `BlockParser` keeps its line index private. But `lines` and `current` are public, so a syntax can read the parser's position around its own work. **Every one of the 848 blocks got a position.**

Two things were learned the hard way, and both are why this needed a spike rather than a reading:

- **Wrapping a `BlockSyntax` silently changes the parse.** The package's syntaxes recognise each other *by type* — `ParagraphSyntax` asks whether what interrupted it `is SetextHeaderSyntax`, `BlockquoteSyntax` and `AlertBlockSyntax` ask `is ParagraphSyntax`/`is CodeBlockSyntax`, and `BlockParser` special-cases `EmptyBlockSyntax` and `LinkReferenceDefinitionSyntax`. Behind a decorator every one of those answers false, and a setext heading quietly becomes a paragraph. **Extending each syntax works; decorating it does not.**
- **The block does not always start where the parser is standing.** A setext heading is only a heading because of the line *after* its text, so the text has already been consumed and handed back by the time the heading claims it. `linesToConsume` is that handed-back buffer, and its length is how far back the block really began. Without it, the heading is recorded on its own underline and its words are lost.

The price: one subclass per block syntax, nineteen of them. A package upgrade that adds a syntax yields blocks with *no* position rather than wrong ones — and the report counts them, so it is visible rather than silent.

### 1 · Granularity — *top level, and that is the right size*

A list is one block; a table is one block. Across the corpus: 376 paragraphs, 213 `h2`, 86 lists, 31 tables, 23 rules, 14 code blocks, 13 quotes. **668 of 848 blocks are a single line, none is longer than 20.**

So the domain model's first question — is a nested list item its own block? — is answered by *not asking it*: the package gives top-level granularity naturally, nested granularity would need recursive parsers whose line numbers are relative to a sub-document, and a 20-line ceiling means "the whole list changed" is a small lie rather than a big one. Finer granularity is a diff v2 question, and it starts from here.

### 3 · Raw text *and* structure — *no duplicated state*

The text is `lines[start..end]`, a slice of the document rather than a second copy of it, and the structure is re-derived by parsing that slice. Recording positions costs **0–3%** over a plain parse.

### 4 · Identity — *there is none; alignment is positional*

A heading path is not an identifier: the corpus has **288 distinct heading paths for 848 blocks, and 285 of those paths hold more than one block**. Twenty-one blocks are byte-identical to another block somewhere.

So `BlockDiffer` aligns by position and similarity, the way a text differ does, and may use the heading path as a coarse bucket. Nothing stable survives a revision. This is the answer that most constrains the differ, and it is the one a design session would most likely have got wrong.

### 5 · Rendering a block in isolation — *yes, with the document's reference map*

Three outcomes, and every block falls into one:

| | |
|---|---|
| **Stands alone** | 848 of 848 in the corpus, and most of the fixture |
| **Needs the reference map** | A paragraph using `[a reference link][spec]`. `Document.linkReferences` is a public, mutable map, so the map *can* travel with the block — handed to the second parse, the output is identical |
| **Lost** | A paragraph carrying a footnote reference. `[^why]` renders as literal text, and injecting the link references does not help: footnote state is separate, and the definition lives in another block |

The corpus answers 848/848 only because this project writes inline links throughout — which is why the fixture exists. A spike that measured only the corpus it had would have answered this question with an accident.

There is also a node with **no source at all**: the `<section class="footnotes">` the parser synthesises at the end of a document that uses footnotes. It corresponds to no lines, so it can have no span, and a block list must expect that.

## Consequences

- The preview can be assembled block by block ([flows](../flows.md#the-preview-is-assembled-block-by-block)), which is what the rendered diff needs. The document's link reference map travels with the blocks.
- **Footnotes are the one construct this breaks.** Options, none of them decided here: render footnote-bearing blocks with the document in scope, keep a document-level footnote map beside the reference map, or declare footnotes out of scope for diff v1. Whichever is chosen belongs to M2, with a test that fails today.
- The parser lives behind a capability contract in `tom_infra` ([Decision 7](007-external-dependencies-behind-contracts.md)), so no package type reaches the domain — which is exactly why `BlockValueObject` carries a span and its text rather than a `Node`.

## Revisit when

A package upgrade leaves blocks unpositioned (the report is the check); or diff v2 needs sub-block granularity, which is where the recursive-parser problem this decision stepped around comes back.
