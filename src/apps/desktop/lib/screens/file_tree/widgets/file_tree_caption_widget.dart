/// What the explorer is called, in the design's own words.
library;

import 'package:flutter/material.dart';
import 'package:tom_desktop/screens/file_tree/file_tree_design.dart';
import 'package:tom_desktop/theme/tom_colors.dart';
import 'package:tom_desktop/theme/tom_metrics.dart';

/// The panel's caption.
///
/// Drawn by the panel itself, because the shell draws no panel chrome.
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
