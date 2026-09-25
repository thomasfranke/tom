# Naming

**A name carries its role, in the class and in the file.** A use case is named
for the operation with the role last and is invoked through a named method:
`OpenSpaceUseCase` in `open_space_use_case.dart`, called as `open(…)` rather
than `call`. The file name mirrors the identifier's own word boundaries, which
is also why a data source is `space_data_source.dart`. That is the shape the
Flutter team's own architecture sample uses —
`BookingCreateUseCase.createFrom(…)` in
[compass_app](https://github.com/flutter/samples/tree/main/compass_app/app/lib/domain/use_cases).

The same goes for every role the reader needs in order to use the thing:
`SpaceRepository`, `HomeState`, `FileTreePanel`, `GitFailure`,
`MarkdownParser`, `FileTreeNotifier`, `BlockKindEnum`, and — when a store
forces a shape that is not a domain type — `Dto` and `Dao`
([Decision 21](../decisions/021-dtos-and-daos-when-they-are-real.md)).

## A domain type says which of the two kinds it is

They are not the same thing, and the difference decides how the code may treat
them ([Decision 23](../decisions/023-domain-types-say-entity-or-value-object.md)).

An **entity** has an identity that outlives its values — a `SpaceEntity` is the
folder it was opened at, whatever it is renamed to; a `DocumentEntity` is its
path, whatever it holds. A **value object** is wholly what it carries, so two
of them with the same contents are not equal but *the same*:
`SpaceEntryValueObject`, `BranchNameValueObject`, `GitStatusValueObject`.

Entities today: `SpaceEntity`, `DocumentEntity`, `CommitEntity`,
`BranchEntity`, `RecentSpaceEntity`. Everything else in `tom_domain` that is
not a failure, a contract, an enum or a service is a value object.

## A rule that belongs to no single type is a `Service`

`BlockDifferService` is the first: what counts as a *modified* block rather
than a removal beside an addition is the product's rule, it is about two
documents rather than one, and putting it on either of them would make one
document the authority on the other
([Decision 27](../decisions/027-blocks-are-aligned-by-myers-and-paired-by-words.md)).
A service holds no state and reaches nothing — it is handed what it compares,
and the seam under it is a port. `tom rules naming` reads the suffix the same
way it reads `Port`, `Repository` and `Enum`.

## An implementation ends in `Impl`, and says what makes it different first

`DartIoFilesystemImpl`, `MarkdownPackageParserImpl`, `GitRepositoryImpl`. The
two halves answer different questions and the name owes both — `DartIo` says
*which* implementation, so a second one is a sibling rather than a rename;
`Impl` says it fulfils a contract declared somewhere else, which is the thing
a reader cannot see from the position of the file. A bare `FilesystemImpl` is
the name that does not survive the second.

## The suffix is for a seam

A contract that exists so it can be fulfilled differently: a capability, a
port, a repository, a `TomModule`, a highlighter a package asks for. A failure
hierarchy implements `AppFailure` and is none of those: that is a marker
classifying data, and `GitFailure` stays `GitFailure`.

---

*See also: [inside-a-package.md](inside-a-package.md) · [domain/](../domain/README.md)*
