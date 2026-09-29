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
import 'package:tom_presentation/src/search/search_scope_enum.dart';
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
    ref
      ..listen<DocumentEntity?>(editorProvider.select(_savedOf), (
        DocumentEntity? previous,
        DocumentEntity? next,
      ) {
        if (next != null && next != previous) {
          unawaited(_refile(space, next));
        }
      })
      // The buffer moving re-finds the occurrences rather than moving them:
      // a position found before a keystroke has moved, and acting on a stale
      // one writes into the middle of something else
      // (`docs/product/search/in-the-document/doc.md`).
      ..listen<String>(editorProvider.select(_sourceOf), (
        String? previous,
        String next,
      ) {
        if (previous != next) {
          _refind(next);
        }
      });
    // Scheduled, not awaited: `build` answers synchronously.
    unawaited(Future<void>.microtask(() => _index(space)));
    return const SearchState.indexing();
  }

  /// Which of the two the box is asking about.
  Future<void> scopeTo(SearchScopeEnum scope) async {
    if (state case final SearchReady ready when ready.scope != scope) {
      state = ready.copyWith(scope: scope);
      await _answer(ready.terms);
    }
  }

  /// What a replacement would write in place of what was found.
  void replaceWith(String replacement) {
    if (state case final SearchReady ready) {
      state = ready.copyWith(replacement: replacement);
    }
  }

  /// Shows the second box, or puts it away.
  ///
  /// Opening it asks the question of the open file, because that is the only
  /// scope with a buffer to write into — the choice is implied by the act
  /// rather than refused after it (`docs/product/search/replacing/doc.md`).
  /// Putting it away keeps what was typed in it: somebody who closed it by
  /// accident has not lost the replacement they were composing.
  void showReplacing({required bool showing}) {
    if (state case final SearchReady ready) {
      state = ready.copyWith(isReplacing: showing);
      if (showing) {
        unawaited(scopeTo(SearchScopeEnum.thisFile));
      }
    }
  }

  /// Points at the occurrence at [index] as the current one.
  ///
  /// The current row is the one carrying the actions, so this is what a
  /// pointer moving down the list does
  /// (`docs/product/search/replacing/doc.md`).
  void focusOn(int index) {
    if (state case final SearchReady ready
        when index >= 0 &&
            index < ready.occurrences.length &&
            index != ready.current) {
      state = ready.copyWith(current: index);
    }
  }

  /// Takes [occurrence] off the list without touching the document.
  ///
  /// It comes back the next time the buffer is read, because it is still in
  /// the text — this is *skip*, not *delete*.
  void dismiss(OccurrenceValueObject occurrence) {
    if (state case final SearchReady ready) {
      state = _showing(ready, _without(ready, occurrence));
    }
  }

  /// [ready] showing [occurrences], with the current one still among them.
  ///
  /// Clamped rather than reset: skipping or replacing the current one
  /// shortens the list, and what takes its index is the next one to act on.
  static SearchReady _showing(
    SearchReady ready,
    List<OccurrenceValueObject> occurrences,
  ) => ready.copyWith(
    occurrences: occurrences,
    current: occurrences.isEmpty
        ? 0
        : ready.current.clamp(0, occurrences.length - 1),
  );

  /// [ready]'s occurrences, minus [gone].
  static List<OccurrenceValueObject> _without(
    SearchReady ready,
    OccurrenceValueObject gone,
  ) => <OccurrenceValueObject>[
    for (final OccurrenceValueObject each in ready.occurrences)
      if (each != gone) each,
  ];

  /// Replaces [occurrence] in the buffer, or drops it when the text moved.
  ///
  /// The verification is the service's: a stale occurrence is refused and
  /// leaves the list rather than corrupting the document
  /// (`docs/product/search/replacing/doc.md`).
  void replaceOne(OccurrenceValueObject occurrence) {
    if (state case final SearchReady ready) {
      final String? written = _finder.replace(
        _source,
        occurrence,
        ready.replacement,
      );
      if (written == null) {
        state = _showing(ready, _without(ready, occurrence));
        return;
      }
      ref.read(editorProvider.notifier).edit(written);
    }
  }

  /// Replaces every occurrence at once, found again as it goes.
  void replaceEvery() {
    if (state case final SearchReady ready when ready.terms.trim().isNotEmpty) {
      ref
          .read(editorProvider.notifier)
          .edit(_finder.replaceAll(_source, ready.terms, ready.replacement));
    }
  }

  /// What the open buffer holds, or empty when nothing is open.
  String get _source => _sourceOf(ref.read(editorProvider));

  /// The rule for finding words in one document.
  static const DocumentSearchService _finder = DocumentSearchService();

  /// The question in the box, asked of whichever scope is chosen.
  Future<void> _answer(String terms) async {
    if (state case final SearchReady ready
        when ready.scope == SearchScopeEnum.thisFile) {
      // The buffer is here, so this one needs nobody: no index, no await.
      // A new question starts at its first hit; a moved buffer does not.
      state = ready.copyWith(
        occurrences: _finder.find(_source, terms),
        current: 0,
      );
      return;
    }
    await _search(terms);
  }

  /// What the open buffer holds, or empty when nothing is open.
  static String _sourceOf(EditorState state) => switch (state) {
    EditorReady(source: final String source) => source,
    _ => '',
  };

  /// The occurrences of what is in the box, in [source].
  void _refind(String source) {
    if (state case final SearchReady ready
        when ready.scope == SearchScopeEnum.thisFile) {
      state = _showing(ready, _finder.find(source, ready.terms));
    }
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
        await _answer(terms);
      // A broken index still takes the question, so the column has somewhere
      // to say it could not answer.
      case final SearchFailed failed:
        state = failed.copyWith(terms: terms);
      case SearchIdle():
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
    // Kept rather than rebuilt: the scope and the replacement are the
    // reader's settings, not part of the answer.
    final SearchReady asking = state as SearchReady;
    if (terms.trim().isEmpty) {
      state = asking.copyWith(
        terms: terms,
        hits: const <SearchHitValueObject>[],
      );
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
        asking.copyWith(
          terms: terms,
          hits: List<SearchHitValueObject>.unmodifiable(hits),
        ),
      Failure<List<SearchHitValueObject>, AppFailure>(
        failure: final AppFailure failure,
      ) =>
        SearchState.failed(failure, terms: terms),
    };
  }

  /// The document the editor last read or wrote, or null when none is open.
  static DocumentEntity? _savedOf(EditorState state) => switch (state) {
    EditorReady(saved: final DocumentEntity document) => document,
    _ => null,
  };
}
