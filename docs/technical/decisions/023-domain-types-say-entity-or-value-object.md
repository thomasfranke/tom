# Decision 23 — A domain type says whether it is an entity or a value object

**Status:** accepted — revises the naming bullet of [Decision 15](015-ddd-is-applied-selectively.md) and the closing paragraph of [Decision 21](021-dtos-and-daos-when-they-are-real.md)

## Context

[Decision 15](015-ddd-is-applied-selectively.md) settled the vocabulary rule as *ubiquitous language, enforced by naming*: the docs say Space, Document, Block, and the code uses exactly those words. It named `SpaceEntity` among the words the code does not use. [Decision 21](021-dtos-and-daos-when-they-are-real.md) restated it while letting `Dto` and `Dao` in.

Both readings are defensible, and the project has been running the other one everywhere else: a use case is `OpenSpaceUseCase`, a failure is `GitFailure`, a contract is `SpaceRepository`, an enum is `BlockKindEnum`, a notifier is `FileTreeNotifier`. The role is in the name because the reader needs it to use the thing. The domain types were the one family where it was left out.

They are also the family where the distinction costs the most to get wrong. Decision 15 itself names both patterns as *in* — "value objects for identifiers and paths", "entities with identity" — and the difference is not decoration: an entity may be compared by its identifier and may change its values; a value object is compared by everything it holds and never changes at all. `Freezed` is mandatory for both ([Decision 16](016-freezed-is-mandatory-for-immutable-data.md)), so the generated `==` looks identical either way, and nothing in the name said which contract the reader was holding.

## Decision

**Every type in `tom_domain` that is not a failure, a contract or an enum carries `Entity` or `ValueObject`, in the class and in the file.**

| Entities — identity outlives the values | Value objects — wholly what they carry |
|---|---|
| `SpaceEntity` · `DocumentEntity` | `BlockValueObject` · `ParsedDocumentValueObject` |
| `CommitEntity` · `BranchEntity` | `AuthorValueObject` · `CommitDateValueObject` |
| `RecentSpaceEntity` | `GitStatusValueObject` · `StatusEntryValueObject` |
| | `SpaceEntryValueObject` |
| | `BranchNameValueObject` · `CommitShaValueObject` |
| | `RepoRelativePathValueObject` · `SpaceRelativePathValueObject` |

The test for which is which is behavioural, not grammatical: **would two of them with identical contents be the same thing?** A `SpaceEntryValueObject` at `guides/writing.md` is *the* entry, whoever built it. A `SpaceEntity` at `/code/app/docs` is the same space after it is renamed, and a different one after it is moved — so the identity is `root`, not the fields.

What does **not** change:

- the words themselves. The product still says space, document, block, and the suffix is a second word, not a different one. Renaming a concept still renames the docs and the code in the same pull request.
- `Impl` stays out ([layers.md](../layers.md#inside-a-package)): an implementation is named for what makes it different, not for being one.
- Contracts keep their own role word and take neither suffix — `BlockReader` is a port, `SpaceRepository` a repository, `MarkdownParser` a capability.

## Consequences

**It is longer, and that is the trade.** `Future<Result<ParsedDocumentValueObject, DocumentFailure>> read(DocumentEntity document)` says a great deal in one line and reads slowly. The project has taken the same trade at every other role word, and the argument is the same: the name is read far more often than it is written, and the one thing a reader cannot recover from the call site is which contract the type obeys.

**The rename touched 92 files and ~1,400 references** and was done with a word-boundary script rather than by hand, because six of the sixteen names are a prefix of something else — `Space` alone begins twenty other identifiers, and `SpaceFailure` becoming `SpaceEntityFailure` is exactly the accident to avoid. Two cases the boundary alone did not cover are worth remembering: `md.Document` is the markdown package's class, and `Freezed` spells one class three ways (`Space`, `_$Space`, `_Space`).

## Alternatives considered

**Leave the domain types bare, as Decision 15 said.** The ubiquitous-language argument is real, and this is the reading most DDD writing takes: `Space` is what the team says, so `Space` is what the code says. Rejected because the project already qualifies every other role, and because the entity/value-object split is a behavioural contract the reader cannot see otherwise.

**`Vo` instead of `ValueObject`.** Shorter, and the project's own `Dto` sets the precedent for an abbreviation. Rejected because `Dto` is the abbreviation the industry actually uses in prose and `Vo` is not — it would be a private shorthand in a repository whose second goal is being worth reading.
