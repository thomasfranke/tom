/// A line of prose where the list of commits would be.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_ui/tom_ui.dart';

/// One muted line, standing in for the history.
///
/// Every state the panel can be in that is not a list — no document open,
/// still asking git, a file git has never been told about, a repository that
/// would not answer — says so with this rather than leaving the column
/// blank.
class HistoryNoteWidget extends StatelessWidget {
  /// Creates a note saying [text].
  const HistoryNoteWidget(this.text, {super.key});

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
