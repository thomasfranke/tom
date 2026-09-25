# Decision 5 — Errors use Result with sealed classes; no `dartz`

**Status:** accepted

## Decision
Keep the Result/Either pattern, implemented with Dart 3 sealed classes + pattern matching (`Result<T>` / `AppFailure`, see [conventions/errors.md](../conventions/errors.md)). Do not adopt `dartz`.

## Rationale
- Same semantics with stronger compiler enforcement: exhaustiveness also over the *failure types* (sealed `GitFailure`), not just success/error.
- `dartz` is no longer actively maintained.
- Idiomatic Dart lowers the barrier for open source contributors.
- Freezed generates each variant's `==`/`hashCode` (element-wise for list/map fields) instead of it being hand-written per failure — a build-time dependency only, no runtime coupling ([conventions/external-dependencies.md](../conventions/external-dependencies.md)).

## Accepted trade-off
Monadic chaining (`flatMap`) — replaced by early return; our own `map`/`flatMap` extension if it ever becomes necessary.
