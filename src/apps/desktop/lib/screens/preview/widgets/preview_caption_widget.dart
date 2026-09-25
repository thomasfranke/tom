/// What the preview panel is called, in the design's own words.
library;

import 'package:flutter/material.dart';
import 'package:tom_desktop/screens/preview/preview_design.dart';
import 'package:tom_ui/tom_ui.dart';

/// The panel's caption, drawn by the panel because the shell draws no chrome.
class PreviewCaptionWidget extends StatelessWidget {
  /// Creates the caption.
  const PreviewCaptionWidget({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: TomMetrics.pad),
    child: Text(
      'PREVIEW',
      style: TextStyle(
        fontSize: PreviewDesign.caption,
        height: 1.4,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w600,
        color: TomColors.of(context).textMuted,
      ),
    ),
  );
}
