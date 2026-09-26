/// The domain's search contract, fulfilled by the index capability.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/src/capabilities/search_index/indexed_document_dto.dart';
import 'package:tom_data/src/capabilities/search_index/search_hit_dto.dart';
import 'package:tom_data/src/documents/document_data_source.dart';
import 'package:tom_data/src/search/search_data_source.dart';
import 'package:tom_domain/tom_domain.dart';
// For the failure vocabulary only (Decision 25).
import 'package:tom_infra/tom_infra.dart';

/// [SearchRepository] over [SearchDataSource], filling it from the disk.
///
/// Two translations, like every repository here: a space-relative path is the
/// key the index files a document under, and a [SearchIndexFailure] becomes
/// the one thing the product can say about it.
final class SearchRepositoryImpl implements SearchRepository {
  /// Creates a repository over [search] and [documents], for [space].
  const SearchRepositoryImpl({
    required this.search,
    required this.documents,
    required this.space,
  });

  /// Where the text is filed and found again.
  final SearchDataSource search;

  /// Where a document's text is read.
  final DocumentDataSource documents;

  /// The space every path on this repository is relative to.
  final SpaceEntity space;

  @override
  Future<Result<void, SearchFailure>> index(
    List<SpaceRelativePathValueObject> paths,
  ) async {
    final List<IndexedDocumentDto> read = <IndexedDocumentDto>[];
    for (final SpaceRelativePathValueObject path in paths) {
      final Result<String, FilesystemFailure> text = await documents.read(
        space.absolutePathOf(path),
      );
      // A file that went away between the listing and the read is one result
      // fewer, never a failed index.
      if (text case Success<String, FilesystemFailure>(
        value: final String content,
      )) {
        read.add(IndexedDocumentDto(key: path.value, text: content));
      }
    }
    return search.replaceAll(read).mapFailure(_asSearchFailure);
  }

  @override
  Future<Result<void, SearchFailure>> refresh(DocumentEntity document) => search
      .put(IndexedDocumentDto(key: document.path.value, text: document.content))
      .mapFailure(_asSearchFailure);

  @override
  Future<Result<List<SearchHitValueObject>, SearchFailure>> find(
    String terms, {
    required int limit,
  }) => search
      .find(terms, limit: limit)
      .map(_asHits)
      .mapFailure(_asSearchFailure);

  /// [hits] as the domain names them, keeping the index's order.
  ///
  /// A key the space no longer spells as a path is dropped: the index is a
  /// cache, and a stale entry is not something to hand to the file tree.
  static List<SearchHitValueObject> _asHits(List<SearchHitDto> hits) =>
      List<SearchHitValueObject>.unmodifiable(<SearchHitValueObject>[
        for (final SearchHitDto hit in hits)
          if (SpaceRelativePathValueObject.tryParse(hit.key)
              case final SpaceRelativePathValueObject path)
            SearchHitValueObject(path: path, excerpt: hit.excerpt),
      ]);

  /// What the index reported, in the product's own words.
  ///
  /// Exhaustive with no default branch, so a new way for an index to refuse
  /// breaks this rather than a search.
  static SearchFailure _asSearchFailure(SearchIndexFailure failure) =>
      switch (failure) {
        SearchIndexFailed() => SearchIndexCorrupted(cause: failure),
      };
}
