/// What the search is showing, and what is in its box.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

part 'search_state.freezed.dart';

/// The states a search can be in, and there are only these.
///
/// What was typed is carried by two of them, because the index is built when
/// a space opens and somebody can be typing while it is: the box is answered
/// immediately and the words are searched for as soon as there is an index.
@freezed
sealed class SearchState with _$SearchState {
  /// No space is open, so there is nothing to search.
  const factory SearchState.idle() = SearchIdle;

  /// The space's documents are being read into the index.
  const factory SearchState.indexing({
    /// What has been typed meanwhile; searched for once the index is built.
    @Default('') String terms,
  }) = SearchIndexing;

  /// The index is built, and this is what the box says and what it found.
  const factory SearchState.ready({
    /// What is in the box; empty means nothing has been asked for.
    @Default('') String terms,

    /// The documents that matched, best first.
    @Default(<SearchHitValueObject>[]) List<SearchHitValueObject> hits,
  }) = SearchReady;

  /// The space could not be indexed, or a search could not be run.
  const factory SearchState.failed(AppFailure failure) = SearchFailed;

  const SearchState._();

  /// What is in the box, whatever state this is.
  String get terms => switch (this) {
    SearchIndexing(terms: final String terms) => terms,
    SearchReady(terms: final String terms) => terms,
    _ => '',
  };
}
