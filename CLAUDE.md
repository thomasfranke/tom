# CLAUDE.md

Project context for AI assistance. Read before any task.

## What this project is

**TOM — Team-Oriented Markdown** *(binary: `tom`)* — a desktop Git client specialized in markdown documentation. Flutter Desktop (Windows/macOS/Linux), open source (MIT), open-core business model.

**Pitch:** "A GitHub Desktop for docs". The differentiator is the Git workflow as a first-class citizen (*rendered* markdown diff, branch/commit/push without ceremony) — NOT the editor, which is deliberately simple (source + preview, no WYSIWYG).

## Source of truth

Every relevant decision lives in `docs/`. **Before suggesting architecture, dependencies or scope, consult:**

- `docs/README.md` — general index
- `docs/products/` — **the source of truth for what each feature must do**, in non-technical language, one folder per feature (`doc.md` + `mocks/`). Maintained by stakeholders, kept current as the app evolves. Check the relevant `doc.md` before implementing or changing a feature's behavior, and flag it if the code diverges from what's written there.
- `docs/product/` — `product.md` for the pitch, principles, personas, killer features and **non-goals** (respect them!); `roadmap.md` for spikes, phases, milestones and links to the relevant `docs/products/` entries — whatever is out of the MVP stays out
- `docs/architecture/` — four files: `layers.md` (the graph and what enforces it), `flows.md` (how it behaves at runtime), `domain-model.md`, `dependencies.md`
- **Read selectively.** Consult only the files relevant to the task at hand; never load `docs/` wholesale. The index above exists so the right file can be picked without reading the rest.
- `docs/decisions/` — formalized decisions (ADR format, declarative names); changing a decision requires a new file or an explicit revision
- **The canonical form of a rule is the dartdoc of the code that implements it** — `docs/architecture/` states the rule, the code shows it. When the two disagree, the code is right and the doc is a bug.
- `docs/architecture/dependencies.md` — stack with licenses; `docs/product/roadmap.md` — goals, phases, open questions

## Non-negotiable rules (summary of the decisions)

1. **MIT license** — NO AGPL/GPL dependency (no `appflowy_editor`). Check the license of every new package (Decision 1).
2. **Git through the system binary** (`Process.run`) behind contracts — do not suggest libgit2/FFI at this phase (Decision 2).
3. **No WYSIWYG** — the editor is source + preview (Decision 3).
4. **No `dartz`** — Result with native sealed classes, exhaustive switch, early return (Decision 5); rules in `docs/architecture/layers.md#errors-across-boundaries`; the types live in `src/packages/core/lib/src/` and `src/packages/domain/lib/src/`. Inline try/catch mandatory in every use case.
5. **No navigation package** — plain `Navigator` for dialogs only (Decision 6).
6. **External dependencies isolated behind contracts** in infrastructure (Decision 7); Riverpod ONLY in presentation + bootstrap/di — no `Ref` in any other layer; constructor injection (`docs/architecture/flows.md#wiring-three-lifetimes`).
7. **One package per layer** (Decision 14, revising 8): `src/packages/{core,domain,application,infra,data,presentation}` are pure Dart with NO Flutter in the pubspec; only `src/apps/desktop` has Flutter. A layer may depend only on the ones below it — enforced by the pubspecs, by `depend_on_referenced_packages`/`implementation_imports` as errors, and by `src/test/architecture_test.dart`.
8. **Files are the truth** — never propose a database or state that is not rebuildable from the `.md` files on disk. The FTS5 index is a cache.
9. **Telemetry is opt-in** — observability behind a contract, no-op by default; no data leaves the user's machine (Decision 11).
10. **Extensible shell** — panels are ALWAYS registered through `TomModule`/`PanelDescriptor`, never hardcoded in the shell, including the built-in ones (Decision 12; `docs/architecture/flows.md#panels-are-registered-never-hardcoded`).
11. **The public repo documents the free product only** — no tier catalogue, no pricing, no licensing mechanics, no reference to a private repository. Commercial modelling lives outside this repo (Decision 4).
12. **A space is a folder, not a repository** — `Space` carries `root` and `repositoryRoot` separately; git runs against the repository, navigation and search stay in the folder.

## Stack (summary — details in docs/dependencies.md)

Riverpod (codegen) + Freezed · `markdown` (AST) · `diff_match_patch` · `re_editor` (spike pending) · `sqlite3` + FTS5 · `watcher` · `window_manager` / `file_selector` · `dart:io Process` for Git. Why Dart rather than a web stack, and where Rust could still enter via FFI: Decision 13.

## Code structure

See `docs/architecture/layers.md` (source of truth). The Dart workspace lives under `src/`; run everything through `make` from the repository root.

```
core ← domain ← application ← presentation
  ↑       ↑                        ↑
  └─── infra ← data ─────────────  desktop
```

`core` holds `Result`, the `AppFailure` marker and the ports every layer needs — mechanism, never product vocabulary; `domain` holds entities, value objects, the sealed failure hierarchies (`GitFailure`, `DocumentFailure`, `SearchFailure`), repository contracts and BlockDiffer; `application` use cases; `infra` capability contracts *and* their implementations, one folder per capability with the impl in a subfolder named after how it is done (`git_client/process/`); `data` parsers and repository implementations; `presentation` the space session and notifiers, pure Dart so it cannot reach a widget; `apps/desktop` the composition root and the widgets.

## Conventions

- **Git workflow (branches, commits, PRs, releases): see the `tom-git-workflow` skill** in `.claude/skills/` — consult it before committing, branching, or opening a PR. Human-facing version: `CONTRIBUTING.md`.
- Conventional Commits + semantic versioning. Trunk-based: `feat/*` → PR into `main` (squash) → tag publishes. No `dev` branch. `main` is publishable; production is the most recent tag.
- **Incomplete work integrates behind a build-time feature flag**, never on a long-lived branch (`CONTRIBUTING.md`, "Feature flags"). Disabled = unreachable, and every flag has a removal target.
- Documentation updated in the same PR that changes behavior (dogfooding: this project exists for that)
- **If a PR changes a product's user-facing interface, it updates that product's mock in the same PR** (`docs/products/<feature>/mocks/`) — a mock that no longer matches what shipped is worse than no mock, see [docs/products/README.md](docs/products/README.md)
- A new architecture decision → a new file in `docs/decisions/` following the existing format
- **All documentation and code in English** (identifiers, comments, docs)

## Current status

**Phase 0 — Spikes.** No milestone has been built. The workspace skeleton is in place and the error model is real code: `Result`, `AppFailure` and `Observability` in `tom_core`; the sealed `GitFailure`/`DocumentFailure`/`SearchFailure` hierarchies in `tom_domain` (8 tests). `docs/architecture/` was consolidated from 13 files into four. The domain model is deliberately partial (`docs/architecture/domain-model.md`) — `Block` in particular is an *output* of Spike B; do not design `BlockDiffer` before the spike reports. Next steps: Spike A (`re_editor` as source mode) and Spike B (the `markdown` AST for block diff, now also answering whether a single block can be rendered in isolation). See `docs/product/roadmap.md`. There is no user-research phase: the project is built on the maintainer's own experience, stated as such in `docs/product/roadmap.md`. Desktop wireframes for M0/M1 live in `docs/design/` (skill: `tom-wireframes`).

> Keep this "Current status" section up to date at the end of each meaningful work session — it is what carries context between sessions.
