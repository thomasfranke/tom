# Naming

**A name carries its role, in the class and in the file.**

## Rules

- A use case is named for the operation with the role last, and is invoked through a named method: `OpenSpaceUseCase` in `open_space_use_case.dart`, called as `open(…)` rather than `call`.
- The file name mirrors the identifier's own word boundaries — which is why a data source is `space_data_source.dart`.
- Every role the reader needs in order to use the thing is in the name: `SpaceRepository`, `HomeState`, `FileTreePanel`, `GitFailure`, `MarkdownParser`, `FileTreeNotifier`, `BlockKindEnum`, and `Dto`/`Dao` when a store forces a shape that is not a domain type ([Decision 21](../decisions/021-dtos-and-daos-when-they-are-real.md)).
- **A domain type says which of the two kinds it is** — `Entity` or `ValueObject` ([Decision 23](../decisions/023-domain-types-say-entity-or-value-object.md)).
- **A rule that belongs to no single type is a `Service`.** It holds no state and reaches nothing: it is handed what it compares, and the seam under it is a port.
- **An implementation ends in `Impl` and says what makes it different first**: `DartIoFilesystemImpl`, `MarkdownPackageParserImpl`. A bare `FilesystemImpl` is the name that does not survive the second implementation.
- **The suffix is for a seam** — a contract that exists so it can be fulfilled differently: a capability, a port, a repository, a `TomModule`, a highlighter a package asks for.
- A failure hierarchy is **not** a seam. It implements `AppFailure`, a marker classifying data, so `GitFailure` stays `GitFailure`.

`tom rules naming` reads these suffixes; the shape is the one the Flutter team's
own architecture sample uses
([compass_app](https://github.com/flutter/samples/tree/main/compass_app/app/lib/domain/use_cases)).

## Entity or value object

An **entity** has an identity that outlives its values — a `SpaceEntity` is the
folder it was opened at, whatever it is renamed to. A **value object** is wholly
what it carries, so two with the same contents are not equal but *the same*.

Entities today: `SpaceEntity`, `DocumentEntity`, `CommitEntity`, `BranchEntity`,
`RecentSpaceEntity`. Everything else in `tom_domain` that is not a failure, a
contract, an enum or a service is a value object.

Why the two halves of an `Impl` name both matter: `DartIo` says *which*
implementation, so a second one is a sibling rather than a rename; `Impl` says it
fulfils a contract declared elsewhere, which a reader cannot see from the
file's position.

---

*See also: [conventions/](README.md) · [inside-a-package.md](inside-a-package.md) · [domain/](../domain/README.md)*
