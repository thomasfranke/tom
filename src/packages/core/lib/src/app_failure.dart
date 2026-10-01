/// The root of the failure vocabulary: the marker and the chain.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_failure.freezed.dart';

/// What every failure in the product implements.
///
/// Deliberately not `sealed`, which would pull the product's vocabulary into
/// `tom_core`: each area's hierarchy is sealed in its own library, and
/// `Result`'s `F` says which one an operation answers with. Failures are
/// Freezed value objects, equal when their data is.
abstract interface class AppFailure {
  /// What this failure was translated from; null at the bottom of a chain.
  ///
  /// The one path technical detail takes upwards: a domain failure says what
  /// the product tells the user, and the `stderr`, `errno` or command line
  /// stays on the failure below it.
  AppFailure? get cause;
}

/// The diagnostic text of a failure and everything it came from.
///
/// Walks [AppFailure.cause] without knowing a single type, so a "details"
/// disclosure can render any failure; each link's text is its `toString()`.
extension FailureChain on AppFailure {
  /// This failure and its causes, outermost first.
  List<AppFailure> get chain => <AppFailure>[this, ...?cause?.chain];

  /// The whole chain as text, one link per line, for diagnostics only.
  ///
  /// Never the explanation shown to the user; that is the UI's, per failure.
  String get diagnostics => chain.map(_ownText).join('\n');

  /// [failure]'s text with its cause's cut out.
  ///
  /// A generated `toString` prints `cause` too, so one link's text already
  /// nests every link under it and the chain would repeat the bottom failure
  /// once per ancestor.
  static String _ownText(AppFailure failure) {
    final String text = failure.toString();
    // `cause: null` is cut too: it says nothing the line below does not.
    final String slot = 'cause: ${failure.cause}';
    final int at = text.indexOf(slot);
    if (at < 0) {
      return text;
    }
    // The separator goes with the field, so `(a: 1, cause: …)` reads `(a: 1)`.
    final int from = at >= 2 && text.startsWith(', ', at - 2) ? at - 2 : at;
    return text.replaceRange(from, at + slot.length, '');
  }
}

/// The failure of last resort: something threw where nothing was expected to.
///
/// Produced by the standardized `try/catch` every use case carries, after the
/// error went to observability. It belongs to no area, which is why it is here.
@freezed
abstract class UnexpectedFailure
    with _$UnexpectedFailure
    implements AppFailure {
  /// An unexpected failure described by [description].
  const factory UnexpectedFailure(
    /// What was caught, as text; never parsed, never matched.
    String description, {

    /// Nothing, in practice: what threw was not a failure to begin with.
    AppFailure? cause,
  }) = _UnexpectedFailure;
}
