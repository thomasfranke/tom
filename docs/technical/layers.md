# Layers

Seven packages in one pub workspace under `src/`. The layering is what the pubspecs declare, so a violation does not resolve ([Decision 14](decisions/014-each-layer-is-its-own-package.md)).

```
core ← domain ← application ← presentation
  ↑       ↑                        ↑
  └─── infra ← data ─────────────  desktop
```

| Package | Holds | May depend on | Flutter |
|---|---|---|---|
| `tom_core` | `Result`, `AppFailure`, ports every layer needs (`Observability`) | nothing | no |
| `tom_domain` | entities, value objects, failures, repository contracts, `BlockDiffer` | `tom_core` | no |
| `tom_application` | use cases | `tom_core`, `tom_domain` | no |
| `tom_infra` | capability contracts **and** their implementations — git, filesystem, settings, platform paths, markdown, search | `tom_core`, `tom_data` (for the DTOs that cross its contracts — [Decision 24](decisions/024-a-capability-is-a-folder.md); never `tom_domain`) | no |
| `tom_data` | DTOs, data sources, parsers, repository implementations | `tom_core`, `tom_domain`, `tom_infra` | no |
| `tom_presentation` | space session, notifiers, view state | `tom_core`, `tom_domain`, `tom_application` | no |
| `tom_ui` | colour roles, metrics, the brand marks, the components both applications draw ([Decision 26](decisions/026-the-look-is-a-package.md)) | nothing | **yes** |
| `tom_desktop` | composition root, screens | all of the above | **yes** |

Six of the eight run under `dart test`, with no Flutter binding available. Folder names are short (`packages/core`); package names carry the `tom_` prefix, because the folder is only a path while the package name is what every import says.

## What enforces it

| Mechanism | Catches |
|---|---|
| the pubspecs | an import of a package the layer never declared — it does not resolve |
| `depend_on_referenced_packages: error` | that same import arriving through a *transitive* dependency, which would otherwise compile |
| `implementation_imports: error` | reaching into another package's `lib/src/` instead of using its barrel |
| `src/test/architecture_test.dart` | what no pubspec can express — see below |

The test carries three checks the mechanisms above cannot make:

- a dependency **added to a pubspec**, after which the illegal import is entirely legal;
- an **SDK library**, which needs no declaration at all. `dart:io` is available to every package by default, so the pubspec graph has nothing to say about a domain entity calling `Process.run`. The test holds a second table — which *capabilities* each layer may import — and scans every `.dart` file under `lib/`, generated code included;
- a **Flutter package in `dev_dependencies`**, the quiet version of the leak: nothing imports a widget, but the package stops running under `dart test` and framework independence stops being provable.

## Inside a package

- **One barrel**, `lib/tom_<name>.dart`; everything else under `lib/src/`, which no other package may import. What the barrel exports *is* the public API.
- **A name carries its role, in the class and in the file.** A use case is named for the operation with the role last and is invoked through a named method: `OpenSpaceUseCase` in `open_space_use_case.dart`, called as `open(…)` rather than `call`. The file name mirrors the identifier's own word boundaries, which is also why a data source is `space_data_source.dart`. That is the shape the Flutter team's own architecture sample uses — `BookingCreateUseCase.createFrom(…)` in [compass_app](https://github.com/flutter/samples/tree/main/compass_app/app/lib/domain/use_cases).

  The same goes for every role the reader needs in order to use the thing: `SpaceRepository`, `HomeState`, `FileTreePanel`, `GitFailure`, `MarkdownParser`, `FileTreeNotifier`, `BlockKindEnum`, and — when a store forces a shape that is not a domain type — `Dto` and `Dao` ([Decision 21](decisions/021-dtos-and-daos-when-they-are-real.md)).

  **A domain type says which of the two kinds it is**, because they are not the same thing and the difference decides how the code may treat them. An **entity** has an identity that outlives its values — a `SpaceEntity` is the folder it was opened at, whatever it is renamed to; a `DocumentEntity` is its path, whatever it holds. A **value object** is wholly what it carries, so two of them with the same contents are not equal but *the same*: `SpaceEntryValueObject`, `BranchNameValueObject`, `GitStatusValueObject`. Entities today: `SpaceEntity`, `DocumentEntity`, `CommitEntity`, `BranchEntity`, `RecentSpaceEntity`. Everything else in `tom_domain` that is not a failure, a contract or an enum is a value object.

  **An implementation ends in `Impl`, and says what makes it different before that**: `DartIoFilesystemImpl`, `MarkdownPackageParserImpl`, `GitRepositoryImpl`. The two halves answer different questions and the name owes both — `DartIo` says *which* implementation, so a second one is a sibling rather than a rename; `Impl` says it fulfils a contract declared somewhere else, which is the thing a reader cannot see from the position of the file. A bare `FilesystemImpl` is the name that does not survive the second.

  The suffix is for a **seam** — a contract that exists so it can be fulfilled differently: a capability, a port, a repository, a `TomModule`, a highlighter a package asks for. A failure hierarchy implements `AppFailure` and is none of those: that is a marker classifying data, and `GitFailure` stays `GitFailure`.
- `tom_infra` organises by **capability, not by technology**: `src/git_client/` holds the contract, its failures, and one subfolder per implementation (`dart_io/`, later `libgit2/`). A second implementation is a sibling folder, and the composition root is the only file that changes. Nothing sits loose beside the capabilities — a file in this package without a contract is a capability that was never declared.

  **One failure file per capability, beside the contract**, and every variant in it is one a second implementation must also be able to produce — that is what makes it the contract rather than one adapter's diary. An adapter keeps nothing of its own: what the dependency said and the contract has no word for is dropped, because [`AppFailure.cause`](../../src/packages/core/lib/src/app_failure.dart) links two *vocabularies* — it is what a repository attaches when it turns `GitClientFailure` into `GitFailure` — and an adapter has only one.
- **No type from a dependency crosses a contract.** A `ProcessException` dies inside `dart_io/` and leaves as a `GitClientFailure`. If it escaped, the caller would be handling exceptions from a library it is not supposed to know about, and the folder would be decoration.
- **A comment is two or three lines.** One sentence saying what the thing is, then the reason it is that way — and there it stops. The exceptions are real but rare: a rule whose only home is this dartdoc ([the canonical form of a rule is the code that implements it](README.md#the-link-dont-restate-rule)), or a trap that costs an afternoon to rediscover. Anything longer is usually two comments, or a paragraph that belongs in `docs/technical/` with a link from here. Keep it prose — cutting a paragraph into a list of fragments is not the same as making it short.
- **A repository obtains nothing itself.** A data source does, and the repository is left with the order the questions are asked in, the turn from a DTO into the domain's vocabulary, and the failure translation ([Decision 25](decisions/025-a-repository-reads-through-a-data-source.md)). A source is a concrete class — whatever varies, varies at the capability below — and it names no domain type. Holding a capability is what a repository may not do, and `tom rules` fails on a field of one in a `*_repository_impl.dart`; naming a capability's *failure* in order to translate it is still the repository's work.
- `tom_core` holds **mechanism, never vocabulary**. `Result`, `AppFailure` and `Observability` belong there. Git, documents and search have vocabulary, and vocabulary belongs to `tom_domain` — otherwise the package everything depends on becomes the package that changes most.
- `test/` **mirrors `lib/src/` exactly**, under one of three top-level folders — `unit/`, `integration/`, `integrity/` — chosen by what the test needs, not by which package it is in:
  - `unit/` — pure logic, no I/O, fakes over real dependencies (failures, parsers, `BlockDiffer`, use cases, notifiers).
  - `integration/` — talks to a real system (a `git init` temp repo, real disk, real sqlite). Slower, and the project's confidence differentiator — never mocked away.
  - `integrity/` — asserts something about the codebase itself, not its runtime behavior (the layer graph, a barrel's exports). Workspace-wide checks live here too: `src/test/architecture_test.dart` is `src/test/integrity/architecture_test.dart`.

  Below that folder, the path matches `lib/src/` exactly, filename plus `_test`: `lib/src/filesystem/dart_io/dart_io_filesystem_impl.dart` (integration, real disk) is tested by `test/integration/filesystem/dart_io/dart_io_filesystem_impl_test.dart`. The layout answers "where are this file's tests, and what kind" without a search.

  **Exactly** means exactly: no test file named after a theme rather than its subject, and no second file for the same subject in the same kind. One subject can have a file under two kinds — `json_file_settings_impl.dart` has a unit test for the failures a real disk will not produce on demand, and an integration test against a real one — because the kind is part of the path.

  The one exception, and it needs no other: a test whose subject is the **stack** rather than a class. `data/test/integration/spaces/opening_end_to_end_test.dart` wires real disk, real git and a real settings file the way the composition root does and asks the question the user asks. It mirrors nothing because it is about no one file, and it is the only test that fails when the pieces are each right and do not fit.

## Errors across boundaries

An exception never crosses a layer boundary ([Decision 5](decisions/005-errors-use-result-with-sealed-classes.md)): every repository method and every use case returns `Result<T>`.

- `Result` is **sealed**, so a `switch` over it is exhaustive — forgetting the failure branch does not compile.
- `AppFailure` is a **marker, not sealed**; each area's hierarchy is sealed inside its own library (`GitFailure`, `DocumentFailure`, `SearchFailure`). Adding a variant breaks every switch that must handle it, and only in the packages that deal with that area. A switch over `AppFailure` itself takes a catch-all.
- Technical failures are translated into domain failures by `tom_data`, in the **repository** and nowhere else. The graph makes the translation mandatory rather than customary: `tom_infra` does not depend on `tom_domain`, so it cannot name a `GitFailure`. A data source hands the technical failure up untouched — translating is what the repository is at that boundary for ([Decision 25](decisions/025-a-repository-reads-through-a-data-source.md)).
- Every use case wraps its body in a standardized `try/catch`, hands what it caught to `Observability`, and returns `UnexpectedFailure` — never rethrows, never swallows ([Decision 11](decisions/011-telemetry-is-opt-in.md)).

The types are documented where they live: `packages/core/lib/src/` and `packages/domain/lib/src/<area>/<area>_failure.dart`.

## External dependencies

Every external dependency is reached through a contract ([Decision 7](decisions/007-external-dependencies-behind-contracts.md)), applied in three tiers:

| Tier | What | How |
|---|---|---|
| **1 — Capabilities** | git binary, filesystem, sqlite/FTS5, markdown parser, text diff | contract + implementation + its own failure type, all inside `tom_infra`; consumed only through the contract |
| **2 — UI widgets** | `re_editor`, third-party components | our own wrapper widget in the app, exposing our API; swapping the package stays in one file |
| **3 — Structural** | Flutter, Riverpod, Freezed | declared exception, not abstracted — wrapping a framework yields a worse homemade one. Scope below |

| Structural | Allowed in | Why the boundary |
|---|---|---|
| **Flutter** | the applications, and `tom_ui` | the pubspecs enforce it; the other six compile and test as pure Dart. `tom_ui` draws and wires nothing, which is what keeps it from becoming a third application ([Decision 26](decisions/026-the-look-is-a-package.md)) |
| **Riverpod** | `tom_presentation` and the composition root | it is *runtime* — lifecycle, scope, invalidation. Use cases and repositories receive dependencies through constructors. A use case that needs a `Ref` is a design error |
| **Freezed** | any layer | pure build-time; the generated code is ours and carries no runtime coupling. Mandatory for immutable data classes wherever one qualifies — entities, multi-field value objects, view-state, sealed hierarchies ([Decision 16](decisions/016-freezed-is-mandatory-for-immutable-data.md)) |

`Observability` is the one capability contract that lives in `tom_core` rather than `tom_infra`: every use case takes one, and `tom_application` cannot see `tom_infra`. It names no technology, and it is not a precedent for anything that does.

## Testing

| Target | Type | Approach |
|---|---|---|
| Parsers (git porcelain, log, markdown AST) | unit | fixtures of real git output; pure and fast |
| `BlockDiffer` | unit / golden | versioned pairs of md input + expected result |
| Use cases | unit | fake repositories; orchestration and failure propagation |
| Repository implementations | integration | a real repo created by `git init` in a temp dir |
| Notifiers | unit | `ProviderContainer` with overridden use cases |
| Diff view | widget / golden | screenshots of the main states |

Integration against real git is the project's confidence differentiator, and runs on all three platforms.

## When mobile arrives (Phase 3)

`apps/mobile` sits beside `apps/desktop` with its **own screens**, sharing `tom_presentation` — which is why that package is pure Dart. Panels do not become screens: a layout drawn for a phone is drawn from the job, not ported from the desktop. What the two do share is the look — `tom_ui`, the marks and the tokens ([Decision 26](decisions/026-the-look-is-a-package.md), which revises the "no shared-UI package" this section used to state: the objection was to sharing *layout*, and identity is not layout). `tom_infra` grows a second implementation per capability (`libgit2/` next to `dart_io/`), chosen at the composition root.
