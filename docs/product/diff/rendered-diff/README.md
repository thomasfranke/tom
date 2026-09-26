# Rendered diff

Show what changed over the *formatted* document — a struck-through removed
paragraph, a highlighted new one — not `+/-` over raw markdown text. **The
product's core differentiator.**

**Status:** Shipped · Milestone M2 (desktop) · Exploratory, Phase 3 post-1.0 (mobile, as "review")

| | |
|---|---|
| [`what-is-compared/`](what-is-compared/doc.md) | Which two things, at which moment, and what happens when git cannot say |
| [`how-it-is-drawn/`](how-it-is-drawn/doc.md) | The marks: letter and tint, the struck-through removal, both panes, the seam |
| [`turning-it-off/`](turning-it-off/doc.md) | The `Diff` chip, and what the document looks like without marks |
| [`review-on-mobile/`](review-on-mobile/doc.md) | The mobile counterpart |

Comparing against another branch or commit instead is
[branch-diff](../branch-diff/doc.md); every rule here holds either way.

## Mocks

Both are drawn in split view with the left column closed, so the marks are
visible in the source and in the preview at once.

- **comparing** — an added, a modified and a struck-through removed block in the preview, the same three in the source with the removed one as a seam. [light](../../../design/screens/desktop/git-diff/comparing-light.svg) · [dark](../../../design/screens/desktop/git-diff/comparing-dark.svg).
- **diff off** — the same document with the chip off: no marks, and the removed block simply absent. [light](../../../design/screens/desktop/git-diff/diff-off-light.svg) · [dark](../../../design/screens/desktop/git-diff/diff-off-dark.svg).

---

*See also: [product/](../../README.md) · [about.md](../../../about.md) · [roadmap.md](../../../roadmap.md)*
