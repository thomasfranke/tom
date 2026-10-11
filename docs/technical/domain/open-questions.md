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

## Can `tom_infra` see a repository implementation?

It can. `tom_infra` depends on `tom_data` for the DTOs that cross its
contracts, and `tom_data` has one barrel, which also exports the repository
implementations
([Decision 22](../decisions/022-capability-contracts-live-in-the-data-layer.md)
named the gap under *Consequences* and left it "not yet closed").
[Decision 24](../decisions/024-a-capability-is-a-folder.md) closed the half
that matters — `tom_infra` has no `tom_domain` in its pubspec, so an adapter
cannot name a domain type — and rejected a second public library for the rest.
Open: whether an adapter *seeing* `GitRepositoryImpl` needs a rule or a test of
its own, or the pubspec line is the whole answer and this question closes.

## How this gets filled in

By evidence, not by a design session: **Spike B** answered `BlockValueObject`
([Decision 19](../decisions/019-blocks-come-from-the-markdown-package.md));
**M0** answered document loading and dirty state
([documents.md](documents.md)); **M3** answered `Wikilink`
([Decision 28](../decisions/028-a-wikilink-resolves-by-name-inside-the-space.md),
now [wikilinks.md](wikilinks.md)) and the conflict region
([git.md](git.md)).

When a milestone or spike answers a question, move it from here into the file
it belongs to, in the same PR that implements it, and delete the question. The
chapter shrinks in uncertainty as it grows in content.

---

*See also: [README.md](README.md) · [roadmap.md](../../roadmap.md)*
