/// Reporting the unexpected, behind a contract.
library;

/// Where unexpected errors go.
///
/// A port, not a policy: the default implementation discards everything, and no
/// data leaves the machine unless the user turns it on (Decision 11).
///
/// It lives in `tom_core` rather than in `tom_infra` — where every other
/// capability contract lives — for a structural reason: every use case takes
/// one, and `tom_application` cannot see `tom_infra`. What that costs is
/// nothing, because the contract names no technology; what it must not become
/// is a precedent for pushing *product* vocabulary down here.
///
/// Implementations stay in infrastructure, and only the composition root ever
/// names one.
abstract interface class Observability {
  /// Records [error] and its [stackTrace], tagged with the [layer] that caught
  /// it (`'application'`, `'data'`, `'presentation'`).
  ///
  /// Never throws: an observability backend that fails must not turn a handled
  /// failure into an unhandled one.
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  });
}
