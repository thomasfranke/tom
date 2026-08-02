# Product

## Personas

- **Maintainer developer** — writes and reviews technical docs; wants documentation on the same lifecycle as the code (PR, review, CI).
- **Tech lead / staff engineer** — wants visibility: who changed what, when, in which PR; wants to retire Confluence.
- **Semi-technical collaborator** *(future persona, post-MVP)* — a PM or QA who can edit a page and click "propose change" without knowing what a rebase is. This path is free: proposing a change is a branch, a commit and a push, with the PR opened on the host — no remote API, no paid tier ([Decision 4](decisions/004-business-model-is-open-core.md)).

## Killer features (the heart of the product)

1. **Rendered markdown diff** — changes shown over the *formatted* document (removed paragraph struck through, new paragraph highlighted), not `+/-` over raw text. No tool does this well today.
2. **Branch workflow without ceremony** — switch branches and watch the docs change; branch off for one edit; commit/push in a single gesture; a clear indication of being behind the remote.
3. **History and section blame** — "who wrote this paragraph, and in which commit/PR?", surfaced readably.
4. **Assisted conflict resolution** — both sides rendered side by side, choice per block.
5. **A documentation experience** — the file tree as space navigation, full-text search, wikilinks between documents, image support.

## Non-goals (equally important)

- WYSIWYG / block-based rich-text editing (Notion/AppFlowy territory)
- Real-time collaboration (the model is asynchronous, through Git)
- Databases / kanban / tasks
- Our own cloud sync (the Git remote **is** the sync)

> **Not a non-goal: mobile.** iOS and Android are a planned direction, post-1.0 — desktop still comes first, and nothing about the MVP scope changes. See the [roadmap](roadmap.md#phases) and [Decision 8](decisions/008-monorepo-with-pure-dart-core.md), which already reserves the shape (`tom_infra_mobile` + `apps/tom_mobile` over the same pure-Dart core).

---

*See also: [vision.md](vision.md) · [mvp.md](mvp.md)*
