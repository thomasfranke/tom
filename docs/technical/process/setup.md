# Development setup

**Prerequisites:** Flutter (Dart ≥ 3.12, for the workspace's `sdk` constraint)
and git — `tom doctor` checks for both, and says what is missing. Nothing else
— no Melos, no global tooling, and `make` is optional. `src/.fvmrc` pins the
exact version CI uses (`tom fvm` to match it locally); anything recent enough
should resolve regardless.

```bash
git clone https://github.com/thomasfranke/tom.git
cd tom
flutter config --enable-windows-desktop --enable-macos-desktop --enable-linux-desktop

dart run tool/tom.dart setup   # one resolve for every package
dart run tool/tom.dart run     # opens the desktop app
```

## Where things are

The Dart workspace is under [`src/`](../../../src/), so the repository root
leads with documentation and licence rather than build files. One package per
layer, and a violation of the layering does not compile — the graph and what
enforces it are in [`architecture.md`](../architecture.md).

Everything runs from the repository root and handles the `src/` hop for you.
The commands themselves are [`commands.md`](commands.md).

## Adding a dependency

Add it to the pubspec of the package that needs it, not to the workspace root.
The root exists to give every package a single lockfile, which is what stops
two layers resolving different versions of the same transitive package.

A new *external* dependency needs a licence check — nothing AGPL or GPL
([Decision 1](../decisions/001-license-is-mit.md)) — and a line in
[`stack/`](../stack/README.md) saying what it is for.

## Conventions

- **Conventional Commits** (`feat:`, `fix:`, `docs:` …) plus semantic
  versioning — dogfooding our own workflow. See
  [`versioning.md`](versioning.md).
- **Documentation lives in `docs/`, in markdown**, and the app should be used
  to edit its own docs as soon as it can.
- **Trunk-based branches:** `feat/*` → PR into `main` (squash) → a tag
  publishes. No `dev`. See [`CONTRIBUTING.md`](../../../CONTRIBUTING.md) and
  the `tom-git-workflow` skill.
- **Feature flags are build-time only** (`--dart-define`); enable experimental
  ones locally, never in a release build.

---

*See also: [commands.md](commands.md) · [ci.md](ci.md) · [stack/](../stack/README.md)*
