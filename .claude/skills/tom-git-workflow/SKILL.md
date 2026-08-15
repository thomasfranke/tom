---
name: tom-git-workflow
description: TOM's Git conventions — trunk-based development on main, branch naming, Conventional Commits, squash-merge policy, feature flags instead of long-lived branches, and how releases are tagged. Use this skill whenever committing, staging changes, writing a commit message, creating a branch, opening or merging a pull request, cutting a release, applying a hotfix, or when the user says "commit this", "push", "open a PR", "ship it", or asks which branch to target in the TOM repositories (tom, tom-pro).
---

# TOM — Git workflow

**Trunk-based.** `main` is the only long-lived branch and is always green. Releases are tags.

```
feat/*  ──PR──▶  main  ──tag──▶  published release
```

**`main` is publishable, not published. What is in production is the most recent tag.** Work that is not ready ships dormant behind a disabled feature flag rather than waiting on a branch — see `the "Feature flags" section of CONTRIBUTING.md`.

There is **no `dev` branch** and **no permanent `release/*` branch.** A `release/x.y` branch is created only if an already-released version needs a fix while `main` has moved on (branch from the tag, fix, tag a patch, cherry-pick back if applicable).

## Branches

Short-lived, off the latest `main`:

```
<type>/<kebab-case-summary>
```

Types mirror the commit types: `feat/`, `fix/`, `refactor/`, `docs/`, `chore/`, `test/`, `perf/`, `ci/`.

```
feat/rendered-diff-v0
fix/watcher-echo-suppression
docs/decision-013-space-config
```

Rules:
- English, lowercase, hyphenated. One concern per branch.
- **Short-lived is the point.** A branch living longer than a few days should have been merged behind a flag instead.
- Rebase on `main` rather than merging `main` in — keeps the squash clean.
- Delete after merge.

## Commits

**Conventional Commits**, imperative mood, English, no trailing period:

```
<type>(<scope>): <subject>

[optional body: WHY, not what]

[optional footer: Refs #12 / BREAKING CHANGE: ...]
```

Types: `feat` · `fix` · `docs` · `refactor` · `test` · `chore` · `perf` · `ci` · `build`

Scopes follow the monorepo structure: `core` · `desktop` · `git` · `diff` · `editor` · `search` · `watcher` · `di`

For a documentation change the scope names the docs area instead: `decisions` · `architecture` · `patterns`. The scope is optional — omit it when a change genuinely spans the repository rather than picking one.

```
feat(diff): classify modified blocks by similarity
fix(watcher): ignore echo events from our own saves
docs(decisions): add 013 on space configuration format
refactor(core): move BlockDiffer to domain/services
```

Rules:
- Subject under ~72 characters, lowercase after the colon.
- The body explains **why**, never restates the diff.
- A commit that changes behavior updates the docs **in the same commit**.
- Messy work-in-progress commits inside a branch are fine — the squash cleans them up. Never push messy commits straight to `main`.

## Merging

**Squash merge, always.** A branch's history collapses into one clean Conventional Commit on `main`, keeping the trunk linear and readable — and making the generated changelog exact.

CI green is required to merge; approval is not required while there is a single maintainer.

## Releases

Tags on `main`, never branches:

```
v0.1.0            # semantic versioning
v0.4.0-beta.1     # pre-release channel
```

- Tagging is the release trigger and is restricted to maintainers.
- The changelog is generated from the Conventional Commits since the previous tag — the reason the convention is enforced rather than suggested.
- A release never waits for a branch to stabilize: unfinished features are already on `main`, dormant behind disabled flags.
- Version alignment across the two repos: the public repo defines the number; see `docs/versioning.md`.

## In the tom-pro repository

Same conventions, with three additions:

- Work belonging to the free tier is done in the **public** repo, in its own PR. If a pro change depends on a public change, land the public one first and pin it.
- **Paid code never lives in the public repo**, regardless of flags. The repo answers "who has this code"; a flag only answers "is it exposed in this build".
- PR descriptions never contain license keys, private key material, customer names or pricing under negotiation.
