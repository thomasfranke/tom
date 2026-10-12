# Documentation

The corpus, split by audience. `about.md` is the shared context above the fork
and `roadmap.md` is the order things arrive in; each chapter answers one
question.

| | |
|---|---|
| [`about.md`](about.md) | What the project *is* — the bet, the principles, the personas, the non-goals. Read it first |
| [`product/`](product/README.md) | What each feature must **do**, in non-technical language. Maintained by stakeholders |
| [`technical/`](technical/README.md) | How it is **built** — the architecture, the conventions, the runtime, the decisions |
| [`design/`](design/README.md) | What it **looks like** — the colour roles, the components, every screen as a board |
| [`roadmap.md`](roadmap.md) | Spikes, phases and milestones, in order. There is no task queue beside it |

**One subject per file, and every folder's `README.md` is its index.** How a
doc is shaped, and where a given sentence belongs:
[`product/conventions.md`](product/conventions.md) and the
[`tom-docs`](../.ai/skills/tom-docs/SKILL.md) skill.

**Which record wins depends on the chapter.**

| Chapter | The truth is | When the code disagrees |
|---|---|---|
| [`product/`](product/README.md) | the `doc.md` | the code is the bug — or the maintainer decides the doc moves |
| [`technical/`](technical/README.md) | the code, whose dartdoc is the canonical form of the rule | the doc is the bug |
| [`design/`](design/README.md) | the Penpot file; the export in the repository is the record of it | an export is never edited by hand — the board changes and is exported again |

---

*See also: [AGENTS.md](../AGENTS.md) · [CONTRIBUTING.md](../CONTRIBUTING.md)*
