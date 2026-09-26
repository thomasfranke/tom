# When mobile arrives (Phase 3)

`apps/mobile` sits beside `apps/desktop` with its **own screens**, sharing
`tom_presentation` — which is why that package is pure Dart.

- **Panels do not become screens.** A layout drawn for a phone is drawn from the job, not ported from the desktop.
- What the two do share is the look: `tom_ui`, the marks and the tokens ([Decision 26](decisions/026-the-look-is-a-package.md)).
- `tom_infra` grows a second implementation per capability — `libgit2/` next to `dart_io/` — chosen at the composition root.

Decision 26 revises the "no shared-UI package" this used to state: the objection
was to sharing *layout*, and identity is not layout.

Two questions have to close first — git without a system binary, and editing on
touch ([roadmap](../roadmap.md#phases)). The product rules that differ live with
their feature, each as its own file: `capture`
([commit](../product/git-workflow/commit/capture-on-mobile/doc.md)), `documents`
([file tree](../product/navigation/file-tree/documents-on-mobile/doc.md)),
`review` ([rendered diff](../product/diff/rendered-diff/review-on-mobile/doc.md)).

---

*See also: [architecture.md](architecture.md) · [Decision 8](decisions/008-monorepo-with-pure-dart-core.md) · [roadmap.md](../roadmap.md)*
