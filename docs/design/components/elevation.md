# Elevation

**One level**, and it is for what floats over the content.

| | Value | Used by |
|---|---|---|
| `overlay` | `0 4 12`, `text_primary` at 14% | Menu, dialog, snackbar, FAB |
| `hairline` | 1px `border` | Card, panels, dividers |

- The shadow colour is `text_primary` at a low opacity, never black.
- `hairline` is not an elevation — it is what everything else uses instead.
- **A card sits in the page, it does not hover above it.** Reaching for a shadow to separate two things that are both on the page is how a flat interface turns soft.

Material ships five levels; the product has exactly three surfaces that leave
the page.

---

*See also: [components/](README.md) · [controls.md](controls.md)*
