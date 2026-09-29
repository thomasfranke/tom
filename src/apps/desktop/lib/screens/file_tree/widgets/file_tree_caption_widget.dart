/// What the left column is called, in the design's own words.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_desktop/screens/file_tree/file_tree_design.dart';
import 'package:tom_ui/tom_ui.dart';

/// The column's caption, drawn by the panel because the shell draws no chrome.
///
/// It says what is under it: the space while the tree is showing, the search
/// while its results are
/// (`docs/product/search/full-text-search/the-surface/doc.md`).
class FileTreeCaptionWidget extends StatelessWidget {
  /// Creates the caption.
  const FileTreeCaptionWidget({this.searching = false, super.key});

  /// Whether the column is showing what a search found.
  final bool searching;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('searching', searching));
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: TomMetrics.pad),
    child: Text(
      searching ? 'SEARCH' : 'EXPLORER',
      style: TextStyle(
        fontSize: FileTreeDesign.caption,
        height: 1.4,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w600,
        color: TomColors.of(context).textMuted,
      ),
    ),
  );
}
