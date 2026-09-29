# Turning it off

The marks are the differentiator, not a mode nobody can leave.

**Status:** Planned · Milestone M2

## Rules

- **The decoration can be turned off**, by a `Diff` chip fixed at the end of the bar above the document. Somebody reading a paragraph they are in the middle of writing needs to see it without the history of it.
- The chip is the one control for the whole feature, and it is 62 points wide: **the base is named beside it, not inside it** — `Compared to <ref>`, in the added role, to its left.
- With no base chosen there is no name at all, only the chip. A label reading `Compare against…` is a control describing itself, which the bar has no room for.
- It is fixed at the *end* of the bar, so it keeps its place when the document's name grows and does not drift towards the centred `Source · Split · Preview`.
- **With the diff off the document is exactly what it would be if nothing had changed** — a removed block is simply not there, because the marks were the only reason it was being shown.

## Mocks

- **No board of its own, and that is the point.** The chip is off on every screen that is not about the diff, so `shell` and the rest already *are* this state — a board drawing it again would have said nothing the other seventy-six do not ([workspace](../../../workspace/regions/doc.md)).

---

*See also: [rendered-diff/](../README.md) · [branch-diff](../../branch-diff/doc.md) · [columns](../../../workspace/columns/doc.md)*
