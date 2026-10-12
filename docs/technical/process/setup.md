# Development setup

**Prerequisites:** Flutter (Dart ≥ 3.12, for the workspace's `sdk` constraint)
and **git 2.41 or newer** — `cli doctor` checks for both, and says what is
missing. Nothing else — no Melos, no global tooling, and `make` is optional.
`src/.fvmrc` pins the exact version CI uses (`cli fvm` to match it locally);
anything recent enough should resolve regardless.

- **2.41 is where `for-each-ref` learnt `%(ahead-behind)`**, which the diff's base is deduced with ([runtime/git.md](../runtime/git.md)); an older git fails that command. `cli doctor` fails on one and names the version it found; the app is to refuse on Home with `TOM needs git 2.41 or newer. This machine has <version>.` ([opening a space](../../product/home/opening-a-space/doc.md)), and does not say it yet.

```bash
git clone https://github.com/thomasfranke/tom.git
cd tom
flutter config --enable-windows-desktop --enable-macos-desktop --enable-linux-desktop

dart run tool/cli.dart setup   # one resolve for every package
dart run tool/cli.dart run     # opens the desktop app
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
- **Feature flags are a pattern, and nothing declares one yet**: build-time
  only (`--dart-define`), never in a release build
  ([CONTRIBUTING.md](../../../CONTRIBUTING.md#feature-flags)).

---

*See also: [commands.md](commands.md) · [ci.md](ci.md) · [stack/](../stack/README.md)*
