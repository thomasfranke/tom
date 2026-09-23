# Decision 24 — A capability is a folder in the infrastructure

**Status:** accepted — supersedes [Decision 22](022-capability-contracts-live-in-the-data-layer.md)

## Context

[Decision 22](022-capability-contracts-live-in-the-data-layer.md) moved the capability contracts out of `tom_infra` and into `tom_data`, on the argument that a port belongs to the layer that declares what it needs. It named its own weak spot in the same breath: `tom_infra` had to depend on the whole of `tom_data` to reach the ports, and `tom_data` also holds the repository implementations — so an adapter importing that barrel could see `GitRepositoryImpl` and reach a domain type through it without ever writing `tom_domain`. The guarantee that infrastructure *cannot name* the domain stopped being a property of the package graph and became a test.

The fix it proposed was a second public library. The cheaper fix is to notice what the move actually cost.

`tom_infra` exists for one reason in this project, and it is narrower than "infrastructure" in the general literature: **it is the only package allowed to touch a third-party dependency**, so those dependencies stay isolated behind contracts ([Decision 7](007-external-dependencies-behind-contracts.md)). A contract and the thing it isolates are the same decision written twice. Putting them in different packages means reading two folders to answer "what can this capability do, and how does it fail".

DDD treats data and infrastructure as one layer, and the split here is deliberate and narrower than the literature's: infrastructure is where third-party access lives, data is where the shapes that cross it live.

## Decision

**A capability is a folder in `tom_infra`: the contract, its failures, and one subfolder per implementation, named after the dependency that makes it different.**

```
tom_infra/lib/src/filesystem/
    filesystem.dart                      ← the contract
    filesystem_failure.dart              ← how it fails
    dart_io/
        dart_io_filesystem_impl.dart     ← one way of doing it

tom_data/lib/src/capabilities/filesystem/
    filesystem_entry_dto.dart            ← what crosses it
    filesystem_entry_type_enum.dart
```

Three rules follow from it, and each is checked by something.

**The DTOs stay in the data layer.** A DTO is a shape a store forced on us ([Decision 21](021-dtos-and-daos-when-they-are-real.md)) and it belongs where shapes belong. `tom_infra` depends on `tom_data` for them; `tom_data` depends on `tom_infra` for the contracts. pub accepts the cycle between workspace packages — it was tried before it was written down — and `src/test/integrity/architecture_test.dart` records it as deliberate. What it buys is the guarantee Decision 22 lost: **`tom_infra` does not depend on `tom_domain`**, so no domain type can be named in an adapter, and that is now a line in a pubspec rather than an assertion in a test.

**Every implementation lives in a folder named after its dependency**, and the class and file end in `Impl`: `filesystem/dart_io/dart_io_filesystem_impl.dart`, `settings/json_file/json_file_settings_impl.dart`. The two halves of the name answer different questions — `DartIo` says *which* implementation, so the second is a sibling rather than a rename; `Impl` says it fulfils a contract declared elsewhere, which the position of the file cannot say. `layers.md#inside-a-package` states the rule for the whole workspace.

**One failure file per capability, and nothing under it.** Every variant in `filesystem_failure.dart` is one a second implementation must also be able to produce — that is what makes it the contract rather than one adapter's diary. An adapter keeps nothing of its own: what the dependency said and the contract has no word for is dropped. `AppFailure.cause` links two *vocabularies* — it is what `SpaceRepositoryImpl` attaches when it turns a `FilesystemFailure` into a `SpaceFailure` — and an adapter has only one.

**Nothing sits loose beside the capabilities.** A file in this package without a contract is a capability nobody declared. That is how `PlatformPaths` came to exist: the folder each platform keeps app data in was a bare function in `settings/json_file/`, called by the composition root and by nothing in the folder it sat in.

## Consequences

**The barrel is the whole of `lib/src/`.** Every file is exported, so "what can another package see" is answered by listing the folder. Decision 22's arrangement had one deliberate omission — a failure carrying the `errno`, kept out so nothing above could switch on it — and that file is gone: it linked a vocabulary to a detail, which is not what a cause is for. The cost is real and small: the operating system's own words no longer reach the diagnostics for `entryNotFound` and `accessDenied`. `operationFailed` still carries them, because that variant has a word for them.

**A second implementation is still one line at the composition root.** `libgit2/` beside `dart_io/`, or the mobile adapters of Phase 3, are new folders here and nothing above changes.

**The port no longer sits with its consumer**, which is the one thing Decision 22 was right about in the abstract. In this workspace it costs nothing: the layer graph is enforced by pubspecs and by `src/test/integrity/architecture_test.dart`, so a `tom_data` repository that reached past its contract would fail a test either way.

## Alternatives considered

**Decision 22's own fix — a second public library in `tom_data`.** `capabilities.dart` exporting only the ports, their DTOs and their failures, with `tom_infra` importing that one. It closes the leak precisely and keeps the ports with the consumer. Rejected because it needs a new kind of thing (a package with two public surfaces, and a test asserting which one each importer uses) to protect a boundary that a pubspec line protects for free.

**Put the DTOs in `tom_infra` too**, and drop the cycle. Simplest graph of all. Rejected because a DTO is a shape, shapes are `tom_data`'s subject, and moving them would mean `tom_data` importing `tom_infra` to name what its own repositories convert.
