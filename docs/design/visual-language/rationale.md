# Why these values

The four choices behind the table in [`README.md`](README.md). They are
prototype **1b** of the 2026-10-07 restyle — seven styles were drawn side by
side, and the others stay on the Penpot file's `Prototypes` page.

| Choice | Why |
|---|---|
| **Islands on a window, not one surface cut by hairlines** | JetBrains' Islands reading: each column is a `surface_raised` container on a darker `surface`, so the regions are told apart by their edge and their fill rather than by a line between them. The warm, flat surface it replaces read as a prototype rather than as a tool somebody uses all day. |
| **Cool neutrals in the dark, a touch of warmth in the light** | The dark theme sits beside an IDE and a terminal, and those are cool grey. The light theme's islands were pure white at first and read as glare; on the maintainer's eye they became an off-white with a little yellow in it, and the window behind them warmed to match — a white page is the one surface where warmth reads as paper rather than as a different temperature. |
| **Teal as the accent, not blue** | The default accent in every framework is a saturated blue, and it makes a documentation tool look like a dashboard. Teal keeps the brand's green family and carries enough light to mark the current thing on a dark island. |
| **No pure black, no pure white text** | `text_primary` is `#1F2328`, not `#000`. Pure black on white is the highest-contrast and least comfortable pairing there is for continuous reading. |

## Not decided here

Type and spacing. The boards fix a working rhythm, but the reading column
width, the heading scale for rendered markdown and the line height for long
prose are decided against real rendered documents, not against boxes.

---

*See also: [visual-language/](README.md) · [rules.md](rules.md) · [components/type.md](../components/type.md)*
