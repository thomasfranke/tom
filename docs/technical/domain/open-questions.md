# Open — with the question formulated

What the model does not answer yet, stated as the question rather than left
out. What *is* settled: [`README.md`](README.md).

## Space configuration → settled for now: nothing is written

A space is "the folder, as is". The `.tom/` name is reserved so a future
shared setting has an obvious home, but nothing is written there until
something genuinely has to be shared across a team — a per-machine preference
never qualifies. A file TOM writes into someone's repository becomes a
compatibility obligation from its first release
([versioning](../process/versioning.md)), and this product's whole claim is
that it owns no format.

## Document loading → decide in **M0**

Does `DocumentEntity` hold `content` for the whole session, or read on demand?
Decide against a real 5k-line file once the editor runs. Related: what the
entity looks like while dirty.

## Conflicted state → decide in **M3**

`GitStatusValueObject` already reports conflicted paths. What is still open is
the region: the two sides as spans of the document's own text, and whether the
choice a reader makes is a value the model carries or only an edit to the
buffer. The product says the latter
([the conflicted document](../../product/editor/conflicted-document/doc.md)),
which is why no `Resolution` is drawn here yet.

## How this gets filled in

By evidence, not by a design session: **Spike B** answered `BlockValueObject`
([Decision 19](../decisions/019-blocks-come-from-the-markdown-package.md));
**M0** answers document loading and dirty state; **M2** refines `DiffBlock`;
**M3** answered `Wikilink`
([Decision 28](../decisions/028-a-wikilink-resolves-by-name-inside-the-space.md),
now [wikilinks.md](wikilinks.md)); **M3** answers the conflict region too.

When a milestone or spike answers a question, move it from here into the file
it belongs to, in the same PR that implements it, and delete the question. The
chapter shrinks in uncertainty as it grows in content.

---

*See also: [README.md](README.md) · [roadmap.md](../../roadmap.md)*
