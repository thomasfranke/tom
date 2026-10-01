---
name: tom-feature-flow
description: The order a feature is built and proved in TOM — design first, then the layers inward-out, then the four proofs in sequence (architecture, unit, integration, end-to-end with recorded evidence), and what "done" means before a commit is offered. Use this skill when picking up a roadmap task, when starting any feature or fix that will touch more than one file, when asking what still has to be proved before something is finished, and when the user says "next task", "let's build X", "is this done", or asks for the video of a run.
---

# TOM — the flow a feature goes through

**A feature is not finished when it works. It is finished when the four proofs
run in order and the last one leaves a video.** Each stage answers a question
the one before it cannot, which is why they are a sequence and not a checklist.

## Before any code: the task and the board

1. **The task comes from [`docs/roadmap.md`](../../../docs/roadmap.md) or from the maintainer**, in that order. There is no queue and no spec folder.
2. **Read the feature's `doc.md` under [`docs/product/`](../../../docs/product/README.md)** — it is what the implementation is checked against, and the code diverging from it is a bug in one of the two.
3. **Check the board exists.** Rule 13: no interface is written before it is designed. If the screen has no board in `docs/design/screens/desktop/<page>/`, the feature is blocked on the `tom-design` skill, not on you.
4. **Chain tasks without asking.** Finishing one and starting the next is the expected behaviour; what always needs asking is a commit, a push, and a doc merge.

## The code: outward from the middle

Build in dependency order, so that every step compiles against something that
already exists and the layer graph is never briefly wrong:

```
domain ─▶ application ─▶ infra / data ─▶ presentation ─▶ desktop
 entities,   use cases,    contracts,      notifiers,      widgets
 failures                  adapters, DTOs  session
```

- **A failure is a case in the sealed hierarchy before it is a message on screen.** Adding the screen first is what produces a `String` error nobody can switch on.
- **A capability that talks to the outside gets its contract in `tom_infra` first**, then the implementation in a subfolder named after the dependency ([Decision 24](../../../docs/technical/decisions/024-a-capability-is-a-folder.md)).
- **Nothing is wired into the shell directly** — a panel arrives through `TomModule`/`PanelDescriptor`, including the built-in ones (Decision 12).

## The four proofs, in order

Each one is cheap to run and expensive to skip. Run them in this order because
a failure early is a failure that costs seconds instead of a whole e2e run.

### 1 · Architecture — does it still obey the graph?

```
dart run tool/tom.dart test arch
```

Reads every `pubspec.yaml` and asserts the dependency graph, including that
exactly one package knows Flutter exists. **Run it first**, because a layer
violation makes every test below it meaningless — they would be proving
behaviour in a shape the project rejects.

### 2 · Unit — does each piece decide correctly?

```
dart run tool/tom.dart test unit
```

Pure logic, fakes over real dependencies: failures, parsers, domain services,
use cases, notifiers. A notifier's test uses a `ProviderContainer` with
overridden use cases. **A bug fix without a test that fails without the fix is
an unfinished fix.**

### 3 · Integration — does it survive the real thing?

```
dart run tool/tom.dart test integration
```

A real `git init` repository in a temp dir, real disk, real sqlite. **This is
the project's confidence differentiator, and mocking it away is a finding even
when the mocked test passes.** Anything that shells out to git belongs here,
because git's porcelain is the contract and only git produces it.

### 4 · End-to-end — can a person actually do it, and can we watch?

```
dart run tool/tom.dart e2e
```

Drives the real app against fixtures it builds. **Every user-facing feature
ships with a scenario in the same PR**, because a widget test's container
answers before the first frame: a surface that loads when it opens looks
instant there and empty in the real app.

The shape of a scenario, the robot, and the traps that make one hang are the
[`tom-testing`](../tom-testing/SKILL.md) skill — load it before writing one.

## The evidence, which is the point of stage 4

A run writes **one PNG per step** and ffmpeg joins them into
`<stamp>-<outcome>.mp4`, two frames a second, under the run's evidence folder.
The frames are the evidence; the video is the convenience, and a machine
without ffmpeg still gets the frames.

- **Hand the maintainer the video, not a summary of it.** "The scenario passed" is a claim; the file is the proof, and watching it is how a wrong-but-green scenario gets caught.
- **A timed-out step takes no frame**, because `timeout` cannot cancel a body — a gap in the film is where the run stopped, not a dropped frame.
- **Two runs must never overlap.** Scenarios write, fixtures are rebuilt per scenario, and the previous log is deleted first.
- `0/0 steps` is a build failure, not a scenario failure. Read the log above it.

## Then, and only then

```
dart run tool/tom.dart verify
```

Everything CI runs, stopping at the first failure. One trap worth the line:
**`verify`'s codegen gate asks git, not the generator** — a new `.freezed.dart`
or `.g.dart` that is merely uncommitted reads as "out of date" and stops the
run before a single test goes green. While the work is untracked, run the
suites directly and leave `verify` for after the files are staged.

## What "done" means

Before offering a commit, all five are true:

| | |
|---|---|
| The product doc matches what was built | Or the doc was corrected in the same change, and it says so |
| The board matches what shipped | Both themes re-exported if the interface moved (rule 13) |
| The four proofs are green | Named individually, with the numbers — not "tests pass" |
| The e2e video exists and was offered | Or the reason there is no scenario is stated |
| `AGENTS.md`'s *Current status* carries what the next session needs | Traps especially: every one there cost somebody a session |

**Report failures as failures.** A suite that did not run is not a suite that
passed, and a step proven only by widget tests is worth saying out loud —
`docs/design` and `AGENTS.md` both already carry entries of exactly that shape.

---

*See also: [`tom-testing`](../tom-testing/SKILL.md) · [`tom-design`](../tom-design/SKILL.md) · [`tom-git-workflow`](../tom-git-workflow/SKILL.md) · [`conventions/testing.md`](../../../docs/technical/conventions/testing.md) · [`process/commands.md`](../../../docs/technical/process/commands.md)*
