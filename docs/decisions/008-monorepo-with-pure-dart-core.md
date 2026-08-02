# Decision 8 — Monorepo with a build boundary between core and app

**Status:** accepted

## Decision

The project is a **monorepo**: a single Git repository holding multiple Dart packages, wired through the **native pub workspace** (Dart 3.6+). Initial structure of **two packages**:

```
tom/                          ← ONE Git repository
├── pubspec.yaml              ← workspace root (declares the packages)
├── docs/
├── packages/
│   └── tom_core/             ← PURE DART package (pubspec without Flutter)
│       └── lib/                 domain/ · application/ · data/ · infrastructure/ · core/
└── apps/
    └── tom_desktop/          ← Flutter desktop app
        └── lib/                 presentation/ · bootstrap/
```

**Important:** monorepo ≠ multi-repo. One clone, one history, one PR able to touch core and app atomically. The split happens at the `pubspec.yaml` (build) level, not in Git.

## The rule of thumb for where a build boundary belongs

**A build boundary only where leakage would be structural; a convention boundary (folders + import lint) everywhere else.**

- **Pure Dart × Flutter** is the catastrophic, silent divide: a `material.dart` import in the application layer slips through review, contaminates the testability of the core and rules out future platforms. It deserves the compiler as a guard: `tom_core`'s `pubspec.yaml` **does not declare Flutter** — importing it does not compile.
- **domain × application × data × infrastructure** (inside the core): leakage here is an elegance problem, detectable in review and fixable locally. Proportional guardian: convention + a per-layer import lint.
- Every new package must justify itself by this rule — it prevents both the sloppy monolith and ceremonial fragmentation (one package per layer).

## Why infrastructure lives INSIDE tom_core (for now)

Every phase-1 infrastructure implementation is pure Dart: `Process.run` (git), `sqlite3` (pure FFI), `watcher`, `markdown`, `diff_match_patch`. None of them imports Flutter. The only related Flutter component (`sqlite3_flutter_libs`, which merely bundles the native SQLite library) is declared in the **app**, not the core. The core stays 100% pure with both contracts AND implementations inside.

## Executable proof

`tom_core`'s CI runs with **`dart test`** (not `flutter test`) — no binding, no emulation. A green job is continuous proof that the heart of the product is framework-independent. Breaking that property breaks the pipeline.

## Projected evolution (with explicit triggers)

```
Projected end state:

apps/tom_desktop ──────┬──> packages/tom_core <──┬────── apps/tom_mobile
        └──> packages/tom_infra_desktop ──> core └──> packages/tom_infra_mobile
```

| Trigger | Action |
|---|---|
| A second platform (mobile) started — **planned for Phase 4, post-1.0** | Extract `tom_infra_desktop` (git via CLI, free filesystem); create `tom_infra_mobile` (libgit2/FFI, sandbox, keychain) and `apps/tom_mobile` (its own presentation — panels do not become screens) |
| 3+ packages in the workspace | Adopt **Melos** (batch command runner across packages: tests, codegen, diff-based filtering in CI) |
| `tom_core` published on pub.dev | Melos versioning + changelog from Conventional Commits |

## Rationale

- **A physical boundary on the divide that matters:** Clean Architecture stops being a convention and becomes a build constraint exactly where leakage would be irreversible.
- **Mobile as a bounded cost:** `domain/application/data/core` are born 100% reusable; the planned iOS/Android app means alternative infrastructure implementations + a new presentation, with no refactor of the core. This decision is what keeps Phase 4 from being a rewrite.
- **Minimal cost:** two packages on the native workspace carry almost no overhead (one `pub get` at the root, the IDE sees the whole set); the real ceremony (Melos, N packages) stays behind triggers.
- **Portfolio narrative:** the repo tree communicates the architecture in the first fold on GitHub.

## Consequences

- Contracts consumed by the app (domain repositories) and implemented by infrastructure all live in the core — the dependency direction is always app → core, never the reverse.
- Flutter shell packages (`window_manager`, `file_selector`, `url_launcher`, `shared_preferences`, `re_editor`, `sqlite3_flutter_libs`) are declared only in `tom_desktop`.
- Refactors crossing the core/app boundary are possible in a single PR/commit (the monorepo's advantage over multi-repo).
