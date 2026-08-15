# Pattern: Error handling

Complements [Decision 5](../../decisions/005-errors-use-result-with-sealed-classes.md) (Result with sealed classes) and the [error model](error-model.md). This file is the **how it is written**.

## Rules

1. Every repository contract method (`domain/repositories/`) returns `Result<T>` — an exception never crosses a layer boundary.
2. Every use case has a **standardized inline try/catch** (template below) as the last customs checkpoint: an unexpected exception never reaches presentation.
3. Technical infrastructure failures (`GitClientFailure`, etc.) are translated into domain failures (`GitFailure`, etc.) by the `repositories_impl` — presentation only ever knows `AppFailure`.
4. Observability always through the contract ([Decision 11](../../decisions/011-telemetry-is-opt-in.md)) — never a vendor SDK or `print` directly.

## Canonical use case template

```dart
// src/packages/application/lib/src/git/commit_changes.dart
import 'package:tom_infra/tom_infra.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// Use case for committing staged changes.
class CommitChanges {
  /// Creates an instance of [CommitChanges].
  const CommitChanges(this._git, this._observability);

  final GitRepositoryInterface _git;
  final ObservabilityInterface _observability;

  /// Commits all staged changes with [message].
  Future<Result<Commit>> call({required final String message}) async {
    try {
      final status = await _git.status();
      if (status case Failure(:final failure)) return Failure(failure);

      return _git.commit(message);
    } on Object catch (e, st) {
      await _observability.capture(e, st, layer: 'application');
      return Failure(UnexpectedFailure(e.toString()));
    }
  }
}
```

Fixed points of the template (identical across every use case):

- **`on Object catch (e, st)`** — catches everything, including `Error`s.
- **`_observability.capture(..., layer: 'application')`** — always with the layer.
- **`return Failure(UnexpectedFailure(...))`** — never rethrow, never swallow silently.
- **Composition through early return** — `if (x case Failure(:final failure)) return Failure(failure);` between chained operations.
- No `debugPrint`/`print` — logging belongs to the observability implementation (the core does not import Flutter).

## Consumption in presentation

```dart
final result = await ref.read(commitChangesProvider(spaceRoot))(message: message);

switch (result) {
  case Success():
    // the session reloads via SpaceChanged (Decisions 9/10); nothing to do here
  case Failure(failure: MergeConflict(:final conflictedFiles)):
    // open the resolution flow
  case Failure(:final failure):
    state = state.copyWith(error: failure);
}
```

An exhaustive switch over the failure types relevant to the panel, with the generic case last.

## Anti-patterns

| ❌ | Why |
|---|---|
| A use case without try/catch | Breaks the "presentation never sees an exception" guarantee |
| A `catch` that only logs and rethrows | The exception crosses the boundary anyway |
| Catching and returning `Failure` without `_observability.capture` | Silent error; impossible to diagnose |
| A vendor SDK or `print` directly in a use case | Violates Decisions 7/11; contaminates the core |
| Translating technical → domain failure inside the use case | Wrong place: that is the `repository_impl`'s job |

## Recorded evolution (plan B)

If, with external contributors, manual enforcement of this template fails repeatedly in PRs, the policy can be centralized in a wrapper (`guard(body)`) — a mechanical refactor with identical runtime behavior. Deliberately **not** adopted now: linear readability and simplicity outweigh insurance against a still-hypothetical risk.
