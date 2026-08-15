# Decision 14 — Each layer is its own package

**Status:** accepted
**Revises:** [Decision 8](008-monorepo-with-pure-dart-core.md), which put a build boundary only between pure Dart and Flutter and left the layers as folders inside one package.

## Context

Decision 8 drew a single build boundary — `tom_core` (pure Dart) against `tom_desktop` (Flutter) — and said plainly: *a build boundary only where leakage would be structural; convention plus an import lint everywhere else.* Inside `tom_core`, `domain/`, `application/`, `data/` and `infrastructure/` were folders.

That works, and for most projects it is the right amount of ceremony. It rests on one thing: that nobody writes the import. A folder does not stop `domain/` importing `sqlite3`. Review does, until the day it does not.

This project's second goal is a repository worth reading ([roadmap](../product/roadmap.md#goals)). An architecture that survives because people are careful demonstrates carefulness. An architecture that survives because the wrong import does not resolve demonstrates the architecture.

## Decision

Seven packages, one per layer, in a pub workspace under `src/`:

| Package | May depend on | Flutter |
|---|---|---|
| `tom_core` | nothing | no |
| `tom_domain` | `tom_core` | no |
| `tom_application` | `tom_core`, `tom_domain` | no |
| `tom_infra` | `tom_core` | no |
| `tom_data` | `tom_core`, `tom_domain`, `tom_infra` | no |
| `tom_presentation` | `tom_core`, `tom_domain`, `tom_application` | no |
| `tom_desktop` | all of the above | **yes** |

The tree, and what each package holds, is in [layers.md](../architecture/layers.md).

## What this buys, precisely

**The domain cannot import a framework.** Not "should not" — `tom_domain`'s pubspec lists `tom_core` and nothing else, so `package:flutter/material.dart` fails to resolve. The same holds for sqlite and for presentation. `dart:io` is the one it cannot cover — SDK libraries need no declaration, so they are available everywhere by default — which is why the architecture test scans imports as well as pubspecs.

**Six of seven packages run under `dart test`**, with no Flutter binding available. Framework independence is asserted on every run rather than claimed in a document.

**`tom_presentation` is pure Dart**, which is the boundary that makes a second app affordable. State cannot reach for a widget, so when `apps/mobile` arrives it shares the state and writes its own layout — no refactor, and no shared-UI package, because [Decision 8](008-monorepo-with-pure-dart-core.md) is right that panels do not become screens.

## What it costs

**Seven pubspecs.** A dependency added for one layer is added in one place, which is the point, but it is also seven files to keep tidy.

**Melos becomes worthwhile.** Decision 8 named 3+ packages as the trigger and it has fired. Until it is adopted, the `Makefile` loops over the packages, which is enough at this size and keeps the repository free of another tool.

**Codegen runs per package.** `build_runner` executes wherever a package declares it, not once for the workspace.

Accepted knowingly: this is more ceremony than a project of this size needs on product grounds alone. It is bought with the second goal, not the first.

## The part the packages do not cover

Two lints, because the pubspec boundary is weaker than it looks:

- **`depend_on_referenced_packages: error`** — Dart resolves transitive dependencies, so importing a package that was never declared still compiles. Without this rule, `tom_data` can import `tom_core` through `tom_infra` without saying so, and the declared graph stops describing the real one.
- **`implementation_imports: error`** — nothing may reach into another package's `lib/src/`. This is what makes "the barrel is the public API" true rather than aspirational, and it is what keeps `tom_data` on `tom_infra`'s contracts instead of its concrete git client.

And one test, [`src/test/architecture_test.dart`](../../src/test/architecture_test.dart), for the failure neither the compiler nor a lint can see: a dependency **added to a pubspec**, after which the illegal import is entirely legal. It reads every pubspec and asserts the table above, including that exactly one package knows Flutter exists. Changing the graph means changing that test first — deliberate friction, because the graph is a decision.

## Revisit when

A layer's package has been empty through a whole milestone. That is evidence the boundary was drawn where nothing needed separating, and merging it costs one `git mv` plus a line in the test.
