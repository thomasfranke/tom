---
name: tom-code-review
description: How code is reviewed in the TOM repositories — the subject is the branch's diff against main and nothing else unless something specific is asked for; what the tooling already proves, the architecture and pattern rules only a reader can check (the layer graph, Result and the failure hierarchies, Freezed, typed paths, the capability contracts, the session and module patterns in presentation, the test layout, the docs that must move with the change), the general canon the project is held to (Effective Dart, Clean Architecture, DDD as Decision 15 applies it, the Dart community's conventions) and its precedence, package by package, and which settled decisions are never a finding. Use this skill whenever reviewing a diff, a branch or a PR in tom or tom-pro; when running /code-review, /simplify or /security-review in this repository; when the user says "review this", "does this follow the architecture", "is this ok to merge", "olha esse código"; or before opening a PR, as the last pass over your own work.
---

# TOM — reviewing code

A review here has two jobs, and only the second one needs a reader.

1. **The tooling proves the mechanical half.** Run it; do not re-check by eye what it already answers.
2. **The architecture and the patterns are the review.** They come from `docs/technical/layers.md` and `flows.md`, from the decisions in `docs/technical/decisions/`, and from the dartdoc of the code that already implements them — and nothing in the build catches them.

Three things about the reviewer's stance before any rule:

- **The canonical form of a rule is the dartdoc of the code that implements it.** `docs/technical/` states the rule; the code shows it. When the two disagree, the code is right and the doc is the bug — the finding names which of the two the diff should have moved, and it is not "make the code match the doc" by reflex.
- **`layers.md` and its testing section are normative.** Every other technical doc describes current practice. Deviating from a normative section requires a new file in `docs/technical/decisions/` in the same change — never a silent exception.
- **The answer to a settled decision is an ADR, not a comment.** A diff that contradicts a decision either changes or writes the decision that revises it (status of the old one becomes *superseded by NNN*; nothing is deleted). Both are legitimate outcomes of a review; a quiet workaround is not.

Reviewing your own branch before a PR is the same pass — run it before drafting the description (`tom-pr-writer`).

## What is under review

**The branch's diff against `main`, and nothing else** — unless the user names something specific (a file, a package, a contract, "look at the whole git client"), in which case that is the subject and the diff is not.

```bash
git fetch origin main
git diff origin/main...HEAD --stat     # what is under review
git diff origin/main...HEAD            # the change itself
```

Code the diff merely touches, sits next to, or calls is **context, not subject**: read it to judge the change, do not review it. A finding must point at a line the branch added or changed. Pre-existing problems seen along the way are not findings — if one is serious, one sentence at the end, marked as outside the diff, and no more; whether that becomes a review is the user's call to make, not yours to pre-empt.

## Step 1 — let the tooling speak first

Everything runs through the `tom` CLI from the repository root; `make` targets are one-line faces over it (Decision 17).

```bash
dart run tool/tom.dart verify       # format, analyze, codegen gate, every test, coverage gate — in that order, first failure stops
dart run tool/tom.dart test arch    # the layer graph on its own
dart run tool/tom.dart test diff    # only what this branch's diff maps to, while iterating
```

`verify` is what CI runs. If it is red, that is the finding — report it and stop; a review of code that does not compile, does not regenerate identically, or drops a package under the coverage threshold (95% by default, `*.freezed.dart` excluded) is wasted on both sides.

What the tooling already covers, and must therefore **never appear as a review finding**: formatting; every lint in `src/analysis_options.yaml` (`always_specify_types`, `public_member_api_docs`, `require_trailing_commas`, `lines_longer_than_80_chars`, `avoid_catches_without_on_clauses`, `always_use_package_imports`…); an import of a package the layer never declared; reaching into another package's `lib/src/`; `dart:io`/`dart:ffi`/`dart:isolate`/Flutter in a package that may not have them; a Flutter package arriving through `dev_dependencies`; a `dependency_overrides` anywhere; generated code that drifted from its source.

## Step 2 — the rules that cut across every package

Ordered by blast radius: a layering mistake outlives every other kind.

### The graph, and the three holes in it

```
core ← domain ← application ← presentation
  ↑       ↑                        ↑
  └─── infra ← data ─────────────  desktop
```

`src/test/integrity/architecture_test.dart` holds this, but three things slip past it and belong to the reviewer:

- **A dependency added to a pubspec, or a package added to the test's own tables.** The test reads the pubspecs, so a diff that edits one edits the rule it is checked against. Any new line in a `dependencies:` block, and any edit to `graph`/`forbiddenImports` in the test, is a finding until justified against the table in `layers.md` — and, if the graph genuinely changed, an ADR.
- **`tom_core` growing vocabulary.** It holds mechanism — `Result`, `AppFailure`, `UnexpectedFailure`, `Observability` — and names no product concept. Git, documents, spaces and search are vocabulary and belong to `tom_domain`; otherwise the package everything depends on becomes the package that changes most. `Observability` is the stated exception (every use case takes one, and `tom_application` cannot see `tom_infra`) and is explicitly not a precedent.
- **A dependency's type crossing a contract.** A `ProcessException` dies inside `git_client/dart_io/` and leaves as a `GitClientFailure`; a `FileSystemException` never escapes `filesystem/dart_io/`; a `markdown` package `Node` never reaches `tom_domain`. If one escapes, the folder is decoration.

### Errors across boundaries (Decision 5)

Every repository method and every use case returns `Result<T>`; an exception never crosses a layer boundary.

- A use case wraps its body in the standardized inline `try/catch`, hands what it caught to `Observability.capture(error, stackTrace, layer: 'application')`, and returns `UnexpectedFailure` — never rethrows, never swallows. Mandatory per use case, not lint-enforced: its absence is a finding. `capture` itself never throws.
- **Technical failures become domain failures in `tom_data`**, by a switch that is exhaustive over the sealed capability hierarchy with no default branch. A failure the capability cannot produce passes through untouched — never dressed up as something that did not happen (a `GitCommandFailed` for a command that was never run puts a lie in the UI's "details").
- A new variant in a sealed hierarchy is a breaking change on purpose: every switch that must handle it was updated, and nobody reached for a catch-all to avoid the work. A switch over `AppFailure` itself takes a catch-all; a switch over an area hierarchy does not.
- Variants carry their hierarchy's prefix — `DocumentPermissionDenied`, `GitMergeConflict`, `SearchIndexCorrupted`, `FilesystemNotUtf8`, `SpaceFolderMissing`. Each hierarchy has a typed fallback (`GitCommandFailed`, `DocumentOperationFailed`, `SpaceOperationFailed`); a variant promoted out of the fallback is a variant that earned a name, and the diff says why.
- A variant nothing produces is a design claim and needs its reason in the dartdoc. `GitDetachedHead` is the standing example: git commits happily on a detached `HEAD`, so refusing is a use case's policy, not a command's failure.
- Early return, not monadic chaining. A `flatMap` extension is the documented fallback if it ever earns its keep; a `dartz`-shaped helper is not.

### Immutable data (Decision 16)

- Entity, value object with more than one field, presentation view-state, sealed hierarchy → `@freezed`. A hand-written `==`/`hashCode`/`copyWith` on a class that qualifies is a finding, not a preference.
- Single-field identifier/path wrapper (`BranchName`, `CommitSha`, `RepoRelativePath`) → `extension type`, *recommended* — a Freezed single-field class is a note, not a finding. A wrapper that grows a second field is the trigger to revisit.
- Use cases, repositories, infra implementations, notifiers, widgets are not data — leave them alone.
- **Freezed compares collections element-wise but does not copy them.** A Freezed field holding a `List` is handed over, not owned: the producer passes `List.unmodifiable` and the field's dartdoc states it (`GitStatus.entries`, `GitMergeConflict.conflictedFiles`). A new collection field without both is a finding. Making it structural needs an immutable-collection package — license check plus an ADR — and is the maintainer's call, not a PR's.
- A `@Assert` is evaluated in the generated part and cannot see a static: its helpers are private top-level functions (`Space` shows the shape). A constructor that stops being `const` for the sake of an invariant is the right trade and says so.

### Paths and vocabulary (Decision 15, rule 12)

**A space is a folder, not a repository.** `Space` carries `root` and `repositoryRoot` separately; git runs against the repository, navigation, search and the watcher stay inside the folder.

- `RepoRelativePath`, `SpaceRelativePath` and absolute `String` paths are distinct types on purpose — path confusion is the most probable bug in this application. A new signature taking a `String` where one of the two relative types belongs is a finding.
- `Space` is the only converter: `toRepoRelative`, `toSpaceRelative` (null for what the space does not contain — an ordinary answer, handled, never `!`-ed), `relativize` (from the absolute paths the filesystem reports), `absolutePathOf`. A conversion written anywhere else is a finding.
- The documentation's words are the code's words: Space, Document, Block, DiffBlock, SpaceEntry. No `FileModel`, no `DocDto`, no `SpaceEntity`. A concept renamed in code is renamed in `docs/` in the same PR.

### Tests (`layers.md#testing`, normative)

`test/` mirrors `lib/src/` exactly, under `unit/`, `integration/` or `integrity/` — chosen by what the test needs, not by which package it is in. A test in the wrong folder, or a path that does not mirror its subject, is a finding: the layout is what answers "where are this file's tests" without a search.

| Changed | Expected |
|---|---|
| a parser | unit, fixtures of real git output |
| `BlockDiffer` | unit / golden, versioned md pairs + expected classification |
| a use case | unit, fake repositories, failure propagation covered |
| a repository or capability implementation | **integration against a real `git init` repo or real disk** |
| a notifier | unit, `ProviderContainer` with overridden use cases |
| UI | widget / golden for the main states |

Integration against real git is the project's confidence differentiator — a diff that mocks it away is a finding even when the mocked test passes. A bug fix without a test that fails without the fix is an unfinished fix. "No tests" is acceptable only with a stated reason.

### What must move with the change

- Behavior changed → the documentation, in the **same PR**. A technical doc **links** to the `docs/product/` chapter that owns a rule and never restates it; a new paragraph in `docs/technical/` that spells out a product rule is a finding.
- Behavior that contradicts `docs/product/<feature>/doc.md` is a finding even if the code is clean: that file is the source of truth for what a feature does, and its rules are atomic on purpose so they can be checked one by one.
- User-facing interface changed → that product's mock in `docs/product/<group>/<feature>/mocks/` in the same PR (a mock that no longer matches what shipped is worse than none).
- A question answered in `domain-model.md`'s *Open* section → moved to *Settled* in the same PR, question deleted.
- Architectural change → a new file in `docs/technical/decisions/` (Status · Context · Decision · Rationale · Consequences · Revisit when); revising an existing decision is an explicit revision, never an edit in passing.
- A new dependency → its license stated in the PR, and it is not AGPL/GPL (rule 1). Check it; do not assume. The excluded list in `dependencies.md` is a rule: no `dartz`, no routing package, no HTTP client before layer 3, no `sqflite` on desktop.
- Anything in `versioning.md`'s left column — a written format, the `TomModule` contract, a `--dart-define` users rely on — is a breaking change and the PR says so.

## Step 3 — the canon the project is held to

The project's own rules are not the whole standard. A diff is also held to the practices the Dart community and the architecture literature already settled — but in a fixed order, because they disagree in places and the project has already chosen:

1. **The decisions and `src/analysis_options.yaml`, where they deliberately deviate.** Explicit types everywhere (`always_specify_types`) is the project's choice against Effective Dart's "don't annotate initialised locals"; seven packages, no aggregates, no navigation package are choices against the default reading of the literature. A deviation the project made on purpose is never a finding (Step 5).
2. **[Effective Dart](https://dart.dev/effective-dart)** — Style, Documentation, Usage, Design — for everything the lints do not encode.
3. **Clean Architecture and DDD, as `layers.md` and Decision 15 apply them.**
4. **The Dart community's conventions** — the [package layout](https://dart.dev/tools/pub/package-layout), `package:lints/recommended` (already included), Conventional Commits and semver (`tom-git-workflow`).

What each contributes that nothing above already covers:

**Effective Dart — Documentation.** A doc comment opens with a one-sentence summary, then a blank line, then the detail. It says what the reader cannot see: a comment that restates the signature ("Returns the status") is a finding — and so is the *why* being absent when the code is a choice between alternatives, which is the project's own habit and the reason its dartdoc reads as it does. Third-person verb for a function ("Reads…"), noun phrase for a property ("The absolute path…"), "Whether…" for a boolean. `[]` for every identifier mentioned. Parameters described in prose, never `@param`. A doc comment before its annotations, never between them and the declaration.

**Effective Dart — Usage and Design.** Return an empty collection, never null for "none"; null is for "no answer" and the type says so (`toSpaceRelative`). Named parameters for booleans, never positional. `Future<void>`, not `Future` or `Future<Null>`. `rethrow`, never `throw e`. No `async` on a function that does not await. Fields `final` unless mutation is the point. A getter is a computation the caller may repeat cheaply; anything else is a method. Acronyms are words — `HttpClient`, `Utf8` — not `HTTP`, `UTF8`. No prefix letters on constants, no `_` on a parameter to mark it unused. Prefer composition; a class exists to hold state or an invariant, not to namespace functions (`avoid_classes_with_only_static_members` already says so — a top-level function is the Dart answer).

**Clean Architecture.** The dependency rule is the graph in Step 2; what it adds is the reading of each layer. Business rules — what a use case orchestrates, what an entity guarantees — know nothing of the framework, the UI or the disk, so a use case is testable with fakes and nothing else; if it cannot be, something leaked. Interface adapters (`tom_data`, `tom_presentation`) *convert* — text into entities, `Result` into state — and hold no rule of their own. The outermost layer (`tom_desktop`) is the **humble object**: widgets are thin enough to need no test of their own logic, because the logic sits in a notifier that runs under `dart test`. Folder and file names scream the domain (`git/`, `documents/`, `spaces/`), never the pattern (`controllers/`, `helpers/`, `utils/`) — a `utils.dart` is a finding until each function has found the type it belongs to.

**DDD, selectively (Decision 15).** Invariants are validated once, at construction — a value object that can be built invalid is a finding, as is a check repeated downstream of a type that already guarantees it. No primitive obsession where a type exists: a `String` path, a `String` branch, a `String` sha in a new signature. Entities compare by identity (`Document` by path), value objects by value; a hand-written equality that confuses the two is a bug, not a style. The ubiquitous language is enforced by naming, in both directions: an infrastructure word in the domain (`process`, `file handle`, `row`) is as much a finding as a `Dto` suffix. A domain service is stateless and exists only for logic that belongs to no single entity — `BlockDiffer`, and possibly nothing else for a long while.

**Good practice, generally.** One public type per file, the file named after it. One responsibility per class and per function; a function that needs a comment to separate its phases wants splitting. No dead code, no commented-out code, no `TODO` without an owner and a trigger. Duplication is a finding on the third occurrence, not the second (YAGNI runs the other way too: an abstraction with one implementation and no second one on the roadmap is speculation). Immutability by default; mutation is local, named, and justified. Magic values are named constants. A test reads as a sentence, arranges-acts-asserts, holds no logic, and fails for exactly one reason.

## Step 4 — package by package

What to check when the diff touches each one. The last three are empty today; their rules are still normative, and the first file in each sets the canonical form.

**`tom_core`** — mechanism only, depends on nothing. A product noun in a new type name is a finding. `AppFailure` stays a marker, not sealed, for a reason its dartdoc gives; do not "fix" it.

**`tom_domain`** — entities, value objects, the sealed area failures, repository contracts, `BlockDiffer`. Knows no framework, no git, no disk, no package type. Domain contracts (`GitRepository`, `DocumentRepository`, `SpaceRepository`) speak in entities and typed paths — never text, never a `GitClientFailure`. Identity by path (`Document`), not by content. The DDD menu is chosen (Decision 15): value objects for identifiers and paths, ubiquitous language, repositories, one domain service — and no aggregates, no domain events, no factories or specifications, no separate persistence model. `Block` is an output of Spike B: **do not design `BlockDiffer` before the spike reports**, and a diff that does is a finding by the roadmap.

**`tom_infra`** — capability contracts and their implementations, organised **by capability, not by technology**: `git_client/` holds the contract, its sealed failure, and one subfolder per implementation named after how it is done (`dart_io/`, later `libgit2/`). Depends on `tom_core` only, so it cannot name a domain failure — do not try. On a contract:
- **Text and bytes cross it, never an entity.** Every method states the exact format it returns — flags, separators, field order — because a caller cannot parse what it was not promised and a second implementation owes the same format. The separators are constants on the contract (`GitClient.unitSeparator`, `recordSeparator`, `nulSeparator`), never re-spelled in a parser.
- **Every path crossing `GitClient` is repository-root relative, in both directions**, sent as a `:(top,literal)` pathspec — so a path read from `status()` can be handed straight back. Getting this wrong breaks every space that is a folder *inside* a repository (the normal case) and passes in the test where the two coincide. A new command that takes a path is checked for this.
- `Filesystem` works in absolute paths, knows nothing about spaces, and filters nothing — hiding `.git/` is the file tree's policy, not the capability's. `writeFile` is atomic and creates parents; `readFile` is strict UTF-8. An implementation that cannot promise these is not an implementation of the contract.
- The environment leaves no prompt to answer, every command has a timeout that kills the process, and a killed command stops waiting on pipes a grandchild still holds. One serialized queue per space; the queue is the client's, so nothing above it serializes again.

**`tom_data`** — parsers and repository implementations; the only place the domain and the capabilities meet. May not import `dart:io`: everything reaches disk and git through `Filesystem` and `GitClient`. Parsers are **total** — a record they cannot read is skipped, never thrown over — and are tested against fixtures of real git output. The translation switch is exhaustive with no default and passes through what it cannot name (Step 2). The file tree's `.git/` policy lives in `SpaceRepositoryImpl`, and the load-bearing half is that it **never descends**: the walk is one level at a time and decides before it descends, and a test asserts the capability was never even asked for that folder.

**`tom_application`** — use cases, one per operation, constructor-injected, `Result` out, the try/catch of Step 2 around the body. No `Ref`, no Riverpod import, no I/O: a use case that needs a process or a file is reaching past its repository. Policy lives here — refusing to commit on a detached `HEAD` is a use case's decision, not a command's failure.

**`tom_presentation`** — pure Dart, so it cannot reach a widget, which is what makes a second app affordable (Decision 14). Riverpod is allowed here and nowhere below.
- **The space session is the single source of truth** (Decision 9): root, current branch, `GitStatus`, ahead/behind. Panels *derive* from it (`select`); git operations *write* to it. A scattered `ref.invalidate` to coordinate panels is a finding — that is the bug the session exists to remove.
- **One notifier per panel, explicit states** `initial / loading / data / error(AppFailure)`. Panel-local state (scroll, selection, a message being typed) stays in the notifier; shared state stays in the session. **No business logic in a notifier**: it calls a use case and turns `Result` into state, nothing else.
- `ref.watch` in build, `ref.read` in callbacks. Presentation never sees a raw file event — it sees the session change.

**`tom_desktop`** — the composition root and the widgets; the only package that knows Flutter exists.
- **The composition root only instantiates and wires — zero logic**, and `ref.watch` rather than `ref.read` while wiring. Three lifetimes, and a provider in the wrong one is a finding: app (`keepAlive` — parsers, `BlockDiffer`, `Observability`, config), space (a `family` keyed by the space root — `GitClient`, watcher, index, session; disposal tears them down), transient (use cases, default).
- **Panels are registered, never hardcoded** (Decision 12): a `TomModule` contributes `PanelDescriptor`s and provider overrides, `runTom(modules: [...])` collects them, and the built-in panels go through an internal `CoreModule` on exactly the same path. A panel wired straight into the shell widget is a finding even when it is the only panel. Modules add; they never change or degrade what the app does, and none may need the network to start. The app never imports a module.
- **Feature flags are build-time only** — `bool.fromEnvironment`, declared in one file, enabled with `--dart-define` — and guard **registration, not rendering**: a disabled panel is never registered, so it is unreachable rather than invisible. Every flag states when it goes; a flag without a removal target is a finding.
- Third-party widgets (`re_editor`, the markdown renderer) sit behind our own wrapper widget exposing our API, so swapping the package stays in one file (Tier 2).
- The preview is assembled **block by block**: the app owns the container around each block (diff decoration, navigation anchor); inline markdown inside a block is delegated. One opaque widget tree for the whole document is a finding — it makes the rendered diff impossible to express.
- The watcher and git cooperate by protocol (Decision 10): pause before a mutating command, one `SpaceChanged` at the end, echo suppression for the app's own saves, debounce for external bursts, all through the space's queue. Reacting to file events one by one during a checkout is the race the protocol exists to prevent.

**Everywhere: files are the truth.** No database and no state that is not rebuildable from the `.md` files on disk; the FTS5 index is a cache that is rebuilt, never repaired. Nothing is written into the user's repository (`.tom/` is reserved, empty, and stays empty until something genuinely has to be shared across a team). No data leaves the machine unless the user turned it on (Decision 11).

## Step 5 — report

Three levels, and the difference is what the author does next:

- **Blocks merge** — violates a decision, a normative section or a non-negotiable rule, or is a correctness bug. Name the rule or the decision file; the author either changes the code or writes the ADR that revises the decision.
- **Should fix** — a real problem within the rules: a missing test, a failure dressed up, an unhandled null, a collection handed over without `List.unmodifiable`, a dartdoc that no longer states what the code does.
- **Note** — worth knowing, costs nothing to leave. Say so plainly, so it is not mistaken for a request.

Rules for the findings themselves:

- **Quote the diff, not your memory.** A finding names a file and a line — one the branch added or changed. Anything else is outside the review (see *What is under review*).
- **A finding that cannot fail is not a finding.** Describe the input or state that produces the wrong result; if you cannot, it is a note.
- Never report what `tom verify` already catches (Step 1).
- **Never re-litigate a settled decision.** Not findings, ever: `Process.run` for git instead of libgit2 (Decision 2); source + preview instead of WYSIWYG (Decision 3); no `dartz` (Decision 5); plain `Navigator` for dialogs, no routing package (Decision 6); Riverpod codegen and Freezed as structural dependencies (Decision 7); seven packages for a project this size (Decision 14, bought knowingly); the absence of aggregates, domain events, factories and a persistence model (Decision 15); explicit types everywhere; dense dartdoc. Nor the non-goals in `about.md`: WYSIWYG, real-time collaboration, databases/kanban/tasks, our own cloud sync. These are the deliberate deviations of Step 3's precedence; suggesting one of them is suggesting the project be a different project — and if you genuinely believe a decision is wrong, the move is an ADR, not a PR comment.
- **Scope is the roadmap's.** `docs/roadmap.md` decides what exists yet, and each item's `doc.md` decides what it must do. "This should also handle X" is only a finding if X is in the current milestone; mobile is not a non-goal but is Phase 3, and nothing about the MVP bends toward it.

## In tom-pro

Same pass, plus: paid code never appears in the public repo regardless of flags — the repository answers *who has this code*, a flag only *whether it is reachable in this build* — and a review comment never carries license keys, private key material, customer names or pricing under negotiation.
