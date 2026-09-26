---
name: tom-docs
description: Writes and reviews the documentation under `docs/`. Use this skill when adding or editing any file under `docs/`, when writing or repairing a folder's `README.md` index, when moving a doc or a whole chapter, when reviewing the corpus for style, and when the user says "the docs are too wordy", "trim this doc", "no prose", "where does this belong", or asks what a `doc.md` must contain. Also use before adding a paragraph to `about.md`, `roadmap.md` or any chapter index.
---

# TOM — writing a doc

**A doc treats its subject directly.** The first sentence is already the
subject, and every line after it is a rule, a pointer, or the reason one of
them is that way. No preamble, no transition, no recap.

The rule is easy to agree with and hard to keep. The leaf files in this
repository hold it — [`product/export/doc.md`](../../../docs/product/export/doc.md)
is 101 words and complete — while the files that introduce them drifted into
explaining themselves. Prose is what a doc grows when nobody names the shape it
was supposed to have. So what follows is the shape.

## The form: four shapes, and nothing else

**The opening.** One sentence under the `#` title, saying what the file
answers. Bold it when the file is normative. Never "This document
describes…", never a paragraph of context the reader's next click would give
them anyway.

```markdown
# Export

Get a document out of the app as PDF or HTML — free, always, for every user.
```

**The rule.** Atomic, imperative, one line, checkable by a reader who knows
nothing else. A rule that needs two sentences is two rules — or one rule and a
reason.

```markdown
- Fetch alone never changes a file on disk.
- Export is free in every edition of the app; it is never a paid or gated feature.
```

**The table.** The shape for a set of pairs: a file and what it answers, a
folder and who owns it, a transition and who decides it. A paragraph that is
enumerating is a table nobody has written yet.

**The reason clause.** Rides on the rule it justifies, after an em dash or a
semicolon, in the same line. It carries what a reader would otherwise
reverse-engineer or, worse, undo.

```markdown
- A file that has grown a second subject is split rather than sectioned — dartdoc points at `conventions/errors.md` expecting the whole file to be the rule it means.
```

## Not a shape

- The throat-clearing paragraph before the first rule.
- The transition between two sections ("With that settled, …").
- The recap at the end of a section, and the paragraph that restates the table
  above it.
- "As mentioned above", "it is worth noting", "in other words".
- The argument for a decision — that is a file in
  [`decisions/`](../../../docs/technical/decisions/README.md), linked.
- The history of the doc itself. Git holds it.

## The one exception, and it is counted

A paragraph that is not a rule, a table or an index row earns its place only
when no rule can own it — a trap, or the *why* behind a whole chapter — and it
is **at most three lines**. Same bargain [`tom-comments`](../tom-comments/SKILL.md)
strikes for a dartdoc: the exception exists, and it is bounded.

## One subject per file, and the file is small

**Prefer three files and an index over one file with three sections.** An index
row is cheap; a reader scrolling past two subjects to reach theirs is not, and
a link into a file is a promise about the whole file — dartdoc points at
`conventions/errors.md` expecting everything in it to be the rule it means.

Two signals that a file is two files, either one enough:

- It passes **about 400 words**. That is a signal, not a law: every leaf
  `doc.md` in this repository is under it, and every file over it is an index or
  `about.md`/`roadmap.md`.
- Its second `##` is a different *subject*, not another facet of the same one.
  "Rules" and "Mocks" are facets. "Rules" and "How the index is built" are two
  files.

Splitting is not finished when the files exist: the parent index gains a row
per child, the inbound links move (see *What moves in the same commit*), and
nothing is left behind as a stub that says "moved".

## Structure: where a sentence goes

| The sentence says | It belongs in |
|---|---|
| what a feature must do | `product/<group>/<feature>/doc.md` |
| why the project exists, who it is for, what it refuses | `docs/about.md` — short and stable; if it grows, something belongs elsewhere |
| what gets built, and in what order | `docs/roadmap.md` |
| how something is built | the `technical/` chapter that owns it |
| why it is built that way, once and for all | a new file in `technical/decisions/` |
| what it looks like | `docs/design/` — drawing it is [`tom-design`](../tom-design/SKILL.md) |
| the rule as the code states it | the dartdoc, which is canonical ([`tom-comments`](../tom-comments/SKILL.md)) |

Two lines are never crossed: a technical doc never states a product rule, and a
product doc never names a class. When product and technical disagree, product
states the intent and technical is wrong. When a doc and the code disagree, the
code is right and the doc is a bug.

## Indexes

Every folder's `README.md` **is** its index, and holds five things:

1. The `#` title.
2. One sentence: what the folder answers.
3. Its normative status, when it has one, and what deviating costs.
4. A table of children — one row per file or folder, one line per row.
5. The `*See also:*` footer.

An index never explains what a child explains: the row is a pointer, not a
summary. A child that cannot be described in one line is two children.

## What moves in the same commit

- The index of the folder, when a file is added, renamed or removed.
- Every inbound link: `grep -rn "<old-path>" docs src tool .ai AGENTS.md`.
- `AGENTS.md` — the source-of-truth list, every rule that cites a path, and the
  *Current status* section.
- The trigger table in `AGENTS.md`, when a skill is added, renamed or retired;
  without it the skill is dead.

## The human gate

`AGENTS.md` names one checkpoint and this is it: **a doc never merges on agent
approval alone.** Draft it, say plainly what changed, and stop. A delta that is
written but not blessed goes under *Doc deltas waiting on the human gate* in
`AGENTS.md` — that list is the handoff, not a backlog.

## A real trim, three times

**`about.md`, under the "Where to find what" table.**

> Two folders and two files, split by audience: `product/` says what each
> feature must do, `technical/` says how it is built, `about.md` is the context
> above both, and `roadmap.md` is the order they arrive in. Everything except
> the roadmap describes the system as it is today.

Deleted. The table above it already carries every row, and the count went stale
the day `design/` became a chapter of its own. One line survives, because the
table does not say it:

> Everything except `roadmap.md` describes the system as it is today.

**`product/README.md`, under "Keeping mocks current".**

> The link is one way round on purpose: the boards live together because they
> are read together — a reviewer looks at the set to see whether it is one
> product — while a `doc.md` is read one feature at a time and points at the
> screens it needs.

Becomes a rule with its reason attached:

> - A `doc.md` links a board; a board never links back — the set is read
>   together to see whether it is one product, a `doc.md` one feature at a time.

**`technical/README.md`, under "One file per subject".**

> Every chapter is a folder whose `README.md` is its index, and every file
> under it answers one question. A file that has grown a second subject is
> split rather than sectioned: the reason is that the links into this folder
> come from dartdoc — a comment that points at `conventions/errors.md` is
> pointing at a file whose whole content is the rule it means, and stays right
> when the file next to it is rewritten.

Two rules, two reasons, four lines:

> - Every folder's `README.md` is its index; every file under it answers one question.
> - A file that grows a second subject is split, not sectioned — dartdoc points at `conventions/errors.md` expecting the whole file to be the rule it means.

## Traps

- A doc moved without its inbound links reads as correct and is not: `about.md`
  and `AGENTS.md` still called `design/` a chapter of `technical/` after it
  moved up beside it.
- A count written in prose goes stale silently — "two folders and two files"
  survived the arrival of a third.
- An index that summarises its children creates two sources of truth; the child
  wins, so the index is the bug.
- A rule phrased as description ("The app shows…") cannot be checked. Imperative,
  or `never`/`always`.
- Product rules are not yet testable criteria (EARS or equivalent) — a known gap
  named in `product/README.md`, not a licence to write prose instead.
- A paragraph worth deleting is often a decision nobody recorded. Check
  `decisions/` first, and open one if it is missing.
- A `doc.md` that has outgrown the signal is a folder waiting to happen. `product/workspace/` was 786 words of four subjects wearing one `#`; it is now `regions/`, `columns/`, `leaving-a-space/` and `feedback/` under a `README.md`. Splitting is not done when the files exist — the nine inbound links, four of them dartdoc, move in the same commit.

---

*See also: [`.ai/skills/README.md`](../README.md) · [`AGENTS.md`](../../../AGENTS.md) · [`docs/about.md`](../../../docs/about.md)*
