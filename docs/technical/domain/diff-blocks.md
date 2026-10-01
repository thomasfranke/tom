# `DiffBlockValueObject`

The output of `BlockDifferService`, and the reason the product exists: a block
paired with what happened to it.

- **Sealed rather than a block carrying a flag**, because only one of the four holds two things — `unchanged` · `added` · `removed` each carry one block, and `modified` carries the before and after sides, which is what a word-level diff *inside* a block starts from (diff v2).
- **A removal carries the block from the old version**, so the preview can render a paragraph that is in no file on disk.
- What it needs to render that — the link reference definitions of the version it was written in — comes from `DocumentDiffValueObject`, which carries both parsed versions beside the blocks and answers `isUnchanged`: the question the preview asks before decorating anything.

## How two blocks are paired

**[Decision 27](../decisions/027-blocks-are-aligned-by-myers-and-paired-by-words.md).**
Myers over the block sources, with two counting as the same block when they share
at least half their words.

- The threshold is the domain's (`BlockDifferService.pairingThreshold`); the measure belongs to the capability, under `BlockAlignerPort`.

---

*See also: [domain/](README.md) · [blocks.md](blocks.md) · [runtime/rendered-diff.md](../runtime/rendered-diff.md)*
