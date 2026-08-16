/// What searching a space can fail with.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';

part 'search_failure.freezed.dart';

/// A search that did not complete.
///
/// The index is a cache over the `.md` files, never the truth, so every
/// variant here has a recovery that ends in rebuilding it from disk.
@freezed
sealed class SearchFailure with _$SearchFailure implements AppFailure {
  /// The index cannot be read and has to be rebuilt.
  ///
  /// Not data loss: nothing lives in the index that is not already in the
  /// files.
  const factory SearchFailure.indexCorrupted() = IndexCorrupted;
}
