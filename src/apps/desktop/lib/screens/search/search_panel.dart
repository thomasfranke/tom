/// The documents whose contents match what is in the search box.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/screens/search/search_design.dart';
import 'package:tom_desktop/screens/search/widgets/search_hit_widget.dart';
import 'package:tom_desktop/screens/search/widgets/search_note_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// What the space says, found by its contents rather than its file names
/// (`docs/product/search/full-text-search/the-surface/doc.md`).
///
/// The box is in the explorer and the results are here, one conversation
/// through [SearchNotifier]. The index is built while the space opens, so
/// the panel says it is reading rather than saying nothing was found.
class SearchPanel extends ConsumerWidget {
  /// Creates the panel.
  const SearchPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SearchState state = ref.watch(searchProvider);
    final String spaceName =
        ref.watch(
          spaceSessionProvider.select(
            (SpaceSessionState? session) => session?.space.name,
          ),
        ) ??
        '';
    final List<SearchHitValueObject> hits = switch (state) {
      SearchReady(hits: final List<SearchHitValueObject> found) => found,
      _ => const <SearchHitValueObject>[],
    };
    final TomColors colors = TomColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Each gap is a subtraction of the design's own numbers, so it cannot
        // drift from the board the way a hand-typed result can.
        const SizedBox(height: SearchDesign.captionTop),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: TomMetrics.pad),
          child: Text(
            'SEARCH',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: SearchDesign.caption,
              height: 1.4,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
              color: colors.textMuted,
            ),
          ),
        ),
        const SizedBox(
          height:
              SearchDesign.countTop -
              SearchDesign.captionTop -
              SearchDesign.caption * 1.4,
        ),
        // The line keeps its height when there is nothing to count, so the
        // list does not move under the pointer as the results arrive.
        SizedBox(
          height: SearchDesign.count * 1.4,
          child: hits.isEmpty
              ? null
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TomMetrics.pad,
                  ),
                  child: Text(
                    _counted(hits.length),
                    style: TextStyle(
                      fontSize: SearchDesign.count,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
        ),
        const SizedBox(
          height:
              SearchDesign.hitsTop -
              SearchDesign.countTop -
              SearchDesign.count * 1.4,
        ),
        Expanded(child: _body(state, hits, spaceName, colors.border)),
        const SizedBox(height: TomMetrics.pad),
      ],
    );
  }

  /// The list, or the sentence that stands in for it.
  static Widget _body(
    SearchState state,
    List<SearchHitValueObject> hits,
    String spaceName,
    Color border,
  ) => switch (state) {
    SearchIdle() => const SearchNoteWidget('No space is open.'),
    SearchIndexing() => const SearchNoteWidget('Reading the space…'),
    SearchFailed(failure: final AppFailure failure) => SearchNoteWidget(
      _explain(failure),
    ),
    SearchReady(terms: final String terms) when terms.trim().isEmpty =>
      const SearchNoteWidget('Type above the tree to search this space.'),
    SearchReady() when hits.isEmpty => const SearchNoteWidget(
      'No document says that.',
    ),
    SearchReady(terms: final String terms) => ListView.separated(
      itemCount: hits.length,
      separatorBuilder: (BuildContext context, int index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: TomMetrics.padTight),
        child: Divider(height: 1, color: border),
      ),
      itemBuilder: (BuildContext context, int index) =>
          SearchHitWidget(hit: hits[index], terms: terms, spaceName: spaceName),
    ),
  };

  /// How many documents matched, counted in words rather than in a number
  /// beside a plural that is wrong once.
  static String _counted(int hits) =>
      hits == 1 ? '1 document' : '$hits documents';

  /// What to say about a space that could not be searched.
  ///
  /// A catch-all, because this switches over [AppFailure] itself and the
  /// panel must say something whatever went wrong.
  static String _explain(AppFailure failure) => switch (failure) {
    SearchIndexCorrupted() =>
      'The index could not be built — reopen the space to try again.',
    _ => 'This space could not be searched.',
  };
}
