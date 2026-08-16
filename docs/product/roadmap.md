# Roadmap

## Phases

```
Phase 0 · Spikes          The two technical unknowns: the editor and the AST
Phase 1 · MVP (M0–M3)     Build in public; launch with a GIF of the rendered diff
Phase 2 · Traction        Assisted conflict resolution, section blame
Phase 3 · Mobile          iOS and Android, post-1.0 (Decision 8 reserves the shape)
```

### Phase 0 — Spikes

Timebox: about one weekend each. Goal: decide, not build.

- [ ] **Spike A — Editor.** Can `re_editor` carry source mode? Test with a 2000+ line md file, desktop shortcuts, selection, find/replace, typing latency. Fallback: a custom `TextField`.
- [ ] **Spike B — The `markdown` AST.** Does the package AST (`Node`/`Element`) carry enough information (source positions, block granularity) for the block diff (v1)? Test: parse two sibling md files, align blocks, classify unchanged/added/removed/modified. Fallback: our own parser, or enriching the AST through post-processing. The questions this spike must answer are listed in [the domain model](../architecture/domain-model.md); the shape of `Block` is its main deliverable, and whether a block can be rendered in isolation decides how the preview is assembled.

### Phase 1 — MVP

**Goal:** publicly demonstrate (HN / Reddit / Discord) that "rendered diff + a comfortable Git workflow" solves a real pain — the minimum slice a developer can try on a real repo in five minutes. Each item is a product: what it must do lives in its `doc.md` under [products/](../products/), not here — this only tracks order, status, and which package builds it. See [dependencies.md](../architecture/dependencies.md) for the full stack and license per package.

**M0 — Foundation**

- [ ] [Workspace](../products/workspace/doc.md) — the panel layout: `runTom(modules: [])`, panels via `PanelDescriptor` ([flows](../architecture/flows.md#panels-are-registered-never-hardcoded)); `window_manager` for window control
- [ ] [Home](../products/home/doc.md) — open a folder, recent spaces, the not-a-repository error; `file_selector`, `shared_preferences`
- [ ] [File tree](../products/navigation/file-tree/doc.md) — `dart:io` directory listing + `path`, no new package
- [ ] [Markdown preview](../products/editor/markdown-preview/doc.md) — `markdown` (AST), `flutter_markdown_plus` (inline rendering), `re_highlight` (code highlighting)
- [ ] [Source-mode editing](../products/editor/source-mode/doc.md) — includes saving to disk; `re_editor` (Spike A)

**M1 — Essential Git**

All four run Git through the system binary via `dart:io Process` behind a `GitClient` contract ([Decision 2](../decisions/002-git-via-system-binary.md)) — no new package.

- [ ] [Commit](../products/git-workflow/commit/doc.md)
- [ ] [Push / pull](../products/git-workflow/push-pull/doc.md)
- [ ] [Branch switch](../products/git-workflow/branch-switch/doc.md)
- [ ] [File history](../products/git-workflow/file-history/doc.md)

**M2 — The differentiator**

- [ ] [Rendered diff](../products/diff/rendered-diff/doc.md) — `diff_match_patch` or `diffutil_dart` for block alignment, on top of Spike B's `Block` shape
- [ ] [Branch / commit diff](../products/diff/branch-diff/doc.md) — same diff packages, over `git show`
- [ ] [Full-text search](../products/search/full-text-search/doc.md) — `sqlite3` + `sqlite3_flutter_libs` (FTS5)

**M3 — Launch polish**

- [ ] [Wikilinks](../products/wikilinks/doc.md) — custom inline syntax over the existing `markdown` pipeline, no new package
- [ ] [Formatting shortcuts](../products/editor/formatting-shortcuts/doc.md) — `re_editor`'s text-manipulation API, no new package
- [ ] [Export](../products/export/doc.md) — PDF/HTML; package not yet chosen — [Decision 13](../decisions/013-stack-is-flutter-and-dart.md) notes it's a separate problem in Flutter, budget for it
- [ ] [Home](../products/home/doc.md) — clone by URL; `dart:io Process` (`git clone`) with progress reporting
- [ ] Packaging: Windows (msix), macOS (dmg), Linux (AppImage/deb) — tooling not yet chosen *(distribution, not a product)*
- [ ] Landing page + a polished README + a GIF of the rendered diff *(marketing, not a product)*

### Phase 2 — Traction

Backlog, unscoped: assisted conflict resolution, section blame, multiple open spaces, an example space repo for onboarding, themes.

### Phase 3 — Mobile

Mobile is a committed direction, not a maybe — but it comes **after** 1.0. It is not a port for its own sake: writing documentation needs a repository, markdown and git, not a development environment, and the people who read and approve documentation are rarely at a desk when they do it. Desktop stays the reference platform: the panel layout, the Git-CLI infrastructure and the MVP scope are all unchanged by it. The cost is bounded because six of the seven packages are pure Dart by construction ([Decision 14](../decisions/014-each-layer-is-its-own-package.md)), so mobile means new infrastructure implementations plus a new set of widgets, not a refactor — the state package is already shared. Each mobile screen is drawn from the job, not the desktop layout, and lives beside its desktop counterpart's product ([products/README.md](../products/README.md)).

Two things must be resolved before Phase 3 starts:

- [ ] **Git without a system binary.** iOS and Android have no `git` CLI and no free filesystem — this is exactly the trigger [Decision 2](../decisions/002-git-via-system-binary.md) names for embedding `libgit2` via FFI.
- [ ] **Editing on touch.** `re_editor` is desktop-oriented ([dependencies](../architecture/dependencies.md)); source mode on a phone is an open design question, not just a port.

## Goals

Three, in this order — the ordering is what makes the plan honest: goals 1 and 2 are met by building well, entirely within the maintainer's control; goal 3 is not, so it carries no date.

1. **A tool worth using every day.** The scope comes from problems the maintainer hits directly — documentation kept as markdown in a repository, a diff that shows syntax instead of the document, colleagues who would read and approve that documentation if reaching it did not require a terminal. Nothing in the MVP is speculative.
2. **A demonstration of how software can be built.** The architecture notes, the decision records and the code patterns are as thorough as they are on purpose: a pure Dart core with framework independence proved by `dart test`, a decision file behind every architectural commitment, documentation updated in the same pull request as the behaviour it describes. If TOM never has a second user, this part still succeeded.
3. **Revenue, eventually, and only if earned.** [Decision 4](../decisions/004-business-model-is-open-core.md) gates anything commercial on genuine signals of team demand and keeps the free tier whole regardless.

Feedback comes from use, not from research. The maintainer is the first user and this repository is the first space TOM opens, so anything awkward shows up within a day of shipping it. Beyond that, the repository is public: whoever clones it, uses it and reports what breaks is a slower signal than a study, but it is a real one.

## Open questions

- [ ] Binary signing (Windows/macOS certificate cost) — needed for launch, or later?
- [ ] PDF/HTML export package — not yet chosen (M3, [Decision 13](../decisions/013-stack-is-flutter-and-dart.md))
- [ ] Packaging tooling per platform: msix / dmg / AppImage / deb — not yet chosen (M3)

---

*See also: [products/](../products/) · [architecture/](../architecture/) · [product.md](product.md)*
