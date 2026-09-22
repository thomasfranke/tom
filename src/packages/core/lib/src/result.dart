/// The outcome of an operation that can fail, carried as a value.
///
/// An exception never crosses a layer boundary (Decision 5): every capability
/// contract, every repository contract and every use case returns a [Result].
library;

import 'package:tom_core/src/app_failure.dart';

/// What an operation that can fail returns: what it produced, or why it did
/// not.
///
/// `sealed`, so a `switch` over a result is exhaustive — forgetting the
/// failure branch does not compile.
///
/// **Both halves are in the signature.** [F] is the vocabulary the operation
/// fails with, bounded to [AppFailure] and normally one of the sealed per-area
/// hierarchies, so the `switch` over the *failure* is exhaustive too. That is
/// what Decision 5 asked for and a single type parameter could not give: with
/// the failure typed only as [AppFailure], every translation needed a
/// catch-all branch it documented as unreachable.
///
/// [F] is covariant, so widening is free — a
/// `Result<SpaceEntity, SpaceFailure>` is already a
/// `Result<SpaceEntity, AppFailure>`. Narrowing is what costs a
/// translation, and that is the point: it only happens where a layer boundary
/// is crossed.
sealed class Result<T, F extends AppFailure> {
  /// Const constructor, for the two variants below.
  const Result();
}

/// An operation that completed, carrying what it produced.
final class Success<T, F extends AppFailure> extends Result<T, F> {
  /// Creates a successful result holding [value].
  const Success(this.value);

  /// What the operation produced.
  final T value;
}

/// An operation that did not complete, carrying why.
final class Failure<T, F extends AppFailure> extends Result<T, F> {
  /// Creates a failed result holding [failure].
  const Failure(this.failure);

  /// Why the operation failed, in the vocabulary [F] names.
  final F failure;
}

/// Chaining, which Decision 5 left open until it was needed.
///
/// The ADR accepted early return, "with our own `map`/`flatMap` extension if
/// it ever becomes necessary". It became necessary once three classes had
/// written the same private helper to carry a failure across a change of type
/// parameter.
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
  /// The layer boundary as one call. [onto] takes an [F] rather than an
  /// [AppFailure], so the switch inside it is exhaustive and a variant added
  /// below breaks the translation instead of falling through it.
  Result<T, G> mapFailure<G extends AppFailure>(G Function(F failure) onto) =>
      switch (this) {
        Success<T, F>(value: final T value) => Success<T, G>(value),
        Failure<T, F>(failure: final F failure) => Failure<T, G>(onto(failure)),
      };

  /// Both branches collapsed into one value.
  ///
  /// For the caller that has to produce something either way — a view state, a
  /// line of text — where a `switch` carries no information the two callbacks
  /// do not.
  U fold<U>(U Function(T value) onSuccess, U Function(F failure) onFailure) =>
      switch (this) {
        Success<T, F>(value: final T value) => onSuccess(value),
        Failure<T, F>(failure: final F failure) => onFailure(failure),
      };

  /// What this holds, or null when it failed.
  ///
  /// For the caller that treats a failure as an absence — the recent list is
  /// the standing example, where a store nobody can read is an empty list.
  T? get valueOrNull => switch (this) {
    Success<T, F>(value: final T value) => value,
    Failure<T, F>() => null,
  };
}

/// The same chaining, without unwrapping the future first.
///
/// Every contract in the graph is asynchronous, so a chain that had to be
/// awaited at each step would put the whole pipeline back into statements.
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
