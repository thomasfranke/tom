/// The outcome of an operation that can fail, carried as a value (Decision 5).
library;

import 'package:tom_core/src/app_failure.dart';

/// What an operation that can fail returns: what it produced, or why not.
///
/// `sealed`, so a `switch` over a result is exhaustive. [F] is the vocabulary
/// the operation fails with, normally one sealed per-area hierarchy, so the
/// `switch` over the failure is exhaustive too; it is covariant, so widening
/// to [AppFailure] is free and only narrowing costs a translation.
sealed class Result<T, F extends AppFailure> {
  /// Const constructor, for the two variants below.
  const Result();
}

/// An operation that completed, carrying what it produced.
final class Success<T, F extends AppFailure> extends Result<T, F> {
  /// A successful result holding [value].
  const Success(this.value);

  /// What the operation produced.
  final T value;
}

/// An operation that did not complete, carrying why.
final class Failure<T, F extends AppFailure> extends Result<T, F> {
  /// A failed result holding [failure].
  const Failure(this.failure);

  /// Why the operation failed, in the vocabulary [F] names.
  final F failure;
}

/// Chaining over a result, the `map`/`flatMap` Decision 5 left open.
extension ResultChain<T, F extends AppFailure> on Result<T, F> {
  /// This result with its value transformed, the failure carried untouched.
  Result<U, F> map<U>(U Function(T value) transform) => switch (this) {
    Success<T, F>(value: final T value) => Success<U, F>(transform(value)),
    Failure<T, F>(failure: final F failure) => Failure<U, F>(failure),
  };

  /// This result continued into another operation that fails the same way.
  Result<U, F> flatMap<U>(Result<U, F> Function(T value) next) =>
      switch (this) {
        Success<T, F>(value: final T value) => next(value),
        Failure<T, F>(failure: final F failure) => Failure<U, F>(failure),
      };

  /// This result with its failure translated into another vocabulary.
  ///
  /// [onto] takes an [F] rather than an [AppFailure], so its switch is
  /// exhaustive and a variant added below breaks the translation.
  Result<T, G> mapFailure<G extends AppFailure>(G Function(F failure) onto) =>
      switch (this) {
        Success<T, F>(value: final T value) => Success<T, G>(value),
        Failure<T, F>(failure: final F failure) => Failure<T, G>(onto(failure)),
      };

  /// Both branches collapsed into one value.
  U fold<U>(U Function(T value) onSuccess, U Function(F failure) onFailure) =>
      switch (this) {
        Success<T, F>(value: final T value) => onSuccess(value),
        Failure<T, F>(failure: final F failure) => onFailure(failure),
      };

  /// What this holds, or null when it failed.
  T? get valueOrNull => switch (this) {
    Success<T, F>(value: final T value) => value,
    Failure<T, F>() => null,
  };
}

/// The same chaining, without unwrapping the future first.
extension FutureResultChain<T, F extends AppFailure> on Future<Result<T, F>> {
  /// [ResultChain.map], awaited.
  Future<Result<U, F>> map<U>(U Function(T value) transform) async =>
      (await this).map(transform);

  /// [ResultChain.flatMap] over an operation that is itself asynchronous.
  Future<Result<U, F>> flatMap<U>(
    Future<Result<U, F>> Function(T value) next,
  ) async => switch (await this) {
    Success<T, F>(value: final T value) => await next(value),
    Failure<T, F>(failure: final F failure) => Failure<U, F>(failure),
  };

  /// [ResultChain.mapFailure], awaited.
  Future<Result<T, G>> mapFailure<G extends AppFailure>(
    G Function(F failure) onto,
  ) async => (await this).mapFailure(onto);

  /// [ResultChain.fold], awaited.
  Future<U> fold<U>(
    U Function(T value) onSuccess,
    U Function(F failure) onFailure,
  ) async => (await this).fold(onSuccess, onFailure);
}
