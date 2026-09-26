# Actions

- **Require approval before running workflows from a fork, for contributors who have not landed a PR yet.** GitHub's default, and deliberate rather than inherited.
- Workflow permissions read-only by default; write is granted per workflow, only where genuinely needed.
- **No secrets in this repository's CI.** Signing keys, certificates and distribution credentials live outside it, and validation here must never require one — which is why git tests run against a temporary local repository rather than a real remote.

## Why not approval from everyone, forever

Considered and rejected. The abuse it guards against — a workflow that exists to
mine crypto on the runner — arrives from throwaway accounts with no history,
which is exactly what the default catches.

Requiring it from every outside contributor buys almost nothing here: fork PRs
get a read-only token and no secrets, and this repository has no secrets in CI
anyway. It would cost a maintainer click on every contribution from people who
have already proven themselves, and leave their pull requests sitting without CI
until somebody is awake.

---

*See also: [repository-settings/](README.md) · [ci.md](../ci.md)*
