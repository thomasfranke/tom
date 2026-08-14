# Skills — TOM

Two skills holding the project's operational conventions. They are loaded **on demand** — only when the task at hand matches — unlike `CLAUDE.md`, which enters every session.

| Skill | Fires on | Covers |
|---|---|---|
| `tom-git-workflow` | committing, creating a branch, opening a PR, tagging a release, "commit this", "push", "ship it" | Branch naming, Conventional Commits with the monorepo's scopes, squash policy, releases as tags, the extra rules for `tom-pro` |
| `tom-pr-writer` | "write the PR", "draft a PR description", finishing a branch, revising an existing description | Inspecting the real diff before writing, title = the Conventional Commit the squash will produce, the What/Why/Notes template, conditional checklist |

## Where they live: the public repo, and nowhere else

The skills live in **`tom/.claude/skills/`**:

- Versioned with the project and available to anyone who clones it and uses Claude Code — `tom-git-workflow` only does its job if an outside contributor receives it too.
- **`tom-pro` inherits them by relative path** (`../tom/.claude/skills/`), exactly as it already does with the documentation. The path is relative on purpose: the commercial repo's setup requires both clones side by side, so it resolves wherever the pair happens to live. **Never copy them there** — one source of truth, and a divergent copy is worse than no copy. Both skills carry a final section covering what differs in `tom-pro`.
- That rule is not theoretical. Copies did exist in `tom-pro`, and they had drifted from the originals within a single working session. They were removed on 2026-08-14.

## Maintenance

The skills mirror `CONTRIBUTING.md` and the decisions. When a convention changes — new scopes, merge policy, release format — update all three: `CONTRIBUTING.md`, the corresponding skill, and, if it is an architectural decision, a file in `docs/decisions/`. Because `tom-pro` references the skills by path instead of copying them, it follows along automatically.
