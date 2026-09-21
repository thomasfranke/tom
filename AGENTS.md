# AGENTS.md

Entry point for any AI agent working in this repository (platform-agnostic
by design — Claude Code, Codex, Cursor, or anything that reads this file).
Read before any task.

## What this project is

**TOM — Team-Oriented Markdown** *(binary: `tom`)* — a desktop Git client specialized in markdown documentation. Flutter Desktop (Windows/macOS/Linux), open source (MIT), open-core business model.

**Pitch:** "A GitHub Desktop for docs". The differentiator is the Git workflow as a first-class citizen (*rendered* markdown diff, branch/commit/push without ceremony) — NOT the editor, which is deliberately simple (source + preview, no WYSIWYG).

## Source of truth

`docs/` is two folders and two files, split by audience (product vs. technical), with `about.md` as the shared context above the fork and `roadmap.md` as the order things arrive in. **Before suggesting architecture, dependencies or scope, consult:**

- [`docs/about.md`](docs/about.md) — what the project *is*: the bet, principles, personas, killer features and **non-goals** (respect them!). Short by design; read it first.
- [`docs/product/`](docs/product/README.md) — **the source of truth for what each feature must do**, in non-technical language, one folder per feature (`doc.md` + `mocks/`). Maintained by stakeholders, kept current as the app evolves. Check the relevant `doc.md` before implementing or changing a feature's behavior, and flag it if the code diverges from what's written there.
- [`docs/technical/`](docs/technical/README.md) — how it is built: `layers.md` (the graph and what enforces it), `flows.md` (runtime behaviour), `domain-model.md`, `dependencies.md` (stack with licenses), the development process, `decisions/` (ADRs — a new decision is a new file, changing one requires an explicit revision) and `design/` (wireframes and the visual language).
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
| [`tom-git-workflow`](.ai/skills/tom-git-workflow/SKILL.md) | committing, staging, writing a commit message, creating a branch, opening or merging a PR, cutting a release, applying a hotfix — or the user says "commit this", "push", "open a PR", "ship it", or asks which branch to target | Trunk-based on `main`, branch naming, Conventional Commits with the monorepo's scopes, squash policy, releases as tags, what differs in `tom-pro` |
| [`tom-pr-writer`](.ai/skills/tom-pr-writer/SKILL.md) | about to open a PR, "write the PR", "draft a PR description", finishing a branch, reviewing or rewriting an existing description, writing the squash commit message | Inspecting the real diff before writing, title = the Conventional Commit the squash will produce, the What/Why/Notes template |
| [`tom-wireframes`](.ai/skills/tom-wireframes/SKILL.md) | drawing, editing or reviewing a wireframe, mock or screen layout; "wireframe", "mock up a screen", "draw the layout", "excalidraw"; adding a screen to `docs/technical/design/` | The shared drawing kit, design tokens, components, and the rules that keep every screen looking like one product |

How they are maintained, and why `tom-pro` inherits them by relative path
instead of copying: [`.ai/skills/README.md`](.ai/skills/README.md).

## Non-negotiable rules (summary of the decisions)

1. **MIT license** — NO AGPL/GPL dependency (no `appflowy_editor`). Check the license of every new package (Decision 1).
2. **Git through the system binary** (`Process.run`) behind contracts — do not suggest libgit2/FFI at this phase (Decision 2).
3. **No WYSIWYG** — the editor is source + preview (Decision 3).
4. **No `dartz`** — Result with native sealed classes, exhaustive switch, early return (Decision 5); rules in `docs/technical/layers.md#errors-across-boundaries`; the types live in `src/packages/core/lib/src/` and `src/packages/domain/lib/src/`. Inline try/catch mandatory in every use case.
5. **No navigation package** — plain `Navigator` for dialogs only (Decision 6).
6. **External dependencies isolated behind contracts** in infrastructure (Decision 7); Riverpod ONLY in presentation + bootstrap/di — no `Ref` in any other layer; constructor injection (`docs/technical/flows.md#wiring-three-lifetimes`).
7. **One package per layer** (Decision 14, revising 8): `src/packages/{core,domain,application,infra,data,presentation}` are pure Dart with NO Flutter in the pubspec; only `src/apps/desktop` has Flutter. A layer may depend only on the ones below it — enforced by the pubspecs, by `depend_on_referenced_packages`/`implementation_imports` as errors, and by `src/test/architecture_test.dart`.
8. **Files are the truth** — never propose a database or state that is not rebuildable from the `.md` files on disk. The FTS5 index is a cache.
9. **Telemetry is opt-in** — observability behind a contract, no-op by default; no data leaves the user's machine (Decision 11).
10. **Extensible shell** — panels are ALWAYS registered through `TomModule`/`PanelDescriptor`, never hardcoded in the shell, including the built-in ones (Decision 12; `docs/technical/flows.md#panels-are-registered-never-hardcoded`).
11. **The public repo documents the free product only** — no tier catalogue, no pricing, no licensing mechanics, no reference to a private repository. Commercial modelling lives outside this repo (Decision 4).
12. **A space is a folder, not a repository** — `Space` carries `root` and `repositoryRoot` separately; git runs against the repository, navigation and search stay in the folder.
13. **Freezed is mandatory for immutable data** — entities, value objects with more than one field, presentation view-state, and sealed hierarchies; no hand-written `==`/`copyWith` once a class qualifies (Decision 16). Single-field identifier/path value objects (`BranchName`, `CommitSha`…) are the one recommended exception — an `extension type` fits better there.

## Stack (summary — details in docs/technical/dependencies.md)

Riverpod (codegen) + Freezed · `markdown` (AST) · `diff_match_patch` · `re_editor` (spike pending) · `sqlite3` + FTS5 · `watcher` · `window_manager` / `file_selector` · `dart:io Process` for Git. Why Dart rather than a web stack, and where Rust could still enter via FFI: Decision 13.

## Code structure

See `docs/technical/layers.md` (source of truth). The Dart workspace lives under `src/`; run everything through `dart run tool/tom.dart <command>` from the repository root (`make` targets are one-line shortcuts over the same CLI, and `tool/` never calls back into `make`).

```
core ← domain ← application ← presentation
  ↑       ↑                        ↑
  └─── infra ← data ─────────────  desktop
```

`core` holds `Result`, the `AppFailure` marker and the ports every layer needs — mechanism, never product vocabulary; `domain` holds entities, value objects, the sealed failure hierarchies (`GitFailure`, `DocumentFailure`, `SearchFailure`), repository contracts and BlockDiffer; `application` use cases; `infra` capability contracts *and* their implementations, one folder per capability with the impl in a subfolder named after how it is done (`git_client/process/`); `data` parsers and repository implementations; `presentation` the space session and notifiers, pure Dart so it cannot reach a widget; `apps/desktop` the composition root and the widgets.

## Conventions

- **Git workflow (branches, commits, PRs, releases): see the `tom-git-workflow` skill** in `.ai/skills/` — consult it before committing, branching, or opening a PR. Human-facing version: `CONTRIBUTING.md`.
- Conventional Commits + semantic versioning. Trunk-based: `feat/*` → PR into `main` (squash) → tag publishes. No `dev` branch. `main` is publishable; production is the most recent tag.
- **Incomplete work integrates behind a build-time feature flag**, never on a long-lived branch (`CONTRIBUTING.md`, "Feature flags"). Disabled = unreachable, and every flag has a removal target.
- Documentation updated in the same PR that changes behavior (dogfooding: this project exists for that)
- **If a PR changes a product's user-facing interface, it updates that product's mock in the same PR** (`docs/product/<group>/<feature>/mocks/`) — a mock that no longer matches what shipped is worse than no mock, see [docs/product/README.md](docs/product/README.md)
- A new architecture decision → a new file in `docs/technical/decisions/` following the existing format
- **All documentation and code in English** (identifiers, comments, docs)

## Current status

**Phase 0 — Spikes.** No milestone has been built. The workspace skeleton is in place and the error model is real code: `Result`, `AppFailure` and `Observability` in `tom_core`; the sealed `GitFailure`/`DocumentFailure`/`SearchFailure` hierarchies in `tom_domain`; `FilesystemFailure` and `GitClientFailure` in `tom_infra` (96 tests across the workspace). Every `AppFailure` hierarchy is now Freezed — `tom_core`, `tom_domain` and `tom_infra` each carry `freezed`/`freezed_annotation`/`build_runner`, generated equality replaces the hand-written `==`/`hashCode`, and `--ignore-files` keeps `*.freezed.dart` out of the coverage gate (`tool/src/commands/coverage_gate.dart`, `tool/src/commands/run_tests.dart`, `tom coverage`). `docs/architecture/` was consolidated from 13 files into four, and `docs/` then settled on `about.md` + `roadmap.md` + `product/` + `technical/`, with `architecture/`, `process/`, `decisions/` and `design/` folding into `technical/` and `products/` becoming `product/`. The domain model is deliberately partial (`docs/technical/domain-model.md`) — `Block` in particular is an *output* of Spike B; do not design `BlockDiffer` before the spike reports. The task/spec process was removed in full: `docs/tasks/`, `docs/specs/` and the leftover `work/` queue are gone, along with the schemas and the selection algorithm that went with them — work is picked from `docs/roadmap.md` or asked for directly, and nothing has to be filed before it can be built. `tom_infra` holds two of the five capabilities `layers.md` names: `filesystem/` and now `git_client/` — the `GitClient` contract, the sealed `GitClientFailure`, and `dart_io/` driving the system binary with a serialized per-space queue, a forced environment that leaves no prompt to answer (`GIT_TERMINAL_PROMPT`, `GIT_ASKPASS`, `SSH_ASKPASS_REQUIRE`, plus `GIT_OPTIONAL_LOCKS`/`LC_ALL`), timeouts that kill the process, and stderr recognised into typed failures (46 tests, most of them integration against real `git init` repositories and a local bare remote). **Text crosses that contract, never an entity**: `GitStatus`, `Commit` and `Branch` are domain types (`docs/technical/domain-model.md`) and the parsers that build them belong to `tom_data`, so every method documents the exact format it returns. Two doc deltas wait on the human gate: `layers.md` still names the implementation folder `process/` (the code says `dart_io/`, after the capability's package, matching `filesystem/dart_io/`), and Decision 2 still calls the contract `GitClientInterface`. `markdown_parser/` and `text_differ/` sit behind Spike B and `search_index/` is M2. File watching and settings are used by the roadmap but are not yet declared capabilities in `layers.md`. `Filesystem` has since grown the two operations M0 needs beyond read and write: `listDirectory` (one level or recursive, sorted, links reported and never followed, nothing filtered — hiding `.git/` is the file tree's policy, not the capability's) and `directoryExists`, which answers false for a folder that is gone but fails when the machine will not say. `FilesystemEntry` and its type enum live in their own files beside the interface, which holds nothing but the contract. A review of `tom_domain` and `tom_data` closed nine findings, all with tests: `RepoRelativePath` and `BranchName` now validate segment by segment (no `..`, no empty segment, no drive letter; no `@{`, no component starting or ending in `.`, `.lock` per component) — the branch rules were checked against `git check-ref-format --branch` and are a strict subset of it; `GitLogParser` trims the commit body on the right only, because leading indentation is markdown content; a porcelain `2` record is a rename *or a copy*, so `previousPath` is attached only to a rename; every failure variant now carries its hierarchy's prefix (`DocumentPermissionDenied`, `GitMergeConflict`, `SearchIndexCorrupted`…), matching what `tom_infra` already did; the `-z` NUL is `GitClient.nulSeparator` rather than a second copy in the parser. Two of the nine were design, not slips: `Commit.date` is a `CommitDate` (instant + the author's offset) because `DateTime` silently discards the offset `%aI` carries, and `GitStatus.isDetached` is a field rather than `branch == null`, because an unparseable branch name also produced null and was being reported as a detached `HEAD`. The ninth is open by decision: Freezed compares collections element-wise but does not copy them, so `GitStatus.entries` and `GitMergeConflict.conflictedFiles` are handed over rather than copied — the producer passes `List.unmodifiable` and the contract is stated on the fields, but making it structural needs an immutable-collection package (license check under rule 1, plus an ADR) and was left for the maintainer. A review of `tom_infra` closed eleven findings, nine of them with a test that fails without the fix. On `GitClient`: every path crossing the contract is now repository-root relative in both directions — `stage`, `unstage` and `log(path:)` send `:(top,literal)` pathspecs, so a path read from `status()` can be handed straight back, which was broken for every space that is a folder *inside* a repository rather than the repository itself (rule 12, i.e. the normal case); the conflicted paths of a `GitClientMergeConflict` come from the index (`diff --diff-filter=U`) rather than from the `CONFLICT` lines, which spell out a content clash and nothing else — a modify/delete conflict used to be announced with no file named at all; a killed command stops waiting on pipes a surviving grandchild still holds, which left the space's serialized queue stuck for as long as that process lived, the very stall the timeout exists to prevent; `log()` on a branch with no commits yet returns nothing instead of failing; and the probe that tells "no git" from "no folder" can no longer throw a `FileSystemException` out of the package. On `Filesystem`: `writeFile` creates the directories its path needs and lands through a temporary sibling and a rename, so a crash mid-save cannot leave a truncated document; `readFile` decodes UTF-8 explicitly and refuses anything else as the new `FilesystemNotUtf8` rather than writing replacement characters back over bytes it could not read (a capability decision — `docs/product/` rules on no encoding yet); a recursive `listDirectory` skips a folder the machine will not open instead of losing the whole tree, and names the path that actually failed; and the translation reads `dart:io`'s exception types instead of raw `errno`, which had POSIX `EIO` reported to the user as a permission problem. 77 tests in the package, 98% line coverage. `tom_data` now fulfils its first contract: `GitRepository` (the domain's git vocabulary — entities in, entities out) and `GitRepositoryImpl` over the `GitClient` capability, where the three parsers turn text into `GitStatus`/`Commit`/`Branch` and a switch that is exhaustive by construction turns every `GitClientFailure` into a `GitFailure`; a failure the capability cannot produce passes through untouched rather than being dressed up as a command that was never run (86 tests in the package, 100% line coverage, unit for the translation and integration against real `git init` repositories). Two `GitFailure` variants were promoted out of infrastructure's vocabulary — `pushRejected`, which the product shows as its own outcome, and `timedOut` — plus `DocumentFailure.notUtf8` to match `FilesystemNotUtf8`; `GitDetachedHead` is still produced by nothing, because git commits happily on a detached `HEAD` and refusing is a use case's policy, not a command's failure. The integration test found one real defect in `tom_infra`, fixed with a test that fails without it: `unstage` ran `git restore --staged`, which rebuilds the index from `HEAD` and is therefore fatal on a repository with no commits yet — the normal state of a space opened on a fresh `git init` — and now falls back to taking the path back out of the index, `--ignore-unmatch` so both branches behave alike. The domain gained the entities the model already called settled: `Space` (`root`, `repositoryRoot`, `name`, with the enclosure invariant asserted and the assertion's helpers as private top-level functions, since a Freezed `@Assert` is evaluated in the generated part and cannot see a static) and `Document`, plus `SpaceRelativePath` beside `RepoRelativePath` — one syntax rule shared, two types, and `Space` as the only converter, `toSpaceRelative` answering null for what the space does not contain. Next steps: `DocumentRepository` over `Filesystem` (read, write, and the listing the file tree needs — which wants a domain type for a tree entry); then Spike A (`re_editor` as source mode) and Spike B (the `markdown` AST for block diff, now also answering whether a single block can be rendered in isolation). See `docs/roadmap.md`. There is no user-research phase: the project is built on the maintainer's own experience, stated as such in `docs/roadmap.md`. Desktop wireframes for M0/M1 live in `docs/technical/design/` (skill: `tom-wireframes`).

> Keep this "Current status" section up to date at the end of each meaningful work session — it is what carries context between sessions.
