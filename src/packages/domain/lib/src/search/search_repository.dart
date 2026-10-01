/// What the application may ask of a space's searchable text.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/src/documents/document_entity.dart';
import 'package:tom_domain/src/paths/space_relative_path_value_object.dart';
import 'package:tom_domain/src/search/search_failure.dart';
import 'package:tom_domain/src/search/search_hit_value_object.dart';

/// The searchable text of one space.
///
/// One instance per space, every path relative to the space root. What it
/// holds is a cache over the `.md` files and nothing else
/// (`docs/product/search/full-text-search/what-is-searched/doc.md`), so it can be emptied at
/// any moment and [index] will say the same thing again.
abstract interface class SearchRepository {
  /// Makes the index say what the documents at [paths] say, and forget every
  /// other one.
  ///
  /// A file that cannot be read is left out rather than failing the call: one
  /// document missing from the results is a smaller lie than no search at all,
  /// and the next rebuild picks it up.
  Future<Result<void, SearchFailure>> index(
    List<SpaceRelativePathValueObject> paths,
  );

  /// Files [document]'s text under its path, replacing what was there.
  ///
  /// What keeps a search honest between rebuilds: the document that was just
  /// saved is the one most likely to be searched for next.
  Future<Result<void, SearchFailure>> refresh(DocumentEntity document);

  /// The documents matching [terms], best first and at most [limit] of them.
  ///
  /// [terms] is what a person typed: words, in any order, the last of them
  /// possibly half-typed. Typing nothing found nothing — an empty list, not a
  /// failure.
  Future<Result<List<SearchHitValueObject>, SearchFailure>> find(
    String terms, {
    required int limit,
  });
}
