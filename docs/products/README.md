# Products

The source of truth for what each feature must do — non-technical, maintained by stakeholders, and what an implementation should be checked against. `docs/product/` is the "why" (vision, non-goals); this is the "what", one folder per feature.

## Shape

```
docs/products/<group>/<feature>/
  doc.md    ← non-technical rules: the job, the status/milestone, atomic "must" statements
  mocks/    ← wireframes for this feature, if it has a UI
```

A feature with no natural group sits directly under `docs/products/` (e.g. `wikilinks/`, `export/`). Mobile is not a separate tree: the same product folder holds both platforms when they're the same capability (`git-workflow/commit/mocks/committing-desktop.excalidraw` and `capture-mobile.excalidraw`), because a stakeholder cares about "can I commit", not which device drew it. Once a product has a mock for each platform, both filenames carry the platform suffix (`-desktop` / `-mobile`) — a lone unsuffixed file means only one platform has been drawn yet. Mobile's *rules* still get their own subsection in `doc.md` when they diverge from desktop — [Decision 8](../decisions/008-monorepo-with-pure-dart-core.md) gives mobile its own presentation on purpose, so the mock and the rules for it are genuinely different, not a narrower copy.

## Keeping mocks current

**If a product has a user-facing interface, its `mocks/` must reflect that interface.** A `doc.md` describing a screen that no longer looks like its own mock is worse than no mock at all — it teaches the wrong shape with the appearance of authority. When a PR changes a product's interface, it updates that product's `.excalidraw` (or replaces it) in the same PR, same as [CLAUDE.md](../../CLAUDE.md) already requires for documentation generally. A product that has never shipped a UI can say "Not drawn yet" in its `doc.md` — that's honest. A product whose UI shipped and diverged from its mock is not.

Desktop mocks are generated, not hand-drawn — see the `tom-wireframes` skill and [design/README.md](../design/README.md) for how.

## Writing a doc.md

Rules are atomic and imperative ("Fetch alone never changes a file on disk"), not prose paragraphs — that's what makes them checkable, by a stakeholder reading it and by an agent implementing against it. Each file also states a `Status` line (Planned / Shipped) and the milestone it belongs to, per [roadmap.md](../product/roadmap.md).

---

*See also: [roadmap.md](../product/roadmap.md) · [product.md](../product/product.md) · [design/](../design/)*
