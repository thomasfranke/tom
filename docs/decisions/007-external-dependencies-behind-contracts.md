# Decision 7 — Minimal coupling to external dependencies

**Status:** accepted

## Decision
Every external dependency is reached exclusively through a contract and lives isolated in `infrastructure/` (contract + implementation + its own failure type). No other layer imports external service packages directly.

## How it applies per tier

| Tier | Examples | Rule |
|---|---|---|
| 1 — External services/capabilities | git binary, filesystem, sqlite/FTS5, markdown parser, text diff, remote APIs | Full isolation: `*_interface.dart` + impl + `*_failure.dart` in `infrastructure/`; consumed only through the contract |
| 2 — External UI widgets | `re_editor` | Our own wrapper widget in `presentation/widgets/` exposing our API; swapping the package stays confined to one file |
| 3 — Structural (accepted exception) | Flutter, Riverpod, Freezed | Declared foundation, not abstracted, **with restricted scope**: Riverpod only in `presentation/` + `bootstrap/di/` (no `Ref`/provider in any other layer — constructor injection); Freezed allowed everywhere (pure build-time, no runtime coupling); Flutter only in `presentation/`/`bootstrap/` |

## Rationale
- Testability: repositories testable with mocked infrastructure — no real process, disk or database.
- Swappability: CLI → libgit2 (Decision 2), the `markdown` package → our own parser (Spike B), all without touching `domain/`, `application/` or `data/`.
- Contribution discipline: a single principle settles allocation in PRs without case-by-case debate.

## Consequences
- Domain entities are never types from external packages — `data/parsers/` does the translation (anti-corruption layer).
- Our own business rules (e.g. `BlockDiffer`) are NOT external dependencies → they live in `domain/services/`, not in infrastructure.
- Each infrastructure component has its own technical failure type; `data/repositories_impl/` translates it into a domain failure.
