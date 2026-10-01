# Decision 26 — The look is a package, the screens are not

**Status:** accepted

## Context

[Decision 14](014-each-layer-is-its-own-package.md) put one layer in one package and gave the rule its edge: the six layer packages are pure Dart, and `apps/desktop` was the only package in the workspace with Flutter. That sentence did two jobs at once. The first is the one worth keeping — a notifier that cannot import a widget cannot reach for one. The second was an accident of there being a single application.

There are two now. `apps/mobile` has existed as a reserved skeleton since Phase 3 was written into [the roadmap](../../roadmap.md), and its pubspec already claimed to share "the state **and the widgets**" with `tom_desktop` — while depending on four pure-Dart packages and no widgets at all, because there were none to depend on. The intention was recorded; the mechanism was not.

What the two applications must not share is layout. The panel shell is a desktop idea: an explorer beside a document beside an aside is not what a phone does with the same job, and the roadmap says as much — each mobile screen is drawn from the task, not ported from the desktop layout. What they must not *diverge* on is identity. The wordmark is geometry transcribed from `tools/brand.py`, the colour roles are `visual-language.md` as a `ThemeExtension`, and the commit trunk behind Home is the mark's own trunk carried past the letterform. Two copies of those is two things to change when one of them changes, and the second copy is always the stale one.

`layers.md` said the opposite, in one line: *"No shared-UI package: panels do not become screens."* That objection is right and survives — it is about **layout**. A phone does not get an explorer beside a document because a desktop has one. It was doing double duty for identity, which is not layout: the same mark, the same sage, the same 8-pixel radius. This decision revises that sentence rather than stepping around it.

The pure Dart rule cannot hold them. A `CustomPainter` is `dart:ui`; a `ThemeExtension` is Flutter. No amount of wanting them shared moves them into `tom_presentation`, and a package named for *who uses it* rather than *what it is* — a `shared` — would take everything either application happened to touch and turn the graph into a suggestion.

## Decision

**`packages/ui` (`tom_ui`) holds the look: colour roles, metrics, the brand marks and the components both applications draw. It depends on no package in the workspace, and every application depends on it.**

```
core ← domain ← application ← presentation
  ↑       ↑                        ↑
  └─── infra ⇄ data ─────────────  desktop · mobile
                                       ↑
                                     ui
```

It is a Flutter package and it is **not** a composition root: it wires nothing, reads no contract, holds no state and knows no screen. It draws what it is handed. That is what the empty dependency set in `src/test/integrity/architecture_test.dart` says, and the test now separates the two ideas that used to be one word — `compositionRoots` is who assembles an application, `framework` is who may know Flutter exists.

Three rules follow, and the architecture test enforces all three:

- **`tom_ui` imports no `dart:io`, no `dart:ffi`, no `dart:isolate`.** A component that opens a file is a component that cannot be drawn on the other platform, which is the reason the package exists.
- **`tom_ui` depends on no workspace package.** The moment a component reaches a use case, the shared look drags a layer graph behind it into whichever application drew it.
- **A screen's widgets stay its screen's.** What two screens both draw moves to `tom_ui`, where the other application can draw it too.

## Consequences

**The move was mechanical, which is the argument for doing it now rather than at Phase 3.** Seven files (`theme/` and `widgets/`) imported nothing but Flutter — no screen, no layer — so nothing had to be untangled, only re-addressed: 38 files in `tom_desktop` swapped their `theme/`/`widgets/` imports for one `package:tom_ui/tom_ui.dart`. Every widget written from here on imports the tokens from wherever they live; the same extraction at M3 is the same change against ten times the surface.

**`tom_desktop` is no longer "the only package that depends on Flutter".** It remains the only one on the desktop side that knows which implementation satisfies which contract, which was always the load-bearing half of that sentence.

**The mobile application now has somewhere to start.** It depends on `tom_ui` and draws the same marks with the same colours on its first screen, without a second transcription of `brand.py`.

**`tom_ui` carries its own tests**, which is where the commit trunk's six went. A widget test that mounts a mark does not need an application around it.

## Alternatives considered

**A package named `shared`.** Rejected: everything in `packages/` is already shared by both applications — six of them by construction. A name that says *who uses it* rather than *what it holds* has no answer to "does this belong here?", and the first use case two applications call would be argued into it.

**Put the shared widgets in `tom_presentation`.** Rejected, and not on taste: the package is pure Dart, and `Widget`, `Canvas` and `ThemeExtension` are not available to it. The layer is defined by responsibility — state a screen reads — not by audience.

**Wait for Phase 3.** The usual argument holds in general: a shared package designed with one consumer guesses wrong. It does not hold here, because nothing is being designed — the files exist, they already import nothing but Flutter, and the second consumer is already in the workspace. What waiting buys is the same move later against every widget M1 and M2 add.

**Share by copying into `apps/mobile` when it is built.** Rejected: the wordmark is brand rule 1 — the commit is never redrawn — and two copies of a transcription is exactly how a mark drifts.
