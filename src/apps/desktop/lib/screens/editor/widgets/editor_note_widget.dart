/// A line of prose where the source would be.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_ui/tom_ui.dart';

/// One muted line, standing in for the source.
///
/// Every state the editor can be in that is not a buffer — nothing chosen,
/// still reading, failed — says so with this rather than leaving the pane
/// blank.
class EditorNoteWidget extends StatelessWidget {
  /// Creates a note saying [text].
  const EditorNoteWidget(this.text, {super.key});

  /// What it says.
  final String text;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('text', text));
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: TomMetrics.pad),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 12,
        height: 1.5,
        color: TomColors.of(context).textMuted,
      ),
    ),
  );
}
