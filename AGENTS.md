# AGENTS.md

Entry point for any AI agent working in this repository (platform-agnostic
by design — Claude Code, Codex, Cursor, or anything that reads this file).
Read before any task.

## What this project is

**TOM — Team-Oriented Markdown** *(binary: `tom`)* — a desktop Git client specialized in markdown documentation. Flutter Desktop (Windows/macOS/Linux), open source (MIT), open-core business model.

**Pitch:** "A GitHub Desktop for docs". The differentiator is the Git workflow as a first-class citizen (*rendered* markdown diff, branch/commit/push without ceremony) — NOT the editor, which is deliberately simple (source + preview, no WYSIWYG).

## Source of truth

`docs/` is split by audience, with `about.md` as the shared context above the fork and `roadmap.md` as the order things arrive in. **Before suggesting architecture, dependencies or scope, consult:**

- [`docs/about.md`](docs/about.md) — what the project *is*: the bet, principles, personas, killer features and **non-goals** (respect them!). Short by design; read it first.
- [`docs/product/`](docs/product/README.md) — **the source of truth for what each feature must do**, in non-technical language, one folder per feature holding its `doc.md`. Maintained by stakeholders, kept current as the app evolves. Check the relevant `doc.md` before implementing or changing a feature's behavior, and flag it if the code diverges from what's written there.
- [`docs/technical/`](docs/technical/README.md) — how it is built: `architecture.md` (the graph and what enforces it), then one folder per chapter — `conventions/` (the rules inside a package: structure, naming, errors, external dependencies, testing), `runtime/` (runtime behaviour), `domain/` (the model), `stack/` (dependencies with licenses), `process/` (setup, the CLI, CI, versioning, repository settings), and `decisions/` (ADRs — a new decision is a new file, changing one requires an explicit revision). Each folder's `README.md` is its index.
- [`docs/design/`](docs/design/README.md) — what it *looks like*, a chapter of its own: `visual-language/` (the sixteen colour roles), `brand/` (the identity), `components/` (the control set with the exact numbers), `foundations/`, `screens/` (every screen as a board exported from Penpot, both themes, one folder per page) and `tools/`. The Penpot file is the source, the export is the record.
- [`docs/roadmap.md`](docs/roadmap.md) — spikes, phases and milestones, in order — whatever is out of the MVP stays out. **There is no task queue and no spec folder**: work is picked from the roadmap, or from what the maintainer asks for directly.
- **Read selectively.** Consult only the files relevant to the task at hand; never load `docs/` wholesale. The index above exists so the right file can be picked without reading the rest.
- **The canonical form of a rule is the dartdoc of the code that implements it** — `docs/technical/` states the rule, the code shows it. When the two disagree, the code is right and the doc is a bug.

## Human gates

One checkpoint, named explicitly rather than implied. Everything else is agent work, autonomously — and **no process artefact is a prerequisite for doing the work**: there is no task to open, no spec to draft, no approval to wait for. What is asked for gets built.

| Transition | Who |
|---|---|
| Changing a doc under `docs/` | Human writes it or reviews it before merge. Agents may draft; a doc never merges on agent approval alone. |

The one thing that still applies to any change: if the request is ambiguous
enough that two readings produce different work, ask — don't improvise scope.

## Skills — load on the matching trigger

Operational procedures live in `.ai/skills/`, one folder per skill, each with a
`SKILL.md`. **They are not auto-discovered** — no agent loads them on its own,
so this table is what activates them. Check it before acting.

| Skill | Load it when | Covers |
|---|---|---|
| [`tom-code-review`](.ai/skills/tom-code-review/SKILL.md) | reviewing a diff, a branch or a PR; running `/code-review`, `/simplify` or `/security-review` here; the user says "review this", "does this follow the architecture", "is this ok to merge" — or you are about to open a PR and are reading your own branch | What the tooling already proves versus what only a reader can check — the layer graph, `Result` and the failure hierarchies, Freezed, typed paths, the capability contracts, the session and module patterns — package by package, the test layout, the docs that must move with the change, the general canon (Effective Dart, Clean Architecture, DDD per Decision 15, community conventions) and its precedence under the project's own choices, and which settled decisions are never a finding |
| [`tom-comments`](.ai/skills/tom-comments/SKILL.md) | writing a new class, method or library and reaching for a comment; judging in review whether a comment earns its lines; the user says "the comments are too long", "keep them cohesive", "trim this", or asks what belongs in a dartdoc — and before adding a paragraph to any existing dartdoc | The three shapes (the `library` line, the dartdoc, the why-comment inside a body), what is not a comment, the two exceptions that earn extra lines and the twelve-line ceiling on them, and a real before/after trim from this repository |
| [`tom-docs`](.ai/skills/tom-docs/SKILL.md) | adding or editing any file under `docs/`; writing or repairing a folder's `README.md` index; moving a doc or a whole chapter; reviewing the corpus for style; the user says "the docs are too wordy", "trim this doc", "no prose", "where does this belong" — and before adding a paragraph to `about.md`, `roadmap.md` or any chapter index | The four shapes (the opening, the rule, the table, the reason clause), what is not a shape, the three-line ceiling on the exception, one subject per file with the signals that a file is two, what an index may and may not hold, where a given sentence belongs, what moves in the same commit, and three real trims from this repository |
| [`tom-git-workflow`](.ai/skills/tom-git-workflow/SKILL.md) | committing, staging, writing a commit message, creating a branch, opening or merging a PR, cutting a release, applying a hotfix — or the user says "commit this", "push", "open a PR", "ship it", or asks which branch to target | Trunk-based on `main`, branch naming, Conventional Commits with the monorepo's scopes, squash policy, releases as tags, what differs in `tom-pro` |
| [`tom-pr-writer`](.ai/skills/tom-pr-writer/SKILL.md) | about to open a PR, "write the PR", "draft a PR description", finishing a branch, reviewing or rewriting an existing description, writing the squash commit message | Inspecting the real diff before writing, title = the Conventional Commit the squash will produce, the What/Why/Notes template |
| [`tom-design`](.ai/skills/tom-design/SKILL.md) | **before writing any widget, screen, panel, dialog, popover or control**; drawing, editing or reviewing a mock; "design this", "mock up a screen", "penpot", "draw the layout" | The Penpot file every piece of interface must exist in first, the component library every control comes from, the card each page is, and the export that puts each board in the repository |

How they are maintained, and why `tom-pro` inherits them by relative path
instead of copying: [`.ai/skills/README.md`](.ai/skills/README.md).

## Non-negotiable rules (summary of the decisions)

1. **MIT license** — NO AGPL/GPL dependency (no `appflowy_editor`). Check the license of every new package (Decision 1).
2. **Git through the system binary** (`Process.run`) behind contracts — do not suggest libgit2/FFI at this phase (Decision 2).
3. **No WYSIWYG** — the editor is source + preview (Decision 3).
4. **No `dartz`** — Result with native sealed classes, exhaustive switch, early return (Decision 5); rules in `docs/technical/conventions/errors.md`; the types live in `src/packages/core/lib/src/` and `src/packages/domain/lib/src/`. Inline try/catch mandatory in every use case.
5. **No navigation package** — plain `Navigator` for dialogs only (Decision 6).
6. **External dependencies isolated behind contracts** in infrastructure (Decision 7); Riverpod ONLY in presentation + bootstrap/di — no `Ref` in any other layer; constructor injection (`docs/technical/runtime/composition.md`).
7. **One package per layer** (Decision 14, revising 8): `src/packages/{core,domain,application,infra,data,presentation}` are pure Dart with NO Flutter in the pubspec. Flutter lives in the applications (`src/apps/{desktop,mobile}`) and in `src/packages/ui` — the look both applications draw, which depends on no package and wires nothing (Decision 26). A layer may depend only on the ones below it — the one exception being `infra` and `data`, two packages of one layer that depend on each other (Decision 24) — enforced by the pubspecs, by `depend_on_referenced_packages`/`implementation_imports` as errors, and by `src/test/integrity/architecture_test.dart`.
8. **Files are the truth** — never propose a database or state that is not rebuildable from the `.md` files on disk. The FTS5 index is a cache.
9. **Telemetry is opt-in** — observability behind a contract, no-op by default; no data leaves the user's machine (Decision 11).
10. **Extensible shell** — panels are ALWAYS registered through `TomModule`/`PanelDescriptor`, never hardcoded in the shell, including the built-in ones (Decision 12; `docs/technical/runtime/composition.md`).
11. **The public repo documents the free product only** — no tier catalogue, no pricing, no licensing mechanics, no reference to a private repository. Commercial modelling lives outside this repo (Decision 4).
12. **A space is a folder, not a repository** — `SpaceEntity` carries `root` and `repositoryRoot` separately; git runs against the repository, navigation and search stay in the folder.
13. **No user interface is written before it is designed** — every screen, panel, dialog, popover and control exists as a board on the Penpot file's `Screens: <subject>` page first, built from the library's components, and **both themes are exported into `docs/design/screens/desktop/<page>/` in the same commit**, beside the page's own PDF. A board nobody exported does not count as designed (skill: `tom-design`).
14. **Freezed is mandatory for immutable data** — entities, value objects with more than one field, presentation view-state, and sealed hierarchies; no hand-written `==`/`copyWith` once a class qualifies (Decision 16). Single-field identifier/path value objects (`BranchNameValueObject`, `CommitShaValueObject`…) are the one recommended exception — an `extension type` fits better there.

## Stack (summary — details in docs/technical/stack/)

Riverpod (codegen) + Freezed · `markdown` (AST) · `diff_match_patch` · `re_editor` (spike pending) · `sqlite3` + FTS5 · `watcher` · `window_manager` / `file_selector` · `dart:io Process` for Git. Why Dart rather than a web stack, and where Rust could still enter via FFI: Decision 13.

## Code structure

See `docs/technical/architecture.md` (source of truth) and `docs/technical/conventions/` for the rules inside a package. The Dart workspace lives under `src/`; run everything through `dart run tool/tom.dart <command>` from the repository root (`make` targets are one-line shortcuts over the same CLI, and `tool/` never calls back into `make`).

```
core ← domain ← application ← presentation
  ↑       ↑                        ↑
  └─── infra ⇄ data ─────────────  desktop · mobile
                                       ↑
                                      ui
```

`infra ⇄ data` is the one two-way edge, and it is deliberate: `infra` holds each capability's contract and failures, `data` the DTOs that cross them, so the two packages depend on each other and pub resolves the cycle ([Decision 24](docs/technical/decisions/024-a-capability-is-a-folder.md)). What `infra` never depends on is `domain`.

`core` holds `Result`, the `AppFailure` marker and the ports every layer needs — mechanism, never product vocabulary; `domain` holds entities, value objects, the sealed failure hierarchies (`GitFailure`, `DocumentFailure`, `SearchFailure`), repository contracts and BlockDiffer; `application` use cases; `infra` capability contracts *and* their implementations, one folder per capability holding the contract, its failures and a subfolder per implementation named after the dependency ([Decision 24](docs/technical/decisions/024-a-capability-is-a-folder.md): `git_client/dart_io/dart_io_git_client_impl.dart`); `data` the DTOs that cross those contracts, the data sources that obtain them, the parsers and the repository implementations ([Decision 25](docs/technical/decisions/025-a-repository-reads-through-a-data-source.md): a repository orchestrates and translates, a source obtains); `presentation` the space session and notifiers, pure Dart so it cannot reach a widget; `ui` the look both applications draw — colour roles, metrics, the brand marks and the shared components, depending on nothing ([Decision 26](docs/technical/decisions/026-the-look-is-a-package.md)); `apps/desktop` the composition root and this application's own screens.

## Conventions

- **Git workflow (branches, commits, PRs, releases): see the `tom-git-workflow` skill** in `.ai/skills/` — consult it before committing, branching, or opening a PR. Human-facing version: `CONTRIBUTING.md`.
- Conventional Commits + semantic versioning. Trunk-based: `feat/*` → PR into `main` (squash) → tag publishes. No `dev` branch. `main` is publishable; production is the most recent tag.
- **Incomplete work integrates behind a build-time feature flag**, never on a long-lived branch (`CONTRIBUTING.md`, "Feature flags"). Disabled = unreachable, and every flag has a removal target.
- Documentation updated in the same PR that changes behavior (dogfooding: this project exists for that)
- **If a PR changes a product's user-facing interface, it updates that screen's Penpot board and re-exports both themes in the same PR** (`docs/design/screens/desktop/<page>/`) — a board that no longer matches what shipped is worse than none, see [docs/product/README.md](docs/product/README.md) and rule 13
- A new architecture decision → a new file in `docs/technical/decisions/` following the existing format
- **All documentation and code in English** (identifiers, comments, docs)
- **A comment is two or three lines** — what the thing is, then why it is that way ([inside-a-package.md](docs/technical/conventions/inside-a-package.md)). Longer is an exception that earns itself: a rule with no other home, or a trap worth an afternoon

## Current status

**Phase 1 — MVP. M0, M1 and M2 are complete** — the rendered diff, the branch/commit diff and full-text search. Next on the roadmap: M3, the launch polish — wikilinks, formatting shortcuts, export, clone by URL, packaging (`docs/roadmap.md`). How each piece arrived is in git history and in the roadmap's own entries; this section holds only what a new session needs and neither of those says.

**What exists.** The graph is whole: a folder picked on Home reaches git through every layer and comes back as a `SpaceEntity`. `tom_infra` holds seven capability folders — `filesystem/`, `git_client/`, `settings/`, `platform_paths/`, `markdown_parser/`, `text_differ/`, `search_index/` — each a contract plus one implementation named after its dependency. `tom_data` fulfils `GitRepository`, `DocumentRepository`, `SpaceRepository`, `RecentSpacesRepository` and `SearchRepository`, plus the block reader and the block aligner ports. `tom_domain` carries the entities, value objects, the sealed failure hierarchies and the first domain service, `BlockDifferService`. `tom_application` is one use case per product action over a `UseCase` mixin that holds the standardised `try/catch`. `tom_presentation` is the space session ([Decision 9](docs/technical/decisions/009-space-session-is-single-source-of-truth.md)) plus one notifier per panel; `tom_ui` the look; `apps/desktop` the composition root, the shell, and `screens/<feature>/` mirroring `tom_presentation/lib/src/<feature>/`. Products shipped: workspace, Home, file tree, markdown preview, source mode with the mode bar, commit, fetch/push/pull, branch switch, file history, rendered diff, branch/commit diff, full-text search. Around 1,000 tests, and an end-to-end suite (`tom e2e`) of twenty-one scenarios in nine groups that drives the real app against fixtures it builds, a bare repository included.

**What the diff is compared against lives on the session**, as `comparingAgainst` beside `readingVersion`: `HEAD` unless somebody chose a `RevisionValueObject` (a branch or a commit, carried whole). `CompareNotifier` offers the choice and **reads no git of its own** — the branches are the switcher's reading and the commits are the history panel's — and the preview *listens* to the base rather than watching it, so another base re-marks the text already on screen instead of parsing it again.

**The search index is in memory, one per open space**, filled from the file tree's own listing when the space opens and never written to disk — a cache that cannot go stale because it does not outlive the session (`docs/technical/runtime/search.md`). A save re-files that one document; nothing watches the folder. What somebody types is words and separators, never a query language, so no character reaches FTS5's syntax; the order the hits come back in *is* the ranking, and the panel — not the index — marks the typed words inside `snippet()`'s excerpt. The box sits above the tree and the results are the aside's first panel, above the git column, with one `SearchNotifier` behind both. **That split is now a known divergence**: the settled arrangement is search whole in the left column, changes and history alone in the right (`docs/product/workspace/regions/doc.md`).

**Settled by the spikes** (Decisions 18, 19, 27): `re_editor` carries source mode; the `markdown` package carries the blocks. `BlockValueObject` is a span, its text and its kind — top level, no stable identity — so `BlockDifferService` aligns by position (Myers over `diffutil_dart`) and pairs by word similarity (`pairingThreshold` is the domain's, the measure is the capability's). The spike harnesses are gone; the decisions carry the numbers.

**Open, by decision rather than omission:**

- macOS profile and release builds are blocked by `flutter_tools` 3.44.5 against Xcode 27 (`lipo -verify_arch` with two architectures). Debug is unaffected; it blocks M3 packaging.
- The macOS app is not sandboxed ([Decision 20](docs/technical/decisions/020-the-macos-app-is-not-sandboxed.md)): the sandbox forbids `/usr/bin/git`, `~/.gitconfig` and SSH keys. The cost is the Mac App Store.
- `GitStatus.entries` and `GitMergeConflict.conflictedFiles` are handed over as `List.unmodifiable`, not copied; a structural fix needs an immutable-collection package (license check under rule 1, plus an ADR) — the maintainer's call.
- In the preview, an external link does not open a browser (needs a plugin) and footnotes render as literal text (M2, failing case waiting). In the diff, move detection is off. "YOUR COMMITS" under a push rejection and a conflicting pull have no screen (Phase 2); the site has only a dark board.
- `GitDetachedHead` is produced by nothing: refusing to commit on a detached `HEAD` is a use case's policy, not a command's failure.
- The e2e suite is unreliable on the maintainer's machine for reasons outside the app: macOS fails to foreground the window (`open returned 1`) and the live binding's pointer crosshair keeps `pumpAndSettle` from settling. The diff scenario's deleted-code-block step is proven by widget tests only. The search scenario is the same story one step worse: once the box has had the keyboard a caret blinks forever, so every `pumpAndSettle` after it waits on an animation that never ends — its clicks pump instead of settling, its save step was dropped (re-filing a saved document is `search_notifier_test`'s), and even so a run that reached step 7 was followed by one that timed out at step 3.

**Doc deltas waiting on the human gate:** `docs/technical/` reorganized into one folder per chapter, `docs/design/` promoted out of it into a chapter of its own, and `product/` **and** `technical/` both split by subject into folders with indexes (see the source-of-truth list above). Decision 2 calls the contract `GitClientInterface`.

Two things an agent deliberately did **not** touch, both needing a human:

- **Decision 8 contradicts Decision 24 about mobile.** Its graph and its "second platform started" row still name `tom_infra_desktop` / `tom_infra_mobile` as separate packages and `apps/tom_mobile`; Decision 24 made a capability a folder with one subfolder per implementation, and the app is `apps/mobile`. Decision 8 already warns that its graph is stale and points at 14, but the mobile row reads as current. **An ADR is revised explicitly, never edited in passing** — so `about.md` and `stack/README.md` were corrected to the real shape and the ADR was left alone. It wants a revision note.
- **`about.md` (1391 words) and `roadmap.md` (2316) were left whole.** `about.md` is the project's front door and AGENTS.md calls it short by design; splitting it into its seven subjects would cost the one-sitting read that is its whole job. The ADRs in `decisions/` are whole for their own reason: a decision is one file by its format, and Status/Context/Decision/Rationale are facets rather than subjects.

**Search shipped behind its boards, knowingly.** The surface was built against the `searching` board; while it was being built that board was replaced by three — `searching-every-document`, `searching-open-file`, `searching-replace` — which put the search in the *left column* with a `This file · Whole space` choice and add finding inside the open document and replacing. Nothing of that is built: what exists is the whole-space search, the box above the tree and the results in the aside. The maintainer chose to review that first rather than rebuild the surface in the same session, and `docs/product/search/full-text-search/known-divergence/doc.md` is the whole of it.

**Traps, one line each — every one of them cost a session:**

- Riverpod disposes a provider nobody listens to, so a notifier that loads in a microtask needs a listener first. The session is `keepAlive` because the screen that writes it is on its way out. Notifiers check `ref.mounted` after every await. Panels derive with `select`; watching the whole session throws an unsaved buffer away on a mode change.
- `riverpod_annotation` 4.0.2 pins `riverpod` 3.2.1 exactly. `Override` is in `flutter_riverpod/misc.dart`; `select` is in the runtime package, not the annotation one.
- `re_editor` installs no keyboard shortcuts on the test platform (save is bound through `CodeShortcutSaveIntent` and proven on a real runner), starts a blink timer it never cancels (pump past it), and its controller is seeded once per document path — re-seed on a buffer that is clean and differs.
- `flutter_markdown_plus` renders a fence from `syntaxHighlighter` alone; `styleSheet.code` never reaches it, so `CodeHighlighterImpl` wraps the colouring inside the style.
- The `markdown` package's syntaxes recognise each other by type: decorate a `BlockSyntax` and a setext heading silently becomes a paragraph. Extend, never wrap.
- `git restore --staged` is fatal on an unborn `HEAD`; `git pull` refuses divergent branches without `--no-rebase`; `invalid object name` must be anchored on `HEAD` or a damaged object store reads as "no earlier version"; conflicted paths come from `diff --diff-filter=U`, not from `CONFLICT` lines.
- A Freezed `@Assert` runs in the generated part and cannot see a static. `prefer_const_constructors` will ask for a const map that is then written into.
- `MaterialApp` animates a theme change (settle before comparing light to dark); two `ProviderContainer`s in one widget test leave a disposal timer pending; the e2e harness disables animations because Home's trunk never stops; `timeout` cannot cancel a body, so a timed-out step takes no frame.
- The macOS Podfile needs `platform :osx, '12.0'` *and* a `post_install` raising `MACOSX_DEPLOYMENT_TARGET`, because Flutter writes 10.15 back.
- `tom e2e` scenarios write, so fixtures are rebuilt per scenario and the previous log is deleted first; two runs must never overlap.
- `verify`'s codegen gate asks git, not the generator: a *new* `.freezed.dart` or `.g.dart` that is merely uncommitted reads as "out of date" and stops the run before a single test has gone green. Run the suites directly while the work is untracked.
- A popover anchored to a control at the *right* of a bar has to hang from its right edge (`followerAnchor: topRight`), or it lands off the window; a widget test must mount such a control where the app puts it or the tap misses.
- A widget test's `ProviderContainer` answers before the first frame, so a surface that loads when it opens looks instant there and empty in the real app; `tom e2e` is what catches the sentence it says meanwhile.
- Penpot cannot move a shape between pages (`Cannot modify a page that is not currently active`), and duplicating or cut-pasting a page that holds main instances duplicates the components — count `library.local.components` before and after any page surgery. `isVariantContainer` is a *function*, and `fills` is a proxy, so `Array.from` it.
- Penpot's SVG export points `@font-face` at its own font proxy; `embed_fonts.py` is the fix, and `rsvg-convert` is not the judge — it drops every mono face over quoting and blames the file. Render with headless Chrome.
- IBM Plex Sans has no `↑`/`↓` outside its `regular` cut: an arrow at weight 500 renders as nothing, silently.
- A Penpot text box goes stale — a title at half its size has a collapsed bounding box, not a wrong font, and neither resizing nor a `growType` round-trip recomputes it. Delete the text and create it again.

**Last session (2026-09-26, design):** a long prototyping pass in Penpot and the paperwork that closes it. No application code written.

What was settled, all of it drawn and none of it built: the **right column carries a `Changes · History` switch** in place of a caption, because stacking does not survive a third panel; the **search belongs whole to the left column**, which makes today's split surface a known divergence; **panel toggles draw outline and divider always, filling the strip only when open**, VS Code's reading, since a bare outline was meaningless; the **rendered diff can be turned off** by a `Diff` chip fixed at the end of the bar with `Compared to <ref>` inside it, and `Diff off` is its own screen where the removed block is simply not there; the **diff screens are split**, explorer closed, marks in *both* panes, with a removed block drawn in the source as a **seam** rather than as text, since it is not in the buffer; the **file tree carries the change**, the changes column's own letter at the right of a file's row and a dot on a folder that holds one, chosen over five other treatments because colour alone cannot tell added from untracked and cannot survive the open row's highlight; the tree is **folders first at every level**; the **chevron is VS Code's codicon path**, filled, at 16, aligned by its ink rather than its box; the **counts live inside the buttons** as `Fetch (3)` and `Push (2)` with the arrow outside the parentheses; **news from git is a band above the document, never a panel**, which revokes the old "that banner is the column" rule; **a commit that worked says so** and one in progress shows a spinner on the button pressed; and **the space can always be left**, through the breadcrumb's menu with `Close space` at its foot.

**The library and the exports are closed.** Twenty-four masters, every screen built from instances rather than drawing its own controls, and the masters abstracted from this product's vocabulary — labels are `One`/`Two`/`Three`, specimen text is `Item name`, `Diff mark` became `Status mark` and `Branch control` became `Select control`. Three pages divide it: `Components - Master`, `Components`, `Foundations`. The Git page was split into five (`Commit`, `Branches`, `History`, `Remote`, `Diff`) because one page of a dozen screens scrolled past reading. **Twenty-six screens are exported in both themes with the fonts embedded, plus a PDF per page**, into `docs/design/screens/desktop/<page>/`; `foundations/`, `components/`, `brand/` and `site/` export the same way. Rule 13's debt is paid.

**`docs/design/` is now a chapter of its own**, promoted out of `docs/technical/`, one folder per subject with its own `README.md`. Every path into it changed, which is what most of this session's doc diff is: 36 files, the Dart dartdocs included. Two real bugs fell out of the move and are fixed — `palette.py` and `brand.py` were still writing to the old root, and `.gitignore` was still ignoring the font cache at its old path, so it was heading for a commit. Dead references to the retired Excalidraw kit and to `docs/product/**/mocks/` went with them.

**Then the corpus was split by subject**, on the `tom-docs` rule that one file answers one question and an index beats a section. `design/` went from 5 files to 24, and the seven product docs over ~400 words became folders: `home/`, `workspace/`, `commit/`, `push-pull/`, `rendered-diff/`, `file-tree/` and `full-text-search/` each carry a `README.md` index and one `doc.md` per subject, with mobile counterparts as their own files rather than subsections. **Every leaf is now under 400 words**; the two deliberate exceptions are `components/controls.md` (one lookup table — splitting it would make a reader open three files for one control) and the indexes. That moved about 70 inbound links, roughly half of them dartdoc, and `product/conventions.md` is new: the shape rules that were crowding the index.

Left open, deliberately: the Penpot file still holds `Working tree — variants`, the study board behind the tree decision, which can go once that decision is recorded; whether Home gets a theme toggle; and `TOM.penpot` at 25 MB, which wants Git LFS or milestone-only commits — the maintainer's call.

**Before that (2026-09-26):** full-text search closed M2. The layers below the screen were already written and uncommitted when the session started — the `search_index` capability with its sqlite3 implementation, `SearchRepository`, the three use cases, `SearchNotifier` and the wiring; what this session added is the interface and the proof: the `SEARCH` panel at the top of the aside (caption, the count line, a hit as name · folder · excerpt with the typed words marked), the box above the tree made live, `tom.search` registered through `CoreModuleImpl` like every other panel, and tests at every layer plus an e2e scenario (`Finds a document by its contents`, group *Search*) that searches for a word no file name holds. The `searching` board was already exported in both themes.

**Before that (2026-09-25):** the branch/commit diff was built — `RevisionValueObject`, `comparingAgainst` on the session, `CompareNotifier` and the compare surface in the bar above the document, plus the `comparing` board in Penpot. Before that, every comment in `src/` and `tool/` was trimmed to the two-or-three-line rule through the `tom-comments` skill (about 9,700 comment lines to 6,100, no block over the twelve-line ceiling, `commentBudget` in `tool/src/rules/comment_rules.dart` ratcheted from 48 to 0), and this section was cut from 8,500 words of trail to the above. `docs/roadmap.md` was drafted down to a third for the human gate.

> Keep this "Current status" section up to date at the end of each meaningful work session — it is what carries context between sessions.
