# Radius

**Two steps and a shape.**

| Step | Value | Applied to |
|---|---|---|
| `sm` | **4** | Checkbox, status mark, tab indicator |
| `md` | **8** | Everything else — button, chip, segmented, text field, search bar, select control, card, menu, dialog, snackbar, FAB |
| — | *circular* | Switch track, radio, badge, slider track and thumb |

- Circular is a shape, not a step: those controls are round by definition and their radius is half their height. A value forced by geometry is not a choice.
- The filled text field is the one exception to a uniform radius — `md` on the top two corners, `0` on the bottom two, because the underline needs a straight edge to sit on. Flutter draws that by default.

It was nine numbers at one point — 2, 3, 4, 8, 10, 12, 16, 20, 28 — because
Material's radii were laid over the ones the product already had. A set where
every control rounds differently reads as nine products.

---

*See also: [components/](README.md) · [controls.md](controls.md)*
