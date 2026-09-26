# Protection

What guards `main` and the release tags.

> **Not active yet.** Branch protection and rulesets are unavailable on a
> private repository under a free plan — the API returns 403 for both.
> Everything here takes effect when the repository is made public, and applying
> it is part of going public rather than an afterthought. Until then `main` has
> no protection at all.

## Branch protection — `main`

- Require a pull request before merging.
- Require status checks to pass: analyze, tests, Linux compile check, `license/cla`.
- Require branches to be up to date before merging.
- **Do not allow bypassing the above, administrators included** — without this the protection is advisory, and a rushed direct push by the maintainer is the most common way this discipline dies.
- Require linear history, squash merges only, so the trunk stays readable and the generated changelog stays exact.
- Automatically delete head branches after merge.
- Approval is **not** required while there is a single maintainer; requiring it would only block the maintainer's own PRs. Add it the moment a second person has write access.

## Tag protection

- A ruleset on the `v*` pattern restricting **creation** to maintainers. The tag is the release trigger, so this is the real gate — a collaborator with write access could otherwise ship a release.
- There is defence in depth behind it: a tag here marks a point in history and, on its own, produces nothing. No build, signing or publishing step runs in this repository.

---

*See also: [repository-settings/](README.md) · [access.md](access.md) · [versioning.md](../versioning.md)*
