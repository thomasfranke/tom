# Testing strategy

| Target | Type | Approach |
|---|---|---|
| Parsers (git porcelain, log, markdown AST) | Unit | Fixtures of real git output; pure and fast |
| `block_differ` (diff v1) | Unit / golden | Versioned pairs of md input + expected result |
| Use cases | Unit | Mocked repositories; focus on orchestration and `Failure` propagation |
| `GitRepositoryImpl` | Integration | Temporary git repo created in test setup (`git init` in a temp dir) — tested against real git |
| Notifiers | Unit | Test `ProviderContainer`; mocked use cases |
| Critical UI (diff view) | Widget/golden | Screenshots of the main states |

Integration tests against real git are the project's confidence differentiator: they run in CI on all three platforms.

---

*See also: [../mvp.md](../mvp.md) · [../decisions/](../decisions/) · Dependency stack: [../dependencies.md](../dependencies.md)*
