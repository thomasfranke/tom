# Repository settings

The GitHub configuration that the workflow in [CONTRIBUTING.md](../../CONTRIBUTING.md) assumes. Recorded here because settings live in a web UI where nobody can review them — a change that quietly weakens a protection leaves no trace otherwise.

## Who can do what

| Action | Who |
|---|---|
| Fork, open a PR against `main` | Anyone |
| Run PR validation | Automatic (first PR from a new outside contributor requires maintainer approval) |
| Merge into `main` | Maintainer only |
| Create a `v*` tag | Maintainer only |
| Trigger the official build | Maintainer only — it does not run in this repository |

Nobody outside the maintainers has write access, which is the default for a public repository: contribution happens through forks, never through branches here.

## Branch protection — `main`

> **Not active yet.** Branch protection and rulesets are unavailable on a private repository under a free plan — the API returns 403 for both. Everything in this section takes effect when the repository is made public, and applying it is part of going public, not an afterthought. Until then `main` has no protection at all.

- Require a pull request before merging
- Require status checks to pass (analyze, tests, Linux compile check, `license/cla`)
- Require branches to be up to date before merging
- **Do not allow bypassing the above settings — including administrators.** Without this, the protection is advisory: a rushed direct push by the maintainer is the most common way this discipline dies.
- Require linear history (squash merges only) — the trunk stays readable and the generated changelog stays exact
- Automatically delete head branches after merge

Approval is **not** required while there is a single maintainer — requiring it would only block the maintainer's own PRs. Add it the moment a second person has write access.

## Tag protection

A ruleset on the `v*` pattern restricting **creation** to maintainers. The tag is the release trigger, so this is the real gate: a collaborator with write access could otherwise ship a release.

There is defence in depth behind it: a tag here marks a point in history and, on its own, produces nothing. No build, signing or publishing step runs in this repository.

## Actions settings

- **Require approval before running workflows from a fork, for contributors who have not landed a PR yet.** This is GitHub's default, and it is deliberate rather than inherited: the abuse it guards against — a workflow that exists to mine crypto on the runner — arrives from throwaway accounts with no history, which is exactly what this setting catches. Requiring approval from *every* outside contributor, forever, was considered and rejected: it buys almost nothing here, because fork PRs get a read-only token and no secrets, and this repository has no secrets in CI anyway (below). It would cost a maintainer click on every contribution from people who have already proven themselves, and leave their pull requests sitting without CI until someone is awake.
- Workflow permissions: read-only by default; grant write per workflow only where genuinely needed.
- **No secrets in this repository's CI.** Signing keys, certificates and distribution credentials live outside it. Validation here must never require a secret — which is why git tests run against a temporary local repository rather than a real remote.

## CLA bot

The [CLA](../../CLA.md) is enforced by [`.github/workflows/cla.yml`](../../.github/workflows/cla.yml), which runs the self-hosted `contributor-assistant/github-action`. Nothing is delegated to a third-party service — the alternative, the hosted CLA Assistant GitHub App, would mean granting an outside service write access to this repository, which contradicts the Actions rules above.

Setup, in order:

1. ~~**Create the signatures branch.**~~ Done — the orphan branch `cla-signatures` holds `signatures/v1/cla.json`. It still needs pushing.
2. ~~**Fill in the repository URL.**~~ Done — the workflow derives it from `${{ github.repository }}`, so renaming the repo or moving it to an organization leaves no broken links.
3. **Leave workflow permissions read-only** at the repository level — the workflow declares its own `permissions:` block, which is how it gets write access without loosening the global default. Confirm this holds after the first run; an organization-level policy can cap it.
4. **Add `license/cla` to the required status checks** on `main` once it has run once and the check name exists. Blocked until the repository is public (see the branch protection note above). Until it is done the bot comments but does not block — the failure mode that lets an unsigned contribution merge.
5. **Test from a second account**, against a fork — the maintainer's own PRs never exercise the unsigned path.

The bot only reacts to a comment matching the acceptance phrase exactly, and the job performs no checkout: `pull_request_target` runs with a writable token in the base repo's context, so executing anything from the PR head would hand that token to the contributor.

**Timing matters.** A contribution merged before the bot is live is MIT-only and permanently blocks relicensing of that code ([Decision 1](../decisions/001-license-is-mit.md)). This has to be in place before the first external PR, not after.

## General

- Issues and Discussions enabled; blank issues disabled (templates in `.github/ISSUE_TEMPLATE/`)
- Private vulnerability reporting enabled ([SECURITY.md](../../SECURITY.md))
- Wiki disabled — documentation lives in `docs/`, versioned with the code, which is the entire thesis of this project
- Default branch: `main` — the only long-lived line of development. The orphan branch `cla-signatures` is also permanent, but it holds the CLA signature file and no code; the bot commits to it directly, which is why it cannot live on `main`.

## Changing any of this

A change to these settings is a change to the project's guarantees. Update this file in the same PR-worthy spirit as the rest of the docs, and state the reason.
