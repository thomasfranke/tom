/// How many documents matched, and which.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/search/search_design.dart';
import 'package:tom_desktop/screens/search/widgets/search_hit_widget.dart';
import 'package:tom_desktop/screens/search/widgets/search_note_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The count and the hits, drawn where the tree would be.
///
/// **The results belong to the left column**, under the box that produced
/// them (`docs/product/search/full-text-search/the-surface/doc.md`); the
/// caption above is the column's, which is why this draws none.
class SearchResultsPanel extends ConsumerWidget {
  /// Creates the results.
  const SearchResultsPanel({super.key});

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
        // The line keeps its height when there is nothing to count, so the
        // list does not move under the pointer as the results arrive.
        SizedBox(
          height: SearchDesign.countRow,
          child: hits.isEmpty
              ? null
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SearchDesign.controlInset,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      context.l10n.searchDocumentCount(hits.length),
                      style: TextStyle(
                        fontSize: SearchDesign.count,
                        height: 1.2,
                        color: colors.textMuted,
                      ),
                    ),
                  ),
                ),
        ),
        const SizedBox(height: SearchDesign.countGap),
        Expanded(
          child: _body(context.l10n, state, hits, spaceName, colors.border),
        ),
      ],
    );
  }

  /// The list, or the sentence that stands in for it.
  static Widget _body(
    AppLocalizations l10n,
    SearchState state,
    List<SearchHitValueObject> hits,
    String spaceName,
    Color border,
  ) => switch (state) {
    SearchIdle() => SearchNoteWidget(l10n.commonNoSpaceOpen),
    SearchIndexing() => SearchNoteWidget(l10n.searchReadingTheSpace),
    SearchFailed(failure: final AppFailure failure) => SearchNoteWidget(
      _explain(l10n, failure),
    ),
    SearchReady() when hits.isEmpty => SearchNoteWidget(
      l10n.searchNoDocumentSaysThat,
    ),
    SearchReady(terms: final String terms) => ListView.separated(
      itemCount: hits.length,
      separatorBuilder: (BuildContext context, int index) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SearchDesign.controlInset,
        ),
        child: Divider(height: SearchDesign.divider, color: border),
      ),
      itemBuilder: (BuildContext context, int index) =>
          SearchHitWidget(hit: hits[index], terms: terms, spaceName: spaceName),
    ),
  };

  /// What to say about a space that could not be searched.
  ///
  /// A catch-all, because this switches over [AppFailure] itself and the
  /// column must say something whatever went wrong.
  static String _explain(AppLocalizations l10n, AppFailure failure) =>
      switch (failure) {
        SearchIndexCorrupted() => l10n.searchIndexCorrupted,
        _ => l10n.searchFailed,
      };
}
