# The `tom` CLI

`tom` is the CLI, in [`tool/`](../../../tool/). **It needs nothing but the Dart
SDK** — no `pub get` of its own, which is what lets it be the thing that resolves
the workspace
([Decision 17](../decisions/017-tom-is-the-entry-point-and-make-is-a-face.md)).

```bash
dart run tool/tom.dart                 # the menu: arrow keys, Enter, Esc to go back
dart run tool/tom.dart --help          # every command, non-interactively
dart run tool/tom.dart verify          # everything CI runs, stopping at the first failure
dart run tool/tom.dart test unit       # then it asks which package
dart run tool/tom.dart test arch       # just the layer-graph assertions
dart run tool/tom.dart codegen hard    # delete every generated file, then regenerate
dart run tool/tom.dart coverage domain # measure, build the HTML report, open it
dart run tool/tom.dart doctor          # can this machine build the repository at all
dart run tool/tom.dart updates         # the pinned SDKs, against the latest stable
```

## The three worth knowing early

| | |
|---|---|
| `tom doctor` | The first thing to run on a new machine. Reports git, the Dart the pubspecs ask for, the Flutter `src/.fvmrc` pins and the two optional tools some commands reach for, and fails only on what actually stops a build. It stops at the repository's own needs — platform toolchains are `flutter doctor`'s question, and a second implementation of that check would only drift from it |
| `tom updates` | Puts the pin beside the current stable Flutter and Dart. Reports and changes nothing: `src/.fvmrc` is what CI builds against, so raising it raises it for everyone, which makes it a decision rather than a chore |
| `tom test arch` | Reads every `pubspec.yaml` and asserts the dependency graph, including that exactly one package knows Flutter exists. A dependency between layers is declared there, deliberately, because the graph is a decision ([`architecture.md`](../architecture.md)) |

## Rules

- **`make` is a face, not a layer.** Every target is one line through `tom`, and nothing in `tool/` calls back into `make` — the direction is deliberate, because `make` is not installed on Windows and the commands have to work there.
- **`codegen-gate` and `coverage-gate` exist to fail a build**, not to do anything for you, so they are not menu rows and `codegen-gate` is not a `make` target. Both arrive as steps of `verify`, which is how anyone wants them locally, and as steps of the PR job ([`ci.md`](ci.md)).

---

*See also: [process/](README.md) · [setup.md](setup.md) · [ci.md](ci.md)*
