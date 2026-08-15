# Development setup

A monorepo on the native pub workspace ([Decision 8](../decisions/008-monorepo-with-pure-dart-core.md)). Prerequisites: Flutter stable (Dart ≥ 3.6) and git.

```bash
flutter config --enable-windows-desktop --enable-macos-desktop --enable-linux-desktop

# Workspace structure
mkdir -p tom/{packages,apps,docs} && cd tom
git init

# Workspace root (pubspec.yaml):
#   name: tom_workspace
#   environment: { sdk: ^3.6.0 }
#   workspace:
#     - packages/tom_core
#     - apps/tom_desktop

# Core (pure Dart — NO Flutter in the pubspec)
dart create -t package packages/tom_core
# core pubspec: add `resolution: workspace`
cd packages/tom_core
dart pub add freezed_annotation markdown diff_match_patch sqlite3 watcher path
dart pub add --dev build_runner freezed test custom_lint
cd ../..

# Desktop app
flutter create --platforms=windows,macos,linux --org dev.YOURDOMAIN apps/tom_desktop
# app pubspec: add `resolution: workspace` and `tom_core: {}` to dependencies
cd apps/tom_desktop
flutter pub add flutter_riverpod riverpod_annotation re_editor re_highlight \
  sqlite3_flutter_libs window_manager file_selector url_launcher shared_preferences
flutter pub add --dev build_runner riverpod_generator custom_lint riverpod_lint
cd ../..

dart pub get          # a single get at the root resolves the whole workspace
cd apps/tom_desktop && flutter run -d windows   # or macos / linux
```

## Everyday commands

A `Makefile` wraps the common tasks as a convenience. Every target is a short command you can equally run by hand, and the docs name those commands directly — nothing in the project requires `make`.

```bash
make help            # list every target
make setup           # resolve the workspace
make verify          # format + analyze + test — everything CI runs
make test-core       # pure Dart tests (the framework-independence proof)
make test-changed    # only the tests matching what this branch changed
make runner          # build_runner in both packages
make run             # run the app (DEVICE=windows|linux|macos)
make run-flags FLAGS="FEATURE_DIFF_V1=true"
```

## Conventions

- **Conventional Commits** (`feat:`, `fix:`, `docs:` …) + semantic versioning — dogfooding our own workflow
- **This project's documentation lives in `docs/`, in markdown** — the app should, as soon as possible, be used to edit its own docs (full dogfooding)
- **Branches:** trunk-based — `feat/*` → PR into **`main`** (squash) → tag publishes. No `dev`. See `CONTRIBUTING.md` and the `tom-git-workflow` skill.
- **CI from day one, in two levels:**
  - **PR into `main`:** `dart analyze` + **`dart test`** on `tom_core` (the purity proof — no Flutter binding), `flutter analyze` + `flutter test` on `tom_desktop`. Required to merge.
  - **Tag on `main`:** the full build for all three platforms, signing, packaging and publishing.
- **Feature flags** are build-time only (`--dart-define`); enable experimental ones locally, never in a release build.
- **The PR checklist includes a license check** for every new dependency (nothing AGPL/GPL — [Decision 1](../decisions/001-license-is-mit.md))
- **Per-layer import lint** inside the core — boundaries between packages are enforced by the build; boundaries inside the core, by the lint

---

*See also: [architecture/](../architecture/) · [dependencies.md](../architecture/dependencies.md)*
