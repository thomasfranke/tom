# Turning it off

The marks are the differentiator, not a mode nobody can leave.

**Status:** Planned · Milestone M2

## Rules

- **The decoration can be turned off**, by a `Diff` chip fixed at the end of the bar above the document. Somebody reading a paragraph they are in the middle of writing needs to see it without the history of it.
- The chip is the one control for the whole feature: it turns the marks off, and it names what they are measured against as `Compared to <ref>` inside it. Two controls for one decoration is two things to find.
- It is fixed at the *end* of the bar, so it keeps its place when the document's name grows and does not drift towards the centred `Source · Split · Preview`.
- **With the diff off the document is exactly what it would be if nothing had changed** — a removed block is simply not there, because the marks were the only reason it was being shown.

## Mocks

- **diff off** — [light](../../../../design/screens/desktop/git-diff/diff-off-light.svg) · [dark](../../../../design/screens/desktop/git-diff/diff-off-dark.svg).

---

*See also: [rendered-diff/](../README.md) · [branch-diff](../../branch-diff/doc.md) · [columns](../../../workspace/columns/doc.md)*
