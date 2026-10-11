# The `tom` CLI

`tom` is the CLI, in [`tool/`](../../../tool/). **It needs nothing but the Dart
SDK** — no `pub get` of its own, which is what lets it be the thing that resolves
the workspace
([Decision 17](../decisions/017-tom-is-the-entry-point-and-make-is-a-face.md)).

```bash
dart run tool/tom.dart                 # the menu: arrow keys, Enter, Esc to go back
dart run tool/tom.dart --help          # every command, non-interactively
dart run tool/tom.dart --preview e2e   # a screen as plain text, without driving the menu
```

## Every command

Run as `dart run tool/tom.dart <command>`, from the repository root.

| Command | Does |
|---|---|
| `setup` | One `pub get` for the whole workspace — the first thing after a clone, and after pulling a pubspec change |
| `doctor` | Says whether this machine can build the repository: git, the Dart the workspace asks for, the Flutter `src/.fvmrc` pins, and the two optional tools some commands reach for. Fails only on what stops a build — a git older than 2.41 among them ([setup.md](setup.md)); platform toolchains are `flutter doctor`'s question |
| `updates` | Puts the pin beside the current stable Flutter and Dart. Reports and changes nothing: raising `src/.fvmrc` raises it for CI too, which makes it a decision |
| `fvm` | Installs FVM and pins this workspace to `src/.fvmrc` |
| `clean [package…]` | Removes build output and the `build_runner` cache, then resolves again |
| `format` | Formats `src/` and `tool/`, failing if anything was not already formatted |
| `analyze` | Static analysis: the workspace, then the CLI on its own options |
| `rules [name]` | What the analyzer cannot check — `comments`, `data-layer`, `infrastructure`, `links`, `naming` — every break in one pass |
| `codegen [normal\|hard] [package…]` | `build_runner`: `normal` where this branch changed something, `hard` deletes every `.g.dart` and `.freezed.dart` first |
| `test` | The architecture assertions, then every package, then the apps — see below |
| `coverage [package…]` · `coverage diff [--base=REF]` · `coverage last [--count=N]` | Measures and opens the HTML report; the two narrowed forms print to the terminal |
| `e2e` | The end-to-end scenarios — see below |
| `run [macos\|linux\|windows]` | Opens the desktop app |
| `build [macos\|linux\|windows]` | A release compile, as proof the repository builds on its own; never the distributed artifact |
| `verify` | `format` → `analyze` → `rules` → `codegen-gate` → `test` → `coverage-gate`, stopping at the first failure |
| `codegen-gate` · `coverage-gate [--kind=unit\|all] [--threshold=N]` | Exist to fail a build: regenerate from scratch and fail on drift; fail if a package is under 90 % of line coverage by unit tests alone (`all` reports the whole `test/`) |

## `test`

| | Runs |
|---|---|
| `test` | `arch`, the packages in dependency order, the apps, then `cli` — with coverage |
| `test <package…>` | Only those: `core` `domain` `application` `infra` `data` `presentation` `ui` `desktop` `mobile` |
| `test unit` · `test integration` | That folder of each package named, or of all; a package without the folder is reported as skipped |
| `test arch` | `src/test/integrity/` — the dependency graph read from every `pubspec.yaml`, which packages may know Flutter, the capability table ([enforcement.md](../enforcement.md)) |
| `test cli` | `src/test/cli/` — the CLI's own tests, on the workspace side because `tool/` has no pubspec. The whole `test` run ends with them; a narrowed run leaves them out |
| `test diff [--base=REF]` | What this branch's diff maps to, by name: `lib/foo.dart` runs `foo_test.dart` |
| `test last [--count=N]` | The same mapping over the files edited most recently |

## `e2e`

The scenarios drive the assembled app on this machine, one at a time
([what they prove](end-to-end-coverage.md)).

| | Does |
|---|---|
| `e2e` · `e2e list` | Lists every scenario by group, with when each last passed and on which version of the app |
| `e2e <the scenario's name>` | Runs that one. **The name is the prose the source declares**, words and all — `tom e2e Works in tabs` |
| `e2e all` | Every scenario, sequentially |
| `e2e prepare` · `e2e clean` | Builds, or removes, the folders the scenarios run against, under `.e2e/` |
| `e2e fixtures` | Lists the situations on disk the scenarios flow through |
| `--watch` | Holds the screen after each action, slowly enough to follow |
| `--board` | Opens the window at the boards' own 1440 × 900, so a frame and a board crop to the same rectangle ([testing](../conventions/testing.md)) |

- **A name that matches no scenario exits 64 and prints the names there are.** It never runs something else.
- **The environment is rebuilt before each scenario that reads a fixture** — scenarios commit, save and push, so the next one would otherwise open a situation nobody described.
- **Two runs never overlap**: each launches the app, and on macOS the next launch fails while the previous window is still there.
- **A run leaves its evidence under `.e2e-evidence/`**: a frame per step, the transcript, and a video joined from the frames when `ffmpeg` is installed. The last outcome of each scenario is `.e2e-results.json`.
- **A scenario with no step is a failure, whatever its exit code**: the build failed, or the process was killed. The line reads `✘ <name> — 0/0 steps · did not run`, its log and video carry `did-not-run` in their names, and `e2e all` counts it as failed.
- **`e2e all` is slow and locks the machine**, so it is the end of a piece of work, not a step of it; while building, only the feature's own scenario runs.

## Rules

- **`make` is a face, not a layer.** A target is one line through `tom`, and nothing in `tool/` calls back into `make` — the direction is deliberate, because `make` is not installed on Windows and the commands have to work there. `runner-watch` is the one recipe still written as shell, since `build_runner watch` never returns an exit code.
- **The end-to-end screen is two screens: the groups, then one group's scenarios.** A suite grows a scenario at a time and a single list grows with it until it runs off the window; a group is the unit somebody thinks in anyway. Backing out of a group returns to the groups rather than leaving, the way codegen's two screens do.
- **A group's row says what the group adds up to** — `✘ 1 failing`, `✓ 6 passed`, or `4 of 6 run`. A failure is what the eye is looking for, so it is said first, and "all passed" is claimed only when every one of them actually ran.
- **`rules links` follows every relative link in the written record** — the markdown under `docs/` and `.ai/skills/`, plus `AGENTS.md`, `CONTRIBUTING.md` and `README.md`: the file by exact case, and the heading when the target is markdown. An address on the network is never asked — a gate that needs one fails with the weather — and links inside dartdoc are not read.
- **`codegen-gate` and `coverage-gate` are not menu rows**, and `codegen-gate` is not a `make` target. Both arrive as steps of `verify`, which is how anyone wants them locally, and as steps of the PR job ([`ci.md`](ci.md)).
- **The codegen gate asks git, not the generator**: a new `.g.dart` or `.freezed.dart` that is merely uncommitted reads as drift and stops `verify` before a test runs. Run the suites directly while the work is untracked.

---

*See also: [process/](README.md) · [setup.md](setup.md) · [ci.md](ci.md)*
