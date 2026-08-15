# Architecture

How TOM is built. The [decisions](../decisions/) record *why* a choice was made; this folder records *what the system is*.

One folder per package, mirroring [`src/packages/`](../../src/packages/) exactly — a document about `tom_domain` lives in `domain/`. The single exception is `overview/`, for what genuinely crosses every layer.

## Read in dependency order

Bottom of the graph first: each layer only knows the ones before it.

| Folder | Document | Covers |
|---|---|---|
| [overview/](overview/) | [repository-structure.md](overview/repository-structure.md) | The seven packages, the graph, and the three mechanisms that enforce it |
| | [dependency-isolation.md](overview/dependency-isolation.md) | External dependencies behind contracts, and the three tiers |
| | [testing.md](overview/testing.md) | What is tested at each layer, and against what |
| | [feature-flags.md](overview/feature-flags.md) | Shipping unfinished work dormant rather than on a branch |
| [core/](core/) | [error-model.md](core/error-model.md) | `Result`, sealed failure hierarchies, exhaustive consumption |
| | [error-handling.md](core/error-handling.md) | The canonical template: inline try/catch, early return |
| [domain/](domain/) | [model.md](domain/model.md) | Entities and value objects: what is settled, what a spike still owes |
| [infra/](infra/) | [git-integration.md](infra/git-integration.md) | The three conceptual layers of Git: folder → binary → remote APIs |
| | [capabilities.md](infra/capabilities.md) | Serialized git executor, watcher protocol, the index as a cache |
| [presentation/](presentation/) | [state.md](presentation/state.md) | The space session, one notifier per panel, Riverpod discipline |
| | [extension-modules.md](presentation/extension-modules.md) | Panels registered rather than hardcoded |
| | [dependency-injection.md](presentation/dependency-injection.md) | The composition root, and why nothing else sees an implementation |

`application/` and `data/` have no document of their own yet. Their shape is in [overview/repository-structure.md](overview/repository-structure.md); they get a page when there is something to say that the graph does not already say.

## The 30-second view

```
core ← domain ← application ← presentation
  ↑       ↑                        ↑
  └─── infra ← data ─────────────  desktop
```

Seven packages, one per layer ([Decision 14](../decisions/014-each-layer-is-its-own-package.md)). Six are pure Dart and run under `dart test`; only `tom_desktop` knows Flutter exists, and it is the only place a contract meets the thing that satisfies it.

A violation of that graph does not resolve, does not pass the analyzer, and fails [`src/test/architecture_test.dart`](../../src/test/architecture_test.dart) — three mechanisms, because each catches what the one before it cannot see.

`.md` files on disk and the Git repository remain the single source of truth. Nothing here is a cache that cannot be rebuilt from them.

---

*See also: [../README.md](../README.md) · [../decisions/](../decisions/) · [dependencies.md](dependencies.md)*
