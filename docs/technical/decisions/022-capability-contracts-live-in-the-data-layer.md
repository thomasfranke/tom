# Decision 22 — Capability contracts live in the data layer

**Status:** superseded by [Decision 24](024-a-capability-is-a-folder.md)

> The contracts went back to `tom_infra`, beside the adapters, and only the
> DTOs stayed in `tom_data`. What decided it was the weak spot this document
> names itself, under *Consequences*: with the ports in `tom_data`, the
> guarantee that infrastructure cannot name a domain type stopped being a
> property of the package graph. Decision 24 buys it back with a pubspec
> line. `DartIoFailure`, described below, no longer exists.

## Context

[Decision 7](007-external-dependencies-behind-contracts.md) put every external dependency behind a contract, and [Decision 14](014-each-layer-is-its-own-package.md) gave each layer its own package. Between them they left one question unanswered: which package holds the *contract*.

Until now it was `tom_infra`, beside the adapter that fulfils it — `Filesystem` next to `DartIoFilesystem`, `GitClient` next to `DartIoGitClient`. That reads naturally: the two files are about the same capability, so they sit together.

It stopped reading naturally once the contracts grew shapes of their own. `Filesystem.listDirectory` answers a `FilesystemEntryDto`; `MarkdownParser.outline` answers a `MarkdownOutlineDto`. Those are DTOs ([Decision 21](021-dtos-and-daos-when-they-are-real.md)), and a DTO belongs to the data layer — which put the DTO in one package and the repository that converts it in another, with the arrow pointing outwards.

## Decision

**A capability contract, its DTOs and its failure hierarchy live in `tom_data`. `tom_infra` holds adapters and nothing else.**

```
tom_data/lib/src/capabilities/filesystem/
    filesystem.dart                  ← the port
    filesystem_entry_dto.dart        ← what crosses it
    filesystem_entry_type_enum.dart
    filesystem_failure.dart          ← how it fails

tom_infra/lib/src/filesystem/dart_io/
    dart_io_filesystem.dart          ← one way of doing it
```

The arrow therefore points inwards: `tom_infra` depends on `tom_data`, never the reverse.

**Why the port goes with the consumer.** A port is dependency inversion, and inversion means the interface belongs to the layer that *declares what it needs*, not to the layer that happens to satisfy it. `tom_data`'s repositories are the ones that need a filesystem; `tom_infra` is what answers. Putting the contract with the answer makes it a published API of the adapter, which is the shape inversion exists to avoid.

**Why the failure goes with it.** A failure hierarchy is part of the signature — `Future<Result<String, FilesystemFailure>> readFile(String)` cannot compile unless the port can name it ([Decision 5](005-errors-use-result-with-sealed-classes.md)). Separating the two is not an option; they move together or not at all.

**What `tom_infra` does declare** is the detail only its own third-party dependency knows: `DartIoFailure` carries the `errno` and the OS message. No contract names it, the barrel does not export it, and nothing outside the package can write the name. It reaches the rest of the application only as `AppFailure.cause`, which is how a bug report keeps the number while the product keeps its own vocabulary.

## Consequences

**One guarantee is weaker than it was, and is not yet closed.** While the contracts lived in `tom_infra`, that package depended only on `tom_core` and so *could not name* a domain type — the dartdoc of `GitRepositoryImpl` said exactly that. It now depends on `tom_data`, which holds the repository implementations too, so an adapter importing the full barrel can see `GitRepositoryImpl` and reach a `GitStatusValueObject` through it without ever writing `tom_domain`. Dart imports are not transitive, so `tom_domain` itself stays unreachable; what is lost is that the boundary is checked by a test rather than by the package graph.

The fix is a second public library — `capabilities.dart` exporting only the ports, their DTOs and their failures — with `tom_infra` importing that one and the architecture test asserting it. **Not built yet**; until it is, the barrel is the whole of `tom_data` and the graph entry in `src/test/integrity/architecture_test.dart` is what holds the line.

**The arrow comes back once, for tests only.** `tom_data`'s integration tests drive the real adapters against a real disk and a real `git init`, which is the project's confidence differentiator, so `tom_infra` is a dev dependency there. `testOnlyGraph` in `src/test/integrity/architecture_test.dart` records it, and a companion test proves no file under `tom_data/lib/` imports it.

**A second implementation changes nothing above it.** A `libgit2/` sibling of `dart_io/`, or the mobile adapters of Phase 3, are new files in `tom_infra` (or in a package beside it) and one line in the composition root. Under the old arrangement they would have had to depend on the desktop adapter's package just to name the failure they produce.

## Alternatives considered

**Leave the contracts in `tom_infra`.** Keeps capability and adapter in one folder, which is the arrangement [`conventions/inside-a-package.md`](../conventions/inside-a-package.md) describes and the one that reads best in isolation. Rejected because it drags the DTOs out of the data layer with them, and because it inverts the arrow the whole layering exists to point.

**A third package for the contracts.** `tom_ports` between the two, depended on by both. It resolves the tension exactly and costs an eighth package plus a name that says less than `capabilities/` does. Reconsider if `tom_data` ever grows large enough that the two halves want separate build boundaries.
