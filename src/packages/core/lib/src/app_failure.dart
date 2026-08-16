/// The root of the failure vocabulary — the marker, and nothing else.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_failure.freezed.dart';

/// What every failure in the product implements.
///
/// Deliberately **not** `sealed`. A sealed type requires every direct subtype
/// to live in the same library, which would pull the product's whole failure
/// vocabulary — merge conflicts, missing documents, a corrupt index — down into
/// the package that sits at the bottom of the graph and depends on no
/// `tom_*` package. `tom_core` holds mechanism, never vocabulary.
///
/// Exhaustiveness is kept where it pays instead: each area's hierarchy *is*
/// sealed inside its own library — `GitFailure` and `DocumentFailure` in
/// `tom_domain`, the technical ones in `tom_infra` — so adding a failure mode
/// still breaks every `switch` that must handle it, and breaks it only in the
/// packages that deal with that area.
///
/// The consequence to know: a `switch` over an [AppFailure] itself needs a
/// catch-all branch. That is how the UI already consumes it — an exhaustive
/// switch over the failures a panel actually handles, generic case last.
///
/// Failures are **value objects**: two of the same kind carrying the same data
/// are the same failure, so tests can assert on them and state can be compared
/// without spurious rebuilds. Every area hierarchy is Freezed, which is what
/// gets that equality without writing `==`/`hashCode` by hand per variant.
abstract interface class AppFailure {}

/// The failure of last resort: something threw where nothing was expected to.
///
/// Produced by the standardized `try/catch` every use case carries, after the
/// error has been handed to observability. It is not an area failure — there is
/// no vocabulary to give it, which is exactly why it lives here.
@freezed
abstract class UnexpectedFailure
    with _$UnexpectedFailure
    implements AppFailure {
  /// Creates an unexpected failure described by [description].
  const factory UnexpectedFailure(
    /// What was caught, as text. For diagnostics — never parsed, never matched.
    String description,
  ) = _UnexpectedFailure;
}
