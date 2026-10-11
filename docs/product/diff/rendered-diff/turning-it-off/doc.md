# Turning it off

The marks are the differentiator, not a mode nobody can leave.

**Status:** Shipped · Milestone M2

## Rules

- **The decoration can be turned off**, by a `Diff` chip fixed at the end of the bar above the document. Somebody reading a paragraph they are in the middle of writing needs to see it without the history of it.
- **A press on the chip only turns the marks off, and the next turns them back on.** It opens nothing: what the marks are measured against is not a choice ([branch-diff](../../branch-diff/doc.md)).
- The chip is the one control for the whole feature, and it is 62 points wide: **the base is named beside it, not inside it** — `Compared to <ref>`, in the accent, to its left. The chip's tooltip names it too, for a row with no room for the name.
- On, the chip is a chosen control; off, a control at rest — never one that reads as unavailable, because it can always be pressed.
- With no base — on the base branch itself, or on no branch — there is no name at all, only the chip. A label reading `Compare against…` is a control describing itself, which the bar has no room for.
- **With the marks off the base is not named**, and it is kept: turning them back on compares against the same branch, because off is a reading position and not another comparison.
- It is fixed at the *end* of the bar, so it keeps its place when what shares the row with it grows.
- **With the diff off the document is exactly what it would be if nothing had changed** — a removed block is simply not there, because the marks were the only reason it was being shown.

## Mocks

- **No board of its own, and that is the point.** The chip is off on every screen that is not about the diff, so `shell` and the rest already *are* this state — a board drawing it again would say nothing the others do not ([workspace](../../../workspace/regions/doc.md)).

---

*See also: [rendered-diff/](../README.md) · [branch-diff](../../branch-diff/doc.md) · [columns](../../../workspace/columns/doc.md)*
