# Visual language

The colour system for the app: sixteen roles, each with a light and a dark
value.

![Both modes](palette.svg)

| | |
|---|---|
| [`rules.md`](rules.md) | What the roles are held to — contrast, both modes, colour never alone |
| [`rationale.md`](rationale.md) | Why these values, and what is deliberately not decided here |
| [`palette.svg`](palette.svg) | The sheet above, generated |

**Values live in [`tools/palette.py`](../tools/palette.py)**, which generates
the sheet and checks every pairing:

```bash
python3 docs/design/tools/palette.py
```

## Roles, never shades

Nothing here is called `grey200`. A role survives a palette change; a shade
number does not, and renaming it later means touching every widget that used it.

| Role | Light | Dark | Used for |
|---|---|---|---|
| `surface` | `#FAF9F6` | `#1A1917` | The page |
| `surface_raised` | `#FFFFFF` | `#232220` | Panels, popovers, cards |
| `surface_sunken` | `#F0EEE9` | `#131211` | Inputs, code blocks, the inactive pane |
| `border` | `#E2DFD8` | `#34322D` | Dividers between regions |
| `border_strong` | `#C9C5BB` | `#4C4942` | Control outlines, focus |
| `text_primary` | `#26251F` | `#ECEAE4` | Body and headings |
| `text_secondary` | `#57544C` | `#ADA9A0` | Metadata, secondary labels |
| `text_muted` | `#8B877D` | `#807C74` | Captions, placeholders |
| `accent` | `#4C7D6E` | `#84B5A5` | Selection, active state, links |
| `accent_soft` | `#E4EEEA` | `#1E2C28` | The fill behind an active row |
| `added` / `added_soft` | `#3D7A52` / `#E6F0E8` | `#86BC98` / `#1B2820` | Diff: a block that appeared |
| `removed` / `removed_soft` | `#A24F46` / `#F6E8E6` | `#DA9A92` / `#2C1E1C` | Diff: a block that went |
| `modified` / `modified_soft` | `#8F6F2E` / `#F4EDDF` | `#D2B274` / `#2A2418` | Diff: a block that changed |

**This table is the only place these values are written.** How they map onto
Flutter's own names is [`components/color-scheme.md`](../components/color-scheme.md),
which links here and never restates them.

---

*See also: [design/](../README.md) · [components/](../components/README.md) · [brand/](../brand/README.md)*
