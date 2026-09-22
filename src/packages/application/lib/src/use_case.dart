/// The one try/catch every use case carries.
library;

import 'package:tom_core/tom_core.dart';

/// What every use case mixes in to get the standardized failure handling.
///
/// The rule is stated in
/// [layers.md](../../../../../docs/technical/layers.md#errors-across-boundaries):
/// every use case wraps its body in a standardized `try/catch`, hands what
/// it caught to [Observability], and returns [UnexpectedFailure] — **never
/// rethrows, never swallows**.
///
/// It is a mixin rather than a convention repeated in each file, because
/// "standardized" and "copied nineteen times" are different things: a rule
/// that lives in one place can be changed in one place, and a use case that
/// forgot it would have to work to do so.
///
/// What this does *not* do is turn expected failures into unexpected ones. A
/// repository that answers `Failure(GitNotARepository(...))` has not thrown;
/// it has reported, and [guard] hands that result straight back. Only an
/// exception reaching this point is unexpected, by definition — every
/// boundary below has already promised not to throw.
mixin UseCase {
  /// Where an exception goes if one ever gets this far.
  ///
  /// A port, not a policy: the default discards everything and no data
  /// leaves the machine unless the user turns it on ([Decision
  /// 11](../../../../../docs/technical/decisions/011-telemetry-is-opt-in.md)).
  Observability get observability;

  /// Runs [body], turning anything it throws into a failure.
  ///
  /// The layer is `'application'` because that is where the catch is, not
  /// where the throw was: a stack trace says the second, and conflating them
  /// would make every report look like a use-case bug.
  ///
  /// **It widens, and that is the honest signature.** [body] answers with one
  /// vocabulary; this can also produce [UnexpectedFailure], which belongs to
  /// none. So what a use case returns is `Result<T, AppFailure>` — a screen
  /// switching over it handles the failures it knows and ends in a general
  /// case, which is what the UI already does.
  Future<Result<T, AppFailure>> guard<T, F extends AppFailure>(
    Future<Result<T, F>> Function() body,
  ) async {
    try {
      return (await body()).mapFailure<AppFailure>((F failure) => failure);
    } on Object catch (error, stackTrace) {
      await observability.capture(error, stackTrace, layer: 'application');
      return Failure<T, AppFailure>(UnexpectedFailure(error.toString()));
    }
  }
}
