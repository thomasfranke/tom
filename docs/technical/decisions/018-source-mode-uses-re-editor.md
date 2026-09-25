# Decision 18 — Source mode is built on `re_editor`

**Status:** accepted — this is the verdict of **Spike A** ([roadmap](../../roadmap.md))

## Decision

`re_editor` (MIT, `^0.10.0`) carries source mode. The fallback named in [stack/editor.md](../stack/editor.md) — a plain `TextField` — is withdrawn: it cannot do the job.

## Rationale

The spike measured both arms on the same machine, in the same build mode, with the same generated document (2853 lines, 131KB, mixed headings / fenced code / tables / long unbroken lines). Typing was driven at 60 characters per second, which is faster than a person types.

| | `re_editor` | `TextField` (the fallback) |
|---|---|---|
| Frames while typing | 176 | 53 |
| Build p50 | **4.4ms** | **38.8ms** |
| Build p95 | 9.9ms | 40.4ms |
| Frames over a 16.7ms budget | **1 (0.6%)** | **51 (96.2%)** |

The fallback is not slow, it is unusable: a `TextField` lays out the whole document as one paragraph, so every keystroke re-lays out 131KB. `re_editor` lays out per line and paints only the viewport, and pays for that once at load (`controller.text` ≈ 20ms against the fallback's 1.2ms) — a trade in exactly the right direction for a document that is opened once and edited for an hour.

The other roadmap criteria:

- **Desktop shortcuts** — 50 named shortcut types, with separate macOS and Windows/Linux bindings, covering word-boundary movement and selection, line move, indent/outdent, undo/redo, page start/end, find, replace and save. `shortcutsActivatorsBuilder` rebinds them and `shortcutOverrideActions` replaces their behaviour, so TOM's own shortcut language is not fighting the package's.
- **Find and replace** — driven through `CodeFindController`, not by hand: 89 matches found in the fixture, replace-all left zero occurrences.
- **Selection** — the API is complete (`selectLine`, `extendSelectionToWordBoundaryForward`, and the rest); what a drag *feels* like is the one thing that stays a human check.

## How far it goes past what was asked

The roadmap asked for 2000+ lines. At **29,637 lines and 1.37MB** — ten times over — typing holds at 6.6ms p50 and 2.5% of frames miss the budget, and the whole file still scrolls at 2.8ms p50. It degrades, and it degrades gently. Two hitches are worth remembering rather than fixing now: a worst-case 45.8ms frame while typing and a 380.7ms one while scrolling that file, both isolated.

## What it does not give us

`re_editor` is an editing engine, not an editor UI. Three pieces are ours to write and own:

1. **Find and replace panel** — `findBuilder` hands over a controller and expects a widget. The package's own example carries ~250 lines of UI to fill that gap.
2. **Selection toolbar / context menu** — same shape, via `toolbarController`.
3. **Line-number gutter** — the one that *is* provided, as `DefaultCodeLineNumber`.

That is the right split for this product: the chrome has to be in TOM's visual language anyway ([design](../design/)), and a package that shipped its own would be something to fight.

## Maintenance

Four releases in the twelve months to July 2026 (0.7.0 → 0.10.0), and 0.9.0 is literally *"Fix the compile error in Flutter 3.44.0"* — published weeks after that Flutter release. The package tracks the framework.

The spike started on `^0.7.0` and it did not compile: `TextInputClient` had gained `onFocusReceived`. That is the risk in one sentence — a Flutter release can break it — and the same sentence is the mitigation: it was already fixed upstream before we looked. Pin an exact minor, and treat a Flutter upgrade as a reason to check this package first.

The harness that measured this was removed with the spike, and `re_editor` left the app's pubspec with it: nothing imports a package until the code that needs it exists. Both come back when M0 builds source mode, which is also what will re-run the check above — until then a Flutter upgrade has nothing here to break.

## Why the numbers are from a debug build

`flutter run --profile` and `flutter build --release` for macOS are **both blocked on this machine**, and not by anything in this repository: `flutter_tools` 3.44.5 verifies the engine framework with `lipo <file> -verify_arch arm64 x86_64`, and the `lipo` shipped with Xcode 27 answers *"-verify_arch requires exactly one input file"*. A correct universal binary is rejected.

Debug is the slower mode, so every number above is a floor — release is faster, and the comparison between the two arms is fair because both ran in the same mode. But this blocks release packaging (M3) and it is tracked as an open question in the [roadmap](../../roadmap.md#open-questions).

## Revisit when

A Flutter upgrade breaks the package and upstream does not follow within a release cycle; or source mode needs something the engine cannot express (block-level decorations for the rendered diff are the likely candidate, and are M2's problem, not M0's).
