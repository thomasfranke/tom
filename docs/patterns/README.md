# Design patterns

Canonical code patterns for the project. While the [decisions](../decisions/) record **why** we chose something (context, alternatives, status), the patterns record **how it is written here** (canonical template, examples, anti-patterns). All new code follows these templates; deviations are a PR review matter.

| Pattern | Covers |
|---|---|
| [error-handling.md](error-handling.md) | Result, Failure hierarchies, the use case template with inline try/catch, error translation boundaries |
| [dependency-injection.md](dependency-injection.md) | Composition root, the three lifetimes, per-space families, provider file template |
| [extension-modules.md](extension-modules.md) | Extensible shell through compile-time modules: the TomModule contract, PanelDescriptor, entrypoints |
| [feature-flags.md](feature-flags.md) | Build-time flags so large features integrate early; disabled means unreachable; flags expire |

## When to add a new pattern

A pattern belongs here when: (1) it repeats in 3+ places, (2) there is a non-obvious right way to do it, and (3) getting it wrong causes inconsistency or bugs — not aesthetic preference. Too small for that becomes a code comment; too big becomes a decision in `decisions/` that references a pattern.

---

*See also: [../architecture/](../architecture/) · [../decisions/](../decisions/)*
