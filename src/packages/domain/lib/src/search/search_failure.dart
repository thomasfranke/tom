/// What searching a space can fail with.
library;

import 'package:tom_core/tom_core.dart';

/// A search that did not complete.
///
/// The index is a cache over the `.md` files, never the truth, so every variant
/// here has a recovery that ends in rebuilding it from disk.
sealed class SearchFailure implements AppFailure {
  /// Const constructor, for the variants below.
  const SearchFailure();
}

/// The index cannot be read and has to be rebuilt.
///
/// Not data loss: nothing lives in the index that is not already in the files.
final class IndexCorrupted extends SearchFailure {
  /// Creates the failure.
  const IndexCorrupted();
}
