# Composition: modules and lifetimes

## Panels are registered, never hardcoded

The shell is extensible through compile-time modules from M0, even with no
module existing yet
([Decision 12](../decisions/012-shell-is-extensible-via-compile-time-modules.md)).
A `TomModule` contributes panels (`PanelDescriptor`: id, title, builder,
placement) and provider overrides; `runTom(modules: [...])` collects them,
builds the `ProviderScope` and starts the shell. The built-in panels go
through exactly the same path — that is what keeps the extension point real.

Modules **add**; they never change or degrade what the app already does, and
none of them may need the network to start.

## Wiring: three lifetimes

The composition root only instantiates and wires — zero logic, and `ref.watch`
rather than `ref.read` while wiring.

| Lifetime | What | Mechanism |
|---|---|---|
| **App** | parsers, `BlockDiffer`, `Observability`, the `CommandLog` every process-running capability is handed ([Decision 36](../decisions/036-every-command-is-written-down.md)), config | `keepAlive` |
| **Space** | what a folder needs — the `GitClient`, the FTS5 index | no `family`: app-lifetime factories take the folder (`gitClientFor`, `gitRepositoryFor`, `searchRepositoryFor`). A client is kept per folder for as long as the app runs; an index is kept per space root and closed with the app |
| **Transient** | use cases | default; lightweight objects created on demand |

- **An index asked for twice is the same index** — it holds an open database, and a fresh one would be a search that silently finds nothing ([search.md](search.md)).
- **A git client asked for twice for one folder is the same client** — its queue is what serializes every use case's commands on that repository ([git.md](git.md)).

---

*See also: [state.md](state.md) · [conventions/external-dependencies.md](../conventions/external-dependencies.md)*
