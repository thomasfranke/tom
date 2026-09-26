# Rules

What the colour roles are held to. The roles themselves are
[`README.md`](README.md).

1. **Colour is never the only signal.** A diff block carries a gutter mark and a position, not just a tint — roughly one in twelve men cannot separate the red from the green. The same holds for status anywhere else in the app.
2. **Both modes ship together.** A colour added in one mode without its counterpart is a bug, not a follow-up; [`palette.py`](../tools/palette.py) fails loudly if a role is missing from either map.
3. **Contrast is verified, not eyeballed.** Every pairing the UI produces is checked against WCAG AA — 4.5:1 for body text, 3:1 for large text and non-text marks. Adding a role means adding its pairing to `PAIRS`.
4. **The accent does not carry meaning on its own.** It marks *the current thing*: the open document, the checked-out branch, the focused control. Anything semantic — added, removed, modified — uses the diff roles.
5. **`surface_raised` means "above".** Popovers and panels use it in light mode and get *lighter* in dark mode, because elevation reads as proximity to the light source in both.

---

*See also: [visual-language/](README.md) · [rationale.md](rationale.md)*
