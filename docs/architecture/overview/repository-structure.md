# Repository and layer structure

## One package per layer ([Decision 14](../../decisions/014-each-layer-is-its-own-package.md))

Seven Dart packages in a single Git repository, wired through the **native pub workspace** (Dart 3.6+). The layering is not a convention that reviewers have to defend — it is what the pubspecs declare, so a violation does not resolve.

```
tom/                             ← ONE Git repository
├── docs/                        ← this documentation
├── README.md · LICENSE · CONTRIBUTING.md · Makefile
└── src/                         ← the Dart workspace
    ├── pubspec.yaml                 workspace root (no code)
    ├── analysis_options.yaml        shared by every package
    ├── test/
    │   └── architecture_test.dart   asserts the graph below
    ├── packages/
    │   ├── core/                    tom_core          Result · AppFailure
    │   ├── domain/                  tom_domain        entities · value objects ·
    │   │                                              repository contracts · services
    │   ├── application/             tom_application   use cases
    │   ├── infra/                   tom_infra         capability contracts + impls
    │   ├── data/                    tom_data          parsers · repository impls
    │   └── presentation/            tom_presentation  session · notifiers
    └── apps/
        └── desktop/                 tom_desktop       composition root + widgets
```

Folder names are short; package names carry the `tom_` prefix, because the folder is only a path while the package name is what every import says.

**The workspace lives under `src/`** so the repository root leads with documentation, licence and community files rather than build artefacts. Every `make` target hides that, so commands still run from the root.

## The graph

```
core ← domain ← application ← presentation
  ↑       ↑                        ↑
  └─── infra ← data ─────────────  desktop
```

| Package | May depend on | Flutter? |
|---|---|---|
| `tom_core` | nothing | no |
| `tom_domain` | `tom_core` | no |
| `tom_application` | `tom_core`, `tom_domain` | no |
| `tom_infra` | `tom_core` | no |
| `tom_data` | `tom_core`, `tom_domain`, `tom_infra` | no |
| `tom_presentation` | `tom_core`, `tom_domain`, `tom_application` | no |
| `tom_desktop` | all of the above | **yes** |

Six of the seven are pure Dart and run under `dart test`, with no Flutter binding available. That is a continuously executed proof rather than a promise: a layer that quietly grew a Flutter dependency fails the suite.

## What actually enforces it

Three mechanisms, each covering what the previous one cannot see.

**The pubspecs.** `tom_domain` declares only `tom_core`, so `import 'package:flutter/material.dart'` inside the domain does not resolve. This is the primary boundary.

**Two lints**, because the pubspec alone is weaker than it looks. Dart resolves *transitive* dependencies, so an import of a package that was never declared still compiles — `depend_on_referenced_packages: error` closes that. And `implementation_imports: error` forbids reaching into another package's `lib/src/`, which is what stops `tom_data` importing the concrete git client instead of the contract `tom_infra` chose to export.

**[`src/test/architecture_test.dart`](../../../src/test/architecture_test.dart)**, for the failure neither of the above can see: someone *adding* the dependency to a pubspec, after which the illegal import is perfectly legal. The test reads every pubspec and asserts the table above — including that exactly one package knows Flutter exists.

## Inside a package

Each package exposes one barrel — `lib/tom_<name>.dart` — and keeps everything else under `lib/src/`, which no other package may import. What a package chooses to export *is* its public API, and the boundary is enforced rather than documented.

Infrastructure organises by **capability**, not by technology ([Decision 7](../../decisions/007-external-dependencies-behind-contracts.md)):

```
infra/lib/src/git_client/
├── git_client_interface.dart      the contract — exported
├── git_client_failures.dart       what it can fail with — exported
└── process/                       one implementation, over dart:io Process
```

The rule that gives the shape meaning: **no type from a dependency crosses the interface.** A `ProcessException` dies inside `process/`, translated into a `GitClientFailure` there. If it escaped, the caller would be handling exceptions from a library it is not supposed to know about, and the folder would be decoration.

A second implementation arrives as a sibling — `libgit2/` when mobile needs git without a system binary ([Decision 2](../../decisions/002-git-via-system-binary.md)) — and the composition root is the only file that changes.

## Rendered diff flow (every layer in action)

```
tom_desktop      panel asks the notifier for the diff of the open document
tom_presentation notifier calls the use case, translates Result into state
tom_application  ComputeRenderedDiff orchestrates repository + BlockDiffer
tom_data         DocumentRepositoryImpl reads HEAD and the working tree
tom_infra        GitClient runs `git show`, FileSystem reads the file
tom_domain       BlockDiffer classifies blocks: added, removed, modified
tom_core         every step returns Result<T>; failures are sealed
```

Read the arrows: each layer only ever talks to the one below it, and the direction never inverts. `tom_domain` sits at the bottom of the call and knows nothing about how the bytes arrived.

## When mobile arrives (Phase 3)

`apps/mobile` is added alongside `apps/desktop` with its own widgets, sharing `tom_presentation`. No package of shared UI is created — [Decision 8](../../decisions/008-monorepo-with-pure-dart-core.md) is explicit that panels do not become screens, so there is no widget to share. What *is* shared is the state, which is exactly the package that is already pure Dart.

`tom_infra` grows a second implementation per capability rather than splitting: `libgit2/` next to `process/`, chosen at the composition root.
