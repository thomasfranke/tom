/// Result, AppFailure and the mechanisms every layer shares.
///
/// Depends on nothing, and names no product concept: git, documents and search
/// have vocabulary, and vocabulary belongs to `tom_domain`. What lives here is
/// machinery every layer needs and no layer owns.
///
/// Nothing outside `lib/src/` is importable from another package, so this file
/// is the whole public surface.
library;

export 'src/app_failure.dart';
export 'src/observability.dart';
export 'src/result.dart';
