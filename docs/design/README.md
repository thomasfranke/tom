# Design — wireframes

Low-fidelity screens, one per state the app is actually in. They answer **what is on the screen and where** — nothing about colour, iconography or final wording, all of which are open and none of which should attract feedback while the layout is still moving.

## Desktop

| Screen | State | Milestone |
|---|---|---|
| [empty-state](screens/desktop/empty-state.excalidraw) | No space open: brand, open a folder, recent | M0 (clone by URL: M3) |
| [shell](screens/desktop/shell.excalidraw) | Reading and editing — explorer, source and preview side by side | M0 (search: M2) |
| [committing](screens/desktop/committing.excalidraw) | Stage, describe, commit, push | M1 |

```
docs/design/
├── README.md            ← this file
├── screens/desktop/     ← the wireframes (.excalidraw)
└── tools/               ← kit.py (tokens, components) · build.py (composes the screens)
```

## Mobile

The name `screens/mobile/` is reserved; nothing is written there yet, so the folder does not exist. Mobile is a committed direction for **Phase 3, post-1.0** ([roadmap](../roadmap.md#phases)), and [Decision 8](../decisions/008-monorepo-with-pure-dart-core.md) is explicit that it gets its own presentation — *panels do not become screens*. Drawing it now as narrower versions of the screens above would encode the opposite of that decision in the one artefact people copy from.

Two questions have to close before anything is drawn there, and both are named in the roadmap: git without a system binary, and editing on touch — "an open design question, not just a port". The folder exists so mobile arrives as a sibling rather than as a rename of `desktop/`.

## How to read them

**A coloured chip means "this part arrives later".** The screens show the app as it will look once built, with anything post-M0 marked in place. That is deliberate: a wireframe drawn strictly to the current milestone would need redrawing three times, and the parts nobody has built yet are exactly the ones worth arguing about early.

**Text is placeholder bars.** Real words appear only in labels, buttons and the file tree — the parts whose wording *is* the design.

**The chrome does not move between screens.** The explorer is the same width everywhere it appears. If the screens disagree about that, the wireframes are wrong, not the app.

## How they are made

Generated, not hand-drawn:

```bash
python3 docs/design/tools/build.py
```

`tools/kit.py` holds the tokens (colour, type scale, spacing) and the components; `tools/build.py` composes the screens from them. Nothing sets a padding or a colour by hand, so changing a token moves every screen at once — which is the only way a set of wireframes keeps looking like one product. Full conventions are in the `tom-wireframes` skill.

Refining a screen inside Excalidraw while exploring is fine. When it settles, fold the change back into `_build.py` and regenerate, so what is in the repository is reproducible rather than a snapshot someone once exported.

## What is deliberately not drawn yet

**The rendered diff.** Its block granularity is the output of Spike B ([mvp.md](../mvp.md)) — whether a block can be rendered in isolation is still an open question ([domain model](../architecture/08-domain-model.md)). Drawing it in detail now would be work thrown away the moment the spike reports, so `shell` shows the preview assembled block by block and stops there.

**Conflict resolution, section blame, wikilink navigation.** Post-MVP, and none of them constrain the M0 layout.

## Reviewing a change to these

`.excalidraw` is JSON and unreadable in a diff. Before opening a pull request that changes a screen, export it from Excalidraw as SVG with **Embed scene** enabled, saved alongside as `<screen>.excalidraw.svg` — GitHub renders it inline and Excalidraw reopens it fully editable, so one file serves both the reviewer and the next person to edit it.
