# Architecture

TOM's architecture documentation, in reading order. The [decisions](../decisions/) record the *why*; the [patterns](../patterns/) record the code templates; this folder is the **system design**.

| # | File | Covers |
|---|---|---|
| 01 | [git-integration.md](01-git-integration.md) | The three conceptual layers of Git integration (folder → `git` binary → remote APIs) |
| 02 | [dependency-isolation.md](02-dependency-isolation.md) | The guiding principle: external dependencies isolated behind contracts, and the three tiers (services, widgets, structural) |
| 03 | [repository-structure.md](03-repository-structure.md) | Core/app monorepo, layer tree inside each package, rendered diff flow, adaptations from the mobile reference |
| 04 | [error-model.md](04-error-model.md) | Result, sealed Failure hierarchies, exhaustive consumption, translation boundaries |
| 05 | [infrastructure.md](05-infrastructure.md) | Serialized git executor, watcher ↔ git protocol, search index as cache, diff evolution (v0→v2) |
| 06 | [presentation.md](06-presentation.md) | Space session as single source of truth, one notifier per panel, Riverpod discipline |
| 07 | [testing.md](07-testing.md) | Testing strategy per layer, including integration against real git |
| 08 | [domain-model.md](08-domain-model.md) | Entities: what is settled, what is still open (and which spike or milestone answers it) |

## The 30-second view

```
apps/tom_desktop (Flutter)              packages/tom_core (pure Dart)
┌─────────────────────────┐             ┌──────────────────────────────────────┐
│ presentation             │             │ application ──> domain <── data      │
│   (panels + session)     │──contracts──▶   (use cases)  (entities, (parsers, │
│ bootstrap/di             │             │                BlockDiffer) repos)   │
│   (composition root)     │             │        ▲                    │        │
└─────────────────────────┘             │        └── infrastructure ◀─┘        │
                                        │  (git_client · file_system · markdown │
                                        │   _parser · text_diff · search_index) │
                                        └──────────────────────────────────────┘
.md files on disk + the Git repo = the single source of truth.
```

---

*See also: [../README.md](../README.md) · [../decisions/](../decisions/) · [../patterns/](../patterns/)*
