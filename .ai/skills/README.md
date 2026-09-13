# Skills — TOM

Three skills holding the project's operational conventions, one folder each
with a `SKILL.md`. They cover procedure — how work is done here — not product
or architecture, which live in [`docs/`](../../docs/about.md).

## They do not load themselves

No agent discovers these files on its own. What activates them is the trigger
table in [`AGENTS.md`](../../AGENTS.md#skills--load-on-the-matching-trigger) —
that table is the mechanism, not a summary of one. If a skill is added,
renamed or retired, the table changes in the same commit or the skill is
effectively dead.

Each `SKILL.md` keeps a YAML frontmatter with `name` and `description`. That
is metadata, not a tool binding: an agent that understands the format uses it,
one that doesn't reads straight past it into the markdown.

## Where they live: `.ai/`, and nowhere else

- **`.ai/skills/`, versioned with the project.** Anyone who clones the repo
  receives them — `tom-git-workflow` only does its job if an outside
  contributor gets it too. The folder is deliberately not named after any
  vendor: the content is agent-agnostic, and nothing tool-specific is
  committed — any vendor folder is gitignored machine-local scratch.
- **`tom-pro` inherits them by relative path** (`../tom/.ai/skills/`), exactly
  as it already does with the documentation. The path is relative on purpose:
  the commercial repo's setup requires both clones side by side, so it
  resolves wherever the pair happens to live. **Never copy them there** — one
  source of truth, and a divergent copy is worse than no copy.
- That rule is not theoretical. Copies did exist in `tom-pro`, and they had
  drifted from the originals within a single working session. They were
  removed on 2026-08-14.

## Maintenance

The skills mirror `CONTRIBUTING.md` and the decisions. When a convention
changes — new scopes, merge policy, release format — update all three:
`CONTRIBUTING.md`, the corresponding skill, and, if it is an architectural
decision, a file in `docs/technical/decisions/`. Because `tom-pro` references the skills
by path instead of copying them, it follows along automatically.
