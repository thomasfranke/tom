# CLA bot

The [CLA](../../../../CLA.md) is enforced by
[`.github/workflows/cla.yml`](../../../../.github/workflows/cla.yml), which runs
the self-hosted `contributor-assistant/github-action`.

- **Nothing is delegated to a third-party service.** The alternative — the hosted CLA Assistant GitHub App — would grant an outside service write access to this repository, which contradicts [actions.md](actions.md).
- The bot reacts only to a comment matching the acceptance phrase exactly.
- **The job performs no checkout.** `pull_request_target` runs with a writable token in the base repo's context, so executing anything from the PR head would hand that token to the contributor.

## Setup, in order

1. ~~Create the signatures branch.~~ Done — the orphan branch `cla-signatures` holds `signatures/v1/cla.json`. **It still needs pushing.**
2. ~~Fill in the repository URL.~~ Done — the workflow derives it from `${{ github.repository }}`, so renaming the repo or moving it to an organization leaves no broken links.
3. **Leave workflow permissions read-only** at the repository level; the workflow declares its own `permissions:` block, which is how it gets write access without loosening the global default. Confirm this holds after the first run — an organization-level policy can cap it.
4. **Add `license/cla` to the required status checks** on `main` once it has run and the check name exists. Blocked until the repository is public ([protection.md](protection.md)). Until then the bot comments but does not block, which is the failure mode that lets an unsigned contribution merge.
5. **Test from a second account**, against a fork. The maintainer's own PRs never exercise the unsigned path.

**Timing matters.** A contribution merged before the bot is live is MIT-only and
permanently blocks relicensing of that code
([Decision 1](../../decisions/001-license-is-mit.md)). This has to be in place
before the first external PR, not after.

---

*See also: [repository-settings/](README.md) · [CLA.md](../../../../CLA.md)*
