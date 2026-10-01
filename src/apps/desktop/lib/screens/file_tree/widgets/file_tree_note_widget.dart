/// A line of prose where the tree would be.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_desktop/screens/file_tree/file_tree_design.dart';
import 'package:tom_ui/tom_ui.dart';

/// One muted line standing in for the tree, so no state leaves the panel
/// blank.
class FileTreeNoteWidget extends StatelessWidget {
  /// Creates a note saying [text].
  const FileTreeNoteWidget(this.text, {super.key});

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
        fontSize: FileTreeDesign.placeholder,
        height: 1.5,
        color: TomColors.of(context).textMuted,
      ),
    ),
  );
}
