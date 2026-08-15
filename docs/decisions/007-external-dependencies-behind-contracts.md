# Decision 7 — Minimal coupling to external dependencies

**Status:** accepted

## Decision
Every external dependency is reached exclusively through a contract and lives isolated in `infrastructure/` (contract + implementation + its own failure type). No other layer imports external service packages directly.

## How it applies per tier

The principle is not uniform: external services get full isolation, third-party widgets get a wrapper we own, and structural dependencies (Flutter, Riverpod, Freezed) are a declared exception with a restricted scope rather than an abstraction. The three tiers, their boundaries and why the exception exists are in [../architecture/02-dependency-isolation.md](../architecture/overview/dependency-isolation.md).

## Rationale
- Testability: repositories testable with mocked infrastructure — no real process, disk or database.
- Swappability: CLI → libgit2 (Decision 2), the `markdown` package → our own parser (Spike B), all without touching `domain/`, `application/` or `data/`.
- Contribution discipline: a single principle settles allocation in PRs without case-by-case debate.

## Consequences
- Domain entities are never types from external packages — `data/parsers/` does the translation (anti-corruption layer).
- Our own business rules (e.g. `BlockDiffer`) are NOT external dependencies → they live in `domain/services/`, not in infrastructure.
- Each infrastructure component has its own technical failure type; `data/repositories_impl/` translates it into a domain failure.
