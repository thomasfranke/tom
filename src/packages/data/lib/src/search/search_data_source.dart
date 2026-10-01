/// Where the searchable text is filed, and where the hits come from.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/src/capabilities/search_index/indexed_document_dto.dart';
import 'package:tom_data/src/capabilities/search_index/search_hit_dto.dart';
import 'package:tom_infra/tom_infra.dart';

/// The index, reached the way every capability is reached
/// ([Decision
/// 25](../../../../../../docs/technical/decisions/025-a-repository-reads-through-a-data-source.md)).
///
/// Keys, not paths: what a key means is the repository's, which is what lets
/// the index below stay a store of text under names.
final class SearchDataSource {
  /// Creates a source over [index].
  const SearchDataSource({required this.index});

  /// Where the text is filed and found again.
  final SearchIndex index;

  /// Makes the index hold [documents] and nothing else.
  Future<Result<void, SearchIndexFailure>> replaceAll(
    List<IndexedDocumentDto> documents,
  ) => index.replaceAll(documents);

  /// Files [document] under its key, replacing whatever was there.
  Future<Result<void, SearchIndexFailure>> put(IndexedDocumentDto document) =>
      index.put(document);

  /// The keys matching [terms], best first and at most [limit] of them.
  Future<Result<List<SearchHitDto>, SearchIndexFailure>> find(
    String terms, {
    required int limit,
  }) => index.find(terms, limit: limit);
}
