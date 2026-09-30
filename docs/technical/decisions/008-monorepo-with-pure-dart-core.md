# Decision 8 — Monorepo with a build boundary between core and app

**Status:** partly superseded by [Decision 14](014-each-layer-is-its-own-package.md) and [Decision 24](024-a-capability-is-a-folder.md)

> **What changed.** The monorepo, the pub workspace and the pure Dart core all stand. Decision 14 revises *how many* boundaries there are: this decision drew one, between pure Dart and Flutter, and left the layers as folders; there is now one package per layer, enforced by the pubspecs rather than by convention. Decision 24 revises how a *platform* is added: by an implementation subfolder inside a capability, not by a package of its own.
>
> Read this file for the reasoning about monorepo versus multi-repo, and about why mobile is a bounded cost. Read Decision 14 for the package graph as it actually is, and Decision 24 for the shape of `tom_infra`.

## Decision

The project is a **monorepo**: a single Git repository holding multiple Dart packages, wired through the **native pub workspace** (Dart 3.6+). ~~Two packages to start~~ — one package per layer, plus the Flutter application; see [Decision 14](014-each-layer-is-its-own-package.md). The tree is in [architecture.md](../architecture.md).

**Important:** monorepo ≠ multi-repo. One clone, one history, one PR able to touch core and app atomically. The split happens at the `pubspec.yaml` (build) level, not in Git.

## The rule of thumb for where a build boundary belongs

> **Superseded.** [Decision 14](014-each-layer-is-its-own-package.md) took the opposite view and put a build boundary at every layer. The reasoning below is kept because it is the argument that had to be answered, and because the trade-off it names — ceremony against enforcement — is real. What changed is the weight given to each: this project's second goal is a repository worth reading, and an architecture that holds because the wrong import does not resolve demonstrates more than one that holds because reviewers were careful.

**A build boundary only where leakage would be structural; a convention boundary (folders + import lint) everywhere else.**

- **Pure Dart × Flutter** is the catastrophic, silent divide: a `material.dart` import in the application layer slips through review, contaminates the testability of the core and rules out future platforms. It deserves the compiler as a guard: `tom_core`'s `pubspec.yaml` **does not declare Flutter** — importing it does not compile.
- **domain × application × data × infrastructure** (inside the core): leakage here is an elegance problem, detectable in review and fixable locally. Proportional guardian: convention + a per-layer import lint.
- Every new package must justify itself by this rule — it prevents both the sloppy monolith and ceremonial fragmentation (one package per layer). *Decision 14 accepts that cost deliberately, and names the trigger for undoing it: a layer whose package stayed empty through a whole milestone.*

## Why infrastructure lives INSIDE tom_core (for now)

Every phase-1 infrastructure implementation is pure Dart: `Process.run` (git), `sqlite3` (pure FFI), `watcher`, `markdown`, `diff_match_patch`. None of them imports Flutter. The only related Flutter component (`sqlite3_flutter_libs`, which merely bundles the native SQLite library) is declared in the **app**, not the core. The core stays 100% pure with both contracts AND implementations inside.

## Executable proof

`tom_core`'s CI runs with **`dart test`** (not `flutter test`) — no binding, no emulation. A green job is continuous proof that the heart of the product is framework-independent. Breaking that property breaks the pipeline.

## Projected evolution (with explicit triggers)

> **Revised.** The graph and the mobile row below named `tom_infra_desktop`,
> `tom_infra_mobile` and `apps/tom_mobile` — a package per platform.
> [Decision 24](024-a-capability-is-a-folder.md) made a capability a *folder*
> with one subfolder per implementation, so a second platform adds a subfolder
> beside `dart_io/`, not a package beside `tom_infra`. The application is
> `tom_mobile`, under `apps/mobile`. What did **not** change is the reasoning: mobile is a second
> infrastructure and a second presentation over the same pure Dart layers, and
> that is what keeps Phase 3 from being a rewrite.

```
Projected end state:

apps/desktop ──┬──> the pure Dart layers <──┬── apps/mobile
               └──> tom_infra ⇄ tom_data ───┘
                      git_client/
                        dart_io/      ← desktop: the system binary
                        libgit2/      ← mobile: FFI, sandbox, keychain
```

| Trigger | Action |
|---|---|
| A second platform (mobile) started — **planned for Phase 3, post-1.0** | Add an implementation subfolder per capability that differs (git via FFI, a sandboxed filesystem, the keychain) and `apps/mobile` with its own presentation — panels do not become screens. The contract each one fulfils does not move |
| 3+ packages in the workspace | Adopt **Melos** (batch command runner across packages: tests, codegen, diff-based filtering in CI) |
| `tom_core` published on pub.dev | Melos versioning + changelog from Conventional Commits |

## Rationale

- **A physical boundary on the divide that matters:** Clean Architecture stops being a convention and becomes a build constraint exactly where leakage would be irreversible.
- **Mobile as a bounded cost:** `domain/application/data/core` are born 100% reusable; the planned iOS/Android app means alternative infrastructure implementations + a new presentation, with no refactor of the core. This decision is what keeps Phase 3 from being a rewrite. And mobile is expected rather than merely hoped for: writing documentation needs a repository, markdown and git — not a development environment — and the people who read and approve documentation are rarely at a desk when they do ([roadmap](../../roadmap.md#phases)).
- **Minimal cost:** two packages on the native workspace carry almost no overhead (one `pub get` at the root, the IDE sees the whole set); the real ceremony (Melos, N packages) stays behind triggers.
- **Portfolio narrative:** the repo tree communicates the architecture in the first fold on GitHub.

## Consequences

- ~~Contracts consumed by the app and implemented by infrastructure all live in the core~~ — the layers became packages ([Decision 14](014-each-layer-is-its-own-package.md)) and each capability's contract now sits beside its adapters in `tom_infra` ([Decision 24](024-a-capability-is-a-folder.md)). The dependency direction the sentence was about is unchanged.
- Flutter shell packages (`window_manager`, `file_selector`, `url_launcher`, `shared_preferences`, `re_editor`, `sqlite3_flutter_libs`) are declared only in `tom_desktop`.
- Refactors crossing the core/app boundary are possible in a single PR/commit (the monorepo's advantage over multi-repo).
