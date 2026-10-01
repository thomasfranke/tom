/// Filing text away, and finding it again.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_infra/src/search_index/search_index_failure.dart';

/// A full-text index over documents named by a key.
///
/// **The index is a cache and never the truth** — whatever it holds can be
/// thrown away and rebuilt from the files
/// ([search](../../../../../../docs/technical/runtime/search.md)), which is
/// why nothing here promises to survive anything.
abstract interface class SearchIndex {
  /// Makes the index hold [documents] and nothing else.
  ///
  /// The whole set in one call, because a rebuild is this capability's only
  /// maintenance operation: the caller decides what the index should say and
  /// this makes it say it.
  Future<Result<void, SearchIndexFailure>> replaceAll(
    List<IndexedDocumentDto> documents,
  );

  /// Files [document] under its key, replacing whatever was there.
  Future<Result<void, SearchIndexFailure>> put(IndexedDocumentDto document);

  /// The documents matching [terms], best first and at most [limit] of them.
  ///
  /// [terms] is what a person typed, not a query language: an implementation
  /// takes the words out of it and everything else is punctuation. Every word
  /// has to appear, the last one may be a prefix, and typing nothing searched
  /// for nothing — an empty list, not a failure.
  Future<Result<List<SearchHitDto>, SearchIndexFailure>> find(
    String terms, {
    required int limit,
  });

  /// Lets go of whatever this holds open.
  void dispose();
}
