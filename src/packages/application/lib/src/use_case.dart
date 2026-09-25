/// The one try/catch every use case carries.
library;

import 'package:tom_core/tom_core.dart';

/// The standardized failure handling every use case mixes in
/// ([errors](../../../../../docs/technical/conventions/errors.md)).
///
/// A mixin rather than a convention, so the rule lives in one place. A
/// reported failure passes through [guard] untouched; only an exception is
/// unexpected, since every boundary below has promised not to throw.
mixin UseCase {
  /// Where an exception goes if one ever gets this far ([Decision
  /// 11](../../../../../docs/technical/decisions/011-telemetry-is-opt-in.md)).
  Observability get observability;

  /// [body]'s result, with anything it throws turned into [UnexpectedFailure].
  ///
  /// The layer is `'application'` because that is where the catch is, not
  /// where the throw was. The failure type widens to [AppFailure] because
  /// [UnexpectedFailure] belongs to no vocabulary [body] answers in.
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
