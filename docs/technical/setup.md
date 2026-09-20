# Development setup

**Prerequisites:** Flutter (Dart ≥ 3.12, for the workspace's `sdk` constraint) and git. Nothing else — no Melos, no global tooling, and `make` is optional. `src/.fvmrc` pins the exact version CI uses (`tom fvm` to match it locally); anything recent enough should resolve regardless.

```bash
git clone https://github.com/thomasfranke/tom.git
cd tom
flutter config --enable-windows-desktop --enable-macos-desktop --enable-linux-desktop

dart run tool/tom.dart setup   # one resolve for all seven packages
dart run tool/tom.dart run     # opens the desktop app
```

## Where things are

The Dart workspace is under [`src/`](../../src/), so the repository root leads with documentation and licence rather than build files. Seven packages, one per layer, and a violation of the layering does not compile — the graph and what enforces it are in [layers.md](layers.md).

Everything runs from the repository root and handles the `src/` hop for you.

## Everyday commands

`tom` is the CLI, in [`tool/`](../../tool/). It needs nothing but the Dart SDK — no `pub get` of its own, which is what lets it be the thing that resolves the workspace. Run it with no arguments for a navigable menu, or name a command directly:

```bash
dart run tool/tom.dart                 # the menu: arrow keys, Enter, Esc to go back
dart run tool/tom.dart --help          # every command, non-interactively
dart run tool/tom.dart verify          # everything CI runs, stopping at the first failure
dart run tool/tom.dart test unit       # then it asks which package
dart run tool/tom.dart test arch       # just the layer-graph assertions
dart run tool/tom.dart codegen hard    # delete every generated file, then regenerate
dart run tool/tom.dart coverage domain # measure, build the HTML report, open it
```

The `Makefile` is a shortcut over the same commands, for the muscle memory and the shell completion — `make verify`, `make flutter-test`, `make setup`. It holds no logic of its own: every target is one line through `tom`, and nothing in `tool/` calls back into `make`. That direction is deliberate, because `make` is not installed on Windows and the commands have to work there.

`tom test arch` is worth knowing early: it reads every `pubspec.yaml` and asserts the dependency graph, including that exactly one package knows Flutter exists. If you add a dependency between layers, that test is where you declare the intent — deliberately, because the graph is a decision.

The gates — `codegen-gate` and `coverage-gate` — exist to fail a build rather than to do anything for you, so they are not menu rows and `codegen-gate` is not a `make` target. Both arrive as steps of `verify`, which is how anyone wants them locally.

## Adding a dependency

Add it to the pubspec of the package that needs it, not to the workspace root. The root exists to give all seven a single lockfile, which is what stops two layers resolving different versions of the same transitive package.

A new *external* dependency needs a licence check — nothing AGPL or GPL ([Decision 1](decisions/001-license-is-mit.md)) — and a line in [dependencies.md](dependencies.md) saying what it is for.

## Conventions

- **Conventional Commits** (`feat:`, `fix:`, `docs:` …) plus semantic versioning — dogfooding our own workflow.
- **Documentation lives in `docs/`, in markdown**, and the app should be used to edit its own docs as soon as it can.
- **Trunk-based branches:** `feat/*` → PR into `main` (squash) → a tag publishes. No `dev`. See `CONTRIBUTING.md` and the `tom-git-workflow` skill.
- **Feature flags are build-time only** (`--dart-define`); enable experimental ones locally, never in a release build.
- **CI, in two levels:**
  - **PR into `main`:** format, analyze, a from-scratch codegen run that fails if `.g.dart`/`.freezed.dart` drifted from the committed source, the architecture test, `dart test` on the six pure packages (the framework-independence proof — no Flutter binding available), `flutter test` on the app, and the coverage gate. Required to merge.
  - **Tag on `main`:** the full build for all three platforms, signing, packaging and publishing.

---

*See also: [technical/](README.md) · [dependencies.md](dependencies.md)*
