# AGENTS.md

Entry point for any AI agent working in this repository (platform-agnostic
by design — Claude Code, Codex, Cursor, or anything that reads this file).
Read before any task.

## What this project is

**TOM — Team-Oriented Markdown** *(binary: `tom`)* — a desktop Git client specialized in markdown documentation. Flutter Desktop (Windows/macOS/Linux), open source (MIT), open-core business model.

**Pitch:** "A GitHub Desktop for docs". The differentiator is the Git workflow as a first-class citizen (*rendered* markdown diff, branch/commit/push without ceremony) — NOT the editor, which is deliberately simple (source + preview, no WYSIWYG).

## Source of truth

`docs/` follows [WritRun](https://github.com/thomasfranke/whitrun): four folders, split by audience (product vs. technical) and by nature (permanent vs. work in progress), with `about.md` as the shared context above the fork. **Before suggesting architecture, dependencies or scope, consult:**

- [`docs/about.md`](docs/about.md) — what the project *is*: the bet, principles, personas, killer features and **non-goals** (respect them!). Short by design; read it first.
- [`docs/product/`](docs/product/README.md) — **the source of truth for what each feature must do**, in non-technical language, one folder per feature (`doc.md` + `mocks/`). Maintained by stakeholders, kept current as the app evolves. Check the relevant `doc.md` before implementing or changing a feature's behavior, and flag it if the code diverges from what's written there.
- [`docs/technical/`](docs/technical/README.md) — how it is built: `layers.md` (the graph and what enforces it), `flows.md` (runtime behaviour), `domain-model.md`, `dependencies.md` (stack with licenses), the development process, `decisions/` (ADRs — a new decision is a new file, changing one requires an explicit revision) and `design/` (wireframes and the visual language).
- [`docs/tasks/`](docs/tasks/README.md) — the queue, plus `roadmap.md` for spikes, phases and milestones — whatever is out of the MVP stays out. **The queue is empty today**: work is still selected from the roadmap, and the [selection algorithm](docs/technical/README.md#task-selection-algorithm) has nothing to run against yet.
- [`docs/specs/`](docs/specs/README.md) — the detail of one change. Also empty today.
- **Read selectively.** Consult only the files relevant to the task at hand; never load `docs/` wholesale. The index above exists so the right file can be picked without reading the rest.
- **The canonical form of a rule is the dartdoc of the code that implements it** — `docs/technical/` states the rule, the code shows it. When the two disagree, the code is right and the doc is a bug.

## Human gates

Three checkpoints, named explicitly rather than implied. Everything not on this table — creating tasks, drafting specs, implementing an approved spec, filling a spec's Outcome — is agent work, autonomously.

| Transition | Who |
|---|---|
| Changing a permanent doc: `docs/about.md`, anything under `docs/product/` or `docs/technical/` | Human writes it or reviews it before merge. Agents may draft; a permanent doc never merges on agent approval alone. |
| Spec `draft → approved` | **Human only.** An agent never self-approves, not even a draft it wrote itself. |
| A task with an empty `spec_ref` whose body plus `product_ref` is not a sufficient brief | **Stop and ask** whether to draft a spec first. Never improvise scope to keep moving. |

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

See `docs/technical/layers.md` (source of truth). The Dart workspace lives under `src/`; run everything through `make` from the repository root.

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

**Phase 0 — Spikes.** No milestone has been built. The workspace skeleton is in place and the error model is real code: `Result`, `AppFailure` and `Observability` in `tom_core`; the sealed `GitFailure`/`DocumentFailure`/`SearchFailure` hierarchies in `tom_domain`; `FilesystemFailure` in `tom_infra` (55 tests across the workspace). Every `AppFailure` hierarchy is now Freezed — `tom_core`, `tom_domain` and `tom_infra` each carry `freezed`/`freezed_annotation`/`build_runner`, generated equality replaces the hand-written `==`/`hashCode`, and `--ignore-files` keeps `*.freezed.dart` out of the coverage gate (`tool/coverage_gate.dart`, `tool/run_tests.dart`, `make coverage`). `docs/architecture/` was consolidated from 13 files into four, and `docs/` was then restructured to the WritRun layout — `about.md` + `product/` + `technical/` + `tasks/` + `specs/` — with `architecture/`, `process/`, `decisions/` and `design/` folding into `technical/`, `products/` becoming `product/`, and the roadmap moving next to the (still empty) queue. The domain model is deliberately partial (`docs/technical/domain-model.md`) — `Block` in particular is an *output* of Spike B; do not design `BlockDiffer` before the spike reports. Next steps: Spike A (`re_editor` as source mode) and Spike B (the `markdown` AST for block diff, now also answering whether a single block can be rendered in isolation). See `docs/tasks/roadmap.md`. There is no user-research phase: the project is built on the maintainer's own experience, stated as such in `docs/tasks/roadmap.md`. Desktop wireframes for M0/M1 live in `docs/technical/design/` (skill: `tom-wireframes`).

> Keep this "Current status" section up to date at the end of each meaningful work session — it is what carries context between sessions.
