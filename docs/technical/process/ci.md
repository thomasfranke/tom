# CI, in two levels

Everything the PR level runs is also `tom verify` locally, in the same order
and stopping at the first failure ([`commands.md`](commands.md)).

## Level one — PR into `main`

Required to merge. Defined in
[`.github/workflows/pr-checks.yml`](../../../.github/workflows/pr-checks.yml).

| Step | Catches |
|---|---|
| format | a diff nobody wrote |
| analyze | the lints that are errors here, `depend_on_referenced_packages` and `implementation_imports` among them ([enforcement.md](../enforcement.md)) |
| codegen from scratch | a `.g.dart`/`.freezed.dart` that drifted from the committed source |
| the architecture test | the layer graph, and the capability table no pubspec can express |
| `dart test` on the pure packages | the framework-independence proof — no Flutter binding is available to them |
| `flutter test` on the app | the widget and golden tests |
| the coverage gate | a drop below the threshold |

The workflow's token is **read-only by default**, and no secret exists in this
repository's CI at all — which is why git tests run against a temporary local
repository rather than a real remote
([`repository-settings/actions.md`](repository-settings/actions.md)).

## Level two — a tag on `main`

The full build for all three platforms, signing, packaging and publishing.
Signing keys and distribution credentials live outside this repository, so a
tag here marks a point in history and, on its own, produces nothing.

---

*See also: [conventions/testing.md](../conventions/testing.md) · [repository-settings/](repository-settings/README.md)*
