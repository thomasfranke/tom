# Not drawn yet

What has no board in the Penpot file, and why. Saying so is honest; a board
that no longer matches what shipped is not.

A board that is drawn is exported, and is in [`desktop/`](desktop/) — what the
file still owes is the [Penpot backlog](../penpot-backlog.md).

| | Why |
|---|---|
| **Mobile** | A `mobile/` folder appears when Phase 3 does. Drawn from the job, not from the desktop layout — [Decision 8](../../technical/decisions/008-monorepo-with-pure-dart-core.md) says *panels do not become screens* — and waiting on the two questions the [roadmap](../../roadmap.md#phases) names |
| **"YOUR COMMITS" under a rejection** | Phase 2, by the [roadmap](../../roadmap.md)'s own words |
| **Resolving a whole list of documents at once** · section blame · several spaces open · themes | Post-MVP; none constrains today's layout |
| **A rebase, a cherry-pick or a revert stopped half way** | Only a merge is recognised for now, so there is no state to draw |
| **A command palette** | After the MVP. `⌘K` is the search box's, so a palette does not get that key by default |
| **A selection toolbar in the source pane** | Not decided: the editor package ships none, and whether one is drawn or the [formatting bar](../../product/editor/formatting-shortcuts/doc.md) is all there will be is the maintainer's call ([roadmap](../../roadmap.md)) |
| **The site in light** | By decision: the site does not follow the reader's system setting, and its picture of the app becomes a real screenshot at launch rather than a redrawn board ([site/](../site/README.md)) |
| **The diff turned off** | By decision: every screen that is not about the diff already draws the chip off, so a board of its own would say nothing the others do not ([turning it off](../../product/diff/rendered-diff/turning-it-off/doc.md)) |
| **Closing the window with unsaved tabs** | No board of its own, by the rule that a screen is drawn once: it raises the popover `Leaving with unsaved work — the question` already draws, with one sentence changed, and that row's notes say so ([leaving a space](../../product/workspace/leaving-a-space/doc.md)) |

---

*See also: [screens/](README.md) · [penpot-backlog.md](../penpot-backlog.md) · [roadmap.md](../../roadmap.md)*
