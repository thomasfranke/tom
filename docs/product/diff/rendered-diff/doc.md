# Rendered diff

Show what changed over the *formatted* document — a struck-through removed paragraph, a highlighted new one — not `+/-` over raw markdown text. This is the product's core differentiator.

**Status:** Shipped · Milestone M2 (desktop) · Exploratory, Phase 3 post-1.0 (mobile, as "review")

## Rules — desktop

- The diff compares the working tree against HEAD and renders both sides as formatted output, never as raw-text `+/-` lines. Comparing against another branch or commit instead is [branch-diff](../branch-diff/doc.md); everything below holds either way.
- Version 1 is a block diff: added, removed and modified paragraphs and headings are highlighted in the preview. Finer-grained (inline word-level) diffing is not required for v1.
- A document with no changes shows no diff decoration at all — the rendered diff never adds noise to an unmodified file.
- **What is compared is what is on screen**, not what is on disk: an edit is marked as it is typed, before anything is saved.
- A changed block carries a **letter as well as a tint** — A, R, M for a block that arrived, went or was rewritten — because colour is never the only signal.
- **A removed block is still rendered**, struck through, where it used to be: reading what was deleted is the point of showing it at all.
- A document Git has never seen is every block added. A new file is not an error, and it is not a blank comparison either.
- A comparison Git could not make leaves the document undecorated rather than replacing it with an error. What failed is the diff; the document is readable either way.
- A version opened from the file history is not compared against anything *by default*: it is the past, and nothing is being changed against it. Asking to compare it against a revision is [branch-diff](../branch-diff/doc.md)'s — two commits, neither of them the working copy.

## Rules — mobile ("review")

- Changes are shown rendered, the same principle as desktop — never as raw text.
- Approving is the one action on this screen — for someone who is rarely at a desk when review happens.
- Block granularity depends on the same open question as desktop (Spike B).

## Mocks

- Desktop: **not drawn yet, and now behind the code** — Spike B answered the granularity (a block is top level) and the feature is built, so what is missing is a mock of the decoration itself: the tint, the gutter mark and a struck-through block in the reading column. The [shell](../../workspace/mocks/shell.excalidraw) layout still stops at "preview assembled block by block".
- Mobile: [review](mocks/review-mobile.excalidraw) — what changed, rendered, with approve as the one action.

---

*See also: [about.md](../../../about.md) · [roadmap.md](../../../roadmap.md)*
