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

- [x] **Spike A — Editor.** ✅ **`re_editor` carries source mode** — [Decision 18](technical/decisions/018-source-mode-uses-re-editor.md). Decided by measurement against the `TextField` fallback on the same machine and document, and it holds at ten times the file size the spike asked for. What the package does *not* ship — the find panel and the selection toolbar — is ours to draw.
- [x] **Spike B — The `markdown` AST.** ✅ **The package carries it** — [Decision 19](technical/decisions/019-blocks-come-from-the-markdown-package.md). A block is a span, its text and its kind, top level, with no stable identity — so the diff aligns by position and similarity. Footnotes are the one construct that does not render in isolation, and that is M2's problem with a failing case waiting.

### Phase 1 — MVP

**Goal:** publicly demonstrate (HN / Reddit / Discord) that "rendered diff + a comfortable Git workflow" solves a real pain — the minimum slice a developer can try on a real repo in five minutes. Each item is a product: what it must do lives in its `doc.md` under [product/](product/README.md), not here — this only tracks order, status, and which package builds it. See [the dependency stack](technical/stack/README.md) for the full stack and license per package.

**M0 — Foundation**

- [x] [Workspace](product/workspace/README.md) — the panel layout and the extension contract under it: `TomModule`, `PanelDescriptor`, `runTom(modules: [])` ([runtime](technical/runtime/composition.md)); `window_manager` for the title and the minimum size. The built-in panels are registered by `CoreModuleImpl` through the same path as a stranger's, and the shell names none of them
- [x] [Home](product/home/README.md) — `file_selector` for the folder picker; recent spaces through the `Settings` capability, one JSON file in the platform's application-support folder. **Not** `shared_preferences`: it is a Flutter plugin and settings belong to `tom_infra`, which is pure Dart ([stack](technical/stack/platform.md)). Clone by URL is still M3, and its button is on screen disabled rather than absent
- [x] [File tree](product/navigation/file-tree/README.md) — `dart:io` directory listing + `path`, no new package. The **space session** arrives with it ([Decision 9](technical/decisions/009-space-session-is-single-source-of-truth.md)): Home writes the space it opened there, and the window and every panel read it. The search field above the tree is on screen disabled with its M2 chip until full-text search lands
- [x] [Markdown preview](product/editor/markdown-preview/doc.md) — `markdown` (AST) as the `markdown_parser` capability in `tom_infra`, text in and **spans out** so no package node reaches the domain; `flutter_markdown_plus` for inline rendering; `re_highlight` for code. The panel renders **one container per block**, which is what the rendered diff decorates. **An external link does not open a browser** — that needs a plugin, and taking one is a decision, not an omission
- [x] [Source-mode editing](product/editor/source-mode/doc.md) — `re_editor` (Spike A), and with it the **mode bar**: Source · Split · Preview is chrome the shell draws, and which panels a mode includes is the panel's answer through `PanelDescriptor.modes`, so [Decision 12](technical/decisions/012-shell-is-extensible-via-compile-time-modules.md) survives the first feature that had to hide a panel. There is one buffer, and the preview renders it rather than the disk. The find panel and the selection toolbar Spike A left to us are not drawn yet

**M1 — Essential Git**

All four run Git through the system binary via `dart:io Process` behind a `GitClient` contract ([Decision 2](technical/decisions/002-git-via-system-binary.md)) — no new package.

- [x] [Commit](product/git-workflow/commit/README.md) — `ReadGitStatusUseCase`, `StageChangesUseCase` and `CommitChangesUseCase` over `GitRepository`, plus the changes panel in the aside, registered like every other panel. **What git said lives on the space session** ([Decision 9](technical/decisions/009-space-session-is-single-source-of-truth.md)), so the panel's list and the status bar's branch and counts come from one reading, re-read after every operation rather than patched. The list is the **repository's**, not the space's, since a commit records the index. Fetch, Push and the branch control belong to the two items below
- [x] [Push / pull](product/git-workflow/push-pull/README.md) — `FetchRemoteUseCase`, `PullRemoteUseCase` and `PushRemoteUseCase`, three because the product says three: **no combined Sync**, and nothing on a timer. `RemoteNotifier` reads no git of its own and ends every action in the changes panel's refresh, so the window keeps one source of truth about the repository. `GitPushRejected` is its own state, and **Pull is not a fourth button** — it is the remedy inside the rejection. Two things the mock draws and this does not: the **"YOUR COMMITS" list** under the rejection needs `history()`, and a **pull that conflicts** has no screen yet (Phase 2)
- [x] [Branch switch](product/git-workflow/branch-switch/doc.md) — `ListBranchesUseCase` and `SwitchBranchUseCase` (switch *and* create), plus the first **non-modal surface in the app**: a popover anchored to the control in the top bar, not a route and not a dialog, which is the pattern every later one follows ([Decision 6](technical/decisions/006-no-navigation-package.md) keeps `Navigator` for dialogs). A switch rewrites the working tree, so it ends by re-reading the status, the folder and the open buffer. The block on unsaved work is the buffer's only: a working tree git would overwrite is git's own refusal, reported and not prevented
- [x] [File history](product/git-workflow/file-history/doc.md) — `ReadFileHistoryUseCase` and `ReadVersionUseCase`, and the aside's second panel, **scoped to the open document, not the repository**. Opening an entry renders that version in the preview, preview only, with the way back on the bar above it and the chosen mode kept for the return. It draws no diff against the version on disk — that is the branch / commit diff below — and there is no repository-wide log

**M2 — The differentiator**

- [x] [Rendered diff](product/diff/rendered-diff/README.md) — `diffutil_dart` behind the new `TextDiffer` capability ([Decision 27](technical/decisions/027-blocks-are-aligned-by-myers-and-paired-by-words.md)); `diff_match_patch` was the alternative and does not resolve on Dart 3. `BlockDifferService` aligns by position and pairs by words, since blocks have no identity, and the decoration is **on the preview**'s own block container, not a second screen. **What is compared is the buffer** against `HEAD`, read with `git show`; a document git has never seen is every block added. Move detection is off. It shipped ahead of its board, which is the case [rule 13](../AGENTS.md) now prevents; the boards exist and are exported
- [x] [Branch / commit diff](product/diff/branch-diff/doc.md) — the same `BlockDifferService` against another revision, which `DiffDocumentUseCase` already took as an argument: **no new algorithm and no new capability**, so what this item is really made of is the vocabulary and the surface. `RevisionValueObject` is the domain's name for what can be compared against — a branch or a commit, carried whole rather than as the string git resolves, because the control names a commit's sha and age and a sha alone would need a second lookup. It lives on the session as `comparingAgainst`, beside `readingVersion` and for the same reason: the preview builds the diff against it and the bar above the document says what it is. **`CompareNotifier` asks git nothing** — the branches are the switcher's reading and the commits are the history panel's, so the list cannot disagree with the control beside it or the panel under it, and that is the same rule push/pull already follows. The preview *listens* to the base rather than watching it, so another base is the same text with other marks: nothing is parsed again and the pane never goes back to "reading it". **Comparing is reading** — nothing is checked out and the document stays the working copy. A past version opened from the history is now comparable too, which closes the one thing the rendered diff deliberately left open: by default the past is undecorated, and with a base chosen it is two commits against each other. Two traps paid for. The popover hangs from the control's **right** edge, because the control sits at the right of the bar and anchoring it left puts it off the window — a widget test that mounted the control anywhere else was what found it. And the surface reads the two lists *when it opens*, so on the first frame it has neither: an empty list with nothing typed now says **"Asking git…"** rather than "Nothing by that name.", which is a different sentence and was the wrong one — the end-to-end run is what caught it, because a widget test's container answers before the frame is drawn
- [x] [Full-text search](product/search/full-text-search/README.md) — `sqlite3` + `sqlite3_flutter_libs` behind the new `search_index` capability, one FTS5 table **kept in memory**. The index is a cache over the `.md` files and is rebuilt whenever a space opens, so a copy on disk would be written and never read — and a database that does not outlive the session cannot go stale, cannot be half-written and has no schema to migrate. What it files is the *file tree's* listing, so `.git/` is outside it by the rule that was already there, and a file that cannot be read costs that file rather than the search. **What somebody types is not a query language**: the words are taken out of it and every other character is punctuation, the last word may still be half-typed, and that is what keeps FTS5's own syntax — `AND`, `"`, `*` — out of reach of the keyboard. The box is above the tree and the results are in the aside, one `SearchNotifier` for both because they are one conversation; typing while the index is still building is kept and asked the moment there is something to ask. **The order the hits arrive in is the ranking** — no score crosses the contract — and the excerpt is `snippet()`'s, with the panel marking the words that were typed rather than the index reporting them. Two things it deliberately does not do: nothing is written to disk, and nothing watches the folder — a document changed outside TOM is filed again when it is saved here or when the space is reopened

**M3 — Launch polish**

- [ ] [Wikilinks](product/wikilinks/doc.md) — custom inline syntax over the existing `markdown` pipeline, no new package
- [ ] [Formatting shortcuts](product/editor/formatting-shortcuts/doc.md) — `re_editor`'s text-manipulation API, no new package
- [ ] [Export](product/export/doc.md) — PDF/HTML; package not yet chosen — [Decision 13](technical/decisions/013-stack-is-flutter-and-dart.md) notes it's a separate problem in Flutter, budget for it
- [ ] [Home](product/home/cloning/doc.md) — clone by URL; `dart:io Process` (`git clone`) with progress reporting
- [ ] Packaging: Windows (msix), macOS (dmg), Linux (AppImage/deb) — tooling not yet chosen *(distribution, not a product)*. The Mac App Store is **out**: the app cannot be sandboxed and drive the user's own git ([Decision 20](technical/decisions/020-the-macos-app-is-not-sandboxed.md))
- [ ] Landing page + a polished README + a GIF of the rendered diff *(marketing, not a product)*

### Phase 2 — Traction

Backlog, unscoped: assisted conflict resolution, section blame, multiple open spaces, an example space repo for onboarding, themes.

### Phase 3 — Mobile

Mobile is a committed direction, not a maybe — but it comes **after** 1.0. Writing documentation needs a repository, markdown and git, not a development environment, and the people who read and approve documentation are rarely at a desk when they do it. Desktop stays the reference platform: the panel layout, the Git-CLI infrastructure and the MVP scope are unchanged by it. The cost is bounded because six of the seven packages are pure Dart by construction ([Decision 14](technical/decisions/014-each-layer-is-its-own-package.md)): mobile means new infrastructure implementations plus a new set of widgets, not a refactor. Each mobile screen is drawn from the job, not the desktop layout, and lives beside its desktop counterpart's product ([product/README.md](product/README.md)).

Two things must be resolved before Phase 3 starts:

- [ ] **Git without a system binary.** iOS and Android have no `git` CLI and no free filesystem — exactly the trigger [Decision 2](technical/decisions/002-git-via-system-binary.md) names for embedding `libgit2` via FFI.
- [ ] **Editing on touch.** `re_editor` is desktop-oriented ([stack](technical/stack/editor.md)); source mode on a phone is an open design question, not just a port.

## Goals

Three, in this order — goals 1 and 2 are met by building well, entirely within the maintainer's control; goal 3 is not, so it carries no date.

1. **A tool worth using every day.** The scope comes from problems the maintainer hits directly — documentation kept as markdown in a repository, a diff that shows syntax instead of the document, colleagues who would read and approve that documentation if reaching it did not require a terminal. Nothing in the MVP is speculative.
2. **A demonstration of how software can be built.** A pure Dart core with framework independence proved by `dart test`, a decision file behind every architectural commitment, documentation updated in the same pull request as the behaviour it describes. If TOM never has a second user, this part still succeeded.
3. **Revenue, eventually, and only if earned.** [Decision 4](technical/decisions/004-business-model-is-open-core.md) gates anything commercial on genuine signals of team demand and keeps the free tier whole regardless.

Feedback comes from use, not from research. The maintainer is the first user and this repository is the first space TOM opens, so anything awkward shows up within a day of shipping it. Beyond that the repository is public: whoever clones it and reports what breaks is a slower signal than a study, but a real one.

## Open questions

- [ ] Binary signing (Windows/macOS certificate cost) — needed for launch, or later?
- [ ] PDF/HTML export package — not yet chosen (M3, [Decision 13](technical/decisions/013-stack-is-flutter-and-dart.md))
- [ ] Packaging tooling per platform: msix / dmg / AppImage / deb — not yet chosen (M3)
- [ ] **macOS profile and release builds are blocked** by a `flutter_tools` 3.44.5 / Xcode 27 incompatibility in the tool's `lipo` check of the engine framework; debug builds are unaffected. Blocks M3 packaging and any release-mode measurement; found during Spike A ([Decision 18](technical/decisions/018-source-mode-uses-re-editor.md))

---

*See also: [product/](product/README.md) · [technical/](technical/README.md) · [about.md](about.md)*
