# Contributing to TOM

Thanks for considering a contribution. TOM is a Git client specialized in markdown documentation — [read the vision first](docs/vision.md), it explains what this project deliberately does *not* try to be.

## Before you start

- **Check the non-goals.** [product.md](docs/product.md) lists what TOM will not become (WYSIWYG editing, real-time collaboration, its own cloud sync). PRs implementing a non-goal will be declined, however good the code.
- **Read the decisions.** [docs/decisions/](docs/decisions/) records the architectural choices and *why* they were made. If your change contradicts one, that is a conversation to have in an issue first — not a surprise in a PR.
- **Follow the patterns.** [docs/patterns/](docs/patterns/) holds the canonical code templates (error handling, dependency injection, extension modules). New code follows them.
- **Open an issue for anything substantial.** Small fixes can go straight to a PR; a feature or refactor deserves a discussion first, so nobody wastes an afternoon.

## Development setup

See [docs/setup.md](docs/setup.md). In short: a pub workspace with `packages/tom_core` (pure Dart) and `apps/tom_desktop` (Flutter).

## How contributions reach the project

Nobody needs write access to contribute. **Fork the repository, work on a branch in your fork, and open a pull request against `main`.** Your branch lives in your copy; the PR is the request to bring it here.

Merging and tagging are restricted to the maintainer — including the `v*` tags that trigger a release build. This is not a comment on trust: a release ships signed binaries to users, and that responsibility stays in one place.

Two practical consequences:

- **Keep your fork in sync.** A fork is a snapshot; branch from an up-to-date `main` or your PR will be reviewed against a moving target.
- **The first PR from a new contributor needs approval to run CI.** GitHub asks the maintainer before running workflows from an outside fork. This is standard hygiene, not suspicion — after your first merged PR it stops asking.

## Workflow

**Trunk-based.** `main` is the only long-lived branch and is always green.

```
feat/*  ──PR──▶  main  ──tag──▶  published release
```

1. Branch off the latest `main`: `<type>/<kebab-case-summary>` (e.g. `feat/rendered-diff-v0`, `fix/watcher-echo-suppression`). Keep branches short-lived — a branch alive for weeks should have been merged behind a flag instead.
2. Commit using [Conventional Commits](https://www.conventionalcommits.org/): `feat(diff): classify modified blocks by similarity`. The type says what kind of change it is (`feat`, `fix`, `docs`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`); the scope says which part it touches, and follows the structure: `core`, `desktop`, `git`, `diff`, `editor`, `search`, `watcher`, `di` — or, for a documentation change, the docs area: `decisions`, `architecture`, `patterns`. The scope is optional; omit it when a change genuinely spans the repository rather than picking one.
3. Open a PR **against `main`** whose **title is the Conventional Commit** the squash will produce.
4. Fill in the description: **What**, **Why** (link the decision if there is one), **How to test**, **Automated tests**, **Notes**. Both testing sections are required — first the steps a reviewer can follow (and the platform you verified on), then the coverage you added; "none needed" is fine with a reason.
5. CI must be green. PRs are **squash-merged**, so a messy branch history is fine — the commit landing on `main` is not.

Incomplete work integrates early behind a [feature flag](docs/patterns/feature-flags.md) rather than living on a branch. Releases are tags on `main` (`v0.1.0`) and the changelog is generated from commit messages; **`main` is publishable, and what is in production is the most recent tag.** There is no `dev` branch and no permanent `release/*` branch — the latter is created only if a released version needs a fix while `main` has moved on.

## Rules that PRs are checked against

- **New dependency?** State its license in the PR description. Nothing AGPL/GPL — the project is MIT and must stay relicensable ([Decision 1](docs/decisions/001-license-is-mit.md)).
- **Behavior changed?** Update the documentation in the same PR. Docs live with the code they describe; that is the whole thesis of this project.
- **Architectural change?** Add or revise a file in `docs/decisions/` in the same PR.
- **`tom_core` stays pure Dart.** No `import 'package:flutter/...'` — the build enforces it, and `dart test` proves it ([Decision 8](docs/decisions/008-monorepo-with-pure-dart-core.md)).
- **Riverpod only in `presentation/` and `bootstrap/di/`.** Everything below takes its dependencies through constructors ([Decision 7](docs/decisions/007-external-dependencies-behind-contracts.md)).
- **Reviewable?** The PR gives concrete steps to see the change working, starting from a described repo state, on a named platform.
- **Tests?** Match the level to what changed ([strategy](docs/architecture/07-testing.md)): parsers get fixtures, the block differ gets golden files, use cases get mocked repositories, repository implementations get a real git repo in a temp dir. A PR whose Testing section is empty will be asked about it.
- **Incomplete feature?** Put it behind a build-time flag ([pattern](docs/patterns/feature-flags.md)) — disabled means *unreachable*, not merely invisible, and every flag states when it will be removed.
- **English everywhere:** code, comments, commits, documentation.

## Tests

- `tom_core`: `dart test` — pure, fast, no Flutter binding.
- `tom_desktop`: `flutter test`.
- Parsers get fixtures of real git output; the block differ gets golden files; `GitRepositoryImpl` gets integration tests against a real git repo created in a temp directory.

See [docs/architecture/07-testing.md](docs/architecture/07-testing.md).

## Contributor License Agreement

Before a pull request can be merged, we ask you to accept the [CLA](CLA.md). It is a one-time thing: the bot leaves a comment on your first PR, you reply to it once, and it remembers you after that.

Here is what it means in plain terms — nobody should have to read legalese to know what they are agreeing to:

- **You keep the copyright to your work.** Nothing is signed over. You can reuse your own contribution anywhere, under any terms, forever.
- **Anything already released under MIT stays MIT, permanently.** MIT grants cannot be revoked, so every version published as free software remains free software — forkable and usable by anyone, you included.
- **The project can relicense contributed code in future releases**, possibly under terms other than MIT. We would rather say so here than let you find it in a legal file later; the reasoning is written out in [Decision 1](docs/decisions/001-license-is-mit.md).

Questions are welcome — open an issue and ask. And if you would rather not sign, that is completely understandable: issues, bug reports, design discussion and docs feedback are all genuinely useful, and none of them need a CLA.

## Reporting a security issue

Do not open a public issue — see [SECURITY.md](SECURITY.md).

## Code of conduct

Be decent. Assume good faith, critique the code and not the person, and remember that most people here are doing this in their spare time.
