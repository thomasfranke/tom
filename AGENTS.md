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
- [`docs/product/`](docs/product/README.md) — **the source of truth for what each feature must do**, in non-technical language, one folder per feature holding its `doc.md`. Maintained by stakeholders, kept current as the app evolves. Check the relevant `doc.md` before implementing or changing a feature's behavior.
- [`docs/technical/`](docs/technical/README.md) — how it is built: `architecture.md` (the graph and what enforces it), then one folder per chapter — `conventions/` (the rules inside a package: structure, naming, errors, external dependencies, testing), `runtime/` (runtime behaviour), `domain/` (the model), `stack/` (dependencies with licenses), `process/` (setup, the CLI, CI, versioning, repository settings), and `decisions/` (ADRs — a new decision is a new file, changing one requires an explicit revision). Each folder's `README.md` is its index.
- [`docs/design/`](docs/design/README.md) — what it *looks like*, a chapter of its own: `visual-language/` (the colour roles), `brand/` (the identity), `components/` (the control set with the exact numbers), `foundations/`, `screens/` (every screen as a board exported from Penpot, both themes, one folder per page) and `tools/` (the scripts that measure the app against a board).
- [`docs/roadmap.md`](docs/roadmap.md) — spikes, phases and milestones, in order — whatever is out of the MVP stays out. **There is no task queue and no spec folder**: work is picked from the roadmap, or from what the maintainer asks for directly.
- **Read selectively.** Consult only the files relevant to the task at hand; never load `docs/` wholesale. The index above exists so the right file can be picked without reading the rest.

**Which record wins, per chapter** — the three chapters do not answer a disagreement the same way:

| Chapter | The truth is | When the code disagrees |
|---|---|---|
| `docs/product/` | the `doc.md` | the code is the bug — flag it; a doc that should move instead is the maintainer's call, never an edit in passing |
| `docs/technical/` | the code, whose dartdoc is the canonical form of the rule | the doc is the bug |
| `docs/design/` | the Penpot file; the export in the repository is the record of it | an export is never edited by hand — the board changes in Penpot and is exported again |

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
| [`tom-feature-flow`](.ai/skills/tom-feature-flow/SKILL.md) | **picking up a roadmap task**; starting any feature or fix that touches more than one file; asking what is left to prove before something is finished; the user says "next task", "let's build X", "is this done", or asks for the video of a run | The order: the task from the roadmap, the product doc it is checked against, the board that must already be approved, then the code outward from the domain — and the four proofs in sequence (`test arch` → `test unit` → `test integration` → `e2e`), the evidence a run leaves and why the video is handed over rather than summarised, the `verify` codegen-gate trap, and what must be true before a commit is offered |
| [`tom-code-review`](.ai/skills/tom-code-review/SKILL.md) | reviewing a diff, a branch or a PR; running `/code-review`, `/simplify` or `/security-review` here; the user says "review this", "does this follow the architecture", "is this ok to merge" — or you are about to open a PR and are reading your own branch | What the tooling already proves versus what only a reader can check — the layer graph, `Result` and the failure hierarchies, Freezed, typed paths, the capability contracts, the session and module patterns — package by package, the test layout, the docs that must move with the change, the general canon (Effective Dart, Clean Architecture, DDD per Decision 15, community conventions) and its precedence under the project's own choices, and which settled decisions are never a finding |
| [`tom-comments`](.ai/skills/tom-comments/SKILL.md) | writing a new class, method or library and reaching for a comment; judging in review whether a comment earns its lines; the user says "the comments are too long", "keep them cohesive", "trim this", or asks what belongs in a dartdoc — and before adding a paragraph to any existing dartdoc | The three shapes (the `library` line, the dartdoc, the why-comment inside a body), what is not a comment, the two exceptions that earn extra lines and the twelve-line ceiling on them, and a real before/after trim from this repository |
| [`tom-docs`](.ai/skills/tom-docs/SKILL.md) | adding or editing any file under `docs/`; writing or repairing a folder's `README.md` index; moving a doc or a whole chapter; reviewing the corpus for style; the user says "the docs are too wordy", "trim this doc", "no prose", "where does this belong" — and before adding a paragraph to `about.md`, `roadmap.md` or any chapter index | The four shapes (the opening, the rule, the table, the reason clause), what is not a shape, the three-line ceiling on the exception, one subject per file with the signals that a file is two, what an index may and may not hold, where a given sentence belongs and which record wins in each chapter, what moves in the same commit, and real trims from this repository |
| [`tom-testing`](.ai/skills/tom-testing/SKILL.md) | finishing a feature and asking what proves it; adding or changing any test — unit, widget, integration or end-to-end; writing or debugging an end-to-end scenario; a scenario that hangs, times out or reports `0/0 steps`; a widget test that ends with a timer pending or finds no editor; the user says "write a test", "add an e2e", "does this need a test", or asks why the suite is flaky | The rule that every user-facing feature ships with a scenario — and what *every* means: each control, rule and edge case with a step and evidence, an integration test against the real dependency under it, a survey and a roadmap before writing in bulk — a scenario as data with steps named for the progress screen, the robot that holds every reusable action and assertion, the frames every run writes and the video ffmpeg joins from them, how to run it and at the board's size, and **every trap of the test side**: the end-to-end ones (the uncancellable `timeout`, the caret that blinks forever, the killed run that prints green), the widget-test ones (the notifiers a mounted shell creates, `re_editor` on the test platform) and the integration ones |
| [`tom-git-workflow`](.ai/skills/tom-git-workflow/SKILL.md) | committing, staging, writing a commit message, creating a branch, opening or merging a PR, cutting a release, applying a hotfix — or the user says "commit this", "push", "open a PR", "ship it", or asks which branch to target | Trunk-based on `main`, branch naming, Conventional Commits scoped by feature, squash policy, releases as tags, what differs in `tom-pro` |
| [`tom-pr-writer`](.ai/skills/tom-pr-writer/SKILL.md) | about to open a PR, "write the PR", "draft a PR description", finishing a branch, reviewing or rewriting an existing description, writing the squash commit message | Inspecting the real diff before writing, title = the Conventional Commit the squash will produce, the What / Why / How to test / Automated tests / Notes template |
| [`tom-design`](.ai/skills/tom-design/SKILL.md) | **before writing any widget, screen, panel, dialog, popover or control**; drawing, editing or reviewing a mock; touching the Penpot file through its plugin at all; measuring the app against a board; "design this", "mock up a screen", "penpot", "draw the layout" | The Penpot file every piece of interface must exist in and be approved in first, the component library every control comes from, the file page by page, the card each page is, the first screen whole and then only what varies, the export that puts each board in the repository before a merge, and **every trap of the Penpot side**: pages and `openPage`, writes that do not land and renders that lag, components and copies, text and fonts, sweeps, the export, the plugin's tab — plus how the app is measured against a board |

How they are maintained, and why `tom-pro` inherits them by relative path
instead of copying: [`.ai/skills/README.md`](.ai/skills/README.md).

## Non-negotiable rules (summary of the decisions)

1. **MIT license** — NO AGPL/GPL dependency (no `appflowy_editor`). Check the license of every new package (Decision 1).
2. **Git through the system binary** (`Process.run`) behind contracts — do not suggest libgit2/FFI at this phase (Decision 2).
3. **No WYSIWYG** — the editor is source + preview (Decision 3).
4. **No `dartz`** — Result with native sealed classes, exhaustive switch, early return (Decision 5); rules in `docs/technical/conventions/errors.md`; the types live in `src/packages/core/lib/src/` and `src/packages/domain/lib/src/`. Inline try/catch mandatory in every use case.
5. **No navigation package** — plain `Navigator` for dialogs only (Decision 6).
6. **External dependencies isolated behind contracts** in infrastructure (Decision 7); Riverpod ONLY in presentation and the composition root (`src/apps/desktop/lib/bootstrap/`) — no `Ref` in any other layer; constructor injection (`docs/technical/runtime/composition.md`).
7. **One package per layer** (Decision 14, revising 8): `src/packages/{core,domain,application,infra,data,presentation}` are pure Dart with NO Flutter in the pubspec. Flutter lives in the applications (`src/apps/{desktop,mobile}`) and in `src/packages/ui` — the look both applications draw, which depends on no package and wires nothing (Decision 26). A layer may depend only on the ones below it — the one exception being `infra` and `data`, two packages of one layer that depend on each other (Decision 24) — enforced by the pubspecs, by `depend_on_referenced_packages`/`implementation_imports` as errors, and by `src/test/integrity/architecture_test.dart`.
8. **Files are the truth** — never propose a database or state that is not rebuildable from the `.md` files on disk. The FTS5 index is a cache.
9. **Telemetry is opt-in** — observability behind a contract, no-op by default; nothing about the person leaves the machine. The one request TOM makes on its own is the version check to GitHub, which carries no data about the person and can be turned off (Decision 11).
10. **Extensible shell** — panels are ALWAYS registered through `TomModule`/`PanelDescriptor`, never hardcoded in the shell, including the built-in ones (Decision 12; `docs/technical/runtime/composition.md`).
11. **The public repo documents the free product only** — no tier catalogue, no pricing, no licensing mechanics, no reference to a private repository. Commercial modelling lives outside this repo (Decision 4).
12. **A space is a folder, not a repository** — `SpaceEntity` carries `root` and `repositoryRoot` separately; git runs against the repository, navigation and search stay in the folder.
13. **No user interface is written before it is designed** — every screen, panel, dialog, popover and control exists as a board on the Penpot file's `Screens: <subject>` page, built from the library's components and **approved by the maintainer in Penpot before any code**; both themes are **exported into `docs/design/screens/desktop/<page>/` before the merge**. The export is slow and runs only when the maintainer asks for it, so it is the end of the work, not a step of it; card PDFs are not exported. A board nobody approved does not count as designed (skill: `tom-design`).
14. **Freezed is mandatory for immutable data** — entities, value objects with more than one field, presentation view-state, and sealed hierarchies; no hand-written `==`/`copyWith` once a class qualifies (Decision 16). Single-field identifier/path value objects (`BranchNameValueObject`, `CommitShaValueObject`…) are the one recommended exception — an `extension type` fits better there.

## Stack (summary — details in docs/technical/stack/)

Riverpod (codegen) + Freezed · `markdown` (AST) · `flutter_markdown_plus` · `diffutil_dart` · `re_editor` · `sqlite3` + FTS5 · `pdf` · `xterm` + `pty2` · `window_manager` / `file_selector` · `flutter gen-l10n` · `dart:io Process` for Git and `gh`. Nothing watches the folder and there is no HTTP package. Why Dart rather than a web stack, and where Rust could still enter via FFI: Decision 13.

## Code structure

See `docs/technical/architecture.md` (source of truth) and `docs/technical/conventions/` for the rules inside a package. The Dart workspace lives under `src/`; run everything through `dart run tool/tom.dart <command>` from the repository root (`make` targets are shortcuts over the same CLI, and `tool/` never calls back into `make`).

```
core ← domain ← application ← presentation
  ↑       ↑                        ↑
  └─── infra ⇄ data ─────────────  desktop · mobile
                                       ↑
                                      ui
```

`infra ⇄ data` is the one two-way edge, and it is deliberate: `infra` holds each capability's contract and failures, `data` the DTOs that cross them, so the two packages depend on each other and pub resolves the cycle ([Decision 24](docs/technical/decisions/024-a-capability-is-a-folder.md)). What `infra` never depends on is `domain`.

`core` holds `Result`, the `AppFailure` marker and the ports every layer needs — mechanism, never product vocabulary; `domain` holds entities, value objects, the sealed failure hierarchies, repository contracts and the domain services; `application` use cases; `infra` capability contracts *and* their implementations, one folder per capability holding the contract, its failures and a subfolder per implementation named after the dependency ([Decision 24](docs/technical/decisions/024-a-capability-is-a-folder.md): `git_client/dart_io/dart_io_git_client_impl.dart`); `data` the DTOs that cross those contracts, the data sources that obtain them, the parsers and the repository implementations ([Decision 25](docs/technical/decisions/025-a-repository-reads-through-a-data-source.md): a repository orchestrates and translates, a source obtains); `presentation` the space session and notifiers, pure Dart so it cannot reach a widget; `ui` the look both applications draw — colour roles, metrics, the brand marks and the shared components, depending on nothing ([Decision 26](docs/technical/decisions/026-the-look-is-a-package.md)); `apps/desktop` the composition root and this application's own screens.

## Conventions

- **Git workflow (branches, commits, PRs, releases): see the `tom-git-workflow` skill** in `.ai/skills/` — consult it before committing, branching, or opening a PR. Human-facing version: `CONTRIBUTING.md`.
- Conventional Commits + semantic versioning. Trunk-based: `feat/*` → PR into `main` (squash) → tag publishes. No `dev` branch. `main` is publishable; production is the most recent tag.
- **Incomplete work integrates behind a build-time feature flag**, never on a long-lived branch (`CONTRIBUTING.md`, "Feature flags"). Disabled = unreachable, and every flag has a removal target.
- Documentation updated in the same PR that changes behavior (dogfooding: this project exists for that)
- **If a PR changes a product's user-facing interface, the screen's Penpot board is changed and approved before the code, and both themes are exported again before the PR merges** (`docs/design/screens/desktop/<page>/`) — a board that no longer matches what shipped is worse than none, see [docs/product/README.md](docs/product/README.md) and rule 13
- A new architecture decision → a new file in `docs/technical/decisions/` following the existing format
- **All documentation and code in English** (identifiers, comments, docs)
- **A comment is two or three lines** — what the thing is, then why it is that way ([inside-a-package.md](docs/technical/conventions/inside-a-package.md)). Longer is an exception that earns itself: a rule with no other home, or a trap worth an afternoon

## Current status

**Phase 1 — MVP. M0, M1 and M2 are complete; M3 is built except packaging and what the alignment roadmap lists.** This section holds what a new session needs and neither git history nor `docs/roadmap.md` says, in three parts: what exists, what is open by decision, and the traps.

- It is a status, not a log: no dated narration and no strike-through — an item that closed is deleted, and how it closed is git's.
- It carries no counts (tests, scenarios, components, boards, messages) — `tom e2e list`, `ls` and the suites answer, and a number written here is stale by the next session.
- A trap lives where it is loaded when it applies: the code's here, Penpot's in [`tom-design`](.ai/skills/tom-design/SKILL.md), the test side's in [`tom-testing`](.ai/skills/tom-testing/SKILL.md).

### The maintainer's working rules

- **The Penpot export and `tom e2e all` run only when he asks** — both are slow and lock development. While building, only the feature's own scenario runs; a stage that draws boards ends at "drawn and approved in Penpot".
- **The `Prototypes` page is kept in the Penpot file and never exported.**
- **A doubt never blocks.** Proceed on the conservative reading and bring the question with its options.
- **Nothing is committed or pushed without his approval of the exact text**, and commits and pull requests carry no attribution lines.
- **The alignment roadmap and its decisions live in `.claude/audits/2026-10-09-alignment/`** (gitignored: `roadmap.md`, `decisions.md`, `alignment-inventory.md`, `penpot-progress.md`), and no stage of it starts without his word.
- **At most two main agents work at once, each with at most two sub-agents** — a sub-agent counts as an agent, so a brief that forbids spawning means it.
- **A finished roadmap task is reported in the conversation, with a summary** of what was built, what proves it and what stays open — not only in a file under `.claude/`.
- **Tests for what already existed are written after the alignment, not before** — the survey and its roadmap are in `.claude/audits/2026-10-09-test-coverage/`. A correction made meanwhile still ships with its own tests ([`tom-testing`](.ai/skills/tom-testing/SKILL.md)).

### What exists

The graph is whole: a folder picked on Home reaches git through every layer and comes back as a `SpaceEntity`.

| Where | Holds |
|---|---|
| `tom_core` | `Result`, `AppFailure`, and the ports: `Observability`, `CommandLog` (every process TOM starts is recorded through it; `CommandRecord.of` is the one place a secret is masked) and `CommandGate` (a command waits there for approval) |
| `tom_domain` | one folder per subject under `lib/src/` — entities, value objects, the sealed failure hierarchies, the repository contracts and the services (`BlockDifferService`, `ConflictScannerService`, `MarkdownFormatterService`, `DocumentSearchService`, `BranchBaseService`, `BranchOverviewService`, the wikilink resolver and completion, `HeadingAnchorService`) |
| `tom_application` | one use case per product action, over a `UseCase` mixin that holds the standardised `try/catch` |
| `tom_infra` | one folder per capability, a contract plus an implementation named after its dependency: `filesystem`, `git_client`, `settings`, `platform_paths`, `markdown_parser`, `text_differ`, `search_index`, `desktop_shell`, `document_exporter`, `credentials`, `github_api`, `pseudo_terminal`, `app_updates` |
| `tom_data` | the DTOs, sources, parsers and repository implementations, one folder per subject |
| `tom_presentation` | the space session ([Decision 9](docs/technical/decisions/009-space-session-is-single-source-of-truth.md)) and one notifier per panel, one folder per feature |
| `tom_ui` | colour roles, metrics, the shared components, the three vendored IBM Plex faces (`TomFonts`, never fetched at runtime) and Font Awesome Free Solid, reached only through `TomGlyphWidget` ([Decision 32](docs/technical/decisions/032-the-icon-set-is-font-awesome.md)); it has no words of its own |
| `apps/desktop` | the composition root (`lib/bootstrap/`), the shell, `screens/<feature>/` mirroring `tom_presentation/lib/src/<feature>/`, the two ARB files (`lib/l10n/`), and the end-to-end suite (`integration_test/`) |

**Shipped** — each has its `doc.md` under `docs/product/`: the workspace (three island columns and a bottom region, dragged), Home with recent spaces and clone by URL, the file tree with new document, new folder and its `⋮` menu, the preview, source mode, the formatting bar and GitHub's keys, tabs, commit with a description, staging, one file or everything put back, fetch · push · pull with the line that says what the link is, branch switch and create, file history and reading a version, the rendered diff, the conflict flow in both panes, search over the space and in the open file with replace, wikilinks, export to PDF and HTML, the pull request (draft, overview, opened through `gh` or handed to the browser), preferences and `preferences.json` in a tab, two languages, the account, the Commands panel, the terminal, a folder outside any repository, any changed file opened from the changes list, leaving a space.

**Built below the interface, drawn by no widget and run by no scenario:** git approvals ([Decision 38](docs/technical/decisions/038-a-command-waits-at-a-gate-in-tom-core.md), draft) — `CommandGate` asked by `git_client`, `github_api` and `credentials` before the queue, the keys as enums, `ApprovalsRepository` over `git-approvals.json`, `CommandsNotifier` as both ports, an action's name carried as a zone value (`CommandScope.run`), `GitReadingState.stale()` for a denied read.

**About and the update check are built** (`docs/product/about/doc.md`, `docs/technical/runtime/updates.md`), bar `Update and restart`: the `app_updates/` capability, the dialog, the gear's dot, the status-bar notice and the opt-in `checkingForUpdates` preference. `TOM_VERSION`, `TOM_BUILD` and `TOM_RELEASES` are `--dart-define`s; with `TOM_RELEASES` unset the check is unavailable and says `No release yet.`. `git --version` is part of opening a space, and an older git than 2.41 is refused on Home.

**Designed and approved in Penpot, not built:** the approvals' interface; and every board the alignment drew — what each is and where it sits is `penpot-progress.md`, and the order they are built in is the alignment roadmap's.

**Every page of the Penpot file is exported** into `docs/design/screens/desktop/<page>/`, both themes, fonts embedded; a board changed after that export is not on disk until the next one. `docs/design/penpot-backlog.md` holds what the file still owes.

How the pieces that are easy to get wrong are shaped:

- **The diff's base is on the session and nobody chooses it** — `comparingAgainst` is the branch the checked-out one came from (recorded as `branch.<name>.tomBase` when TOM creates a branch, deduced otherwise by `BranchBaseService`) read at its fork point, and `HEAD` on the default branch, detached, or with nothing to have come from. The `Diff` chip only toggles `showingDiff`.
- **The search index is in memory, one per open space**, filled from the tree's own listing and never written to disk; a save re-files that one document. What is typed is words, never a query language. `This file` is answered by the buffer and reaches no index.
- **A block is a span, its text and its kind — no stable identity** — so `BlockDifferService` aligns by position and pairs by word similarity (`pairingThreshold` is the domain's, the measure is the capability's; Decisions 18, 19, 27).
- **Every git reading on the session has one writer, `GitReadingNotifier`**, alive while a space is open; a conflict is the repository's state, not the session's, so closing and reopening finds it.
- **A conflict's regions are read from the text and offered only while git says so** — `SpaceSessionState.isConflicted(path)` gates both panes, which keeps a `<<<<<<<` typed into a document *about* merging as plain text.
- **The editor has one buffer.** Tabs are a sealed `DocumentTab` (`inSpace` · `outside` · `preferences`); leaving a dirty tab parks its `EditorReady` in `HeldBuffersNotifier`; `unsavedDocumentsProvider` is what the strip, the tree's dots and the leaving question read.
- **A save asks the disk first** — `SaveDocumentUseCase.save(…, replacing:)` reads the file before it writes, for every document and the preferences file, never a pull request's draft. Other text on disk writes nothing and raises the `Keep mine` / `Reload` band (`EditorReady.changedOnDisk`); `Keep mine` lets one save through (`overwritesDisk`); `Save all` leaves a held tab that conflicted unsaved, so leaving stays put.
- **A write replaces the text and nothing else** — `Filesystem.writeBytes` follows a symbolic link and keeps the file's mode, and a file nobody may write to refuses the save (`FilesystemAccessDenied`) where it used to be replaced.
- **Closing the window asks the leaving question** — `WindowCloseGuardWidget` wraps Home and the shell and hears both the window's close and the system's quit; `SpaceMenuNotifier.quit()` raises the breadcrumb's question, and the window closes through `windowCloserProvider` only after the space did. The seam has no default in presentation: the desktop overrides it with `desktopWindowCloserProvider`, which is the one a module replaces.
- **One git client per folder, kept** (`gitClientForProvider`), so every command on a repository shares one queue — and a read waits behind a fetch, pull or push in flight there, up to the network timeout.
- **A file beside the space is addressed through `SpaceEntity.repositorySpace`**, the repository seen as a folder — only to address it: the session never opens it, and the tree, search and index ignore it (rule 12 holds).
- **A folder with no repository is a space** whose `repositoryRoot` is null; `hasRepository` is the one gate every git reader returns early on.
- **A pull request's draft is a document outside the space** ([Decision 33](docs/technical/decisions/033-a-pull-request-draft-is-a-document-outside-the-space.md)): `<git-common-dir>/tom/pull-request/<branch>.md`, saved on the way out without asking, never held behind a tab, never deleted, and skipped by the index, the diff and the tab dots.
- **TOM signs nobody in and stores no token** ([Decision 35](docs/technical/decisions/035-github-is-reached-through-the-gh-cli.md)): the account is whatever `gh`, `git credential fill` or `ssh -T` already know, chosen per repository in git config (`tom.githubAccount`); `GithubTokenReader` is the one place a token is read, and it travels only in `GH_TOKEN`.
- **The terminal is the person's own shell in a pty**, one per space, at the repository root or the folder ([Decision 37](docs/technical/decisions/037-the-terminal-is-the-persons-own-shell-in-a-pty.md)); nothing typed there reaches the `CommandLog`.
- **A panel says everything about itself through `PanelDescriptor`** — `title` (a builder, for the language), `placement`, `pages`, `actions`, `badge`, `summary`, `isKeptAlive` — so the shell draws a column's head without naming a panel (Decision 12).
- **Presentation produces no sentence**: it carries a reason as an enum and the widget words it through `context.l10n` ([Decision 34](docs/technical/decisions/034-the-interface-is-localised-with-gen-l10n.md)); `app_en.arb` is the template.
- **Preferences are applied when pressed** and kept as plain JSON per key under `app.preferences`; a missing or unreadable value is the default, silently.
- **Every control in `controls.md` has a master in the Penpot library, and most of the newest are reference only**: the screens draw them inside the shell masters (`Top bar`, `Explorer`, `Document`, `Git panel`), whose copies cannot change structure — only `Overflow strip`, `Wordmark` and `Commit trunk` are instanced by a screen.
- **`tom rules` has a `links` rule**: every relative link in `docs/`, `.ai/skills/`, `AGENTS.md`, `CONTRIBUTING.md` and `README.md` names a file that exists, by exact case, and a heading it has — `tom rules links` after moving or renaming a doc.
- **The app is held to the boards by measuring, never by eye**: `tom e2e "<scenario's name>" --board` runs it at the boards' own 1440×900 and `docs/design/tools/` compares the two ([`tom-design`](.ai/skills/tom-design/SKILL.md), *Measuring the app against a board*).

### Open, by decision

Each is known and deliberate; none is a task until the roadmap or the maintainer makes it one.

- **macOS profile and release builds failed on the maintainer's machine** (`flutter_tools` against the installed Xcode, `lipo -verify_arch`), while CI's `Build (macOS)` job built a release on the same pinned Flutter — so the block is that machine's Xcode, not the repository. No run has built this branch yet. Debug is unaffected.
- **The macOS app is not sandboxed** ([Decision 20](docs/technical/decisions/020-the-macos-app-is-not-sandboxed.md)) — the sandbox forbids `/usr/bin/git`, `~/.gitconfig` and SSH keys; the cost is the Mac App Store.
- **Nothing watches the folder** ([Decision 10](docs/technical/decisions/010-watcher-and-git-cooperate-by-protocol.md), revised) — a change made outside TOM is caught at save and by `Reload`, never as it happens.
- **Two windows of the app are not supported** — preferences and approvals are written unlocked and the last write wins.
- **Only a merge in progress is recognised**; a rebase, cherry-pick or revert stopped in a terminal shows conflicted rows and no band.
- **A skipped integration test marks a known defect** (`skip: 'defect <id>: …'`), written to the intended behaviour and un-skipped with its fix; the few still skipped are unjudged, none is an accepted limit.
- **A wikilink from the root is written `[[/name]]`** ([Decision 28](docs/technical/decisions/028-a-wikilink-resolves-by-name-inside-the-space.md), revised) — a document whose name holds `#` or `|` is never offered by `[[`.
- **The git client's `version()` is asked on every open** and an older git than 2.41 is refused on Home; the maintainer decided it is read once per run and cached — not built.
- **A footnote's text reaches the model and produces no block** ([Decision 31](docs/technical/decisions/031-where-a-footnotes-text-goes.md)), so a rewritten note is seen by the diff and not decorated by it; move detection in the diff is off.
- **The conflict choices in the source pane are painted on the `<<<<<<<` line**, not on a line of their own — `re_editor` cannot draw one.
- **The `Document` master's toolbar is not rebuilt from `Toolbar button`**: the library carries the `Unavailable` state and the screens keep it as overrides.
- **What a push rejection lists as the person's own commits has no screen** (Phase 2); the site has only a dark board, and its drawing of the app waits for a real screenshot at launch.
- **`Update and restart`, the download and `Restart now` are not built** — they wait on code signing, a per-platform updater and the macOS release build.
- **Noted, neither designed nor scheduled:** scrolling both panes together in `Split`; a command palette (after the MVP).

### Traps — the code's

Every one of them cost a session. One line each; the dartdoc of the symbol named carries the rest.

**Riverpod and the session**

- A provider nobody listens to is disposed — a notifier that loads in a microtask needs a listener first, and the session is `keepAlive` because the screen that writes it is on its way out.
- Check `ref.mounted` after every await, and read every notifier you will need **before the first await** — a popover's disposal races the rest of the method (`BranchesNotifier`).
- A panel derives from the session with `select` — watching the whole session throws an unsaved buffer away on a mode change.
- Everything that writes to the repository — a save included — ends in `GitReadingNotifier.refresh()`; the read does not belong in `SpaceSessionNotifier.open()`, which would couple opening a space to a use case.
- `GitReadingNotifier.updateShouldNotify` is `true` — `ready()` is const, so an equal reading would be silent and the column would stay busy.
- A notifier that holds a draft *listens* to its sibling, never watches it — a watch rebuilds it and drops the draft (`ChangesNotifier` over the git reading; the preview over the diff base, which re-marks the text on screen instead of parsing it again).
- Watching a sibling makes it exist — `editorMarks` watches `previewProvider`, debounce timer and all; the shell is what makes `gitReadingProvider` and `diffBaseProvider` exist.
- A `build` may not write another provider — write in the microtask after it; `stateOrNull` is how a `build` sees the state it is leaving (`EditorNotifier` and the held buffers).
- Riverpod retries a failing provider on a timer — a provider whose failure is an ordinary answer turns the retry off (`recentBranchProvider`).
- `riverpod_annotation` pins `riverpod` to an exact version; `Override` is in `flutter_riverpod/misc.dart`; `select` is in the runtime package, not the annotation one.
- `riverpod_generator` cannot see a class Freezed declares in a part and says only *InvalidTypeException* — type the provider by the sealed parent.
- A `ChangeNotifier` the shell owns is disposed before a child's post-frame callback runs — it needs a disposed flag of its own.
- A caret move must not cancel the preview's pending parse — `PreviewNotifier._follow` cancels its timer only when it reschedules.
- A new git reader returns early on `hasRepository` — the composition root falls back to `space.root` where it needs a folder, so one that forgets runs git there and logs a failed command instead of crashing.

**`re_editor` and the two panes**

- It wraps the controller it is given in a delegate of its own, and the undo history is the delegate's — `EditorHistory` reaches it by invoking `CodeShortcutUndoIntent` through the `indicatorBuilder`'s context, so the button and ⌘Z walk one stack.
- It counts in lines and columns, the buffer in characters — the pane converts both ways, and a formatting press that does not hand the selection back sends the caret to the top.
- It writes its layout to `CodeIndicatorValueNotifier` *while laying out* — a gutter paints (`CustomPainter(repaint: notifier)`) and never rebuilds, or *Build scheduled during frame*.
- It hands its layout over inside the child's build — a pane that draws outside the editor settles in one post-frame pass, and the guard on that pass is not optional: without it every frame schedules a frame.
- It forces one height per line and has no view zones — nothing can be drawn on a line of its own between two lines of text.
- The source pane follows a buffer it did not write, dirty or not — a replacement writes while dirty; the pane tells the two apart by remembering the last text it pushed, set in `initState`: read lazily, a write from elsewhere before the first keystroke was taken for the pane's own.
- In preview the source pane stays mounted and unseen (`PanelDescriptor.isKeptAlive` under `Visibility(maintainState)`, a `GlobalKey` per document panel) — the undo history is the pane's, and the hidden layer excludes focus.
- A mark's letter and its tint are different stretches (`EditorMarkSpan`): a changed block carries both, a conflict's `<<<<<<<` only the letter, each side only the tint, a removal neither — it is a seam between two lines.
- The band behind a line is painted *behind a transparent editor* — it crosses the numbers and the text, and the indicator column is only as wide as the numbers.
- The source pane's diff marks are the preview's own diff turned into spans (`EditorMarks`), never a second comparison; a file that is not markdown is marked by line (`LineDiffNotifier`).

**Flutter layout and paint**

- `Border.all` draws *inside* the box and a board measures an inset from the outside — subtract the stroke.
- A `DecoratedBox` paints its border *over* the child where a `Container` reserves room — `inset - stroke` lands a point short, and a `Positioned.fill` child sits under the border.
- A container drawn inside a region cannot reach the chrome above it — `TomShell` owns the three column containers, `ShellRegionWidget` draws panels and nothing around them.
- `InputDecoration` sizes its box from content plus `contentPadding`, and `constraints` does not fix it — a field whose height the design fixes is drawn, not decorated (`TomFieldBoxWidget`).
- A control smaller than its tap target lands where the *target* is centred — pin the paint to the edge the margin is on (`TomCheckWidget.alignment`) and let the target overhang inwards.
- A control sized by what a `Row` has left changes shape when its neighbours do — measure what the design fixes from the window's structure and put the slack on what the boards treat as optional, in `Expanded`.
- Fixed-width buttons in a `Row` overflow a split pane — `Wrap` keeps the board's line where there is room.
- A `Stack` whose children change in number re-parents the ones after them (a re-created `CodeEditor` loses focus and selection) — keep the slot, empty or not.
- A `Stack` given loose width sizes itself to its text, so `Positioned(right:)` lands from the caption's end — give it the column's width.
- A drag handle wants `dragStartBehavior: DragStartBehavior.down`, or the recogniser eats the touch slop and the rule trails the pointer.
- A post-frame callback after a `jumpTo` to where the pane already is waits for ever — call `WidgetsBinding.instance.ensureVisualUpdate()` with it.
- When a control's ink is off-centre, fix the geometry and keep the ripple — removing the affordance to hide a misalignment was rejected.

**Popovers, focus and keys**

- A popover anchored to a control at the *right* of a bar hangs from its right edge (`followerAnchor: topRight`), or it lands off the window.
- `MenuAnchor` cannot live inside a `CompositedTransformFollower` (*the paint transform cannot be reliably computed*, and the menu never opens) — a popover that holds a select measures the control's `RenderBox` and uses `Positioned`.
- A `TapRegion` around a popover dismisses it before the button that opened it toggles — give the button and the popover the same `groupId`.
- A `CallbackShortcuts` hears only focus inside it — the shell holds a `Focus(autofocus: true)` so a window-wide key is heard with nothing focused.
- `xterm`'s view calls `onResize` during layout — tell the notifier in a microtask; and it exports a `TerminalState` of its own — import it with `hide` or `show`.

**Dart, Freezed and the generators**

- A Freezed `@Assert` runs in the generated part and cannot see a static — its helpers are private top-level functions.
- `prefer_const_constructors` will ask for a const map that is then written into.
- An enum member called `name` shadows `Enum.name` — through a generic `Enum` reference the store wrote one word and read the other (`LanguageEnum.label`).
- Two extension-type paths are equal at runtime — what must stay distinct is a sealed type (`DocumentTab`).
- `verify`'s codegen gate asks git, not the generator — the line is in [`tom-feature-flow`](.ai/skills/tom-feature-flow/SKILL.md).
- `gen-l10n` falls back to English silently for a key added in English only — `test/l10n/arb_test.dart` is what catches it.

**Markdown and the preview**

- `flutter_markdown_plus` renders a fence from `syntaxHighlighter` alone; `styleSheet.code` never reaches it — `CodeHighlighterImpl` wraps the colouring inside the style.
- The `markdown` package's syntaxes recognise each other by type — decorate a `BlockSyntax` and a setext heading silently becomes a paragraph. Extend, never wrap.
- Line endings are normalised in the parser and stripped by the block reader and the line differ, never in the document — a new comparison over lines strips `\r` itself.
- The `markdown` package's `TextSyntax` backtracks over a whole run with no space; `_LongRun` takes it in 200-character chunks ahead of it, so a new inline syntax goes after it.
- Links are resolved against the tree's listing (`PreviewLinksNotifier`), not the preview's own state — which would make the tree exist for every preview.

**Git and the processes TOM starts**

- `git restore --staged` is fatal on an unborn `HEAD`; `git pull` refuses divergent branches without `--no-rebase`; `invalid object name` must be anchored on `HEAD`, or a damaged object store reads as "no earlier version"; conflicted paths come from `diff --diff-filter=U`, never from `CONFLICT` lines.
- A command whose non-zero exit is an ordinary answer **declares it** (`answers:` — `config --get` of an unset key, `rev-parse --verify --quiet MERGE_HEAD`, `remote get-url origin` with no origin), or the Commands panel draws it as a failure.
- The base is deduced with `for-each-ref %(ahead-behind:HEAD)`, which needs git 2.41 or newer.
- The client may run below the repository root — a pathspec that means the whole repository is `:/`.
- `git remote get-url` expands `insteadOf` — what comes back is not what the config holds.
- Git decides hunk boundaries — two nearby edits come back as **one** conflict region.
- The staging refusal reads the document's **text**, not git's `u` record — staging is how a resolution is declared. It asks git's status first and reads only the paths git calls conflicted, one beside the space through `repositorySpace`; one marker line (`<<<<<<<`, `|||||||`, `=======`, `>>>>>>>`) is enough to refuse.
- A read an action makes for its own safety is a command with its own key — `deleteUncommitted` asks `ls-tree HEAD` before it deletes, `DiscardAllChangesUseCase` the merge state and `HEAD` before `reset` — and a refusal that means the list was stale re-reads git before `ChangesNotifier` publishes it.- A git killed by our own timeout leaves `.git` behind — a failed clone removes what it created; its timeout counts silence, not duration, and the URL is guarded by `--` with `ext::` refused.
- A pull request's drafts are found through `git rev-parse --git-common-dir`, never `<root>/.git` — a worktree's `.git` is a file.
- A push refusal for a protected branch is matched (`protected branch`, `GH006`, `GH013`) before the lost-race pattern, or it reads as a race and offers `Try again`.
- `log --follow` takes one path; the `:(top,literal)` pathspec works with it.
- `explorer`'s exit code lies on Windows; `DesktopShell` does not read it.

**Architecture and wiring**

- A screen's `widgets/` are readable from that screen only — a control one screen owns and another mounts lives at the owner's top level (`CompareControlWidget`), and `test arch` says so on the first run.
- A widget added to `tom_ui` needs its row in `docs/design/components/controls.md` — `test arch` fails without one, and on a row naming a widget that is gone.
- A plugin cannot live in a pure-Dart package — what needs Flutter is handed in from the composition root (`BundledFacesPdfExporterImpl` for the asset bundle's fonts) — the pty is no case of it, `pty2` being pure Dart.
- A value that crosses a repository belongs to the domain, not to presentation (`ThemeChoiceEnum`).

**Platform and build**

- The macOS Podfile needs `platform :osx, '12.0'` *and* a `post_install` raising `MACOSX_DEPLOYMENT_TARGET` — Flutter writes 10.15 back.

**Sessions and agents**

- Background agents stall when the machine sleeps; resuming them works, and they stall again unless it is kept awake (`caffeinate -di`). A stalled agent can leave a temporary render test behind (`zz_*_render_test.dart`) — the analyser finds it.

> Keep this section a status. At the end of a meaningful session: add what now exists, delete what closed, and put a new trap in the group — or the skill — it belongs to. A dated paragraph belongs in the commit message.
