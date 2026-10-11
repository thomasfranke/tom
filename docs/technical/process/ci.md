# CI, in two levels

## Level one — a PR into `main`, and every push to `main`

Defined in
[`.github/workflows/pr-checks.yml`](../../../.github/workflows/pr-checks.yml),
two jobs.

**`Verify`**, on Ubuntu:

| Step | Catches |
|---|---|
| format | a diff nobody wrote |
| analyze | the lints that are errors here, `depend_on_referenced_packages` and `implementation_imports` among them ([enforcement.md](../enforcement.md)) |
| `Rules` — `tom rules` | what the analyzer cannot see: naming, the shape of the data and infra packages, the comment ceiling, a relative link in the docs that leads nowhere ([`commands.md`](commands.md)) |
| codegen from scratch | a `.g.dart`/`.freezed.dart` that drifted from the committed source |
| the architecture test | the layer graph, and the capability table no pubspec can express |
| `dart test` on the pure packages | the framework-independence proof — no Flutter binding is available to them |
| `flutter test` on `tom_ui` and the apps | the widget tests |
| the CLI's own tests, `src/test/cli/` | a command this job calls that no longer answers as it expects |
| the coverage gate | a drop below the threshold |

**`Build (macOS)`**, on macOS, after `Verify`: `tom build macos`, a release
compile of the desktop app — proof the repository builds on its own, never the
distributed artifact.

- **`tom verify` is the same list locally, in the same order** ([`commands.md`](commands.md)) — one implementation, so green locally and green on the PR mean the same thing.
- **The `Rules` step calls the CLI directly**, as the codegen gate does: a rule file added to the catalogue runs here the day it lands.
- **The codegen step knows two suffixes.** `gen-l10n`'s output under `lib/l10n/generated/` is committed and regenerated on every `pub get`, and no step compares the two.
- **Neither job runs the end-to-end suite** — a scenario needs a window ([testing](../conventions/testing.md)).
- **The job names are the required status checks**: `Verify`, `Build (macOS)`, and `CLA` from the workflow below. Renaming a job un-requires it on GitHub without a word ([`repository-settings/protection.md`](repository-settings/protection.md)).
- **Integration tests run on Ubuntu only.** macOS compiles and Windows does nothing; a three-platform test matrix is owed before packaging.
- The workflow's token is **read-only by default**, and no secret exists in this repository's CI at all — which is why git tests run against a temporary local repository rather than a real remote ([`repository-settings/actions.md`](repository-settings/actions.md)).

The CLA check is a workflow of its own, whose one job is named `CLA`
([`repository-settings/cla-bot.md`](repository-settings/cla-bot.md)).

## Level two — a tag on `main`

The full build for all three platforms, signing, packaging and publishing. No
workflow for it exists here: signing keys and distribution credentials live
outside this repository, so a tag marks a point in history and, on its own,
produces nothing.

---

*See also: [conventions/testing.md](../conventions/testing.md) · [repository-settings/](repository-settings/README.md)*
