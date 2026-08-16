# Rendered diff

Show what changed over the *formatted* document — a struck-through removed paragraph, a highlighted new one — not `+/-` over raw markdown text. This is the product's core differentiator.

**Status:** Planned · Milestone M2 (desktop) · Exploratory, Phase 3 post-1.0 (mobile, as "review")

## Rules — desktop

- The diff compares the working tree against HEAD and renders both sides as formatted output, never as raw-text `+/-` lines.
- Version 1 is a block diff: added, removed and modified paragraphs and headings are highlighted in the preview. Finer-grained (inline word-level) diffing is not required for v1.
- A document with no changes shows no diff decoration at all — the rendered diff never adds noise to an unmodified file.

## Rules — mobile ("review")

- Changes are shown rendered, the same principle as desktop — never as raw text.
- Approving is the one action on this screen — for someone who is rarely at a desk when review happens.
- Block granularity depends on the same open question as desktop (Spike B).

## Mocks

- Desktop: not drawn yet — the block granularity depends on Spike B's findings (see [roadmap.md](../../../product/roadmap.md)); the [shell](../../workspace/mocks/shell.excalidraw) layout deliberately stops at "preview assembled block by block" until that's answered.
- Mobile: [review](mocks/review-mobile.excalidraw) — what changed, rendered, with approve as the one action.

---

*See also: [product.md](../../../product/product.md) · [roadmap.md](../../../product/roadmap.md)*
