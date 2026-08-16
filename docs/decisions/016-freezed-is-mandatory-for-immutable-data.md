# Decision 16 — Freezed is mandatory for immutable data classes

**Status:** accepted

## Context

Freezed is already a structural dependency ([layers.md#external-dependencies](../architecture/layers.md#external-dependencies)) and already in use for the `AppFailure` hierarchies (`GitFailure`, `DocumentFailure`, `SearchFailure`, `FilesystemFailure`), whose generated equality [Decision 5](005-errors-use-result-with-sealed-classes.md) already relies on. What was missing was a rule for everything that comes after: `Space`, `Document`, `GitStatus`, `Commit`, `Branch`, `DiffBlock` ([domain-model.md](../architecture/domain-model.md)) and presentation view-state are not built yet (phase 0), and without an explicit rule, each one is a small decision on its own — hand-write `==`/`copyWith`, or generate it. Left implicit, the codebase ends up with two shapes of the same problem depending on who wrote which class first.

## Decision

Every immutable data class that is an **entity, value object with more than one field, presentation view-state, or sealed hierarchy** is implemented with `@freezed`. A hand-written `==`/`hashCode`/`copyWith` is not an accepted alternative once a class qualifies — this is the same reasoning [Decision 5](005-errors-use-result-with-sealed-classes.md) already applied to `AppFailure`, generalized to every layer freezed is allowed in.

**Does not extend to:**
- Single-field identifier/path value objects (`RepoRelativePath`, `AbsolutePath`, `BranchName`, `CommitSha`, `SpaceName` — [domain-model.md](../architecture/domain-model.md), [Decision 15](015-ddd-is-applied-selectively.md)). Freezed's generated surface (`copyWith`, `when`/`map`) has nothing to earn its keep on a single-field wrapper; a Dart 3 `extension type` is the zero-cost fit there. This stays a recommendation, not a mandate — revisit if a wrapper grows a second field.
- Use cases, repositories, infra implementations, notifiers (already codegen'd by Riverpod), widgets — none of these are data.

## Rationale

- Consistency: one way to express immutable data, not one-per-author.
- Decision 5's rationale already made the case for the failure hierarchies specifically ("generated equality replaces hand-written `==`/`hashCode` instead of it being hand-written per failure"); nothing in that rationale is specific to failures.
- Freezed stays a build-time-only dependency ([layers.md](../architecture/layers.md#external-dependencies)) regardless of how many classes use it — the runtime-coupling argument that allows it in every layer does not weaken as usage grows.

## Consequences

- `tool/coverage_gate.dart`'s `--ignore-files` for `*.freezed.dart` ([Current status, CLAUDE.md](../../CLAUDE.md)) keeps excluding generated code as usage grows; no gate change needed.
- Not lint-enforced today — same as Decision 5's "inline try/catch mandatory", this is reviewed in PR, not caught by tooling.

## Revisit when

Spike B settles `Block`'s shape ([domain-model.md](../architecture/domain-model.md#block--the-central-unknown--spike-b)). If performance during parsing pushes `Block` toward a mutable builder, that is a documented exception then, not a reason to weaken this rule now.
