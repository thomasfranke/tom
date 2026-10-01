# Technical documentation

**How TOM is built.** Developer- and agent-facing.

What the project *is* is [`about.md`](../about.md); what each feature *must do*
is [`product/`](../product/README.md); what it *looks like* is
[`design/`](../design/README.md). This chapter answers *how*.

**Start with [`architecture.md`](architecture.md)** — the package graph, what
each package holds, and what makes a violation fail to compile. Every chapter
below details one part of it.

| | Answers |
|---|---|
| [`architecture.md`](architecture.md) | The layer graph: eight packages, who may depend on whom |
| [`enforcement.md`](enforcement.md) | What makes a violation fail rather than be discouraged |
| [`mobile.md`](mobile.md) | What changes when a second application arrives |
| [`conventions/`](conventions/README.md) | The rules inside a package: naming, structure, errors across boundaries, external dependencies, the test layout |
| [`runtime/`](runtime/README.md) | How it behaves while running: the git queue, the preview, the diff pipeline, the session, the wiring |
| [`domain/`](domain/README.md) | The entities and value objects — deliberately partial, with the open questions named |
| [`stack/`](stack/README.md) | The dependencies, package by package, with licenses and what was deliberately excluded |
| [`process/`](process/README.md) | Setting up, the `tom` CLI, CI, versioning, and the repository settings that are not in code |
| [`decisions/`](decisions/README.md) | The numbered decision log — one file per decision, flat and global |

## Rules

- **[`architecture.md`](architecture.md) and [`conventions/`](conventions/README.md) are normative** — binding on every change, not descriptive of the current one. Deviating requires a new entry in [`decisions/`](decisions/README.md) stating why, in the same change that deviates. Never a silent exception. Every other chapter describes current practice.
- **A technical doc never states a product rule.** It links to the [`product/`](../product/README.md) chapter that owns it and explains the machinery underneath; when the two disagree, product states the intent and this is wrong.
- **The canonical form of a rule is the dartdoc of the code that implements it.** These files state the rule, the code shows it — when those disagree the code is right and the doc is a bug.
- **Every folder's `README.md` is its index, and every file under it answers one question.** A file that grows a second subject is split, not sectioned — dartdoc points at `conventions/errors.md` expecting the whole file to be the rule it means.

How any doc here is written is the `tom-docs` skill.

---

*See also: [about.md](../about.md) · [product/](../product/README.md) · [design/](../design/README.md) · [roadmap.md](../roadmap.md)*
