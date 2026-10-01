---
name: tom-testing
description: How TOM is tested, and the end-to-end suite in particular — the rule that every user-facing feature ships with a scenario, where a test lives by its kind, the robot that holds every reusable action, steps declared as data so the CLI can report them, and the frames and video every run leaves behind. Use this skill when adding or changing a test, when finishing a feature and asking what proves it, when writing or debugging an e2e scenario, when a scenario hangs or times out, and when the user says "write a test", "add an e2e", "does this need a test", or asks why the suite is flaky.
---

# TOM — testing

**Integration against real git is the project's confidence differentiator.** A
diff that mocks it away is a finding even when the mocked test passes, and a bug
fix without a test that fails without the fix is an unfinished fix.

Where a test lives by its kind — `unit/`, `integration/`, `integrity/` — and
what each subject gets is
[`conventions/testing.md`](../../../docs/technical/conventions/testing.md).
This skill is the end-to-end suite, which that file does not cover.

## The rule

**Every user-facing feature ships with an end-to-end scenario, in the same PR.**
A feature nobody can drive is a feature nobody proved: widget tests answer
before the first frame, so a surface that loads when it opens looks instant
there and empty in the real app.

A feature with no scenario needs a stated reason, the same way "no tests" does.

## Where it lives

```
src/apps/desktop/integration_test/
├── <doing_a_thing>_test.dart     ← one file, one flow, named for the job
├── fixtures/<name>/              ← content + fixture.json, built per scenario
└── support/
    ├── harness.dart              ← the one import a scenario needs
    ├── scenario.dart             ← scenario() and Step
    ├── robot.dart                ← every reusable action and assertion
    ├── evidence.dart             ← the frames
    ├── fixture.dart              ← building a fixture's repository
    └── e2e_module_impl.dart      ← the panels, wired for a run
```

Scenarios live **inside the desktop app** because a run happens in the app's own
native runner with its entitlements and its Podfile, and a second runner would
drift.

## A scenario is data

```dart
scenario(
  'Finds a document by its contents',
  group: 'Search',
  describe: 'What search is for, and the one thing a file tree cannot do…',
  steps: <Step>[
    Step('open the docs folder inside a repository', (TomRobot robot) async {
      await robot.launchWindowed(pickFolder: docsInRepo.root);
      await robot.chooseFolder();
      await robot.seesTheShell();
    }),
  ],
);
```

- **The flow is data and the *how* is the robot's.** A scenario lists what
  happens; the next scenario reuses how.
- **Every step is known before the first one runs**, which is what a `12/71`
  progress bar needs. The CLI reads them over a line protocol marked
  `⦙tom-e2e⦙`.
- **A step name is written for a dashboard**, not for a stack trace: *"choose
  the docs folder"*, never `tapChooseFolder`. It is what the progress screen
  shows and what names a failure.
- **`describe` says what the scenario is *for***, under the name on screen — the
  reason the flow is worth driving, not a restatement of the steps.
- **`group` must exist in `scenarioGroups`** (`tool/src/commands/e2e_catalogue.dart`).
  A group that list does not carry is shown last rather than hidden, so a typo is
  visible — and a real group missing from the list sorts wrong forever.

## Everything reusable is the robot's

`support/robot.dart` holds every action and every assertion. **A scenario never
calls `tester` directly**: a finder written inline is a finder the next scenario
rewrites slightly differently, and the two disagree about what the app looks
like.

Two shapes, and the names carry which:

| Shape | Example | Answers |
|---|---|---|
| A verb | `clickInTheTree`, `stages`, `commits`, `typesInTheSearch` | does something |
| `sees…` | `seesTheShell`, `seesInTheResults`, `seesNoResults` | asserts something |

- A new action goes in the robot **first**, then the scenario uses it.
- `seesNothingBroken()` ends a scenario: nothing threw and no error surface is up.
- Prefer an assertion that names what the reader would see (`seesTheOpenDocument`)
  over one that names a widget.

## What a run leaves behind

| | |
|---|---|
| Frames | `.e2e-evidence/<group>/<scenario>/<stamp>-shot-<nnn>-<step>.png` — **always** |
| Video | `<stamp>-<outcome>.mp4`, joined from those frames at 2fps — **when ffmpeg is installed** |

- A frame is taken **between steps, never inside one**: reading a frame asks for
  a rasterised one, and inside a pump-and-settle the settling never settles.
- Frames are read off the **composited layer**, not the screen, so a frame holds
  the app whatever is in front of the window.
- **Evidence never fails a scenario.** A frame that cannot be read is simply not
  there.
- Runs accumulate under a stamp, so the evidence of a failure survives the run
  meant to reproduce it.
- The folders mirror the suite's headings — `search/`, `git-local/` — because a
  flat listing of twenty-three scenarios is not a listing anybody reads.
- ffmpeg is a convenience this repository does not ask anybody to install; the
  frames are the evidence.

## Running it

```bash
dart run tool/tom.dart e2e            # the menu: groups, scenarios, last outcome
```

- **Two runs must never overlap.** Scenarios write, so fixtures are rebuilt per
  scenario and the previous log is deleted first.
- `0/0 steps` is a build failure, not a scenario failure — the app never started.

## Traps, every one of which cost a session

- **`timeout` cannot cancel a body.** A timed-out step is still running inside the binding, so no frame is captured after one — a capture there reports a second error over the timeout.
- **A caret blinks forever.** Once a text field has had the keyboard, every `pumpAndSettle` waits on an animation that never ends; drive with pumps instead of settling.
- **`re_editor` installs no keyboard shortcuts on the test platform.** Save is bound through `CodeShortcutSaveIntent` and is proven on a real runner, not here.
- **The live binding's pointer crosshair** keeps `pumpAndSettle` from settling, and macOS sometimes fails to foreground the window (`open returned 1`). Both are environmental and neither is the app.
- **Home's trunk animation never stops**, which is why the harness disables animations.
- A scenario gets **its own preferences file, wiped first** — it must not inherit the last one's, nor write where a person's own copy of the app reads.

## What is proven elsewhere, and say so

When a step cannot run here, the scenario says which test carries it instead
rather than pretending. Today: the diff scenario's deleted-code-block step is
proven by widget tests, and re-filing a saved document is
`search_notifier_test`'s.

---

*See also: [`conventions/testing.md`](../../../docs/technical/conventions/testing.md) · [`process/ci.md`](../../../docs/technical/process/ci.md) · [`tom-code-review`](../tom-code-review/SKILL.md)*
