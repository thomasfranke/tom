/// Reporting the unexpected, behind a contract.
library;

/// Where unexpected errors go.
///
/// A port, not a policy: the default discards everything and nothing leaves
/// the machine unless the user turns it on (Decision 11). It lives here, not
/// in `tom_infra`, because every use case takes one and `tom_application`
/// cannot see `tom_infra`; not a precedent for product vocabulary here.
abstract interface class Observability {
  /// Records [error] and its [stackTrace], tagged with the [layer] that caught
  /// it (`'application'`, `'data'`, `'presentation'`).
  ///
  /// Never throws: a failing backend must not turn a handled failure into an
  /// unhandled one.
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  });
}
