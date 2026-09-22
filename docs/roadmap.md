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

- [x] **Spike A — Editor.** ✅ **`re_editor` carries source mode** — [Decision 18](technical/decisions/018-source-mode-uses-re-editor.md). Measured against the fallback on the same machine and document: 4.4ms build p50 while typing and 0.6% of frames over budget, against the `TextField`'s 38.8ms and 96.2%. It holds at ten times the file size the spike asked for. The fallback is withdrawn; what the package does *not* ship — the find panel and the selection toolbar — is ours to write.
- [x] **Spike B — The `markdown` AST.** ✅ **The package carries it** — [Decision 19](technical/decisions/019-blocks-come-from-the-markdown-package.md). Neither fallback is taken. The AST has no source positions, but they are recoverable for every one of 848 blocks by *extending* each block syntax — decorating one silently changes the parse, because the package's syntaxes recognise each other by type. `Block` is a span, its text and its kind; granularity is top level; there is no stable identity, so alignment is positional and by similarity. A block renders in isolation, reference links included if the document's map travels with it — footnotes are the one thing that breaks, and that is M2's problem with a failing case waiting.

### Phase 1 — MVP

**Goal:** publicly demonstrate (HN / Reddit / Discord) that "rendered diff + a comfortable Git workflow" solves a real pain — the minimum slice a developer can try on a real repo in five minutes. Each item is a product: what it must do lives in its `doc.md` under [product/](product/README.md), not here — this only tracks order, status, and which package builds it. See [dependencies.md](technical/dependencies.md) for the full stack and license per package.

**M0 — Foundation**

- [x] [Workspace](product/workspace/doc.md) — the panel layout, and the extension contract under it: `TomModule`, `PanelDescriptor`, `runTom(modules: [])` ([flows](technical/flows.md#panels-are-registered-never-hardcoded)); `window_manager` for the title and the minimum size. The built-in panels are registered by a `CoreModule` and are placeholders until the four items below replace them — which is a change to that list and to nothing else
- [x] [Home](product/home/doc.md) — open a folder, recent spaces, the not-a-repository error; `file_selector`. **Not** `shared_preferences`: it is a Flutter plugin and settings belong to `tom_infra`, which is pure Dart, so the capability is one JSON file in the platform's application-support folder ([dependencies](technical/dependencies.md)). Clone by URL is still M3, and the button is on screen disabled rather than absent
- [x] [File tree](product/navigation/file-tree/doc.md) — `dart:io` directory listing + `path`, no new package. The listing was already there (`SpaceRepository.entries`, `.git/` never descended into), so this is the panel: the **space session** arrives with it ([Decision 9](technical/decisions/009-space-session-is-single-source-of-truth.md)) — Home writes the space it opened there instead of into a state of its own, the window reads *that* to decide between Home and the shell, and the tree derives from it with `select` so opening a document does not send the folder back to the disk. It shows every file the space holds and opens only markdown; the top bar and the status bar say which space and which document, and the search field above the tree is on screen disabled with its M2 chip
- [x] [Markdown preview](product/editor/markdown-preview/doc.md) — `markdown` (AST), `flutter_markdown_plus` (inline rendering), `re_highlight` (code highlighting). Spike B's parser became the `markdown_parser` capability in `tom_infra`: text in, **spans out**, so no package node reaches the domain and `Block` is finally code. The panel renders **one container per block**, which is what M2's rendered diff needs, and link reference definitions travel with the document so a block still resolves `[text][ref]` on its own. Two things the rules ask for and this does not do yet, both waiting on the same control: **preview-only reading mode** and its more generous 660/16 measure need the Source · Split · Preview bar, which arrives with source mode below. **An external link does not open a browser** — that needs a plugin, and taking one is a decision, not an omission
- [ ] [Source-mode editing](product/editor/source-mode/doc.md) — includes saving to disk; `re_editor` (Spike A)

**M1 — Essential Git**

All four run Git through the system binary via `dart:io Process` behind a `GitClient` contract ([Decision 2](technical/decisions/002-git-via-system-binary.md)) — no new package.

- [ ] [Commit](product/git-workflow/commit/doc.md)
- [ ] [Push / pull](product/git-workflow/push-pull/doc.md)
- [ ] [Branch switch](product/git-workflow/branch-switch/doc.md)
- [ ] [File history](product/git-workflow/file-history/doc.md)

**M2 — The differentiator**

- [ ] [Rendered diff](product/diff/rendered-diff/doc.md) — `diff_match_patch` or `diffutil_dart` for block alignment, on top of Spike B's `Block` shape
- [ ] [Branch / commit diff](product/diff/branch-diff/doc.md) — same diff packages, over `git show`
- [ ] [Full-text search](product/search/full-text-search/doc.md) — `sqlite3` + `sqlite3_flutter_libs` (FTS5)

**M3 — Launch polish**

- [ ] [Wikilinks](product/wikilinks/doc.md) — custom inline syntax over the existing `markdown` pipeline, no new package
- [ ] [Formatting shortcuts](product/editor/formatting-shortcuts/doc.md) — `re_editor`'s text-manipulation API, no new package
- [ ] [Export](product/export/doc.md) — PDF/HTML; package not yet chosen — [Decision 13](technical/decisions/013-stack-is-flutter-and-dart.md) notes it's a separate problem in Flutter, budget for it
- [ ] [Home](product/home/doc.md) — clone by URL; `dart:io Process` (`git clone`) with progress reporting
- [ ] Packaging: Windows (msix), macOS (dmg), Linux (AppImage/deb) — tooling not yet chosen *(distribution, not a product)*. The Mac App Store is **out**, and now explicitly: the app cannot be sandboxed and drive the user's own git ([Decision 20](technical/decisions/020-the-macos-app-is-not-sandboxed.md))
- [ ] Landing page + a polished README + a GIF of the rendered diff *(marketing, not a product)*

### Phase 2 — Traction

Backlog, unscoped: assisted conflict resolution, section blame, multiple open spaces, an example space repo for onboarding, themes.

### Phase 3 — Mobile

Mobile is a committed direction, not a maybe — but it comes **after** 1.0. It is not a port for its own sake: writing documentation needs a repository, markdown and git, not a development environment, and the people who read and approve documentation are rarely at a desk when they do it. Desktop stays the reference platform: the panel layout, the Git-CLI infrastructure and the MVP scope are all unchanged by it. The cost is bounded because six of the seven packages are pure Dart by construction ([Decision 14](technical/decisions/014-each-layer-is-its-own-package.md)), so mobile means new infrastructure implementations plus a new set of widgets, not a refactor — the state package is already shared. Each mobile screen is drawn from the job, not the desktop layout, and lives beside its desktop counterpart's product ([products/README.md](product/README.md)).

Two things must be resolved before Phase 3 starts:

- [ ] **Git without a system binary.** iOS and Android have no `git` CLI and no free filesystem — this is exactly the trigger [Decision 2](technical/decisions/002-git-via-system-binary.md) names for embedding `libgit2` via FFI.
- [ ] **Editing on touch.** `re_editor` is desktop-oriented ([dependencies](technical/dependencies.md)); source mode on a phone is an open design question, not just a port.

## Goals

Three, in this order — the ordering is what makes the plan honest: goals 1 and 2 are met by building well, entirely within the maintainer's control; goal 3 is not, so it carries no date.

1. **A tool worth using every day.** The scope comes from problems the maintainer hits directly — documentation kept as markdown in a repository, a diff that shows syntax instead of the document, colleagues who would read and approve that documentation if reaching it did not require a terminal. Nothing in the MVP is speculative.
2. **A demonstration of how software can be built.** The architecture notes, the decision records and the code patterns are as thorough as they are on purpose: a pure Dart core with framework independence proved by `dart test`, a decision file behind every architectural commitment, documentation updated in the same pull request as the behaviour it describes. If TOM never has a second user, this part still succeeded.
3. **Revenue, eventually, and only if earned.** [Decision 4](technical/decisions/004-business-model-is-open-core.md) gates anything commercial on genuine signals of team demand and keeps the free tier whole regardless.

Feedback comes from use, not from research. The maintainer is the first user and this repository is the first space TOM opens, so anything awkward shows up within a day of shipping it. Beyond that, the repository is public: whoever clones it, uses it and reports what breaks is a slower signal than a study, but it is a real one.

## Open questions

- [ ] Binary signing (Windows/macOS certificate cost) — needed for launch, or later?
- [ ] PDF/HTML export package — not yet chosen (M3, [Decision 13](technical/decisions/013-stack-is-flutter-and-dart.md))
- [ ] Packaging tooling per platform: msix / dmg / AppImage / deb — not yet chosen (M3)
- [ ] **macOS profile and release builds are blocked** by a `flutter_tools` 3.44.5 / Xcode 27 incompatibility: the tool verifies the engine framework with `lipo <file> -verify_arch arm64 x86_64`, and Xcode 27's `lipo` refuses more than one architecture there. Debug builds are unaffected. Blocks M3 packaging and any release-mode measurement; found during Spike A ([Decision 18](technical/decisions/018-source-mode-uses-re-editor.md))

---

*See also: [product/](product/README.md) · [technical/](technical/README.md) · [about.md](about.md)*
