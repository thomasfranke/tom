/// The outcome of an operation that can fail, carried as a value.
///
/// An exception never crosses a layer boundary (Decision 5): every repository
/// contract and every use case returns a [Result].
library;

import 'package:tom_core/src/app_failure.dart';

/// What an operation that can fail returns.
///
/// `sealed`, so a `switch` over a result is exhaustive: forgetting the failure
/// branch does not compile.
sealed class Result<T> {
  /// Const constructor, for the two variants below.
  const Result();
}

/// An operation that completed, carrying what it produced.
final class Success<T> extends Result<T> {
  /// Creates a successful result holding [value].
  const Success(this.value);

  /// What the operation produced.
  final T value;
}

/// An operation that did not complete, carrying why.
final class Failure<T> extends Result<T> {
  /// Creates a failed result holding [failure].
  const Failure(this.failure);

  /// Why the operation failed.
  ///
  /// Typed rather than a message: the UI decides per failure, and the
  /// area hierarchies are sealed, so a new failure mode breaks every switch
  /// that has to handle it. See [AppFailure].
  final AppFailure failure;
}
