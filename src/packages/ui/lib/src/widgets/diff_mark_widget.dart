/// A letter on a tinted square, saying what happened to something.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_ui/src/theme/tom_metrics.dart';

/// The diff mark of
/// [components.md](../../../../../../docs/technical/design/components.md):
/// twenty square, a letter inside it.
///
/// **A letter as well as a colour** — roughly one in twelve men cannot
/// separate the red from the green, so what happened is never the tint
/// alone (`docs/technical/design/visual-language.md`).
///
/// It is handed a letter and two colours rather than anything meaning
/// *added* or *removed*: this package draws and names nothing, so the two
/// places that show a mark — the changes column and the rendered diff —
/// keep their own alphabets and share the drawing.
class DiffMarkWidget extends StatelessWidget {
  /// Creates the mark.
  const DiffMarkWidget({
    required this.letter,
    required this.ink,
    required this.fill,
    this.tooltip,
    super.key,
  });

  /// The one character inside the square.
  final String letter;

  /// The letter's colour.
  final Color ink;

  /// The square's colour.
  final Color fill;

  /// The whole word, for whoever has not learnt the letters.
  final String? tooltip;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('letter', letter))
      ..add(ColorProperty('ink', ink))
      ..add(ColorProperty('fill', fill))
      ..add(StringProperty('tooltip', tooltip));
  }

  @override
  Widget build(BuildContext context) {
    final Widget mark = SizedBox(
      width: TomMetrics.mark,
      height: TomMetrics.mark,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(TomMetrics.radiusTight),
        ),
        child: Center(
          child: Text(
            letter,
            style: TextStyle(
              fontSize: 11,
              height: 1,
              fontWeight: FontWeight.w600,
              color: ink,
            ),
          ),
        ),
      ),
    );
    return tooltip == null ? mark : Tooltip(message: tooltip!, child: mark);
  }
}
