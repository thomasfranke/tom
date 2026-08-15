# Decision 15 — DDD is applied selectively

**Status:** accepted

## Context

The layering ([Decision 14](014-each-layer-is-its-own-package.md)) gives the project a domain package that nothing else can contaminate. The question it raises immediately is what goes in it, and "DDD" is not an answer on its own — the tactical patterns are a menu, not a set.

It matters here more than usual because the second goal is a repository worth reading ([roadmap](../product/roadmap.md#goals)). A codebase that applies a pattern where it does not fit teaches the pattern wrongly, and does so with the project's full authority behind it. Ceremony is not neutral when the artefact is meant to be an example.

**TOM's domain is thin, and admitting that is the whole decision.** The truth of this application lives on disk and in Git, both external by definition — "files are the truth" is a project rule. Business logic with nowhere else to live has essentially one inhabitant: classifying blocks as added, removed or modified. Most of what looks like domain work here is orchestration of a filesystem and a process.

## Decision

Adopt the tactical patterns that earn their keep, and say plainly which ones do not apply.

### In

**Value objects for identifiers and paths.** The most probable bug in this entire application is path confusion: `root` against `repositoryRoot`, relative against absolute, and git reporting paths relative to the repository while navigation stays inside the space folder. With `String` everywhere, that is a runtime error a user finds. With `RepoRelativePath` and `AbsolutePath` as distinct types, passing one where the other belongs does not compile. Same reasoning for `BranchName`, `CommitSha` and `SpaceName`: the invariant is validated once, at construction, and never checked again.

**Ubiquitous language, enforced by naming.** The vocabulary already exists in the documentation — Space, Document, Block, DiffBlock — and the code uses exactly those words. No `FileModel`, no `DocDto`, no `SpaceEntity`. If a concept needs renaming, the docs and the code are renamed together, in the same pull request.

**Repositories as a domain concept.** `DocumentRepository` is declared in `tom_domain` and speaks in entities. It is not the same thing as an infrastructure contract: `GitClient` and `FileSystem` speak in processes and bytes, live in `tom_infra` with their implementations ([Decision 7](007-external-dependencies-behind-contracts.md)), and `tom_data` is where the two meet. The domain therefore knows neither git nor disk, and infrastructure never learns what a `Document` is.

**Domain services** for logic that belongs to no single entity. `BlockDiffer` is the example, and possibly the only one for a long while. Its shape waits on Spike B ([domain model](../architecture/domain/model.md)).

**Entities with identity.** A `Document` is identified by its path, not by its content — two files with identical text are two documents, and the same file edited is still the same document.

### Out

**Aggregates with a transactional boundary.** The classic form — a root controlling all access so invariants hold across a commit — needs a transaction to protect. Here a write is "save this file to disk". Routing every document change through `Space` would add a bottleneck for a file tree of hundreds of entries and protect nothing.

**Domain events.** There is no second bounded context to notify and no eventual consistency to reconcile. The one thing resembling an event, the filesystem watcher, is already handled by an explicit protocol ([Decision 10](010-watcher-and-git-cooperate-by-protocol.md)) and belongs to infrastructure.

**Factories, specifications, and a repository per aggregate.** Constructors and named constructors cover every case this project has. A pattern adopted before its problem arrives is a pattern nobody can explain.

**A separate persistence model.** Files are the truth. There is no ORM entity to map to and back, so an entity/model split would be two shapes of the same thing kept in sync by hand.

## Rationale

The two patterns doing the real work here — typed paths and shared vocabulary — are the ones that pay in this application specifically, and both pay immediately rather than at some future scale. The rest address problems a documentation editor with a filesystem backend does not have.

Saying so explicitly is worth as much as the choices themselves: the absence of aggregates should read as a decision, not an oversight, to whoever opens `tom_domain` expecting the full catalogue.

## Revisit when

A second bounded context appears — the most plausible candidate is remote review, if PR data ever becomes a model of its own rather than a view over the host's API. That is post-MVP and behind [Decision 4](004-business-model-is-open-core.md)'s gate, so it is a genuine trigger rather than a hedge.
