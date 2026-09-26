/// What indexing or searching can fail with.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';

part 'search_index_failure.freezed.dart';

/// An index operation that did not complete.
///
/// One variant, and it is enough: every way an index can refuse ends in the
/// same remedy, which is to throw it away and build it again from the files.
@freezed
sealed class SearchIndexFailure
    with _$SearchIndexFailure
    implements AppFailure {
  /// The index could not be read or written.
  const factory SearchIndexFailure.failed(
    /// What it reported, verbatim. For diagnostics — never parsed.
    String description, {
    AppFailure? cause,
  }) = SearchIndexFailed;
}
