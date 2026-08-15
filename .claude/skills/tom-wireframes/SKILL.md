---
name: tom-wireframes
description: How TOM's screen wireframes are made — the shared drawing kit, the design tokens (colour, type scale, spacing), the components, and the rules that keep every screen looking like one product. Use this skill whenever drawing, editing or reviewing a wireframe, mock or screen layout for TOM; when the user says "wireframe", "mock up a screen", "draw the layout", "excalidraw"; or when adding a new screen to docs/design/.
---

# TOM — wireframes

Wireframes live in `docs/design/`, are **generated rather than hand-drawn**, and exist to answer one question: what is on the screen and where. Anything beyond that — iconography, final copy, visual styling — is out of scope and actively harmful, because it draws feedback onto decoration while the structure is still open.

Colour is decided separately, in [visual-language.md](../../../docs/design/visual-language.md). The four values below are *drawing* tokens; they are not the product palette and must never be confused with it.

## Never hand-draw a screen

Every screen is produced by `docs/design/tools/build.py` on top of `docs/design/tools/kit.py`:

```bash
python3 docs/design/tools/build.py         # desktop screens
python3 docs/design/tools/build_mobile.py  # mobile screens (Phase 3, exploratory)
python3 docs/design/tools/palette.py       # palette.svg + WCAG check
```

Hand-tuning one `.excalidraw` file is how a set of wireframes stops looking like one product: the second screen's explorer ends up 8px narrower than the first, and nobody notices until they are side by side. Change a token in `tools/kit.py` and rebuild instead — all screens move together.

Refining a screen in the Excalidraw app is fine while exploring. When it settles, fold the change back into `tools/build.py` and regenerate, so the file in the repo is reproducible.

## Tokens

Defined in `tools/kit.py`. Never write a literal colour, size or padding into `tools/build.py`.

**Colour — four values, and no more.** A screen that needs a fifth is describing visual design, not structure.

| Token | Value | Used for |
|---|---|---|
| `INK` | `#1e1e1e` | Structure: window, panels, controls, real labels |
| `SOFT` | `#adb5bd` | Placeholder content: text bars, block outlines, disabled controls |
| `LABEL` | `#868e96` | Panel captions (`EXPLORER`, `CHANGES`) and secondary text |
| `MILESTONE[...]` | M0 `#1971c2` · M1 `#2f9e44` · M2 `#f08c00` · M3 `#9c36b5` | Milestone chips only |

A coloured mark in a TOM wireframe always means **"this part arrives later"**. Never use an accent as decoration or emphasis.

**Type — Excalidraw font family 1 (hand-drawn), deliberately.** A wireframe that looks drawn invites structural comment; one that looks finished invites comment on corner radius.

| Token | Size | Used for |
|---|---|---|
| `TITLE` | 24 | Screen name, above the frame |
| `SUBTITLE` | 14 | One line under it: the state, then ` · ` and the milestone |
| `HEADING` | 17 | In-app titles (the space name in the top bar) |
| `BODY` | 14 | Tree items, buttons, controls |
| `CAPTION` | 13 | Tab labels, placeholders, chips |
| `LABEL_SIZE` | 12 | Panel captions, status bar |

**Layout — constants shared by every screen.**

| Token | Value | Meaning |
|---|---|---|
| `CANVAS_W` | 1040 | Every screen is this wide, so they align when stacked in review |
| `TOP_BAR` / `STATUS_BAR` | 52 / 32 | App chrome |
| `EXPLORER_W` / `GIT_W` | 220 / 280 | Side panels — **constant across screens; the explorer never moves** |
| `PAD` / `PAD_TIGHT` | 20 / 16 | Panel edge to content · panel edge to a full-width control |
| `ROW` / `LIST_ROW` | 34 / 42 | Tree row pitch · file-list row pitch |
| `BAR_H` / `BAR_GAP` | 8 / 26 | Placeholder text bar height and pitch |

## Components

`Scene` provides these; prefer them over raw `rect`/`text`, because they carry the spacing rules.

| Call | Draws |
|---|---|
| `title(name, subtitle)` | The caption above the frame |
| `window(space, height)` | Frame, top bar with the space name, status bar |
| `explorer(tree, selected, search_chip)` | The left panel, identical on every screen where a space is open |
| `status(*items)` | Status-bar items, evenly spaced |
| `chip(id, x, y, "M2")` | The milestone chip |
| `button(id, x, y, w, label, muted=)` | Control; `muted=True` for one that arrives later |
| `field(id, x, y, w, placeholder)` | Dashed input |
| `bars(id, x, y, widths)` | Placeholder text lines |
| `caption(id, x, y, s)` | Panel caption in `LABEL` |
| `hline(id, x, y, w)` / `vline(id, x, y, h)` | Divider between regions |
| `text_centred(id, y, s, size)` | Text centred across the canvas |
| `popover(id, x, y, w, h)` | Floating surface — opaque, anchored to its trigger |
| `banner(id, x, y, w, msg, accent)` | A condition to act on, stated where it happened |
| `dot(id, x, y)` | Status mark (unsaved, unread) |

`Phone` extends `Scene` for mobile with `frame(title, back, action)`, `action_bar(label)` and `row(id, y, label, meta)` — a navigation stack, not panels.

## Rules

1. **Desktop and mobile are separate sets, not one set at two widths.** `screens/desktop/` is the product; `screens/mobile/` is exploratory for Phase 3 and is built by `build_mobile.py` on the `Phone` frame. [Decision 8](../../../docs/decisions/008-monorepo-with-pure-dart-core.md) gives mobile its own presentation and says *panels do not become screens*, so a narrowed copy of a desktop screen is the one thing never to draw there — mobile is drawn from the job (read, review, capture), with navigation as a stack.
2. **One file per state the app is actually in** — `empty-state`, `shell`, `committing`. Name it for what the user is doing, never `m0-shell` / `m1-shell`: a screen that gains a panel in a later milestone is one file with a chip on that panel, not two files that must be kept in sync.
3. **Placeholder content, never prose.** Text is `bars(...)`. Real words appear only in labels, buttons and the file tree — the parts whose wording is itself the design.
4. **Draw each border once.** The frame is a rounded rectangle; every region inside it is separated by `hline`/`vline`, never by its own rectangle. A rectangle laid over the frame repeats a border that is already there, and the repeat is obvious because the outer corner is rounded and the inner one is not.
5. **Never centre text by estimating its width.** Use `text_centred(...)`, which hands the centring to Excalidraw. Computing `x` from character count is always a few pixels out, and it shows.
6. **Chrome stays put across screens.** The explorer is 220 wide in every screen that has one, drawn by `explorer(...)`. If one screen needs it narrower, the token changes and every screen follows.
7. **Do not wireframe what a spike has not answered.** The rendered diff's block granularity is Spike B's output ([mvp.md](../../../docs/mvp.md)); drawing it in detail now is work that gets thrown away. Coarse is honest.
8. **Look at it before committing.** Render to PNG and actually view it — a wireframe with an overlapping label or a panel that fell off the canvas is invisible in the JSON diff.

## Review

`.excalidraw` is JSON, so a raw file is unreviewable in a pull request. Before opening one, export from Excalidraw as **SVG with "Embed scene" enabled**, saved next to the source as `<screen>.excalidraw.svg`: GitHub renders it inline, and Excalidraw reopens it fully editable. One file, reviewable and editable, with nothing to drift.

## Where the reasoning goes

Prose belongs in [docs/design/README.md](../../../docs/design/README.md) or in the document the screen serves — never baked into the image as annotations. An image crowded with explanation stops being a wireframe and starts being a diagram nobody updates.
