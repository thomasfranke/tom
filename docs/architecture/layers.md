# Layers

Seven packages in one pub workspace under `src/`. The layering is what the pubspecs declare, so a violation does not resolve ([Decision 14](../decisions/014-each-layer-is-its-own-package.md)).

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
| `tom_infra` | capability contracts **and** their implementations — git, filesystem, markdown, search | `tom_core` | no |
| `tom_data` | parsers, repository implementations | `tom_core`, `tom_domain`, `tom_infra` | no |
| `tom_presentation` | space session, notifiers, view state | `tom_core`, `tom_domain`, `tom_application` | no |
| `tom_desktop` | composition root, widgets | all of the above | **yes** |

Six of the seven run under `dart test`, with no Flutter binding available. Folder names are short (`packages/core`); package names carry the `tom_` prefix, because the folder is only a path while the package name is what every import says.

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
- `tom_infra` organises by **capability, not by technology**: `src/git_client/` holds the contract, its failures, and one subfolder per implementation (`process/`, later `libgit2/`). A second implementation is a sibling folder, and the composition root is the only file that changes.
- **No type from a dependency crosses a contract.** A `ProcessException` dies inside `process/` and leaves as a `GitClientFailure`. If it escaped, the caller would be handling exceptions from a library it is not supposed to know about, and the folder would be decoration.
- `tom_core` holds **mechanism, never vocabulary**. `Result`, `AppFailure` and `Observability` belong there. Git, documents and search have vocabulary, and vocabulary belongs to `tom_domain` — otherwise the package everything depends on becomes the package that changes most.
- `test/` **mirrors `lib/src/` exactly**, under one of three top-level folders — `unit/`, `integration/`, `integrity/` — chosen by what the test needs, not by which package it is in:
  - `unit/` — pure logic, no I/O, fakes over real dependencies (failures, parsers, `BlockDiffer`, use cases, notifiers).
  - `integration/` — talks to a real system (a `git init` temp repo, real disk, real sqlite). Slower, and the project's confidence differentiator — never mocked away.
  - `integrity/` — asserts something about the codebase itself, not its runtime behavior (the layer graph, a barrel's exports). Workspace-wide checks live here too: `src/test/architecture_test.dart` is `src/test/integrity/architecture_test.dart`.

  Below that folder, the path matches `lib/src/` exactly, filename plus `_test`: `lib/src/filesystem/dart_io/dart_io_filesystem.dart` (integration, real disk) is tested by `test/integration/filesystem/dart_io/dart_io_filesystem_test.dart`. The layout answers "where are this file's tests, and what kind" without a search.

## Errors across boundaries

An exception never crosses a layer boundary ([Decision 5](../decisions/005-errors-use-result-with-sealed-classes.md)): every repository method and every use case returns `Result<T>`.

- `Result` is **sealed**, so a `switch` over it is exhaustive — forgetting the failure branch does not compile.
- `AppFailure` is a **marker, not sealed**; each area's hierarchy is sealed inside its own library (`GitFailure`, `DocumentFailure`, `SearchFailure`). Adding a variant breaks every switch that must handle it, and only in the packages that deal with that area. A switch over `AppFailure` itself takes a catch-all.
- Technical failures are translated into domain failures by `tom_data`. The graph makes that mandatory rather than customary: `tom_infra` depends only on `tom_core`, so it cannot name a `GitFailure`.
- Every use case wraps its body in a standardized `try/catch`, hands what it caught to `Observability`, and returns `UnexpectedFailure` — never rethrows, never swallows ([Decision 11](../decisions/011-telemetry-is-opt-in.md)).

The types are documented where they live: `packages/core/lib/src/` and `packages/domain/lib/src/<area>/<area>_failure.dart`.

## External dependencies

Every external dependency is reached through a contract ([Decision 7](../decisions/007-external-dependencies-behind-contracts.md)), applied in three tiers:

| Tier | What | How |
|---|---|---|
| **1 — Capabilities** | git binary, filesystem, sqlite/FTS5, markdown parser, text diff | contract + implementation + its own failure type, all inside `tom_infra`; consumed only through the contract |
| **2 — UI widgets** | `re_editor`, third-party components | our own wrapper widget in the app, exposing our API; swapping the package stays in one file |
| **3 — Structural** | Flutter, Riverpod, Freezed | declared exception, not abstracted — wrapping a framework yields a worse homemade one. Scope below |

| Structural | Allowed in | Why the boundary |
|---|---|---|
| **Flutter** | `tom_desktop` only | the pubspecs enforce it; the other six compile and test as pure Dart |
| **Riverpod** | `tom_presentation` and the composition root | it is *runtime* — lifecycle, scope, invalidation. Use cases and repositories receive dependencies through constructors. A use case that needs a `Ref` is a design error |
| **Freezed** | any layer | pure build-time; the generated code is ours and carries no runtime coupling. Mandatory for immutable data classes wherever one qualifies — entities, multi-field value objects, view-state, sealed hierarchies ([Decision 16](../decisions/016-freezed-is-mandatory-for-immutable-data.md)) |

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

`apps/mobile` sits beside `apps/desktop` with its own widgets, sharing `tom_presentation` — which is why that package is pure Dart. No shared-UI package: panels do not become screens. `tom_infra` grows a second implementation per capability (`libgit2/` next to `process/`), chosen at the composition root.
