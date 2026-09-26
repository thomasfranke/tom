/// The explorer: the space's folders and files, as a tree.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/file_tree/file_tree_design.dart';
import 'package:tom_desktop/screens/file_tree/widgets/file_tree_body_widget.dart';
import 'package:tom_desktop/screens/file_tree/widgets/file_tree_caption_widget.dart';
import 'package:tom_desktop/screens/file_tree/widgets/file_tree_search_widget.dart';
import 'package:tom_presentation/tom_presentation.dart';

/// The file tree, and the search field above it.
///
/// Shows everything the space holds and opens only markdown
/// (`docs/product/navigation/file-tree/what-is-shown/doc.md`); `.git/` is absent because
/// the walk never descends into it, not because anything here filters.
/// Layout only — what a click means lives in [FileTreeNotifier].
class FileTreePanel extends ConsumerWidget {
  /// Creates the panel.
  const FileTreePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FileTreeState state = ref.watch(fileTreeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Each gap is a subtraction of the design's own numbers, so it cannot
        // drift from the drawing the way a hand-typed result can.
        const SizedBox(height: FileTreeDesign.captionTop),
        const FileTreeCaptionWidget(),
        const SizedBox(
          height:
              FileTreeDesign.searchTop -
              FileTreeDesign.captionTop -
              FileTreeDesign.caption * 1.4,
        ),
        const FileTreeSearchWidget(),
        const SizedBox(
          height:
              FileTreeDesign.rowsTop -
              FileTreeDesign.searchTop -
              FileTreeDesign.searchHeight,
        ),
        Expanded(child: FileTreeBodyWidget(state: state)),
      ],
    );
  }
}
