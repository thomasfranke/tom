# Masters no screen asks for

Drawn so the set is complete, and waiting for the feature that needs them.

| Master | What it is waiting for |
|---|---|
| `Fab` · `Slider` | Nothing yet; drawn so nobody invents a second kind later |
| `Switch` | An on/off setting; preferences shipped with a `Checkbox` instead |
| `Radio` | A choice that is not a `Segmented`; none has come up |
| `Snackbar` | The confirmation that is not a band; the band won so far |
| `Search bar` | Superseded in practice by `Column field`, which the search actually uses |
| `Badge` | The unsaved mark, which the editor draws as a dot of its own |

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
