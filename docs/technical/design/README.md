# Design — wireframes

Low-fidelity screens, one per state the app is actually in. They answer **what is on the screen and where** — nothing about colour, iconography or final wording, all of which are open and none of which should attract feedback while the layout is still moving.

## Where screens live

Every screen — desktop or mobile — lives next to the product it belongs to, in `docs/product/<group>/<feature>/mocks/`. There is no separate screens folder for wireframes; this folder holds only what is shared across every screen: the drawing tokens and the build tools. Desktop and mobile mocks share the same `mocks/` folder when they're the same capability; the mobile file is suffixed `-mobile` to tell them apart (`reading.excalidraw` vs `reading-mobile.excalidraw`).

| Screen | State | Platform | Lives in | Milestone |
|---|---|---|---|---|
| shell | The panel layout: explorer, source and preview side by side | Desktop | [products/workspace/mocks/](../../product/workspace/mocks/) | M0 (search: M2) |
| empty-state, not-a-repository | No space open · the one way opening a folder fails | Desktop | [products/home/mocks/](../../product/home/mocks/) | M0 |
| reading-desktop | Preview only — the default for whoever does not edit | Desktop | [products/editor/markdown-preview/mocks/](../../product/editor/markdown-preview/mocks/) | M0 |
| reading-mobile | The primary job on a phone: a rendered document, full bleed | Mobile | [products/editor/markdown-preview/mocks/](../../product/editor/markdown-preview/mocks/) | Phase 3 |
| unsaved-changes | The gap between the buffer and the file on disk | Desktop | [products/editor/source-mode/mocks/](../../product/editor/source-mode/mocks/) | M0 |
| committing-desktop | Stage, describe, commit, push | Desktop | [products/git-workflow/commit/mocks/](../../product/git-workflow/commit/mocks/) | M1 |
| capture-mobile | Record a decision and commit it — not an editor | Mobile | [products/git-workflow/commit/mocks/](../../product/git-workflow/commit/mocks/) | Phase 3 |
| branch-switcher | Switch branches, or start one | Desktop | [products/git-workflow/branch-switch/mocks/](../../product/git-workflow/branch-switch/mocks/) | M1 |
| file-history | The commits that touched this document | Desktop | [products/git-workflow/file-history/mocks/](../../product/git-workflow/file-history/mocks/) | M1 |
| push-rejected | The remote moved first | Desktop | [products/git-workflow/push-pull/mocks/](../../product/git-workflow/push-pull/mocks/) | M1 |
| documents-mobile | The space as a list — on a phone the tree *is* the first screen | Mobile | [products/navigation/file-tree/mocks/](../../product/navigation/file-tree/mocks/) | Phase 3 |
| review-mobile | What changed, rendered, with approve as the one action | Mobile | [products/diff/rendered-diff/mocks/](../../product/diff/rendered-diff/mocks/) | Phase 3 |

A feature-scoped mock does not need to redraw the whole window — chrome, explorer, status bar (desktop) or nav bar, action bar (mobile). `shell` does, because the panel layout *is* what it's showing; most others only need to show enough of the feature to be reviewable, cropped to what matters.

```
docs/technical/design/
├── README.md              ← this file
├── visual-language.md     ← the colour system, light and dark
├── palette.svg            ← generated swatches
└── tools/
    ├── kit.py             ← wireframe tokens and components
    ├── build.py           ← wireframes, desktop
    ├── build_mobile.py    ← wireframes, mobile
    ├── palette.py         ← the palette; palette.svg + the WCAG check
    ├── penpot_kit.js      ← visual-design components
    ├── penpot_screens.js  ← visual-design screens
    ├── penpot_build.py    ← emits generated/penpot_bundle.js
    └── generated/         ← the bundle; regenerated, never edited

docs/product/<group>/<feature>/mocks/  ← every screen, desktop and mobile, next to that feature's doc.md
```

Colour is decided in [visual-language.md](visual-language.md), not here: the wireframes carry four values and no product palette, on purpose.

## Mobile

**Exploratory.** These exist to picture where the product is going, not to specify it — nothing here is committed and everything is subject to the two open questions below. Mobile is not a separate product tree: each mobile screen lives in the desktop product it's the mobile counterpart of (`reading` → [markdown-preview](../../product/editor/markdown-preview/doc.md), `capture` → [commit](../../product/git-workflow/commit/doc.md), `documents` → [file-tree](../../product/navigation/file-tree/doc.md), `review` → [rendered-diff](../../product/diff/rendered-diff/doc.md)) — same underlying capability, drawn for a different device. A product with no mobile counterpart drawn yet (e.g. [home](../../product/home/doc.md)) says so plainly rather than guessing at one.

They are drawn from the **job**, not from the desktop layout: navigation is a stack, there is no split view, and git is one action on the screen it belongs to rather than a permanent panel. That follows [Decision 8](../decisions/008-monorepo-with-pure-dart-core.md), which gives mobile its own presentation and says plainly that *panels do not become screens*. The job itself comes from [about.md](../../about.md) — read, review and approve, and capture a small edit. Authoring a document on a phone is not a goal.

Mobile ships in **Phase 3, post-1.0** ([roadmap](../../tasks/roadmap.md#phases)), and two questions have to close first — git without a system binary, and editing on touch, "an open design question, not just a port". Both are marked on the screens where they bite, which is why `capture` stops at recording a decision rather than showing an editor.

These were drawn early, out of order, to make the destination visible. Treat them as a sketch of intent: nothing in the desktop MVP depends on them, and they will be redrawn once those two questions have answers.

## How to read them

**A coloured chip means "this part arrives later".** The screens show the app as it will look once built, with anything post-M0 marked in place. That is deliberate: a wireframe drawn strictly to the current milestone would need redrawing three times, and the parts nobody has built yet are exactly the ones worth arguing about early.

**Text is placeholder bars.** Real words appear only in labels, buttons and the file tree — the parts whose wording *is* the design.

**The chrome does not move between screens.** The explorer is the same width everywhere it appears. If the screens disagree about that, the wireframes are wrong, not the app.

## How they are made

Generated, not hand-drawn:

```bash
python3 docs/technical/design/tools/build.py         # desktop
python3 docs/technical/design/tools/build_mobile.py  # mobile
python3 docs/technical/design/tools/palette.py       # palette.svg + contrast check
```

`tools/kit.py` holds the tokens (colour, type scale, spacing) and the components; `tools/build.py` composes the screens from them. Nothing sets a padding or a colour by hand, so changing a token moves every screen at once — which is the only way a set of wireframes keeps looking like one product. Full conventions are in the `tom-wireframes` skill.

Refining a screen inside Excalidraw while exploring is fine. When it settles, fold the change back into the build script and regenerate, so what is in the repository is reproducible rather than a snapshot someone once exported.

## The visual design

The wireframes stop at structure, on purpose. What the app *looks like* — the
palette applied, real type, real prose — is a second artifact, and it lives in a
[Penpot](https://penpot.app) file rather than in Excalidraw. Both are generated
from this folder, and neither is edited by hand as a matter of course.

| | Wireframes | Visual design |
|---|---|---|
| Answers | what is on the screen, and where | what it looks like |
| Tool | Excalidraw | Penpot (free plan is enough) |
| Built by | `build.py` on `kit.py` | `penpot_build.py` on `penpot_kit.js` |
| Colour | four drawing values | the roles in [visual-language.md](visual-language.md) |
| Text | placeholder bars | real prose from `docs/` |
| Canvas | 1040×560, a drawing scale | 1440×900, the window the app opens at |

**When the two disagree about layout, the wireframe is right.** It is the one a
stakeholder reviews, and the chrome tokens flow one way: `kit.py` owns
`TOP_BAR`, `EXPLORER_W` and the rest, and `penpot_build.py` re-emits them. No
value is copied between the two.

### Building it

```bash
python3 docs/technical/design/tools/penpot_build.py   # -> generated/penpot_bundle.js
```

The bundle is a **script, not a design file** — Penpot cannot open it. Penpot
opens `.penpot` / `.zip` files and imports SVG; JavaScript reaches it only
through a plugin, which runs in an iframe and talks to the app over the plugin
API. Two ways to run it:

- the **Penpot MCP server**, whose code tool evaluates the bundle directly —
  this is how the boards were built;
- a **local plugin**, from the [starter template](https://github.com/penpot/penpot-plugin-starter-template),
  serving the bundle and loaded through Penpot's Plugin Manager (`Ctrl+Alt+P`)
  by its `manifest.json` URL. There is no built-in JavaScript console.

It is **resumable**: each run builds one screen and returns `{ done: false }`
until the set is complete, so run it until it reports `done: true`.
`globalThis.PENPOT_ONLY = ["Committing"]` before a run restricts it to those
screens.

That shape is not fussiness. The plugin executes inside the Penpot browser tab,
so its timers are throttled the moment that tab goes to the background — a wait
that takes 40ms in front can take a second behind. One screen per call means a
throttled run costs another call rather than leaving a half-drawn board.

The run also creates the file's design tokens — the same roles as
[palette.py](tools/palette.py), so anyone nudging a board by hand picks from the
system instead of typing a hex, and the `Light` / `Dark` themes repaint the
whole file.

### Why it is generated

The same reason the wireframes are, plus one specific to the tool: Penpot's free
plan keeps seven days of version history. **The repository, not the design file,
is the copy that survives** — which is the premise this project is built on. A
board tweaked by hand and never folded back into `penpot_screens.js` is a board
nobody can reproduce next month.

### The `.penpot` file itself

Keeping a copy in the repository is a reasonable safety net — Penpot's free plan
keeps seven days of history — but it is a **safety net, not the source**: the
bundle above rebuilds every board deterministically, so the file adds recovery
convenience rather than truth. It is also an opaque binary that churns on every
save, so commit it when a set of screens settles, not on every edit.

The plugin API exposes `file.export("penpot" | "zip")`, but it is not available
through the MCP plugin runtime today (it raises `No matching clause`), so the
export is a manual step in the Penpot UI. `file.saveVersion(label)` does work,
and a labelled version is the cheaper checkpoint between commits.

### Getting the screens into a pull request

A `.penpot` file is no more reviewable in a diff than an `.excalidraw` one, and
the boards are ~130KB each as SVG or PNG. Export them from Penpot — select the
boards, Export, one file per board — and commit them next to the wireframe of
the product they belong to, suffixed by mode:

```
docs/product/workspace/mocks/
├── shell.excalidraw        ← the wireframe: structure
├── shell-light.svg         ← the visual design, light
└── shell-dark.svg          ← the visual design, dark
```

Same principle as the wireframes' export step: one artifact for the reviewer,
and the source of truth still in the repository.

## What is deliberately not drawn yet

**The rendered diff.** Its block granularity is the output of Spike B ([roadmap.md](../../tasks/roadmap.md)) — whether a block can be rendered in isolation is still an open question ([domain model](../domain-model.md)). Drawing it in detail now would be work thrown away the moment the spike reports, so `shell` shows the preview assembled block by block and stops there.

**Conflict resolution, section blame, wikilink navigation.** Post-MVP, and none of them constrain the M0 layout.

## Reviewing a change to these

`.excalidraw` is JSON and unreadable in a diff. Before opening a pull request that changes a screen, export it from Excalidraw as SVG with **Embed scene** enabled, saved alongside as `<screen>.excalidraw.svg` — GitHub renders it inline and Excalidraw reopens it fully editable, so one file serves both the reviewer and the next person to edit it.
