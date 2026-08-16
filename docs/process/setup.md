# Development setup

**Prerequisites:** Flutter (Dart ≥ 3.12, for the workspace's `sdk` constraint) and git. Nothing else — no Melos, no global tooling, no `make` if you would rather type the commands. `src/.fvmrc` pins the exact version CI uses (`make fvm` to match it locally); anything recent enough should resolve regardless.

```bash
git clone https://github.com/thomasfranke/tom.git
cd tom
flutter config --enable-windows-desktop --enable-macos-desktop --enable-linux-desktop

make setup            # one resolve for all seven packages
make run              # DEVICE=windows|linux|macos
```

## Where things are

The Dart workspace is under [`src/`](../../src/), so the repository root leads with documentation and licence rather than build files. Seven packages, one per layer, and a violation of the layering does not compile — the graph and what enforces it are in [architecture/layers.md](../architecture/layers.md).

Every `make` target runs from the repository root and handles the `src/` hop for you. If you prefer the raw commands, they are what the `Makefile` shows: `cd src && flutter pub get`, `cd src && flutter analyze`, and so on.

## Everyday commands

The `Makefile` is a convenience, not a requirement. Each target wraps a short command you can equally type by hand.

```bash
make help               # list every target
make setup              # resolve the workspace
make verify             # format + analyze + codegen gate + test + coverage gate — everything CI runs
make flutter-test       # architecture test, then each package, then the app
make flutter-test-arch  # just the layer-graph assertions
make analyze            # static analysis across all seven packages at once
make runner             # build_runner wherever a package declares it
make codegen-gate       # runner-hard, then fail if .g.dart/.freezed.dart drifted from git
make run                # run the app (DEVICE=windows|linux|macos)
make run-flags FLAGS="FEATURE_DIFF_V1=true"
```

`make flutter-test-arch` is worth knowing early: it reads every `pubspec.yaml` and asserts the dependency graph, including that exactly one package knows Flutter exists. If you add a dependency between layers, that test is where you declare the intent — deliberately, because the graph is a decision.

## Adding a dependency

Add it to the pubspec of the package that needs it, not to the workspace root. The root exists to give all seven a single lockfile, which is what stops two layers resolving different versions of the same transitive package.

A new *external* dependency needs a licence check — nothing AGPL or GPL ([Decision 1](../decisions/001-license-is-mit.md)) — and a line in [dependencies.md](../architecture/dependencies.md) saying what it is for.

## Conventions

- **Conventional Commits** (`feat:`, `fix:`, `docs:` …) plus semantic versioning — dogfooding our own workflow.
- **Documentation lives in `docs/`, in markdown**, and the app should be used to edit its own docs as soon as it can.
- **Trunk-based branches:** `feat/*` → PR into `main` (squash) → a tag publishes. No `dev`. See `CONTRIBUTING.md` and the `tom-git-workflow` skill.
- **Feature flags are build-time only** (`--dart-define`); enable experimental ones locally, never in a release build.
- **CI, in two levels:**
  - **PR into `main`:** format, analyze, a from-scratch codegen run that fails if `.g.dart`/`.freezed.dart` drifted from the committed source, the architecture test, `dart test` on the six pure packages (the framework-independence proof — no Flutter binding available), `flutter test` on the app, and the coverage gate. Required to merge.
  - **Tag on `main`:** the full build for all three platforms, signing, packaging and publishing.

---

*See also: [architecture/](../architecture/) · [dependencies.md](../architecture/dependencies.md)*
