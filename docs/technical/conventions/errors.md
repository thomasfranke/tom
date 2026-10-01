# Errors across boundaries

An exception never crosses a layer boundary
([Decision 5](../decisions/005-errors-use-result-with-sealed-classes.md)):
every repository method and every use case returns `Result<T>`.

- `Result` is **sealed**, so a `switch` over it is exhaustive — forgetting the
  failure branch does not compile.
- `AppFailure` is a **marker, not sealed**; each area's hierarchy is sealed
  inside its own library (`GitFailure`, `DocumentFailure`, `SearchFailure`).
  Adding a variant breaks every switch that must handle it, and only in the
  packages that deal with that area. A switch over `AppFailure` itself takes a
  catch-all.
- Technical failures are translated into domain failures by `tom_data`, in the
  **repository** and nowhere else. The graph makes the translation mandatory
  rather than customary: `tom_infra` does not depend on `tom_domain`, so it
  cannot name a `GitFailure`. A data source hands the technical failure up
  untouched — translating is what the repository is at that boundary for
  ([Decision 25](../decisions/025-a-repository-reads-through-a-data-source.md)).
- Every use case wraps its body in a standardized `try/catch`, hands what it
  caught to `Observability`, and returns `UnexpectedFailure` — never rethrows,
  never swallows
  ([Decision 11](../decisions/011-telemetry-is-opt-in.md)).

The types are documented where they live: `packages/core/lib/src/` and
`packages/domain/lib/src/<area>/<area>_failure.dart`.

---

*See also: [inside-a-package.md](inside-a-package.md) · [naming.md](naming.md)*
