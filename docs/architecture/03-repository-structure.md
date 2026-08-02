# Repository and layer structure

## Monorepo: build boundary between core and app ([Decision 8](../decisions/008-monorepo-with-pure-dart-core.md))

A single Git repository, multiple packages wired through the **native pub workspace** (Dart 3.6+). The rule of thumb: **a build boundary only where leakage would be structural (pure Dart × Flutter); convention + import lint everywhere else.**

```
tom/                          ← ONE Git repository (monorepo ≠ multi-repo)
├── pubspec.yaml              ← workspace root
├── docs/                     ← this documentation
├── packages/
│   └── tom_core/             ← PURE DART package — pubspec WITHOUT Flutter (leakage does not compile)
│       └── lib/                 domain/ · application/ · data/ · infrastructure/ · core/
└── apps/
    └── tom_desktop/          ← Flutter desktop app
        └── lib/                 presentation/ · bootstrap/
```

- `tom_core`'s CI runs with **`dart test`** — a continuously executable proof of framework independence.
- Infrastructure lives in the core because every phase-1 implementation is pure Dart (`Process.run`, `sqlite3`, `watcher`, `markdown`, `diff_match_patch`); Flutter shell packages (`window_manager`, `re_editor`, `sqlite3_flutter_libs`…) are declared in the app only.
- Evolution (extracting `tom_infra_*`, adding `apps/tom_mobile`, adopting Melos) sits behind explicit triggers in Decision 8.

## Layers inside the packages

```
packages/tom_core/lib/
├── application/                          # Use cases: orchestration between domain and data
│   ├── git/                                 ## CommitChanges, SwitchBranch, SyncWithRemote, ...
│   ├── documents/                           ## OpenSpace, SaveDocument, ResolveWikilink, ...
│   ├── diff/                                ## ComputeRenderedDiff (orchestrates repos + BlockDiffer)
│   └── search/                              ## IndexSpace, SearchInSpace
├── core/                                 # Cross-cutting utilities shared across layers
│   ├── constants/                           ## Global constants
│   ├── result/                              ## Result<T> (sealed) — universal return pattern
│   └── failures/                            ## Domain failures (sealed hierarchies per area)
├── data/                                 # Data layer: fulfils domain contracts by orchestrating infrastructure
│   ├── parsers/                             ## Mapping (the analogue of data_objects/DTO/DAO)
│   │   ├── git_status_parser.dart               ### porcelain v2 → GitStatus
│   │   ├── git_log_parser.dart                  ### git log → List<Commit>
│   │   └── markdown_block_parser.dart           ### package AST → List<Block> (our own entity)
│   └── repositories_impl/
│       ├── git_repository_impl.dart             ### uses GitClientInterface + parsers
│       ├── document_repository_impl.dart        ### uses FileSystemInterface
│       └── search_repository_impl.dart          ### uses SearchIndexInterface
├── domain/                               # Business rules and contracts (pure Dart, zero external imports)
│   ├── entities/                            ## Space, Document, Block, Commit, Branch, GitStatus, DiffBlock, ...
│   ├── services/                            ## Pure business rules
│   │   └── block_differ.dart                    ### THE HEART OF THE PRODUCT: block alignment and classification
│   └── repositories/                        ## Business contracts
│       ├── git_repository_interface.dart
│       ├── document_repository_interface.dart
│       └── search_repository_interface.dart
├── infrastructure/                       # Isolated external dependencies: contract + impl + failure (Tier 1)
│   ├── git_client/                          ## Dependency: the git binary
│   │   ├── git_client_interface.dart            ### serialized run(args), timeout, exit codes
│   │   ├── process/                             ### Impl: Process.run + queue (phase 1)
│   │   └── git_client_failure.dart
│   ├── file_system/                         ## Dependency: the disk
│   │   ├── file_system_interface.dart           ### read/write/watch
│   │   ├── io/                                  ### Impl: dart:io + watcher
│   │   └── file_system_failure.dart
│   ├── markdown_parser/                     ## Dependency: the markdown package
│   │   ├── markdown_parser_interface.dart       ### source → raw AST
│   │   └── dart_markdown/                       ### Impl using the `markdown` package
│   ├── text_diff/                           ## Dependency: Myers/similarity algorithm
│   │   ├── text_diff_interface.dart
│   │   └── diff_match_patch/                    ### Impl using the package
│   └── search_index/                        ## Dependency: sqlite/FTS5
│       ├── search_index_interface.dart
│       ├── sqlite/
│       └── search_index_failure.dart
```

```
apps/tom_desktop/lib/
├── bootstrap/                            # App initialization and wiring
│   └── di/                                  ## Dependency injection (Riverpod) — builds the core's object graph
├── core/
│   └── theme/                               ## Theme and colors (Flutter → lives in the app)
└── presentation/                         # UI and state management
    ├── shell/                               ## Window, panel layout, global shortcuts
    ├── panels/                              ## Panels (the desktop equivalent of "screens")
    │   ├── explorer/                            ### Space file tree
    │   ├── editor/                              ### Source editor + preview
    │   ├── diff/                                ### Rendered diff view
    │   └── git/                                 ### Status, commit, branches, history
    ├── widgets/                             ## Reusable widgets
    │   └── source_editor/                       ### re_editor wrapper (Tier 2) — our own API
    └── providers/                           ## State (Riverpod)
        ├── *_notifier.dart
        └── *_state.dart
```

## Rendered diff flow (every layer in action)

```
presentation (diff panel)
  → application/diff/compute_rendered_diff        # use case
      → GitRepositoryInterface.fileAtRevision()   # both sides of the file (HEAD × working tree)
      → DocumentRepositoryInterface.parse()       # each side → List<Block> (via markdown_block_parser)
      → domain/services/block_differ              # List<Block> × 2 → List<DiffBlock>
  ← Result<List<DiffBlock>>                       # presentation renders with highlights
```

`BlockDiffer` receives `TextDiffInterface` by injection (for block similarity) but **never sees** the `markdown` package or git — only our own entities.

## Adaptations from the reference structure (mobile) — and why

| Reference (mobile) | TOM (desktop) | Reason |
|---|---|---|
| `data/data_objects/` (`*_dto` / `*_dao`) | **`data/parsers/`** | The mapping equivalent here is parsing text: porcelain → `GitStatus`, log → `Commit`, raw AST → `Block`. Same anti-corruption layer role: domain entities are never types from an external package. |
| `data/datasources/` | **Absorbed by infrastructure** | The "datasource" *is* the contracted external dependency (`GitClientInterface`, `FileSystemInterface`). |
| `infrastructure/api_client/` (Dio) | **Absent in the MVP** | There is no HTTP. When layer 3 arrives, `infrastructure/remote_api/` is born in the obvious place, next to its siblings. |
| `infrastructure/storage/` (SharedPreferences) | **Reduced to app config** | Trivial preferences only. No domain data lives outside the filesystem/git; the FTS5 index is a rebuildable cache. |
| `bootstrap/routes/` (AutoRoute) | **Absent** | A panel-based desktop app has *stateful layout*, not navigation ([Decision 6](../decisions/006-no-navigation-package.md)). |
| `core/l10n/` | **Deferred** | Launching in English; the structure can take i18n later without a refactor. |
| `presentation/screens/` | **`presentation/panels/`** | On desktop, UI units are panels coexisting in one window, not stacked screens. |
| — | **`domain/services/` (new)** | `BlockDiffer` is our own business rule, not an external dependency — by the isolation principle ([02-dependency-isolation.md](02-dependency-isolation.md)) it belongs to the domain. It is the product's central rule living in the most valuable and most testable layer (golden files, zero mocks). |

**What stays identical to the reference:** the dependency rule, business contracts in the domain with implementations in `data/repositories_impl/`, infrastructure with a single purpose (external dependencies + contracts), separate notifiers and states, DI in bootstrap.

**Two contract layers (inherited from the reference):** `domain/repositories/` defines *business* contracts (domain vocabulary, returning `Result<T>`); `infrastructure/*/[name]_interface.dart` defines *technical* contracts over the outside world, with their own technical failures. `data/repositories_impl/` is the bridge: it fulfils the former by orchestrating the latter and translating technical failure → domain failure.

**Lesson carried over from the author's thesis:** complexity legitimately concentrates in `infrastructure/` and `data/parsers/`; `domain/` and `application/` stay at low cyclomatic complexity and high testability. If `application/` starts growing fat, logic is leaking from somewhere it shouldn't.
