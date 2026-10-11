# Roadmap

## Phases

```
Phase 0 · Spikes          The two technical unknowns: the editor and the AST
Phase 1 · MVP (M0–M3)     Build in public; launch with a GIF of the rendered diff
Phase 2 · Traction        Section blame, resolving a whole list at once
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
- [x] [Home](product/home/README.md) — `file_selector` for the folder picker; recent spaces through the `Settings` capability, one JSON file in the platform's application-support folder. **Not** `shared_preferences`: it is a Flutter plugin and settings belong to `tom_infra`, which is pure Dart ([stack](technical/stack/platform.md)). Clone by URL arrived with M3, below
- [x] [File tree](product/navigation/file-tree/README.md) — `dart:io` directory listing + `path`, no new package. The **space session** arrives with it ([Decision 9](technical/decisions/009-space-session-is-single-source-of-truth.md)): Home writes the space it opened there, and the window and every panel read it
- [x] [Markdown preview](product/editor/markdown-preview/doc.md) — `markdown` (AST) as the `markdown_parser` capability in `tom_infra`, text in and **spans out** so no package node reaches the domain; `flutter_markdown_plus` for inline rendering; `re_highlight` for code. The panel renders **one container per block**, which is what the rendered diff decorates. An external link opens in the browser through the `desktop_shell` capability, with no plugin
- [x] [Source-mode editing](product/editor/source-mode/doc.md) — `re_editor` (Spike A), and with it the **mode bar**: Source · Split · Preview is chrome the shell draws, and which panels a mode includes is the panel's answer through `PanelDescriptor.modes`, so [Decision 12](technical/decisions/012-shell-is-extensible-via-compile-time-modules.md) survives the first feature that had to hide a panel. There is one buffer, and the preview renders it rather than the disk. Of the two things Spike A left to us, the find panel became `This file` in [search](product/search/full-text-search/README.md), and the selection toolbar is undecided — neither drawn nor struck

**M1 — Essential Git**

All four run Git through the system binary via `dart:io Process` behind a `GitClient` contract ([Decision 2](technical/decisions/002-git-via-system-binary.md)) — no new package.

- [x] [Commit](product/git-workflow/commit/README.md) — `ReadGitStatusUseCase`, `StageChangesUseCase` and `CommitChangesUseCase` over `GitRepository`, plus the changes panel in the aside, registered like every other panel. **What git said lives on the space session** ([Decision 9](technical/decisions/009-space-session-is-single-source-of-truth.md)), so the panel's list and the status bar's branch and counts come from one reading, re-read after every operation rather than patched. The list is the **repository's**, not the space's, since a commit records the index. Fetch, Push and the branch control belong to the two items below
- [x] [Push / pull](product/git-workflow/push-pull/README.md) — `FetchRemoteUseCase`, `PullRemoteUseCase` and `PushRemoteUseCase`, three because the product says three: **no combined Sync**, and nothing on a timer. `RemoteNotifier` reads no git of its own and ends every action in the changes panel's refresh, so the window keeps one source of truth about the repository. `GitPushRejected` is its own state, and `Pull` is a button of its own as well as the remedy inside the rejection ([the controls](product/git-workflow/push-pull/the-controls/doc.md)). What the rejection does not draw is the **"YOUR COMMITS" list** under it, which needs `history()` (Phase 2); a pull that conflicts got its screens in M3, below
- [x] [Branch switch](product/git-workflow/branch-switch/doc.md) — `ListBranchesUseCase` and `SwitchBranchUseCase` (switch *and* create), plus the first **non-modal surface in the app**: a popover anchored to the control in the top bar, not a route and not a dialog, which is the pattern every later one follows ([Decision 6](technical/decisions/006-no-navigation-package.md) keeps `Navigator` for dialogs). A switch rewrites the working tree, so it ends by re-reading the status, the folder and the open buffer. The block on unsaved work is the buffer's only: a working tree git would overwrite is git's own refusal, reported and not prevented
- [x] [File history](product/git-workflow/file-history/doc.md) — `ReadFileHistoryUseCase` and `ReadVersionUseCase`, and the aside's second panel, **scoped to the open document, not the repository**. Opening an entry renders that version in the preview, preview only, with the way back on the bar above it and the chosen mode kept for the return. It draws no diff against the version on disk — that is the branch / commit diff below — and there is no repository-wide log

**M2 — The differentiator**

- [x] [Rendered diff](product/diff/rendered-diff/README.md) — `diffutil_dart` behind the new `TextDiffer` capability ([Decision 27](technical/decisions/027-blocks-are-aligned-by-myers-and-paired-by-words.md)); `diff_match_patch` was the alternative and does not resolve on Dart 3. `BlockDifferService` aligns by position and pairs by words, since blocks have no identity, and the decoration is **on the preview**'s own block container, not a second screen. **What is compared is the buffer** against `HEAD`, read with `git show`; a document git has never seen is every block added. Move detection is off. It shipped ahead of its board, which is the case [rule 13](../AGENTS.md) now prevents; the boards exist and are exported
- [x] [Branch / commit diff](product/diff/branch-diff/doc.md) — the same `BlockDifferService` against another revision, which `DiffDocumentUseCase` already took as an argument: **no new algorithm and no new capability**, so what this item is really made of is the vocabulary and the surface. `RevisionValueObject` is the domain's name for what can be compared against — a branch or a commit, carried whole rather than as the string git resolves, because the control names a commit's sha and age and a sha alone would need a second lookup. It lives on the session as `comparingAgainst`, beside `readingVersion` and for the same reason: the preview builds the diff against it and the bar above the document says what it is. **`CompareNotifier` asks git nothing** — the branches are the switcher's reading and the commits are the history panel's, so the list cannot disagree with the control beside it or the panel under it, and that is the same rule push/pull already follows. The preview *listens* to the base rather than watching it, so another base is the same text with other marks: nothing is parsed again and the pane never goes back to "reading it". **Comparing is reading** — nothing is checked out and the document stays the working copy. A past version opened from the history is now comparable too, which closes the one thing the rendered diff deliberately left open: by default the past is undecorated, and with a base chosen it is two commits against each other. Two traps paid for. The popover hangs from the control's **right** edge, because the control sits at the right of the bar and anchoring it left puts it off the window — a widget test that mounted the control anywhere else was what found it. And the surface reads the two lists *when it opens*, so on the first frame it has neither: an empty list with nothing typed now says **"Asking git…"** rather than "Nothing by that name.", which is a different sentence and was the wrong one — the end-to-end run is what caught it, because a widget test's container answers before the frame is drawn. **Revised 2026-10-08:** the base is no longer chosen — it is the branch the current one came from, recorded in git config when TOM starts a branch and deduced otherwise — and the `Diff` chip only turns the marks off and on; `RevisionValueObject`, `CompareNotifier` and the popover are gone, and a past version is never compared
- [x] [Full-text search](product/search/full-text-search/README.md) — `sqlite3` + `sqlite3_flutter_libs` behind the new `search_index` capability, one FTS5 table **kept in memory**. The index is a cache over the `.md` files and is rebuilt whenever a space opens, so a copy on disk would be written and never read — and a database that does not outlive the session cannot go stale, cannot be half-written and has no schema to migrate. What it files is the *file tree's* listing, so `.git/` is outside it by the rule that was already there, and a file that cannot be read costs that file rather than the search. **What somebody types is not a query language**: the words are taken out of it and every other character is punctuation, the last word may still be half-typed, and that is what keeps FTS5's own syntax — `AND`, `"`, `*` — out of reach of the keyboard. The box is above the tree and the results take the tree's place under it, one `SearchNotifier` for both because they are one conversation; typing while the index is still building is kept and asked the moment there is something to ask. **The order the hits arrive in is the ranking** — no score crosses the contract — and the excerpt is `snippet()`'s, with the panel marking the words that were typed rather than the index reporting them. Two things it deliberately does not do: nothing is written to disk, and nothing watches the folder — a document changed outside TOM is filed again when it is saved here or when the space is reopened

**M3 — Launch polish**

- [x] [Pull conflicts, and choosing a side](product/git-workflow/push-pull/when-a-pull-conflicts/doc.md) — a pull that stops in the middle is named, readable and resolvable rather than silent. It brought **killer feature nº 4 forward from Phase 2**, and what paid for that is a simplification: a choice rewrites the buffer from the markers git already wrote, so nothing reads the index's three stages and no resolution model exists. `merge --abort`, `MERGE_HEAD` and `MERGE_MSG` are the only new git; the scan is a domain service beside `BlockDifferService`, and the preview draws the two sides over the block containers it already has. **The conflict is the repository's state, not the session's** — `SpaceSessionState.isConflicted(path)` is the gate both panes go through, so closing the window and opening it again finds the same band, and a `<<<<<<<` typed into a document *about* merging stays text. `StageChangesUseCase` refuses a document still holding a marker by reading its **text**, never git's `u` record, which is what keeps the marker out of a commit. What stays in Phase 2 is resolving a whole list without opening each document
- [x] [Wikilinks](product/wikilinks/doc.md) — custom inline syntax over the existing `markdown` pipeline, no new package. `HeadingAnchorService` names headings GitHub's way, and the preview walks to the one an `#anchor` names
- [x] [Formatting shortcuts](product/editor/formatting-shortcuts/doc.md) — `MarkdownFormatterService` in the domain, applied to the buffer rather than through `re_editor`; no new package. Undo and redo reach `re_editor`'s own history, so the buttons and ⌘Z walk one stack. The buttons and GitHub's keys are built
- [x] [Export](product/export/doc.md) — PDF/HTML: `pdf` for a paginated A4 and HTML from the same AST ([Decision 30](technical/decisions/030-export-renders-the-preview-not-the-file.md)), asked for from the tab's menu
- [x] [Home](product/home/cloning/doc.md) — clone by URL; `dart:io Process` (`git clone`) with progress reporting
- [x] [Pull request](product/git-workflow/pull-request/README.md) — added on the maintainer's ask: a draft per branch outside the space ([Decision 33](technical/decisions/033-a-pull-request-draft-is-a-document-outside-the-space.md)), created through `gh` where the computer holds a GitHub login and handed to the browser's compare page where it does not ([Decision 35](technical/decisions/035-github-is-reached-through-the-gh-cli.md))
- [x] [Tabs](product/editor/tabs/doc.md) — `tabs` and `previewTab` on the session; the editor keeps one buffer, and a dirty tab left behind is held in `HeldBuffersNotifier` until it is chosen again
- [x] [Preferences](product/preferences/README.md) — a popover under the gear, each choice applied as it is pressed and kept by the `Settings` capability; `preferences.json` opens in a tab, and saving it applies it
- [x] Localisation — English and Português (Brasil) through `flutter gen-l10n`, the language a preference ([Decision 34](technical/decisions/034-the-interface-is-localised-with-gen-l10n.md), [stack](technical/stack/localisation.md))
- [x] [The account](product/workspace/the-account/doc.md) — who commits and what they may do on GitHub, read from the logins the computer already holds; two capabilities, `credentials` and `github_api`, and no token kept ([Decision 35](technical/decisions/035-github-is-reached-through-the-gh-cli.md))
- [x] [The Commands panel](product/workspace/commands/doc.md) — every process TOM starts, written down through a `CommandLog` port in `tom_core` and shown in a region under the document ([Decision 36](technical/decisions/036-every-command-is-written-down.md))
- [x] [The Terminal tab](product/workspace/terminal/doc.md) — the person's own shell in a pty beside the commands: the `pseudo_terminal` capability, `pty2` and `xterm` ([Decision 37](technical/decisions/037-the-terminal-is-the-persons-own-shell-in-a-pty.md))
- [x] [A folder outside any repository](product/workspace/without-a-repository/doc.md) — it opens; `SpaceEntity.repositoryRoot` is nullable and every git reader returns early on `hasRepository`
- [x] [A new document](product/navigation/file-tree/new-document/doc.md), [the explorer's menu](product/navigation/file-tree/explorer-menu/doc.md) and [the git menu](product/git-workflow/git-menu/doc.md) — an exclusive create in `Filesystem`, and the `desktop_shell` capability for Finder and the terminal
- [x] [Putting one file back](product/git-workflow/commit/the-changes-list/doc.md) — `DiscardChangeUseCase`, from the row of the changes list, asking first
- [x] [Opening a change](product/git-workflow/commit/opening-a-change/doc.md) — every row of the changes list opens, whatever the file is and wherever in the repository it sits
- [ ] [Git approvals](product/git-workflow/approvals/doc.md) — commands wait at a `CommandGate` port before they run ([Decision 38](technical/decisions/038-a-command-waits-at-a-gate-in-tom-core.md), draft). The layers under the interface are built; left are the widgets, one plan for opening a space, the Commands panel on Home, a tab each for the two settings files, and its scenarios
- [x] [About and the update check](product/about/doc.md) — the About dialog, and an opt-in check over `dart:io HttpClient` against GitHub's latest release, in the `app_updates/` capability. `Update and restart`, the download and `Restart now` are not in the MVP: they wait on code signing and a per-platform updater
- [ ] Packaging: Windows (msix), macOS (dmg), Linux (AppImage/deb) — `flutter_distributor`, unsigned at launch *(distribution, not a product)*. The Mac App Store is **out**: the app cannot be sandboxed and drive the user's own git ([Decision 20](technical/decisions/020-the-macos-app-is-not-sandboxed.md))
- [ ] Landing page + a polished README + a GIF of the rendered diff *(marketing, not a product)* — with a real screenshot of the app, taken at launch

**M3 — alignment**

The docs, the app and the Penpot file were read against each other and every disagreement was decided, one at a time (2026-10-10). These are what the decisions turn into, in the order they are taken. An item is done with its unit tests, an integration test against the real dependency, and an end-to-end step that presses the control and shows the result ([testing](technical/conventions/testing.md)); a board is approved in Penpot before its code and exported before the merge.

*The texts tell the truth*

- [ ] The docs, `AGENTS.md` and the skills say what the app does: one status vocabulary, no struck text, decisions 34–37 accepted, the process chapter read from the code

*Work can be lost*

- [x] A save asks the disk first, and a document changed underneath an edit offers `Keep mine` / `Reload` — which is what replaces a watcher ([Decision 10](technical/decisions/010-watcher-and-git-cooperate-by-protocol.md), revised)
- [x] Closing the window with unsaved tabs asks the leaving question
- [x] Any conflict-marker line refuses the stage, only while git says the file is conflicted — a file beside the space included
- [x] The conflict scanner reads the `diff3` / `zdiff3` marker
- [x] `Discard all changes` is refused in the use case mid-merge and before the first commit
- [x] Deleting a file git never committed checks that at the moment of deleting
- [x] One git client per folder, kept; a save follows a symbolic link and keeps the file's mode; the search index is written in a transaction

*The app catches up*

- [x] It says what happened: a band after a commit, `Published N commits…` after a push, `Exporting…` while an export runs
- [x] Each refusal says why: a conflict marker names its document, `Not on a branch`, a branch name starting with `-`, a protected branch (no `Try again`, `Pull request` offered), `No remote configured` read before any press, a git older than 2.41
- [x] A past version reads in `Split`, the modes kept, read-only
- [x] The formatting keys, GitHub's — link is ⌘⇧K, and ⌘K stays the search's
- [x] The tree opens any file, as the changes list does, and draws what is not a markdown document dimmer
- [x] Clicking an occurrence in the document goes to it
- [x] A drag on a closed column's gutter opens it
- [x] Enter creates the branch; ⌘Enter commits
- [x] File history follows a rename
- [x] The diff ignores line endings, and a document with Windows line endings is parsed into the same blocks
- [x] `Alert` writes an alert the preview renders: `> [!NOTE]` on one line, `> ` on the next, the caret there
- [x] Every link the `[[` offer writes resolves — a root document that shares its name included; a document whose name holds `#` or `|` is not offered; and nothing is offered inside indented code
- [x] An exported heading's id is the anchor the app follows
- [x] A run of tens of thousands of characters with no space is parsed without stalling the preview
- [x] A fenced block longer than a page ceiling — about twenty pages — exports to PDF, broken across pages
- [x] `Reload` files the search again, if it does not already
- [x] The pull request's base is pickable, if the panel lacks it
- [x] The tree sorts ignoring case and accents
- [x] A removed block's letter is `D`, in the gutter and in the preview
- [x] Taken out: the band while a pull runs, the active tab's right divider, the word `Unsaved` beside the dot, two dead widgets in `tom_ui`
- [ ] Every board drawn during the alignment checked against its widget

*Penpot catches up*

- [ ] The boards those items wait on, each drawn before its item starts: the `Keep mine` / `Reload` band, Home's three refusals, the `⇄` replace toggle, Home with the Commands panel, the `Discard all changes?` dialog, the push band, `Exporting…`, the protected-branch refusal, `D` across the diff and conflict boards, the `Text field` master without its floating label

*Then*

- [ ] Git approvals, above
- [ ] Coverage of what already existed: every control, rule and refusal with a step that shows it, and under each an integration test against the real git, disk or index ([what the suite proves today](technical/process/end-to-end-coverage.md))
- [ ] A three-platform test matrix, before packaging

### Phase 2 — Traction

Backlog, unscoped: section blame, resolving a list of conflicted documents without opening each, multiple open spaces, an example space repo for onboarding, themes.

- A command palette — after the MVP. ⌘K is the search's today, so it is not a free key

### Phase 3 — Mobile

Mobile is a committed direction, not a maybe — but it comes **after** 1.0. Writing documentation needs a repository, markdown and git, not a development environment, and the people who read and approve documentation are rarely at a desk when they do it. Desktop stays the reference platform: the panel layout, the Git-CLI infrastructure and the MVP scope are unchanged by it. The cost is bounded because every layer package is pure Dart by construction ([Decision 14](technical/decisions/014-each-layer-is-its-own-package.md)): mobile means new infrastructure implementations plus a new set of widgets, not a refactor. Each mobile screen is drawn from the job, not the desktop layout, and lives beside its desktop counterpart's product ([product/README.md](product/README.md)).

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

- [x] Binary signing — **none at launch**: the README says how to open an unsigned app (macOS: *Privacy & Security → Open Anyway*; Windows: SmartScreen's *More info → Run anyway*). Signing and notarising macOS needs the paid Apple Developer Program even outside the App Store, so it waits for traction. The maintainer's call, 2026-10-08
- [x] PDF/HTML export package — `pdf` for a paginated A4, HTML from the same AST ([Decision 30](technical/decisions/030-export-renders-the-preview-not-the-file.md))
- [x] Packaging tooling — **`flutter_distributor`**, one config for dmg, msix, AppImage and deb, local and in CI (licence to be checked when it is added, rule 1). The maintainer's call, 2026-10-08
- [ ] **macOS profile and release builds fail on a machine with Xcode 27** — a `flutter_tools` 3.44.5 incompatibility in the tool's `lipo` check of the engine framework; debug builds are unaffected, and CI's `Build (macOS)` job builds a release on the same Flutter ([ci.md](technical/process/ci.md)). Blocks a local release build and any release-mode measurement there; found during Spike A ([Decision 18](technical/decisions/018-source-mode-uses-re-editor.md))

---

*See also: [product/](product/README.md) · [technical/](technical/README.md) · [about.md](about.md)*
