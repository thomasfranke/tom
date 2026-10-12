# Testing

## The layout

In the layer packages (`core` … `presentation`) `test/` **mirrors `lib/src/`**,
under a top-level folder chosen by what the test needs, not by which package it
is in:

| Folder | What it holds |
|---|---|
| `unit/` | Pure logic, no I/O, fakes over real dependencies — failures, parsers, `BlockDifferService`, use cases, notifiers |
| `integration/` | Talks to a real system: a `git init` temp repo, real disk, real sqlite. Slower, and the project's confidence differentiator — **never mocked away** |

- Below that folder the path matches `lib/src/`, filename plus `_test` — so the layout answers "where are this file's tests, and what kind" without a search.
- **No second file for the same subject in the same kind.**
- One subject *can* have a file under two kinds, because the kind is part of the path — `json_file_settings_impl.dart` has a unit test for the failures a real disk will not produce on demand, and an integration test against a real one.
- **A test that mirrors no file is named for what it proves, and there are three kinds of it**: a family of use cases in one file (`merge_use_cases_test.dart`), the wiring of a whole package (`tom_presentation`'s `seams_test.dart` and `wiring_test.dart`), and what two classes decide together (`block_differ_test.dart` under `tom_data`'s `integration/`).
- A test under `unit/` that runs a real library is in the wrong folder and is owed a move to `integration/`.

**The stack is the fourth, and the one that matters most:** a test whose
subject is the stack rather than a class. `opening_end_to_end_test.dart` wires
real disk, real git and a real settings file the way the composition root does,
and asks the question the user asks. It is the only test that fails when the
pieces are each right and do not fit.

Outside the layer packages the kind is the folder itself:

| Where | What it holds |
|---|---|
| `src/test/integrity/` | What is true of the codebase rather than of its behaviour — the layer graph, the capability table, a screen's own widgets (`architecture_test.dart`). `tom test arch` |
| `src/test/cli/` | The `tom` CLI's own tests, on the workspace side because `tool/` has no pubspec. `tom test cli` runs them alone, and the whole `tom test` run ends with them — so `verify` and the PR job do too |
| `src/packages/ui/test/` | Widget tests of the shared components, one file per component, flat |
| `src/apps/desktop/test/` | Widget tests under `bootstrap/`, `l10n/` and `screens/<feature>/`, following `lib/` with no kind folder; a file may be named for the behaviour it holds (`changes_discard_test.dart`) |
| `src/apps/desktop/integration_test/` | The end-to-end scenarios under `e2e/` — one folder per menu of `tom e2e` (`e2e/<group>/<submenu>/`, at most 25 entries a menu, alphabetical), a file per flow named for the job, beside `support/` (the harness and the robot) and `fixtures/` ([end-to-end coverage](../process/end-to-end-coverage.md)) |

## What each subject gets

| Target | Type | Approach |
|---|---|---|
| Parsers (git porcelain, log, markdown AST) | unit | Fixtures of real git output; pure and fast |
| `BlockDifferService` | unit + integration | A fake alignment for the classification; the real parser and differ over real markdown for what the two decide together |
| Use cases | unit | Fake repositories; orchestration and failure propagation |
| Capability implementations | integration | The real tool: `git` on a temp repository, the real disk, the real index. A failure is provoked from the tool, not constructed |
| Repository implementations | integration | A real repo created by `git init` in a temp dir |
| Notifiers | unit | `ProviderContainer` with overridden use cases |
| Shared components (`tom_ui`) | widget | The component alone, in each state it has |
| Screens, panels, dialogs | widget | Mounted where the app mounts them, the notifiers they watch overridden |
| A user-facing feature | end to end | A scenario that drives the real app against a fixture it builds; every step leaves a frame, and the run a video (`tom e2e`, [commands](../process/commands.md)) |
| The `tom` CLI | unit | `src/test/cli/` |

- **A widget test is not a substitute for a scenario or an integration test** — it is the home of a state no scenario can hold still.
- **Integration runs where the suite runs**: the PR job is Ubuntu, and a developer's own machine is whatever it is. A three-platform matrix is owed before packaging ([ci.md](../process/ci.md)).
- There are no golden files. What a screen looks like is held by the comparison below.

## Held to the board

**Every screen and every state is compared with its board, at the board's own
size.** A comparison at any other size scales one side, and then every number
taken off it measures the scaling.

| What the board draws | Compared with |
|---|---|
| A whole window | The app's frame, whole — the scenario run with `tom e2e <name> --board`, which opens the window at the frame's 1440 × 900 |
| A piece of a states board | The app's frame **cropped to the piece's rectangle**, and the widget **rendered alone** at that size in that state — both |

- **A states board records where its piece sits in the window** — `x, y · w × h` — and that rectangle is what both comparisons use ([screens/conventions.md](../../design/screens/conventions.md)).
- **A state needs both comparisons**: the widget alone proves the drawing, in seconds and without the app; the cropped frame proves the app can reach the state and puts the piece where the window does.
- **The render is the judge, not the markup.** The board is rendered from its exported SVG and the two images are put side by side with their difference ([`docs/design/tools/`](../../design/tools/): `render.py`, `compare.py`, `pixels.py`, `bbox.py`).
- Read a shape's pixels at its mid-height, never at its top row — a rounded corner reads narrower than the control is.

---

*See also: [conventions/](README.md) · [inside-a-package.md](inside-a-package.md) · [process/ci.md](../process/ci.md) · [process/end-to-end-coverage.md](../process/end-to-end-coverage.md)*
