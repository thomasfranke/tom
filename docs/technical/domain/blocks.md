# Blocks

## `BlockValueObject`

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

**One construct does not survive isolation: footnotes.** A block carrying
`[^ref]` renders it as literal text, because the definition is another block
and the reference map does not carry it. Reference links do survive, because
`linkReferences` can travel with the block
([`ParsedDocumentValueObject`](documents.md)). The parser also synthesises a
footnotes `section` node that corresponds to no lines at all, so a block list
must tolerate a node with no span. What to do about footnotes is M2's, not
settled here.

## `DiffBlockValueObject`

The output of `BlockDifferService` and the reason the product exists: a block
paired with what happened to it. Sealed rather than a block carrying a flag,
because only one of the four holds two things — `unchanged` · `added` ·
`removed` each carry one block, and `modified` carries the before and after
sides, which is what a word-level diff *inside* a block starts from (diff v2).

A removal carries the block from the **old** version, so the preview can
render a paragraph that is in no file on disk. What it needs to render it —
the link reference definitions of the version it was written in — comes from
`DocumentDiffValueObject`, which carries both parsed versions beside the
blocks and answers `isUnchanged`: the question the preview asks before
decorating anything.

**How two blocks are paired is
[Decision 27](../decisions/027-blocks-are-aligned-by-myers-and-paired-by-words.md)**:
Myers over the block sources, with two of them counting as the same block when
they share at least half their words. The threshold is the domain's
(`BlockDifferService.pairingThreshold`); the measure belongs to the capability
under `BlockAlignerPort`.

---

*See also: [documents.md](documents.md) · [runtime/documents.md](../runtime/documents.md)*
