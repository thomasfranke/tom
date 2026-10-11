# The library

The controls as a real Penpot library, under the `TOM/` path, with variants.

Penpot, file **TOM**, on pages of their own:

| Page | Holds |
|---|---|
| `Components - Catalogue` | The specimens, one row per control, with the Flutter widget named beside it. **Every master has a row** — a master the catalogue does not show is one nobody can find |
| `Components - Master` | The masters of the controls, in a board called `Masters` |
| `Components - Shell` | The masters of the window's own regions — the two bars, the explorer, the document, the git panel — which every screen instances |
| [`Foundations`](../foundations/README.md) | The palette and the type scale, and no component at all |

## Rules

- Every control on a screen is an instance of a master. No screen draws a control, and an instance is never detached to restyle it — the difference is a variant, or the master is wrong.
- A control that does not exist yet becomes a master **before** the screen that needed it: adding one is a smaller decision than the screen, and reviewing it separately is what keeps the set coherent.
- A master carries no product vocabulary. Labels are `One`, `Two`, `Three`; specimen text is `Item name`. Text is a property, so the screen writes the real words — a master that ships this product's words only fits this product.
- Where a family cannot be one variant set, the distinction goes in the name — `Segmented · 2`, `Segmented · 3` — so the two sort together.
- A master stays on the page it is on. Penpot keeps every original as a real shape, so duplicating a page that holds main instances duplicates the components with it; the one move that keeps a master's identity is cut and paste in the Penpot app, and only for a master that is not a variant set — which is how the shell's went to a page of their own.
- A page is cited by its name, never by its number.
- A number that matters belongs in [`components/`](README.md), not only in Penpot — the free plan keeps seven days of history.

What the Penpot API does about all this, and the traps in it:
[`penpot-traps.md`](penpot-traps.md).

---

*See also: [components/](README.md) · [foundations/](../foundations/README.md) · the [`tom-design`](../../../.ai/skills/tom-design/SKILL.md) skill*
