# Domain model (emerging)

> **Partial, and deliberately so.** Several types here can only be settled by
> experiment, never by a design session — `BlockValueObject` was the largest of
> them, and it is now settled by measurement rather than by argument
> ([Decision 19](../decisions/019-blocks-come-from-the-markdown-package.md)).
> What follows is what is **settled**, what is **open with the question
> formulated**, and how the gaps get filled. A partial, honest model is more
> useful than a complete, invented one.

Which DDD patterns apply here, and which are explicitly out:
[Decision 15](../decisions/015-ddd-is-applied-selectively.md).

## Entity or value object

Every type here says which of the two kinds it is, because they are not the
same thing: an **entity** has an identity that outlives its values, a **value
object** is wholly what it carries. The naming rule that enforces it is
[`conventions/naming.md`](../conventions/naming.md).

## Settled

| File | Types |
|---|---|
| [`spaces.md`](spaces.md) | `SpaceEntity`, `SpaceEntryValueObject`, `SpaceRepository` |
| [`paths.md`](paths.md) | `SpaceRelativePathValueObject`, `RepoRelativePathValueObject` |
| [`documents.md`](documents.md) | `DocumentEntity`, `ParsedDocumentValueObject`, `DocumentRepository` |
| [`git.md`](git.md) | `GitStatusValueObject`, `CommitEntity`, `BranchEntity`, `GitRepository` |
| [`blocks.md`](blocks.md) | `BlockValueObject` |
| [`diff-blocks.md`](diff-blocks.md) | `DiffBlockValueObject`, and how two blocks are paired |

## Not settled

[`open-questions.md`](open-questions.md) — space configuration, document
loading, `Wikilink`, the conflict model, and how each one gets answered.

---

*See also: [conventions/naming.md](../conventions/naming.md) · [runtime/](../runtime/README.md)*
