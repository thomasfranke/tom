# `BlockValueObject`

**Settled by [Spike B](../decisions/019-blocks-come-from-the-markdown-package.md).**
A block is *where it is, what it says, and what kind of thing it is* — not a
package AST node, which could not cross into the domain anyway
([Decision 7](../decisions/007-external-dependencies-behind-contracts.md)).

| Field | Type | Notes |
|---|---|---|
| `startLine` · `endLine` | int | Zero-based, inclusive, into the document's lines. Recovered from the parser, which does not report them — see the decision for how, and for why it is subclasses rather than wrappers |
| `source` | string | The document's own lines for that span. A slice, not a second copy: raw text and structure without duplicated state |
| `kind` | enum | paragraph · heading · list · table · code · quote · rule · html |

**Granularity is top level.** A list is one block and a table is one block.
Measured over this repository: 848 blocks across 2277 lines, 668 of them a
single line, none longer than 20. Sub-block granularity is a diff v2 question
and starts from here.

**There is no identity.** A heading path is not one — 288 distinct paths for
848 blocks, 285 of them holding more than one block — so `BlockDiffer` aligns
by position and similarity, and may use the heading path only as a coarse
bucket. This is the constraint that shapes the differ.

**Structure is re-derived, not stored.** Parsing a block's span costs nothing
measurable (0–3% over a plain parse for the whole document), so a block that
needs rendering is parsed then, with the document's link reference map in
scope.

**One construct is not a block at all: a footnote.** Its two halves are in
different blocks, and the definition is in none — the parser moves it into a
`section` it synthesises, which corresponds to no lines and so has no span.
So the document carries the notes beside the blocks
([`ParsedDocumentValueObject`](documents.md)): label, text, and the **number**,
which is the order they are first cited in and which no block can see for
itself ([Decision 31](../decisions/031-where-a-footnotes-text-goes.md)).
Reference links survive differently, by travelling as the lines that declared
them and being parsed again with the block.

What happens to a block once two versions are compared is
[`diff-blocks.md`](diff-blocks.md).

---

*See also: [domain/](README.md) · [documents.md](documents.md) · [runtime/preview.md](../runtime/preview.md)*
