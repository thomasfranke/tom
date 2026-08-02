# Roadmap

## Phases

```
Phase 0 · Validation      Public pitch → measure real demand
                          (in parallel: Spikes A and B — editor and AST)
Phase 1 · MVP (M0–M3)     Build in public; launch with a GIF of the rendered diff
Phase 2 · Traction        Assisted conflicts, section blame, PR integration (layer 3)
Phase 3 · Commercial      Paid edition, gated by real signals (Decision 4)
Phase 4 · Mobile          iOS and Android, post-1.0 (Decision 8 reserves the shape)
```

Mobile is a committed direction, not a maybe — but it comes **after** 1.0. Desktop stays the reference platform: the panel layout, the Git-CLI infrastructure and the MVP scope are all unchanged by it. The cost is bounded because `tom_core` is pure Dart by construction, so mobile means new infrastructure implementations plus a new presentation, not a refactor. Two things must be resolved before Phase 4 starts:

- **Git without a system binary.** iOS and Android have no `git` CLI and no free filesystem — this is exactly the trigger [Decision 2](decisions/002-git-via-system-binary.md) names for embedding `libgit2` via FFI.
- **Editing on touch.** `re_editor` is desktop-oriented ([dependencies](dependencies.md)); source mode on a phone is an open design question, not just a port.

## What to say publicly about the commercial edition

Until a paid edition actually ships, the public line is short and unambiguous:

> TOM is free and open source (MIT). A commercial edition for organizations may come later, funding the project's maintenance — the current feature set stays free.

Rules for every public communication (README, site, HN/Reddit posts, release notes):

- **Never announce features that do not exist**, and never give dates for them.
- **Never quote a price** before there is something to sell.
- **Never use the words "lifetime" or "perpetual"** — the most expensive promise to walk back (see the prior art in [Decision 4](decisions/004-business-model-is-open-core.md)).
- **Never ship a capped build or a countdown trial.** The free tier is the whole product as it stands.
- If asked directly how the project will sustain itself, answer plainly: a future paid edition aimed at organizations, plus GitHub Sponsors — and that the free/paid boundary only ever moves toward free.

## Risks and mitigation

| Risk | Likelihood | Mitigation |
|---|---|---|
| Unvalidated demand (deduced pain, not observed) | High | Phase 0 before heavy code; explicit decision gate |
| Obsidian ships decent official Git support | Medium | Focus on *teams* and the rendered diff (outside their positioning); speed |
| The rendered diff is harder than estimated | Medium | Incremental v0→v2; v0 alone is already shippable and useful |
| Divided energy (a solo maintainer) | High | Aggressively small MVP scope; success in Phase 1 defined without revenue |
| An AGPL dependency slips in | Low | License check as a PR checklist item |

## Open questions

- [ ] Final name + domain + GitHub org (availability and trademark check pending)
- [ ] ~~Does the `markdown` AST handle diff v1?~~ → **Spike B** ([mvp.md](mvp.md))
- [ ] ~~Can `re_editor` serve as source mode?~~ → **Spike A** ([mvp.md](mvp.md))
- [ ] Space configuration format (`.tom/config.yaml` in the repo? none at all?)
- [ ] Binary signing (Windows/macOS certificate cost) — needed for launch or later?
- [ ] Preview: how far does `flutter_markdown_plus` take us before migrating to our own AST renderer? (Spike B may answer this naturally)

---

*See also: [mvp.md](mvp.md) · [Decision 4 (open-core)](decisions/004-business-model-is-open-core.md)*
