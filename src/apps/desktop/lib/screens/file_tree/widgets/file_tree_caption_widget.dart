/// What the explorer is called, in the design's own words.
library;

import 'package:flutter/material.dart';
import 'package:tom_desktop/screens/file_tree/file_tree_design.dart';
import 'package:tom_ui/tom_ui.dart';

/// The panel's caption, drawn by the panel because the shell draws no chrome.
class FileTreeCaptionWidget extends StatelessWidget {
  /// Creates the caption.
  const FileTreeCaptionWidget({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: TomMetrics.pad),
    child: Text(
      'EXPLORER',
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
