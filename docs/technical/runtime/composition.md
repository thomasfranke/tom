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
| **App** | parsers, `BlockDiffer`, `Observability`, config | `keepAlive` |
| **Space** | `GitClient` (the queue is per space), watcher, FTS5 index, the session | a `family` keyed by the space root; disposal tears down watcher and connections when the space closes |
| **Transient** | use cases | default; lightweight objects created on demand |

Per-space scoping is the point: a git queue or a sqlite connection that floats
free instead of belonging to a space is an entire class of "closed resource"
bugs, solved here by construction.

---

*See also: [state.md](state.md) · [conventions/external-dependencies.md](../conventions/external-dependencies.md)*
