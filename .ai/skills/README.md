# Skills — TOM

The skills hold the project's operational conventions, one folder each
with a `SKILL.md`. They cover procedure — how work is done here — not product
or architecture, which live in [`docs/`](../../docs/about.md).
`tom-feature-flow` is the entry point: it is the order the others are reached
in, and it holds no rule of its own beyond that order. `tom-code-review`
is the one that comes closest to the line: it does not restate the rules, it
says how a diff is checked against them and which ones the tooling already
proves. `tom-docs` holds the same position over `docs/` itself: it is the shape
a doc takes, not a second copy of what the docs say, and `tom-testing` the same
over the suite: the kinds of test live in `conventions/testing.md`, the skill is
the end-to-end contract that file names and does not detail, and the test
side's traps.

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

## Traps live in the skill that is loaded when they apply

A trap is a procedure, so it is kept where the work that meets it starts:

| The trap is about | It lives in |
|---|---|
| the code — Riverpod, `re_editor`, Flutter layout, git, the generators | [`AGENTS.md`](../../AGENTS.md), *Current status* |
| the Penpot file and its plugin, and measuring the app against a board | [`tom-design`](tom-design/SKILL.md) |
| a test — end-to-end, widget or integration | [`tom-testing`](tom-testing/SKILL.md) |

- A skill carries no counts — tests, scenarios, components, boards, messages; the repository answers, and a number in prose is stale by the next session.
- A skill cites a page of the Penpot file by its name, never by its number.

## Maintenance

The skills mirror `CONTRIBUTING.md` and the decisions. When a convention
changes — new scopes, merge policy, release format — update all of them:
`CONTRIBUTING.md`, the corresponding skill, and, if it is an architectural
decision, a file in `docs/technical/decisions/`. Because `tom-pro` references the skills
by path instead of copying them, it follows along automatically.
