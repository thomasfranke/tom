/// Drives the search: the index behind it, the box, and what it found.
library;

import 'dart:async';

// `select` lives in the runtime package, not in `riverpod_annotation`.
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/editor/editor_notifier.dart';
import 'package:tom_presentation/src/editor/editor_state.dart';
import 'package:tom_presentation/src/search/search_providers.dart';
import 'package:tom_presentation/src/search/search_state.dart';
import 'package:tom_presentation/src/spaces/space_session.dart';
import 'package:tom_presentation/src/spaces/space_session_notifier.dart';

part 'search_notifier.g.dart';

/// Indexes the space when it opens, answers the box, and opens what is
/// clicked (`docs/product/search/full-text-search/the-surface/doc.md`).
///
/// One notifier for two surfaces — the field above the file tree and the
/// results in the aside — because they are one conversation, and the index
/// under it is a cache that nothing else in the app reads.
@riverpod
class SearchNotifier extends _$SearchNotifier {
  /// How many hits the panel asks for: enough to scroll, few enough to draw.
  static const int limit = 50;

  /// Reads a space's documents into the index.
  IndexSpaceUseCase get indexSpace => ref.read(indexSpaceProvider);

  /// Files one document again.
  IndexDocumentUseCase get indexDocument => ref.read(indexDocumentProvider);

  /// Asks what matches.
  SearchSpaceUseCase get searchSpace => ref.read(searchSpaceProvider);

  @override
  SearchState build() {
    final SpaceEntity? space = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.space,
      ),
    );
    if (space == null) {
      return const SearchState.idle();
    }
    // Listened to, not watched: a save re-files one document, and starting
    // the panel over would throw away what is in the box.
    ref.listen<DocumentEntity?>(editorProvider.select(_savedOf), (
      DocumentEntity? previous,
      DocumentEntity? next,
    ) {
      if (next != null && next != previous) {
        unawaited(_refile(space, next));
      }
    });
    // Scheduled, not awaited: `build` answers synchronously.
    unawaited(Future<void>.microtask(() => _index(space)));
    return const SearchState.indexing();
  }

  /// Puts [terms] in the box and shows what they find.
  ///
  /// Typed into while the index is still building is not a mistake: the
  /// words are kept and searched for the moment there is something to search.
  Future<void> type(String terms) async {
    switch (state) {
      case SearchIndexing():
        state = SearchState.indexing(terms: terms);
      case final SearchReady ready:
        // The previous hits stay on screen until the new ones arrive, so the
        // list does not blink once per keystroke.
        state = ready.copyWith(terms: terms);
        await _search(terms);
      case SearchIdle() || SearchFailed():
        return;
    }
  }

  /// Empties the box, and the list with it.
  Future<void> clear() => type('');

  /// Opens the document [hit] found, the way the file tree opens one.
  void open(SearchHitValueObject hit) =>
      ref.read(spaceSessionProvider.notifier).show(hit.path);

  /// Reads every document of [space] into a fresh index.
  Future<void> _index(SpaceEntity space) async {
    final Result<void, AppFailure> indexed = await indexSpace.index(space);
    // The panel can be gone by the time the disk answers.
    if (!ref.mounted) {
      return;
    }
    final String typed = state.terms;
    switch (indexed) {
      case Success<void, AppFailure>():
        state = SearchState.ready(terms: typed);
        await _search(typed);
      case Failure<void, AppFailure>(failure: final AppFailure failure):
        state = SearchState.failed(failure);
    }
  }

  /// Files [document] again and asks the question in the box once more.
  Future<void> _refile(SpaceEntity space, DocumentEntity document) async {
    await indexDocument.index(space, document);
    if (!ref.mounted) {
      return;
    }
    await _search(state.terms);
  }

  /// Replaces the hits with what [terms] matches, if they still are the
  /// question being asked.
  Future<void> _search(String terms) async {
    if (state is! SearchReady) {
      return;
    }
    final SpaceEntity? space = ref.read(spaceSessionProvider)?.space;
    if (space == null) {
      return;
    }
    if (terms.trim().isEmpty) {
      state = SearchState.ready(terms: terms);
      return;
    }
    final Result<List<SearchHitValueObject>, AppFailure> found =
        await searchSpace.find(space, terms, limit: limit);
    // Another keystroke has already asked a better question.
    if (!ref.mounted || state.terms != terms) {
      return;
    }
    state = switch (found) {
      Success<List<SearchHitValueObject>, AppFailure>(
        value: final List<SearchHitValueObject> hits,
      ) =>
        SearchState.ready(
          terms: terms,
          hits: List<SearchHitValueObject>.unmodifiable(hits),
        ),
      Failure<List<SearchHitValueObject>, AppFailure>(
        failure: final AppFailure failure,
      ) =>
        SearchState.failed(failure),
    };
  }

  /// The document the editor last read or wrote, or null when none is open.
  static DocumentEntity? _savedOf(EditorState state) => switch (state) {
    EditorReady(saved: final DocumentEntity document) => document,
    _ => null,
  };
}
