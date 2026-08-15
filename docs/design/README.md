# Design — wireframes

Low-fidelity screens, one per state the app is actually in. They answer **what is on the screen and where** — nothing about colour, iconography or final wording, all of which are open and none of which should attract feedback while the layout is still moving.

## Desktop

| Screen | State | Milestone |
|---|---|---|
| [empty-state](screens/desktop/empty-state.excalidraw) | No space open: brand, open a folder, recent | M0 (clone by URL: M3) |
| [shell](screens/desktop/shell.excalidraw) | Reading and editing — explorer, source and preview side by side | M0 (search: M2) |
| [reading](screens/desktop/reading.excalidraw) | Preview only — the default for whoever does not edit | M0 |
| [unsaved-changes](screens/desktop/unsaved-changes.excalidraw) | The gap between the buffer and the file on disk | M0 |
| [not-a-repository](screens/desktop/not-a-repository.excalidraw) | The one way opening a folder fails | M0 |
| [committing](screens/desktop/committing.excalidraw) | Stage, describe, commit, push | M1 |
| [branch-switcher](screens/desktop/branch-switcher.excalidraw) | Switch branches, or start one | M1 |
| [file-history](screens/desktop/file-history.excalidraw) | The commits that touched this document | M1 |
| [push-rejected](screens/desktop/push-rejected.excalidraw) | The remote moved first | M1 |

```
docs/design/
├── README.md              ← this file
├── visual-language.md     ← the colour system, light and dark
├── palette.svg            ← generated swatches
├── screens/desktop/       ← the desktop wireframes (.excalidraw)
├── screens/mobile/        ← exploratory, Phase 3
└── tools/                 ← kit.py · build.py · build_mobile.py · palette.py
```

Colour is decided in [visual-language.md](visual-language.md), not here: the wireframes carry four values and no product palette, on purpose.

## Mobile

**Exploratory.** These exist to picture where the product is going, not to specify it — nothing here is committed and everything is subject to the two open questions below.

| Screen | State |
|---|---|
| [documents](screens/mobile/documents.excalidraw) | The space as a list — on a phone the tree *is* the first screen |
| [reading](screens/mobile/reading.excalidraw) | The primary job: a rendered document, full bleed |
| [review](screens/mobile/review.excalidraw) | What changed, rendered, with approve as the one action |
| [capture](screens/mobile/capture.excalidraw) | Record a decision and commit it — not an editor |

They are drawn from the **job**, not from the desktop layout: navigation is a stack, there is no split view, and git is one action on the screen it belongs to rather than a permanent panel. That follows [Decision 8](../decisions/008-monorepo-with-pure-dart-core.md), which gives mobile its own presentation and says plainly that *panels do not become screens*. The job itself comes from [product.md](../product.md) — read, review and approve, and capture a small edit. Authoring a document on a phone is not a goal.

Mobile ships in **Phase 3, post-1.0** ([roadmap](../roadmap.md#phases)), and two questions have to close first — git without a system binary, and editing on touch, "an open design question, not just a port". Both are marked on the screens where they bite, which is why `capture` stops at recording a decision rather than showing an editor.

These were drawn early, out of order, to make the destination visible. Treat them as a sketch of intent: nothing in the desktop MVP depends on them, and they will be redrawn once those two questions have answers.

## How to read them

**A coloured chip means "this part arrives later".** The screens show the app as it will look once built, with anything post-M0 marked in place. That is deliberate: a wireframe drawn strictly to the current milestone would need redrawing three times, and the parts nobody has built yet are exactly the ones worth arguing about early.

**Text is placeholder bars.** Real words appear only in labels, buttons and the file tree — the parts whose wording *is* the design.

**The chrome does not move between screens.** The explorer is the same width everywhere it appears. If the screens disagree about that, the wireframes are wrong, not the app.

## How they are made

Generated, not hand-drawn:

```bash
python3 docs/design/tools/build.py         # desktop
python3 docs/design/tools/build_mobile.py  # mobile
python3 docs/design/tools/palette.py       # palette.svg + contrast check
```

`tools/kit.py` holds the tokens (colour, type scale, spacing) and the components; `tools/build.py` composes the screens from them. Nothing sets a padding or a colour by hand, so changing a token moves every screen at once — which is the only way a set of wireframes keeps looking like one product. Full conventions are in the `tom-wireframes` skill.

Refining a screen inside Excalidraw while exploring is fine. When it settles, fold the change back into the build script and regenerate, so what is in the repository is reproducible rather than a snapshot someone once exported.

## What is deliberately not drawn yet

**The rendered diff.** Its block granularity is the output of Spike B ([mvp.md](../mvp.md)) — whether a block can be rendered in isolation is still an open question ([domain model](../architecture/08-domain-model.md)). Drawing it in detail now would be work thrown away the moment the spike reports, so `shell` shows the preview assembled block by block and stops there.

**Conflict resolution, section blame, wikilink navigation.** Post-MVP, and none of them constrain the M0 layout.

## Reviewing a change to these

`.excalidraw` is JSON and unreadable in a diff. Before opening a pull request that changes a screen, export it from Excalidraw as SVG with **Embed scene** enabled, saved alongside as `<screen>.excalidraw.svg` — GitHub renders it inline and Excalidraw reopens it fully editable, so one file serves both the reviewer and the next person to edit it.
