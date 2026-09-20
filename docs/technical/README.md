# Technical documentation

**How TOM is built.** Developer- and agent-facing: the layer graph, the runtime
flows, the domain model, the dependency stack, the development process, the
visual system — and the numbered decision log underneath all of it.

What the project *is* is [`about.md`](../about.md); what each feature *must do*
is [`product/`](../product/README.md). This folder answers *how*, for a reader
who already knows *what*.

## Chapters

| File | Answers |
|---|---|
| [`layers.md`](layers.md) | The package graph, what enforces it, errors across boundaries, testing |
| [`flows.md`](flows.md) | How it behaves at runtime: the git queue, the watcher protocol, the diff pipeline, wiring |
| [`domain-model.md`](domain-model.md) | The entities and value objects — deliberately partial, with the open questions named |
| [`dependencies.md`](dependencies.md) | The stack, package by package, with licenses and what was deliberately excluded |
| [`setup.md`](setup.md) | Getting a development environment running; CI in two levels |
| [`versioning.md`](versioning.md) | The versioning policy |
| [`repository-settings.md`](repository-settings.md) | Branch protection and the settings that are not in code |
| [`decisions/`](decisions/README.md) | The numbered decision log (ADR) — one file per decision, flat and global |
| [`design/`](design/README.md) | The wireframe index, the visual language, and the tooling that generates both |

## The link-don't-restate rule

A technical doc never states a product rule — it links to the `product/`
chapter that owns it and explains the machinery underneath. When the two
disagree, the product chapter states the intent and the technical section is
what is wrong.

One layer deeper, the same rule applies between this folder and the code:
**the canonical form of a rule is the dartdoc of the code that implements
it.** These files state the rule; the code shows it. When those two disagree,
the code is right and the doc is a bug.

## Normative sections

[`layers.md`](layers.md) and its testing section are **normative** — binding on
every change, not merely descriptive of the current one. Deviating from either
requires a new entry in [`decisions/`](decisions/README.md) stating why, in the
same change that deviates. Never a silent exception.

Every other file here describes current practice and carries no such
requirement.

## Where decisions live

TOM uses a **single flat, chronologically numbered ADR log** in
[`decisions/`](decisions/README.md), not one `decisions.md` per subsystem. The
reason is that several decisions belong to no subsystem at all — 001 is about
licensing, 004 about the business model, 013 about the stack — and splitting
the log by subsystem would leave them homeless while destroying both the
continuous numbering and the "that violates 007" shorthand a review depends
on.

A reversed decision is never deleted; it gets the status *superseded by NNN*.


---

*See also: [about.md](../about.md) · [product/](../product/README.md) · [roadmap.md](../roadmap.md)*
