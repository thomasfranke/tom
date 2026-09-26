# Why these values

The four choices behind the table in [`README.md`](README.md).

| Choice | Why |
|---|---|
| **Warm neutrals, not blue-grey** | Every surface carries a little yellow, so a long document does not glare the way a pure white page does and dark mode does not read as cold slate. The two modes share a temperature, which is what makes switching feel like the same product at a different time of day. |
| **Sage as the accent, not blue** | The default accent in every framework is a saturated blue, and it makes a documentation tool look like a dashboard. A muted green sits back and lets the text lead. |
| **No pure black, no pure white** | `text_primary` is `#26251F`, not `#000`. Pure black on white is the highest-contrast and least comfortable pairing there is for continuous reading. |
| **Muted diff colours** | The rendered diff is the differentiator, so it is on screen constantly rather than occasionally. Saturated red and green would exhaust a reader within one document. |

## Not decided here

Type and spacing. The boards fix a working rhythm, but the reading column
width, the heading scale for rendered markdown and the line height for long
prose are decided against real rendered documents, not against boxes — which
happens when the preview renders for the first time.

---

*See also: [visual-language/](README.md) · [rules.md](rules.md) · [components/type.md](../components/type.md)*
