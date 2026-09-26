# Components

The control set, with the exact numbers the Flutter implementation reads.

**Normative.** A colour picked off a screenshot is a colour that drifts, so
every number a widget needs is written down here. When a file here and the
theme disagree, **the theme is right** — the canonical form of a rule is the
dartdoc of the code that implements it ([AGENTS.md](../../../AGENTS.md)).

| | |
|---|---|
| [`library.md`](library.md) | The three Penpot pages, and the rules every master is held to |
| [`penpot-traps.md`](penpot-traps.md) | What the plugin API does about all that, and the five traps in it |
| [`controls.md`](controls.md) | One row per master: widget, size, radius, states |
| [`unused.md`](unused.md) | The masters no screen asks for, and why they exist |
| [`color-scheme.md`](color-scheme.md) | The colour roles mapped onto Flutter's `ColorScheme` |
| [`radius.md`](radius.md) | Two steps and a shape |
| [`type.md`](type.md) | The type scale, and Material's own scale for controls |
| [`elevation.md`](elevation.md) | One level, for what floats over the content |
| [`icons.md`](icons.md) | The glyph set and how it grows |
| [`icons/`](icons/) | The glyphs themselves, one SVG each |

- **Anatomy is Material 3, palette is TOM's, and the button is the product's own.** Material because every control here is a widget that already exists — a 48px button with an 8px radius is a `ButtonStyle` set once in the theme, not an override at every call site.
- The colour roles are decided in [`visual-language/`](../visual-language/README.md), not here. This chapter maps them onto widgets; it never restates their values.

---

*See also: [design/](../README.md) · [foundations/](../foundations/README.md) · [visual-language/](../visual-language/README.md)*
