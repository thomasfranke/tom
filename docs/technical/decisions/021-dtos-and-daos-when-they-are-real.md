# Decision 21 — DTOs and DAOs are named as such, when they are real

**Status:** accepted — revises two points of [Decision 15](015-ddd-is-applied-selectively.md)

## Context

[Decision 15](015-ddd-is-applied-selectively.md) ruled out "a separate persistence model" and named `DocDto` among the words the code does not use. Both were written when the only store was the filesystem and the only shape was the file itself, and at that point they were true: a `Document` is the bytes on disk, and a second shape of it would have been two things to keep in sync.

The application has since grown stores that are not the file. Settings are a JSON file whose shape is the store's, not the domain's. The FTS5 index arrives in M2 and is a database with a schema. Both have the same property: what crosses into them is **not** a domain type, and pretending otherwise would put serialisation concerns on entities that must not know about any store.

## Decision

**A DTO and a DAO are legitimate here, and carry the word in the class and in the file, when the thing genuinely is one.**

- A **DTO** is a shape that exists to cross a boundary and is not a domain type. The boundary is a contract, not only a store: `MarkdownSpanDto` is what `MarkdownParser` answers and `FilesystemEntryDto` what `Filesystem` reports — neither is serialised anywhere, and both exist because the capability may not name a `Block` or a `SpaceEntry`. A store is the same case with bytes at the end of it, which is what `RecentSpaceDto` will be beside the domain's `RecentSpace`. The conversion belongs to `tom_data`, which is where the domain and everything else already meet.
- A **DAO** is the object that talks to one store, in that store's terms. A `SearchIndexDao` over sqlite is a DAO; it speaks rows and statements, lives in `tom_infra` behind its capability contract, and never sees an entity.

Neither exists in the codebase today. This decision reserves the words and the shape, so that the first one arrives named rather than argued about.

What does **not** change: a domain type keeps the domain's word. `Space`, `Document` and `Block` are the words the product uses, so there is no `SpaceEntity` and no `DocumentModel` — a suffix there would be a second name for the same concept, which is the ubiquitous-language rule of Decision 15 and stands.

## Rationale

The test is whether the word is part of the contract or describes plumbing the code already makes obvious. `Dto` and `Dao` pass it exactly when the object's whole purpose is the boundary: a reader who does not know that `RecentSpaceDto` is the *stored* shape will use it as the domain one, which is the bug the name prevents.

Decision 15's reasoning was about a mapping with no second store to map to. That premise is gone, and the rest of 15 — typed paths, ubiquitous language, repositories as a domain concept, no aggregates, no domain events — is untouched.

## Consequences

- `tom_data` gains conversions between DTOs and entities as stores appear, and that is where they stay: the domain never serialises, and infrastructure never learns what an entity is.
- A DTO that turns out to be identical to its entity is a DTO that was not needed. The word is not a layer to fill in; it is a name for a shape the store forced.
- [`layers.md`](../layers.md#inside-a-package) carries the naming rule this makes room for, and the code-review skill matches it.

## Revisit when

The stores collapse back to one — unlikely — or a DTO appears with no store behind it, which would mean the word is being used for ceremony rather than for a boundary.
