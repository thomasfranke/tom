/// The root of the failure vocabulary — the marker, the chain, and nothing
/// else.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_failure.freezed.dart';

/// What every failure in the product implements.
///
/// Deliberately **not** `sealed`. A sealed type requires every direct subtype
/// to live in the same library, which would pull the product's whole failure
/// vocabulary — merge conflicts, missing documents, a corrupt index — down
/// into the package that sits at the bottom of the graph. `tom_core` holds
/// mechanism, never vocabulary.
///
/// Exhaustiveness is kept where it pays instead: each area's hierarchy *is*
/// sealed inside its own library, and `Result<T, F>` carries which one an
/// operation answers with, so a `switch` over a failure is exhaustive wherever
/// the vocabulary is known.
///
/// Failures are **value objects**: two of the same kind carrying the same data
/// are the same failure, so tests can assert on them and state can be compared
/// without spurious rebuilds. Every area hierarchy is Freezed, which is what
/// gets that equality without writing `==`/`hashCode` per variant.
abstract interface class AppFailure {
  /// What this failure was translated from, if it was translated from
  /// anything.
  ///
  /// **The one path technical detail takes upwards.** A domain failure is what
  /// the product says to the user and carries nothing a machine wrote — no
  /// `stderr`, no `errno`, no command line. The layer below keeps all of it,
  /// and hangs here, so a bug report reads `GitPushRejected ←
  /// GitClientCommandFailed ← DartIoProcessError` while the screen still says
  /// one sentence.
  ///
  /// Null at the bottom of a chain: a failure the machine reported first hand
  /// was translated from nothing.
  AppFailure? get cause;
}

/// The diagnostic text of a failure and everything it came from.
///
/// Walks [AppFailure.cause] without knowing a single type, which is what lets
/// the UI's "details" disclosure render any failure at all. The text of each
/// link is its `toString()` — Freezed generates one naming every field, and a
/// second hand-written `details` member would be that string typed twice.
extension FailureChain on AppFailure {
  /// This failure and its causes, outermost first.
  List<AppFailure> get chain => <AppFailure>[this, ...?cause?.chain];

  /// The whole chain as text, one link per line, for diagnostics only.
  ///
  /// Never shown as the explanation of what happened — that is the UI's job,
  /// per failure. This is what goes behind "details" and into a bug report.
  String get diagnostics => chain.map(_ownText).join('\n');

  /// [failure]'s text with its cause's cut out.
  ///
  /// A generated `toString` prints every field, `cause` included, so the
  /// text of one link already nests every link under it — and a chain
  /// joined as-is repeats the bottom failure once per ancestor. What a link
  /// contributes is its own fields; the next line is where its cause goes.
  static String _ownText(AppFailure failure) {
    final String text = failure.toString();
    // `cause: null` at the bottom of a chain is cut for the same reason: it
    // says nothing the line below it does not.
    final String slot = 'cause: ${failure.cause}';
    final int at = text.indexOf(slot);
    if (at < 0) {
      return text;
    }
    // The separator before the field goes with it, so `(a: 1, cause: …)`
    // reads `(a: 1)` and `(cause: …)` reads `()`.
    final int from = at >= 2 && text.startsWith(', ', at - 2) ? at - 2 : at;
    return text.replaceRange(from, at + slot.length, '');
  }
}

/// The failure of last resort: something threw where nothing was expected to.
///
/// Produced by the standardized `try/catch` every use case carries, after the
/// error has been handed to observability. It belongs to no area — there is no
/// vocabulary to give it, which is exactly why it lives here.
@freezed
abstract class UnexpectedFailure
    with _$UnexpectedFailure
    implements AppFailure {
  /// Creates an unexpected failure described by [description].
  const factory UnexpectedFailure(
    /// What was caught, as text. For diagnostics — never parsed, never
    /// matched.
    String description, {

    /// Nothing, in practice: what threw was not a failure to begin with.
    AppFailure? cause,
  }) = _UnexpectedFailure;
}
