---
name: tom-pr-writer
description: Writes pull request titles and descriptions for the TOM repositories by inspecting the actual diff. Use this skill whenever the user is about to open a PR, asks to "write the PR", "draft a PR description", "prepare the pull request", "what should the PR say", or has just finished a branch and needs it described. Also use when reviewing or rewriting an existing PR description, or when writing the squash commit message for a merge.
---

# TOM — writing a pull request

A PR on a public repository is read by strangers, by future contributors, and by future you. It is the record of **why** — the diff already covers what.

## Step 1: read the actual change

Never write a PR description from memory or from the branch name. Inspect the diff first:

```bash
git fetch origin main
git log --oneline origin/main..HEAD        # commits on the branch
git diff origin/main...HEAD --stat         # scope of the change
git diff origin/main...HEAD                # the change itself
```

From that, establish: which packages and layers were touched, whether behavior changed, whether any dependency was added, and whether any decision or pattern in `docs/` is affected.

## Step 2: write the title

The title is **exactly the Conventional Commit that the squash merge will produce**:

```
<type>(<scope>): <subject>
```

Types: `feat` · `fix` · `docs` · `refactor` · `test` · `chore` · `perf` · `ci` · `build`
Scopes: `core` · `desktop` · `git` · `diff` · `editor` · `search` · `watcher` · `di` — or, for a documentation change, the docs area: `decisions` · `architecture` · `patterns`

The scope is optional: omit it when a change genuinely spans the repository rather than picking one. Imperative mood, lowercase after the colon, no trailing period, under ~72 characters.

```
feat(diff): classify modified blocks by similarity
fix(watcher): suppress echo events from our own saves
```

If the branch does two unrelated things, say so and suggest splitting it rather than inventing a title that covers both.

## Step 3: write the description

```markdown
## What
One or two sentences. Plain language, no diff narration.

## Why
The problem being solved, the trade-off taken, or the decision being
implemented. Link it: docs/decisions/0NN-....md

## How to test
Numbered steps a reviewer can follow: the repo state to start from,
what to do, what should happen. State the platform verified on.

## Automated tests
Which tests were added or changed, and at which level.

## Notes
What was deliberately left out, what was tried and discarded,
follow-ups worth an issue. Omit the section if there is genuinely nothing.
```

**Both testing sections are mandatory, and both are written from the diff — never from assumption.**

**How to test** comes first because it is what the reviewer acts on. Write reproducible steps, not a claim: which repo state to start from (a space with a dirty working tree? two branches with diverging docs?), what to do, and what should happen. A reviewer who cannot follow the steps cannot review the change. Always name the platform it was verified on — this is a three-platform desktop app and "works on my machine" is a real risk.

**Automated tests** comes second. Check the branch for changes under `test/`; if there are none, say so plainly rather than implying coverage that does not exist. Match the level to what changed ([testing strategy](../../../docs/architecture/overview/testing.md)):

| Changed | Expected tests |
|---|---|
| A parser | Unit tests with fixtures of real git output |
| `BlockDiffer` | Golden files: md pairs + expected classification |
| A use case | Unit test with mocked repositories, covering failure propagation |
| A repository implementation | Integration test against a real git repo in a temp dir |
| A notifier | Unit test with a test `ProviderContainer` |
| UI | Widget/golden test for the main states |

"No tests needed" is acceptable **only with a stated reason** — docs-only change, a pure refactor already covered, a spike behind a disabled flag. Never leave either section empty, and never substitute one for the other: manual steps are not coverage, and a green suite does not tell a reviewer how to see the change.

Rules for the prose:

- **Why beats what.** "Adds a queue to GitClient" is the diff talking. "Two concurrent git commands could interleave and corrupt the index; operations are now serialized per space" is a reason.
- **State the trade-off** when there is one, including what it costs.
- **Link the decision** whenever the change implements or revises one. If the change *contradicts* a decision, the PR must add or revise the decision file — say so explicitly in the description.
- **Never invent context.** If the reason for a change is not visible in the diff or the conversation, ask the user rather than fabricating a rationale.
- No emoji, no marketing tone, no "🎉 this awesome PR". English, plain and direct.

## Step 4: the checklist

Append only the lines that actually apply to this diff — never a blank template:

```markdown
- [x] Docs updated in this PR (behavior changed)
- [x] New dependency `foo` — MIT
- [ ] Decision 013 added for the space config format
```

Rules the PR is checked against (from `CONTRIBUTING.md`):

- New dependency → its license is stated, and it is not AGPL/GPL.
- Behavior changed → documentation updated **in the same PR**.
- Architectural change → a file added or revised in `docs/decisions/`.
- A layer package touched → still pure Dart, and `make test-arch` still green.
- Riverpod appears only in `presentation/` or `bootstrap/di/`.

## Size

If the diff is large enough that a reviewer could not read it in one sitting, say so and propose a split. A PR description that opens with "this is a big one, sorry" is a signal the branch should have been two.

## In tom-pro

Same structure, plus: never put license keys, private key material, customer names, or pricing under negotiation into a PR description — even a private repo has more readers than the author.
