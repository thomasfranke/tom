# Conventions

The rules a package is held to once the graph in
[`architecture.md`](../architecture.md) has said where it sits. **Normative**:
deviating from any of them requires a new entry in
[`decisions/`](../decisions/README.md) stating why, in the same change that
deviates.

| File | Answers |
|---|---|
| [`inside-a-package.md`](inside-a-package.md) | The barrel, the capability folder, one failure file per capability, what a repository may not do, where a comment stops |
| [`naming.md`](naming.md) | What a name has to carry: the role last, entity versus value object, `Service`, `Impl`, and what counts as a seam |
| [`errors.md`](errors.md) | `Result`, the `AppFailure` hierarchies, and why the translation happens in the repository and nowhere else |
| [`external-dependencies.md`](external-dependencies.md) | The three tiers, and the declared exceptions — Flutter, Riverpod, Freezed — with the scope of each |
| [`testing.md`](testing.md) | `unit/` · `integration/` · `integrity/`, the mirror rule, and what each kind of subject gets |

---

*See also: [architecture.md](../architecture.md) · [technical/](../README.md)*
