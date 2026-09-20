# Decision 17 — `tom` is the development entry point; `make` is a face over it

**Status:** accepted

## Context

Development commands lived in the `Makefile`, with the substantial ones delegating to four Dart scripts in `tool/` (`run_tests.dart`, `run_codegen.dart`, `run_changed_tests.dart`, `coverage_gate.dart`). Three things had gone wrong with that arrangement:

**`make` is not installed on Windows**, which this project builds for ([Decision 13](013-stack-is-flutter-and-dart.md), `build-windows`). A contributor there could read the Makefile and retype its recipes, which [setup.md](../setup.md) offered as the fallback — but that is not an entry point, it is a transcription exercise.

**The Makefile was no longer the only entry point.** `.github/workflows/pr-checks.yml` bypassed `make codegen-gate` and `make flutter-test` and inlined roughly fifty lines of bash reimplementing both loops, with a comment explaining why: the dashboards redraw on a 250ms ticker with ANSI cursor moves, which a CI log prints as new lines instead of overwriting. The result was two implementations of the same run, only one of which anybody exercised locally.

**Some recipes were POSIX-only regardless of `make`.** `runner-hard` deleted generated files with `find -name ... -delete`; the coverage report opened with `open`. Both fail on Windows even where `make` is available.

## Decision

`dart run tool/tom.dart <command>` is the entry point for development commands. It is one program with two faces: run with no arguments it opens a navigable menu; run with a command it does the same work non-interactively, which is what CI and other agents call.

**`tool/` holds no reference to `make`, and every `Makefile` target is one line through `tom`.** The dependency points one way. The Makefile stays for muscle memory, shell completion and `make help`; it carries no logic of its own.

`tool/` depends on **nothing but the Dart SDK** — no `pubspec.yaml`, no `pub get`. This is a constraint, not an accident: `tom setup` is the command that resolves the workspace, so a tool that needed the workspace resolved before it could run would be circular. It also means the CLI works on a fresh clone, before anything else does.

Output adapts to whether a terminal is attached (`tool/src/tty.dart`): with one, the live dashboards; without one — a pipe, or CI — append-only lines, no ticker, no redraw.

## Rationale

- One implementation of each command, exercised locally every day, is what CI should be running. The inlined bash existed because the CLI could not serve both audiences; making it serve both removes the reason for a second copy.
- Windows support is a stated platform, not an aspiration. Commands that only work on POSIX make it one.
- A menu is discoverable in a way `make help` is not: it can ask which package, which platform, which kind of test, and show what each choice does before it runs.
- The zero-dependency rule is what keeps the bootstrap honest and keeps `tool/` outside the workspace in `src/`, where [Decision 14](014-each-layer-is-its-own-package.md)'s one-package-per-layer graph and the architecture test apply. The CLI is not a layer and does not belong in that graph.

## Consequences

- `make verify` and the other targets keep working, unchanged for anyone who types them.
- CI calls `make` for most steps and `dart run tool/tom.dart codegen-gate` directly for the gate, which is a pipeline concern rather than a developer convenience.
- The gates (`codegen-gate`, `coverage-gate`) and `format`/`analyze`/`setup` are commands but not menu rows: they are steps of `verify`, not things anyone sets out to run alone.
- `run-flags` and `flags` were removed rather than ported — nothing in `src/` declares a build-time flag yet (`CONTRIBUTING.md`, "Feature flags"). They come back with the first one.
- `runner-watch` is the one recipe still written as shell. `build_runner watch` does not terminate, so the run-and-report-an-exit-code shape every other command has does not fit it.
- The CLI has no tests. `tool/` has no `dart test` because it has no pubspec, which is the same constraint that keeps the bootstrap honest — see *Revisit when*.

## Revisit when

A test for the CLI is wanted. The frame composer (`composeFrame`) and the key decoder are pure functions and worth asserting; the interactive loop is not, since it needs a pty. Testing them means giving `tool/` a `pubspec.yaml` of its own, kept **out** of the `workspace:` list in `src/pubspec.yaml` so its dependencies can never reach the product, plus a `dart pub get -C tool` in `tom setup`. That trades the zero-dependency bootstrap for coverage of the part most likely to break silently — worth doing deliberately, not by accident when someone reaches for a package.
