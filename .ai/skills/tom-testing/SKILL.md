---
name: tom-testing
description: How TOM is tested, and the end-to-end suite in particular — the rule that every user-facing feature ships with a scenario, where a test lives by its kind, the robot that holds every reusable action, steps declared as data so the CLI can report them, and the frames and video every run leaves behind, and the traps of the test side: end-to-end, widget tests and integration. Use this skill when adding or changing a test of any kind, when finishing a feature and asking what proves it, when writing or debugging an e2e scenario, when a scenario hangs, times out or reports `0/0 steps`, when a widget test ends with a timer pending or cannot find the editor, and when the user says "write a test", "add an e2e", "does this need a test", or asks why the suite is flaky.
---

# TOM — testing

**Integration against real git is the project's confidence differentiator.** A
diff that mocks it away is a finding even when the mocked test passes, and a bug
fix without a test that fails without the fix is an unfinished fix.

Where a test lives by its kind — `unit/`, `integration/`, `integrity/` — and
what each subject gets is
[`conventions/testing.md`](../../../docs/technical/conventions/testing.md).
This skill is the end-to-end suite, which that file names and does not
detail, and the traps of every kind of test.

## The rule

**Every user-facing feature ships with an end-to-end scenario, in the same PR.**
A feature nobody can drive is a feature nobody proved: widget tests answer
before the first frame, so a surface that loads when it opens looks instant
there and empty in the real app.

A feature with no scenario needs a stated reason, the same way "no tests" does.

### What "every" means

The maintainer's bar (2026-10-09), and it is not a figure of speech:

| | Needs |
|---|---|
| **Every control** — button, menu row, tab, toggle, chip, pill in a band, dialog action, shortcut, drag, right-click entry | a step that presses it **and asserts what it did** — and, where it has one, a step for its unavailable state |
| **Every behaviour** a product doc states as a rule | a step that would fail if the rule broke |
| **Every edge case** — each refusal, empty state, error band, "nothing to do" | a step that provokes it for real |
| **Every one of the above** | **evidence**: the frame after the step shows it. A rule asserted in state and invisible in the frame is half proven |

- **Under each of them, an integration test — and that layer matters more.** A scenario proves the window; an integration test proves the thing the window trusts, against the real dependency: the real `git` on a real repository, the real filesystem, the real index, the real parser, `gh` as a script on `PATH`. Every method of a capability's contract, every failure it can classify — *provoked from the real tool, not constructed* — and every repository above it.
- **A widget test is not a substitute for either.** It is the right home only for a state no scenario can hold still (a commit in flight, a frame of an animation), and that list is kept short and argued, never a default.
- **A fixture is part of the proof.** One whose changes all sat inside the space passed while the real app could not open a single row: a git feature is tested with a space below the repository root *and* a change beside it.
- **A state drawn as a piece is measured as a piece.** A page now draws its first screen whole and then one component in every state ([`tom-design`](../tom-design/SKILL.md)), and the board records where the piece sits in the window — `x, y · w × h`. Two comparisons use that rectangle, and a state needs both: the **render test** pumps the widget alone at that size in that state and compares it with the piece (seconds, no app); the **scenario** reaches the state in the real app at the board's size and compares the frame *cropped to the rectangle* (`compare.py` crops any rectangle). The first proves the drawing, the second that the app can get there and puts the piece where the window does.
- **Survey before writing in bulk.** Closing a coverage gap starts with the audit — rule by rule, control by control, proven / partial / missing — and a roadmap the maintainer approves. Scenarios written before that are scenarios written twice.
- **Writing is not running.** A scenario is run alone, when the maintainer says so; `tom e2e all` and the Penpot export are the end of the work, never part of it.

## Where it lives

```
src/apps/desktop/integration_test/
├── e2e/                          ← the scenarios, mirroring the CLI's menus
│   └── <group>/[<submenu>/]
│       ├── <doing_a_thing>_test.dart       ← a flow, named for the job
│       └── <menu>_planned.dart             ← the plans of that menu, no body
├── fixtures/<name>/              ← content + fixture.json, built per scenario
└── support/
    ├── harness.dart              ← the one import a scenario needs
    ├── scenario.dart             ← scenario() and Step
    ├── robot.dart                ← every reusable action and assertion
    ├── evidence.dart             ← the frames
    ├── fixture.dart              ← building a fixture's repository
    └── e2e_module_impl.dart      ← the panels, wired for a run
```

**The folders are the menus of `tom e2e`**, in the menu's own words in snake case:
`group: 'Git', submenu: 'Remote'` lives in `e2e/git/remote/`, and `group: 'Workspace',
submenu: 'Leaving a space'` in `e2e/workspace/leaving_a_space/`. A group lists
submenus or scenarios, never both; **no menu holds more than 25 entries** (a group
that grows past it is split into submenus by subject), and every menu — groups,
submenus, scenarios, written ones first and plans after — is alphabetical.
A file may hold several scenarios, all of one menu; a plan (`plannedScenario`) sits
in its menu's `<menu>_planned.dart` and moves to a `_test.dart` beside it the day it
is written. `fixtures/` and `support/` stay beside `e2e/` because not everything
under `integration_test/` is a scenario. `src/test/cli/e2e_menus_test.dart` fails on a
file outside the folder of its menu, a menu over 25 or out of order.

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
- **A finder is scoped to the surface it means.** `Pull` is a button in the
  column *and* a pill in a band; "the `FilledButton` in the panel" stopped being
  one button the day the column got a second. Scope to `NoticeBandWidget`, to the
  column, to the dialog.
- **A band's whole notice is one `Text`**, and the sentence continues past any
  quote of it — assert fragments, never the whole sentence with `find.text`.
- **The open document is the tree's open row** — or the session's, while a
  search has the column. A folded group of the toolbar is reached through `⋯`.
- **`ensureVisible` before a tap on anything that scrolls** — a toolbar button
  off the end of its row, a history row a lazy list never built. `tester.tap` on
  one of those hits the document, and the step fails on a silent no-op rather
  than a missed finder.
- **A panel is asked for before it is used.** A scenario that relied on two
  panels being stacked broke the day the column got a switch.
- **The robot pins the platform locale to `en_US`** — `System` would follow the
  developer's machine, and every finder is English.

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
  flat listing of every scenario is not a listing anybody reads.
- ffmpeg is a convenience this repository does not ask anybody to install; the
  frames are the evidence.

## Running it

```bash
dart run tool/tom.dart e2e                                # the menu: groups, scenarios, last outcome
dart run tool/tom.dart e2e list                           # the scenarios there are
dart run tool/tom.dart e2e "Finds a document by its contents"          # one, by its name
dart run tool/tom.dart e2e "Finds a document by its contents" --board  # at the boards' 1440×900
dart run tool/tom.dart e2e all                            # the whole suite — only when the maintainer asks
```

- **A scenario is named by the words of its title**, exactly. Anything else —
  a kebab-case guess, a file name — exits 64 and prints the names there are.
- **`--board` is the pixel review's run**: the window the boards are drawn at,
  so a frame and a board crop to the same rectangle
  ([`tom-design`](../tom-design/SKILL.md), *Measuring the app against a board*).
- **While building, only the feature's own scenario runs.** `tom e2e all` is
  slow and locks the machine, so it runs once, at the end of the work, when the
  maintainer says so.
- **A scenario nobody runs is green by memory** — two sat broken for days after
  a design change because the suite was only ever run one name at a time. That
  is what the whole run at the end is for, and why it is not optional then.
- **Two runs must never overlap.** Scenarios write, so fixtures are rebuilt per
  scenario and the previous log is deleted first.
- **`0/0 steps` means the scenario did not run — never that it passed.** Either
  the build failed and the app never started, or the run hung and its process
  was killed. `tom e2e` reports it as `✘ … did not run` and counts it as a
  failure; a record written before it learnt to still reads as did-not-run.
  Read the log above it, and run it again.

## Traps, every one of which cost a session

The code's own traps are in [`AGENTS.md`](../../../AGENTS.md) and Penpot's in
[`tom-design`](../tom-design/SKILL.md); these are the ones a test meets.

### End to end

- **`timeout` cannot cancel a body.** A timed-out step is still running inside the binding, so no frame is captured after one — a capture there reports a second error over the timeout.
- **A caret blinks forever.** Once a text field has had the keyboard, every `pumpAndSettle` waits on an animation that never ends; drive with pumps instead of settling.
- **The live binding's pointer crosshair** keeps `pumpAndSettle` from settling, and macOS sometimes fails to foreground the window (`open returned 1`). Both are environmental and neither is the app — a red run on a machine that was green is more likely the machine.
- **Home's trunk animation never stops**, which is why the harness disables animations.
- A scenario gets **its own preferences file, wiped first** — it must not inherit the last one's, nor write where a person's own copy of the app reads.
- **Keys the editor owns are proven here and nowhere else.** `re_editor` installs no shortcuts on a widget test's platform, so save (`CodeShortcutSaveIntent`) and ⌘Z are a scenario's.
- **Anything outside the app is a script or a seam, never a fake of our own contract.** `gh` is a shell script on the scenario's `PATH` (`E2eModuleImpl(withGh: true)`, answering from `machine/github/`, wiped per scenario), so the real `GhCliGithubApiImpl` runs offline and proves the environment, the body on stdin and the working folder; the save dialog is `SaveLocationPicker`, replaced to write beside the scenario's preferences.
- **A fixture's remote can lie on purpose**: `docs-proposing` sets `remote.origin.pushurl` to the bare repository and `url` to a GitHub address, because `git remote get-url` expands `insteadOf`.
- **A fixture's remote can refuse on purpose**: `"protected": true` in `fixture.json` installs a `pre-receive` hook on the bare remote that prints GitHub's `GH006` line (`docs-protected-branch`); a fixture commit may carry `"rename": {from: to}` (`git mv`), which is how `docs-with-history` gets a history that crosses a rename.
- **A surface that loads when it opens says something meanwhile.** A widget test never sees that sentence; a scenario is what catches it.

### Widget tests

- **A `ProviderContainer` answers before the first frame**, so a surface that loads when it opens looks instant here and empty in the real app.
- **Mounting the shell, the tree, the top bar or Home creates notifiers that read git or the machine.** Override each with one that builds an empty state: `diffBaseProvider` (`_NoBase`), `pullRequestProvider` (`_NoPullRequest`), `accountProvider` (`_NoAccount`).
- **Mounting the editor creates the preview** — the source pane's marks watch it — so override the preview's three use cases and pump past `PreviewNotifier.settle`, or the tree is disposed with a timer pending.
- **A provider that fails is retried on a timer.** One the test never wired ends the test with a timer pending, unless the provider turns its retry off.
- **Two `ProviderContainer`s in one widget test leave a disposal timer pending.**
- **`re_editor` starts a blink timer it never cancels** — pump past it.
- **`re_editor` installs no `Actions` at all on the test platform**, so undo through it lands on nothing and a test of the button passes vacuously or fails silently. `kIsAndroid` is a lazy final decided once per isolate: pin `TargetPlatformVariant.only(TargetPlatform.macOS)` on the test that **first** builds a `CodeEditor` in the file.
- **In preview the source pane is mounted and offstage.** `find.byType(CodeEditor)` finds nothing; `skipOffstage: false` finds the one kept.
- **`MaterialApp` animates a theme change** — settle before comparing light with dark.
- **Mount a control where the app puts it.** A popover that hangs from the right edge of a bar lands off the window in a bare test, and the tap misses.
- **`tester.drag` compensates for the wrong drag behaviour and takes no parameter for it** — a handle with `DragStartBehavior.down` is driven with `startGesture` and `moveBy` by hand.
- **A test does not import another screen's `widgets/` either** — one that mounts the bottom region must not import `shell_region_widget.dart`.
- **`context.l10n` falls back to English with no delegate in scope**, so a widget test needs none.
- **A temporary render test is deleted before the work is handed over** (`zz_*_render_test.dart`); the analyser finds one left behind.

### Integration

- **Git decides hunk boundaries.** Two nearby edits come back as one conflict region; a test that wants two needs the edits far apart.
- **A failure is provoked from the real tool, never constructed** — the classification is the thing under test.
- **A git feature is tested with a space below the repository root and a change beside it** — *What "every" means*, above.

## What is proven elsewhere, and say so

When a step cannot run here, the scenario says which test carries it instead
rather than pretending — and each entry is a debt with a reason, not a category
(see *What "every" means*). Today: re-filing a saved document is
`search_notifier_test`'s.

---

*See also: [`conventions/testing.md`](../../../docs/technical/conventions/testing.md) · [`process/ci.md`](../../../docs/technical/process/ci.md) · [`tom-code-review`](../tom-code-review/SKILL.md)*
