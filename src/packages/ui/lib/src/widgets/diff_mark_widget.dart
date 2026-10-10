/// A letter in an outlined square, saying what happened to something.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_ui/src/theme/tom_metrics.dart';

/// The diff mark of
/// [components](../../../../../../docs/design/components/README.md):
/// a letter in a square drawn in the letter's own ink, because colour is
/// never the only signal.
///
/// An outline rather than a tint: on a 1b island a filled square reads as a
/// button, and the mark is a label. A letter and a colour rather than a
/// meaning, so the changes column and the rendered diff keep their own
/// alphabets and share the drawing.
class DiffMarkWidget extends StatelessWidget {
  /// Creates the mark.
  const DiffMarkWidget({
    required this.letter,
    required this.ink,
    this.tooltip,
    super.key,
  }) : isBare = false;

  /// The letter alone, in the same square.
  ///
  /// What a tree row carries: the row already has a highlight of its own,
  /// and a second outline inside it reads as a box nobody drew.
  const DiffMarkWidget.bare({
    required this.letter,
    required this.ink,
    this.tooltip,
    super.key,
  }) : isBare = true;

  /// The one character inside the square.
  final String letter;

  /// The letter's colour, and the outline's.
  final Color ink;

  /// Whether the square is left undrawn.
  final bool isBare;

  /// The whole word, for whoever has not learnt the letters.
  final String? tooltip;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('letter', letter))
      ..add(ColorProperty('ink', ink))
      ..add(DiagnosticsProperty<bool>('isBare', isBare))
      ..add(StringProperty('tooltip', tooltip));
  }

  @override
  Widget build(BuildContext context) {
    final Widget mark = SizedBox(
      width: TomMetrics.mark,
      height: TomMetrics.mark,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: isBare ? null : Border.all(color: ink),
          borderRadius: BorderRadius.circular(TomMetrics.radiusTight),
        ),
        child: Center(
          child: Text(
            letter,
            style: TextStyle(
              fontSize: isBare ? 11 : 9.5,
              height: 1,
              fontWeight: isBare ? FontWeight.w600 : FontWeight.w700,
              color: ink,
            ),
          ),
        ),
      ),
    );
    return tooltip == null ? mark : Tooltip(message: tooltip!, child: mark);
  }
}
