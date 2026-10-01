# External dependencies

Every external dependency is reached through a contract
([Decision 7](../decisions/007-external-dependencies-behind-contracts.md)),
applied in three tiers. Which packages are actually taken, and under which
license, is [`stack/`](../stack/README.md).

| Tier | What | How |
|---|---|---|
| **1 — Capabilities** | git binary, filesystem, sqlite/FTS5, markdown parser, text diff | contract + implementation + its own failure type, all inside `tom_infra`; consumed only through the contract |
| **2 — UI widgets** | `re_editor`, third-party components | our own wrapper widget in the app, exposing our API; swapping the package stays in one file |
| **3 — Structural** | Flutter, Riverpod, Freezed | declared exception, not abstracted — wrapping a framework yields a worse homemade one. Scope below |

## The declared exceptions, and their scope

| Structural | Allowed in | Why the boundary |
|---|---|---|
| **Flutter** | the applications, and `tom_ui` | the pubspecs enforce it; the other six compile and test as pure Dart. `tom_ui` draws and wires nothing, which is what keeps it from becoming a third application ([Decision 26](../decisions/026-the-look-is-a-package.md)) |
| **Riverpod** | `tom_presentation` and the composition root | it is *runtime* — lifecycle, scope, invalidation. Use cases and repositories receive dependencies through constructors. A use case that needs a `Ref` is a design error |
| **Freezed** | any layer | pure build-time; the generated code is ours and carries no runtime coupling. Mandatory for immutable data classes wherever one qualifies — entities, multi-field value objects, view-state, sealed hierarchies ([Decision 16](../decisions/016-freezed-is-mandatory-for-immutable-data.md)) |

`Observability` is the one capability contract that lives in `tom_core` rather
than `tom_infra`: every use case takes one, and `tom_application` cannot see
`tom_infra`. It names no technology, and it is not a precedent for anything
that does.

---

*See also: [stack/](../stack/README.md) · [inside-a-package.md](inside-a-package.md)*
