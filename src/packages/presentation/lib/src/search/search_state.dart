/// What the search is showing, and what is in its box.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/search/search_scope_enum.dart';

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

    /// Which of the two the box is asking about.
    @Default(SearchScopeEnum.wholeSpace) SearchScopeEnum scope,

    /// What a replacement would put in place of [terms]; empty deletes.
    @Default('') String replacement,

    /// Whether the second box is showing.
    ///
    /// Revealed rather than always there, because replacing is the rarer
    /// half and a box nobody uses is a box in the way of the results
    /// (`docs/product/search/replacing/doc.md`).
    @Default(false) bool isReplacing,

    /// Where [terms] is in the open buffer, for [SearchScopeEnum.thisFile].
    ///
    /// Recomputed whenever the buffer changes rather than carried across an
    /// edit: a position found before a keystroke has moved
    /// (`docs/product/search/in-the-document/doc.md`).
    @Default(<OccurrenceValueObject>[]) List<OccurrenceValueObject> occurrences,

    /// Which occurrence is the current one, by position in the list above.
    ///
    /// One of them always is, and it is the first until somebody points at
    /// another: the row carries the actions, so a list with no current row
    /// is a list nothing can be done to.
    @Default(0) int current,
  }) = SearchReady;

  /// The space could not be indexed, or a search could not be run.
  ///
  /// It carries [terms] because the column draws the results only while
  /// there is a question in the box — a failure that forgot the question
  /// would have nowhere to be said
  /// (`docs/product/search/full-text-search/the-surface/doc.md`).
  const factory SearchState.failed(
    AppFailure failure, {
    @Default('') String terms,
  }) = SearchFailed;

  const SearchState._();

  /// What is in the box, whatever state this is.
  String get terms => switch (this) {
    SearchIndexing(terms: final String terms) => terms,
    SearchReady(terms: final String terms) => terms,
    SearchFailed(terms: final String terms) => terms,
    SearchIdle() => '',
  };
}
