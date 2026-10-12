# CI, in two levels

## Level one — a PR into `main`, and every push to `main`

Defined in
[`.github/workflows/pr-checks.yml`](../../../.github/workflows/pr-checks.yml),
two jobs.

**`Pull Request Checks`**, on Ubuntu:

| Step | Catches |
|---|---|
| format | a diff nobody wrote |
| analyze | the lints that are errors here, `depend_on_referenced_packages` and `implementation_imports` among them ([enforcement.md](../enforcement.md)) |
| `Rules` — `tom rules` | what the analyzer cannot see: naming, the shape of the data and infra packages, the comment ceiling, a relative link in the docs that leads nowhere ([`commands.md`](commands.md)) |
| codegen from scratch | a `.g.dart`/`.freezed.dart` that drifted from the committed source |
| `Test — architecture` | the layer graph, and the capability table no pubspec can express |
| `Test — packages` | `dart test` on the pure packages, the framework-independence proof — no Flutter binding is available to them |
| `Test — apps` | `flutter test` on `tom_ui` and the apps, the widget tests |
| `Test — CLI`, `src/test/cli/` | a command this job calls that no longer answers as it expects |
| the coverage gate | a drop below the threshold |
| end-to-end, headless | every scenario, run for its exit code alone (`tom e2e all --ci`, [`commands.md`](commands.md)) |

**`Build (macOS)`**, on macOS, after `Pull Request Checks`: `tom build macos`, a release
compile of the desktop app — proof the repository builds on its own, never the
distributed artifact.

- **`tom verify` is the same list locally, in the same order** ([`commands.md`](commands.md)) — one implementation, so green locally and green on the PR mean the same thing. End-to-end is the one exception: it is slow and locks the machine ([`commands.md`](commands.md)), so it is not part of `tom verify` and a maintainer runs it by hand; the job above runs it on every PR because Ubuntu can give it a headless window for free.
- **The four `Test` steps are one `make flutter-test` split apart** (`flutter-test-arch`, `-packages`, `-app`, `-cli`), so a failure points at the layer graph, a package, an app or the CLI directly instead of one combined log for all of them.
- **The `Rules` step calls the CLI directly**, as the codegen gate does: a rule file added to the catalogue runs here the day it lands.
- **The codegen step knows two suffixes.** `gen-l10n`'s output under `lib/l10n/generated/` is committed and regenerated on every `pub get`, and no step compares the two.
- **End-to-end runs with no frame and no video** (`--ci`, [testing](../conventions/testing.md)) — a scenario still needs a window, so the step installs `xvfb` and runs under `xvfb-run`; what it proves is the exit code, not a picture of the run.
- **The job names are the required status checks**: `Pull Request Checks`, `Build (macOS)`, and `CLA` from the workflow below. Renaming a job un-requires it on GitHub without a word ([`repository-settings/protection.md`](repository-settings/protection.md)).
- **Integration tests run on Ubuntu only.** macOS compiles and Windows does nothing; a three-platform test matrix is owed before packaging.
- The workflow's token is **read-only by default**, and no secret exists in this repository's CI at all — which is why git tests run against a temporary local repository rather than a real remote ([`repository-settings/actions.md`](repository-settings/actions.md)).

The CLA check is a workflow of its own, whose one job is named `CLA`
([`repository-settings/cla-bot.md`](repository-settings/cla-bot.md)).

## Level two — a tag on `main`

Defined in
[`.github/workflows/release.yml`](../../../.github/workflows/release.yml).
`tom release <major|minor|patch>` ([versioning.md](versioning.md)) is what
leaves the tag: pushing it is what starts this workflow, never a merge to
`main` on its own.

| Job | Does |
|---|---|
| `Package (macOS)` · `Package (Windows)` · `Package (Linux)` | One each, on that platform's own runner: `fastforge package`, unsigned — dmg, exe, AppImage and deb. Windows is **exe, not msix**: an unsigned msix refuses to install by a double-click |
| `Publish (draft release)` | Downloads the three, then `fastforge publish`s each to the same GitHub Release — found by title, created once, sequentially in one job so two platforms never race to create it |

- **`fastforge`** (`dart pub global activate fastforge`) is the successor to the discontinued `flutter_distributor`; MIT, same publisher.
- **Every artifact carries `TOM_VERSION`, `TOM_BUILD` and `TOM_RELEASES=true`** as `--build-dart-define`s — the version from the tag (or the pubspec's, on a manual run), the build from the commit, so the About dialog and the update check answer for real ([`app_build.dart`](../../../src/apps/desktop/lib/about/app_build.dart), [updates.md](../runtime/updates.md)).
- **The release is a draft.** Nobody reaches it until the maintainer publishes it by hand.
- **A manual run (`workflow_dispatch`) packages but never publishes** — it proves the three platforms still build, and running it twice leaves no stray draft behind; only a `v*` tag reaches the publish job.
- **Read-only except the publish job**, which is the one place write is asked for and the one place it is needed ([`repository-settings/actions.md`](repository-settings/actions.md)).
- **Unverified beyond what each tool's own docs promise** — no run has exercised this workflow yet; Inno Setup on `windows-latest` and `appimagetool`'s FUSE-less extraction are the two steps most likely to need a second look on the first real one.

---

*See also: [conventions/testing.md](../conventions/testing.md) · [repository-settings/](repository-settings/README.md)*
