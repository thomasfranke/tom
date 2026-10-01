# Masters no screen asks for

Drawn so the set is complete, and waiting for the feature that needs them.

| Master | What it is waiting for |
|---|---|
| `Fab` · `Slider` | Nothing yet; drawn so nobody invents a second kind later |
| `Switch` | Settings, in M3 |
| `Radio` | A choice that is not a `Segmented`; none has come up |
| `Menu` · `Dialog` | Drawn, and used on screens that build them by hand rather than instancing |
| `Snackbar` | The confirmation that is not a band; the band won so far |
| `Search bar` | Superseded in practice by `Column field`, which the search actually uses |
| `Tabs` | Panels that stack views; the aside chose a `Segmented · 2` instead |
| `Segmented · 3` | The mode bar draws its own; the master is what it should instance |
| `Badge` | The unsaved mark, which the editor draws as a dot of its own |
| `Panel toggle`, bottom variants | The bottom strip, when it comes |
| `Theme toggle` | Nothing — the theme moved into the [preferences](../../product/preferences/the-popover/doc.md) popover and the bar's control went with it. Kept, because the choice it draws did not go away |

They exist so nobody invents a fourth kind of toggle later. They are **not** a
commitment that the product will use them, and a master here is not a reason to
put one on a screen.

## Counting instances is not how you find these

**A master with no instances is not evidence that the product does not use it.**
Two of this file's controls prove it, in opposite directions:

- The search box, the commit message and a branch's name are all drawn by hand or point at a **deleted** master, so the master they *should* use reads as untouched.
- `Text field` read as untouched for exactly that reason, and two of its four variants were deleted before anybody checked the catalogue, which said `USED IN  Commit message · Branch name` all along.

So the catalogue's `USED IN` line is the statement of intent and outranks any
count, and a master is removed only when a human says the product will not have
that control — never because a query came back empty
([`tom-design`](../../../.ai/skills/tom-design/SKILL.md)).

---

*See also: [components/](README.md) · [controls.md](controls.md) · [library.md](library.md)*
