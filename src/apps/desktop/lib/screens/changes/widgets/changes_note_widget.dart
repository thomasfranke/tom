/// A line of prose where the list would be.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_desktop/screens/changes/changes_design.dart';
import 'package:tom_ui/tom_ui.dart';

/// One muted line standing in for the list, so no state leaves the column
/// blank.
class ChangesNoteWidget extends StatelessWidget {
  /// Creates a note saying [text].
  const ChangesNoteWidget(
    this.text, {
    this.isRefusal = false,
    this.isWaiting = false,
    super.key,
  });

  /// What it says.
  final String text;

  /// Whether it says a read waits for a yes, which the board sets lower and
  /// at the column's own inset (`ChangesDesign.waitingTop`).
  final bool isWaiting;

  /// Whether it is the marker refusal, which the board draws in `removed`
  /// (`when-a-pull-conflicts/doc.md`); every other note stays muted.
  final bool isRefusal;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('text', text))
      ..add(FlagProperty('isWaiting', value: isWaiting, ifTrue: 'waiting'))
      ..add(FlagProperty('isRefusal', value: isRefusal, ifTrue: 'refusal'));
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: isWaiting
        ? const EdgeInsets.fromLTRB(
            ChangesDesign.inset,
            ChangesDesign.waitingTop,
            ChangesDesign.inset,
            0,
          )
        : const EdgeInsets.symmetric(horizontal: TomMetrics.pad),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 12,
        height: 1.5,
        color: isRefusal
            ? TomColors.of(context).removed
            : TomColors.of(context).textMuted,
      ),
    ),
  );
}
