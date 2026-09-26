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
- A feature past about 400 words is usually several subjects wearing one `#`. It becomes a folder with a `README.md` index and one `doc.md` per subject.
- **A mobile counterpart is its own file**, not a subsection — [Decision 8](../technical/decisions/008-monorepo-with-pure-dart-core.md) gives mobile its own presentation, so its rules are genuinely different rather than a narrower copy.
- A feature with no natural group sits directly under `docs/product/`.
- The screens are not here. They live once, in [`design/screens/`](../design/screens/README.md).

## Writing a rule

- Rules are **atomic and imperative** ("Fetch alone never changes a file on disk"), never prose paragraphs — that is what makes them checkable by a stakeholder reading and by an agent implementing.
- Each file states a `Status` line (Planned / Shipped) and its milestone, per [roadmap.md](../roadmap.md).
- A reason rides on the rule it justifies, in the same line after an em dash. A paragraph that is not a rule earns at most three lines.
- A product doc never names a class. When product and technical disagree, product states the intent and technical is wrong.

**Known gap:** the rules are checkable by a reader but are not phrased as
testable criteria (EARS or equivalent), so they do not map one-to-one onto test
names. Nothing mechanically ties a rule to the test that proves it.

## Keeping mocks current

- Every screen, panel, dialog, popover and control exists as a board in Penpot before it is built, exported into [`design/screens/desktop/<page>/`](../design/screens/README.md) in both themes.
- A `doc.md` links a board; a board never links back — the set is read together to see whether it is one product, a `doc.md` one feature at a time.
- A PR that changes an interface edits the board and re-exports it in the same PR, as [AGENTS.md](../../AGENTS.md) requires of documentation generally.
- A product with no UI yet says "Not drawn yet" and that is honest; a product whose UI shipped and diverged from its board is not.

How a screen is drawn and checked against the running app is the `tom-design`
skill; how any doc here is written is `tom-docs`.

---

*See also: [product/](README.md) · [design/](../design/README.md)*
