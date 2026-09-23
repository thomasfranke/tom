/// The explorer: the space's folders and files, as a tree.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/file_tree/file_tree_design.dart';
import 'package:tom_desktop/screens/file_tree/widgets/file_tree_body_widget.dart';
import 'package:tom_desktop/screens/file_tree/widgets/file_tree_caption_widget.dart';
import 'package:tom_desktop/screens/file_tree/widgets/file_tree_search_widget.dart';
import 'package:tom_presentation/tom_presentation.dart';

/// The file tree, and the search field that will sit above it in M2.
///
/// Registered by `CoreModuleImpl` through the same `PanelDescriptor` a
/// stranger's module would use, and it draws its own caption because the
/// shell draws no panel chrome.
///
/// **It shows everything the space holds** and opens only markdown
/// (`docs/product/navigation/file-tree/doc.md`). Hiding `.git/` is not this
/// widget's doing — the walk never descends into it, so there is nothing
/// here to filter.
///
/// A humble widget: what a click means and which document is open live in
/// [FileTreeNotifier] and the session, so everything here is layout.
class FileTreePanel extends ConsumerWidget {
  /// Creates the panel.
  const FileTreePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FileTreeState state = ref.watch(fileTreeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Each gap is written as the subtraction of two of the design's own
        // numbers: arithmetic on screen cannot drift from the drawing
        // quietly, and a result typed by hand can.
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
