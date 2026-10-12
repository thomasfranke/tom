# Conventions

How a product doc is shaped and written. The docs themselves are
[`README.md`](README.md).

## Shape

```
docs/product/<group>/<feature>/doc.md          ← one subject, atomic rules
docs/product/<group>/<feature>/README.md       ← the index, once a feature is several subjects
docs/product/<group>/<feature>/<aspect>/doc.md
```

- One subject per file, and **prefer more files with an index over one file with more sections** — a link into a `doc.md` is a promise about the whole file.
- **A file is two files when it answers two questions**, not when it passes a word count. A feature that grew several subjects becomes a folder with a `README.md` index and one `doc.md` per subject; one that is simply long because its subject has many rules stays one file.
- Length is a prompt to look, never a finding on its own: the finding is a second subject, or prose where a rule belongs.
- **A mobile counterpart is its own file**, not a subsection — [Decision 8](../technical/decisions/008-monorepo-with-pure-dart-core.md) gives mobile its own presentation, so its rules are genuinely different rather than a narrower copy.
- A feature with no natural group sits directly under `docs/product/`.
- The screens are not here. They live once, in [`design/screens/`](../design/screens/README.md).

## Writing a rule

- Rules are **atomic and imperative** ("Fetch alone never changes a file on disk"), never prose paragraphs — that is what makes them checkable by a stakeholder reading and by an agent implementing.
- A reason rides on the rule it justifies, in the same line after an em dash. A paragraph that is not a rule earns at most three lines.
- A product doc never names a class. When product and technical disagree, product states the intent and technical is wrong.
- **When a product doc and the app disagree, the doc is the truth** and the app is the bug — or the maintainer decides the case and the doc is rewritten. "The code is right" holds for [`technical/`](../technical/README.md) only.
- **A revoked rule is deleted, not struck through** — two rules side by side read as two rules, and git holds what the file used to say.

## The Status line

Each file states one, under its opening: **the state, the milestone, and at most one caveat**.

| Word | Means |
|---|---|
| `Planned` | Decided, and not built |
| `Draft` | Written, and not yet accepted by the maintainer; whether it is built is a second fact, said in the caveat |
| `Shipped` | Built, and what the app is checked against |
| `Exploratory` | A direction, not a commitment — mobile, Phase 3 |

- The caveat names what in a `Shipped` file is still `Planned`, or what a `Draft` is waiting on — nothing else.
- No date, no "since", no account of what the file said before — the milestone is per [roadmap.md](../roadmap.md), the history is git's.

**Known gap:** the rules are checkable by a reader but are not phrased as
testable criteria (EARS or equivalent), so they do not map one-to-one onto test
names. Nothing mechanically ties a rule to the test that proves it.

## Keeping mocks current

- Every screen, panel, dialog, popover and control is drawn and approved in Penpot before it is built, and exported into [`design/screens/desktop/<page>/`](../design/screens/README.md) in both themes before the PR merges.
- A `doc.md` links a board; a board never links back — the set is read together to see whether it is one product, a `doc.md` one feature at a time.
- **`## Mocks` live in the subject's own `doc.md`.** An index links none — a list kept in two places drifts, and the index's copy is the one nobody opens the board from.
- **A link points at a file that is on disk.** A board not exported yet is named in words — its Penpot page and its row — and gains its link with the export.
- **A Penpot page is cited by its name, never by its number** — pages are renumbered whenever one is split.
- A PR that changes an interface changes its board first: edited and approved in Penpot before the code, and exported again before the PR merges ([AGENTS.md](../../AGENTS.md), rule 13).
- A product with no UI yet says "Not drawn yet" and that is honest; a product whose UI shipped and diverged from its board is not.

How a screen is drawn and checked against the running app is the `tom-design`
skill; how any doc here is written is `tom-docs`.

---

*See also: [product/](README.md) · [design/](../design/README.md)*
