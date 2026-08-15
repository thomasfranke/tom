# Guiding principle: minimal coupling to external dependencies

**Every external dependency is reached exclusively through a contract and lives isolated in `infrastructure/`.** No other layer imports an external service package directly. This principle ([Decision 7](../../decisions/007-external-dependencies-behind-contracts.md)) settles any allocation question on its own, and applies across three tiers:

| Tier | Dependencies | How the principle applies |
|---|---|---|
| **1 — External services/capabilities** | git binary, filesystem, sqlite/FTS5, markdown parser, text diff, (future) remote APIs | **100%**: interface + implementation + its own failure type in `infrastructure/`; consumed only through the contract |
| **2 — External UI widgets** | `re_editor`, third-party components | **Adapted**: our own wrapper widget in `presentation/widgets/` exposing our API; swapping the package stays confined to one file |
| **3 — Structural (accepted exception)** | Flutter, Riverpod, Freezed | **Explicit exception with declared scope** (see below): foundation, not abstracted — wrapping a framework yields a homemade framework worse than the original |

## Scope of the structural dependencies

Tier 3 is not a licence for unrestricted use — each structural dependency has a declared boundary:

| Structural | Allowed in | Not allowed in | Rationale |
|---|---|---|---|
| **Riverpod** | `presentation/` (notifiers, widgets) and `bootstrap/di/` (graph wiring) | `domain/`, `application/`, `data/`, `infrastructure/` — no `Ref`, no provider, no import | Riverpod is *runtime* (lifecycle, scope, invalidation). Confining it to the UI eliminates by construction the class of lifecycle bugs outside presentation. Use cases and repositories receive dependencies **through constructors** and are pure Dart. |
| **Freezed** | Every layer (entities, states, failures) | — | Pure build-time: it generates code that becomes ours, with no runtime coupling. A `@freezed` entity is an ordinary immutable Dart object. |
| **Flutter** | `presentation/` (and `bootstrap/`) | `domain/`, `application/`, `data/` (zero `import 'package:flutter/...'`) | Business layers compile as pure Dart — tests run without a test binding. |

**Consequence for DI:** `bootstrap/di/` is the only meeting point — providers there merely *instantiate and wire* pure classes (`CommitChanges(ref.read(gitRepositoryProvider))`). If a use case needs a `Ref`, the design is wrong.
