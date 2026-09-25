/// What the source panel is called, in the design's own words.
library;

import 'package:flutter/material.dart';
import 'package:tom_desktop/screens/editor/editor_design.dart';
import 'package:tom_ui/tom_ui.dart';

/// The panel's caption, drawn by the panel because the shell draws no chrome.
class EditorCaptionWidget extends StatelessWidget {
  /// Creates the caption.
  const EditorCaptionWidget({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: TomMetrics.pad),
    child: Text(
      'SOURCE',
      style: TextStyle(
        fontSize: EditorDesign.caption,
        height: 1.4,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w600,
        color: TomColors.of(context).textMuted,
      ),
    ),
  );
}
