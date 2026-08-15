# The Result pattern

> **Canonical use case template** (standardized inline try/catch, observability behind a contract): [patterns/error-handling.md](error-handling.md). DI patterns (composition root, lifetimes): [patterns/dependency-injection.md](../presentation/dependency-injection.md).

Every repository method (contract in the domain) returns `Result<T>` — an exception never crosses a layer boundary. Implemented with **native Dart 3 sealed classes**, no `dartz` ([Decision 5](../../decisions/005-errors-use-result-with-sealed-classes.md)).

## The type

```dart
// core/result/result.dart
sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

final class Failure<T> extends Result<T> {
  final AppFailure failure;
  const Failure(this.failure);
}
```

## Failures as sealed hierarchies per area

```dart
// core/failures/app_failure.dart
sealed class AppFailure {
  const AppFailure();
}

// core/failures/git_failure.dart
sealed class GitFailure extends AppFailure {
  const GitFailure();
}

final class GitNotInstalled extends GitFailure { const GitNotInstalled(); }
final class NotARepository extends GitFailure { final String path; const NotARepository(this.path); }
final class MergeConflict extends GitFailure {
  final List<String> conflictedFiles;
  const MergeConflict(this.conflictedFiles);
}
final class AuthenticationFailed extends GitFailure { const AuthenticationFailed(); }
final class DetachedHead extends GitFailure { const DetachedHead(); }
final class GitCommandFailed extends GitFailure {           // typed fallback for the unexpected
  final String command;
  final String stderr;
  const GitCommandFailed(this.command, this.stderr);
}

// core/failures/document_failure.dart
sealed class DocumentFailure extends AppFailure { ... }     // FileNotFound, PermissionDenied, ExternalChangeConflict, ...

// core/failures/search_failure.dart
sealed class SearchFailure extends AppFailure { ... }       // IndexCorrupted (→ rebuild), ...
```

## Consumption: exhaustive switch

```dart
final result = await commitChanges(message: message);

switch (result) {
  case Success():
    ref.invalidate(gitStatusProvider);
  case Failure(:final failure):
    state = state.copyWith(error: failure);   // the UI decides per failure type
}
```

**The rule that pays for the architecture:** adding a new failure type (`RebaseInProgress`, say) **breaks at compile time** every switch that must handle it. In an app where new git failure modes will be discovered continuously, this turns "I forgot to handle it" from a silent bug into a compile error.

## Composition: early return

```dart
Future<Result<Commit>> call({required String message}) async {
  final status = await _git.status();
  if (status case Failure(:final failure)) return Failure(failure);

  final add = await _git.addAll();
  if (add case Failure(:final failure)) return Failure(failure);

  return _git.commit(message);
}
```

No monadic chaining by design (the trade-off accepted in Decision 5). If the pattern above ever gets too repetitive, our own `extension` with `map`/`flatMap` over `Result` solves it — our code, not a dependency.

## Boundaries of the pattern

- **Repositories and use cases:** always `Result<T>`.
- **Parsers (`data/parsers/`):** pure functions; they may throw `FormatException` internally, but the `repository_impl` calling them converts it into a domain `Failure` before crossing the boundary. The same applies to technical infrastructure failures (`GitClientFailure` → domain `GitFailure`).
- **Presentation:** never sees an infrastructure exception; it sees a typed `AppFailure` and decides the UI case by case (conflict → resolution view; auth → credentials help; `GitCommandFailed` → generic error with stderr under "details").
