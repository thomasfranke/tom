/// The box a small field is drawn in.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_ui/src/theme/tom_colors.dart';

/// The frame around a column-sized field: fill, hairline, corner, height
/// ([controls](../../../../../../docs/design/components/controls.md)).
///
/// Drawn here rather than by `InputDecoration`, because a decoration sizes
/// its container from what is inside it: an empty field painted seven points
/// shorter than a full one, and at this corner that reads as a pill. The
/// design fixes the box, so the box is drawn.
class TomFieldBoxWidget extends StatelessWidget {
  /// Frames [child] in a box of [height], accented while [isFocused].
  const TomFieldBoxWidget({
    required this.child,
    required this.height,
    required this.fill,
    required this.radius,
    this.isFocused = false,
    super.key,
  });

  /// What is inside: the field, and whatever sits beside it.
  final Widget child;

  /// The box's own height, whatever it holds.
  final double height;

  /// The surface it is cut into.
  final Color fill;

  /// Whether the field inside has the keyboard.
  final bool isFocused;

  /// The corner.
  final double radius;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('height', height))
      ..add(ColorProperty('fill', fill))
      ..add(DiagnosticsProperty<bool>('isFocused', isFocused))
      ..add(DoubleProperty('radius', radius));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(radius),
          // A hairline either way: this is the column's small field, not the
          // 56-point `Text field`, so focus does not take that one's two
          // points — which at this height reads as an error.
          border: Border.all(color: isFocused ? colors.accent : colors.border),
        ),
        child: child,
      ),
    );
  }
}
