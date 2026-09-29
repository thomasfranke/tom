/// The explorer: the space's folders and files, or what a search found.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/file_tree/file_tree_design.dart';
import 'package:tom_desktop/screens/file_tree/widgets/file_tree_body_widget.dart';
import 'package:tom_desktop/screens/file_tree/widgets/file_tree_caption_widget.dart';
import 'package:tom_desktop/screens/search/search_boxes.dart';
import 'package:tom_desktop/screens/search/search_design.dart';
import 'package:tom_desktop/screens/search/search_occurrences_panel.dart';
import 'package:tom_desktop/screens/search/search_results_panel.dart';
import 'package:tom_desktop/screens/search/search_scope_control.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

/// The left column: the search box, and under it the tree or what it found.
///
/// **The results are here and not in the git column**, under the box that
/// produced them — one column for navigation and search, the other for git
/// (`docs/product/workspace/regions/doc.md`).
///
/// Shows everything the space holds and opens only markdown
/// (`docs/product/navigation/file-tree/what-is-shown/doc.md`); `.git/` is
/// absent because the walk never descends into it, not because anything here
/// filters.
class FileTreePanel extends ConsumerWidget {
  /// Creates the panel.
  const FileTreePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FileTreeState state = ref.watch(fileTreeProvider);
    // Two selects over the session rather than one deriving the marks:
    // `select` rebuilds on inequality, and a freshly built [FileTreeChanges]
    // is never equal to the last one, so deriving inside it never stops.
    final SpaceEntity? space = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.space,
      ),
    );
    final GitStatusValueObject? git = ref.watch(
      spaceSessionProvider.select((SpaceSessionState? session) => session?.git),
    );
    final FileTreeChanges changes = space == null
        ? const FileTreeChanges.none()
        : FileTreeChanges.of(space, git);
    // What is typed decides which body the column draws: the tree is what a
    // space holds, the results are what a question found.
    final bool searching = ref.watch(
      searchProvider.select(
        (SearchState state) => state.terms.trim().isNotEmpty,
      ),
    );
    final SearchScopeEnum scope = ref.watch(
      searchProvider.select(
        (SearchState state) => switch (state) {
          SearchReady(scope: final SearchScopeEnum it) => it,
          _ => SearchScopeEnum.wholeSpace,
        },
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Each gap is a subtraction of the design's own numbers, so it cannot
        // drift from the drawing the way a hand-typed result can.
        const SizedBox(height: FileTreeDesign.captionTop),
        FileTreeCaptionWidget(searching: searching),
        const SizedBox(
          height:
              FileTreeDesign.searchTop -
              FileTreeDesign.captionTop -
              FileTreeDesign.caption * 1.4,
        ),
        const SearchBoxes(),
        const SizedBox(height: SearchDesign.scopeGap),
        // Always visible, whichever body is under it: the scope is a setting,
        // not a thing that appears once there is a question
        // (`docs/product/search/README.md`).
        const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: FileTreeDesign.controlInset,
          ),
          child: SearchScopeControl(),
        ),
        const SizedBox(height: SearchDesign.scopeGap),
        // Three bodies, one column: the tree when nothing is asked, and one
        // answer per scope when something is.
        Expanded(
          child: switch ((searching, scope)) {
            (false, _) => FileTreeBodyWidget(state: state, changes: changes),
            (true, SearchScopeEnum.thisFile) => const SearchOccurrencesPanel(),
            (true, SearchScopeEnum.wholeSpace) => const SearchResultsPanel(),
          },
        ),
      ],
    );
  }
}
