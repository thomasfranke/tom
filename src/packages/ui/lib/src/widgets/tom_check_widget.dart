/// The box that says whether something is taken.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_ui/src/theme/tom_colors.dart';
import 'package:tom_ui/src/theme/tom_metrics.dart';

/// The `Checkbox` component as the boards draw it
/// ([controls](../../../../../../docs/design/components/controls.md)).
///
/// Drawn rather than Material's, which is eighteen points and has a tick of
/// its own: **off** is `surface_raised` behind a one-point `border_strong`
/// hairline, **on** is `accent` with the tick knocked out of it in the
/// surface's colour — not white, which on this accent would glare.
class TomCheckWidget extends StatelessWidget {
  /// Creates the box, [isChecked] or not, calling [onChanged] when clicked.
  const TomCheckWidget({
    required this.isChecked,
    required this.onChanged,
    this.alignment = Alignment.centerLeft,
    super.key,
  });

  /// Whether it is taken.
  final bool isChecked;

  /// What clicking it does; null makes it inert rather than hiding it.
  final ValueChanged<bool>? onChanged;

  /// Which edge of its target the box is pinned to.
  ///
  /// The target is wider than the box, so a box centred in it would sit two
  /// and a half points inside the column's margin — the rows pin left and
  /// the caption pins right, and both land where the board draws them.
  final Alignment alignment;

  /// The box itself.
  static const double box = 15;

  /// What can be clicked, centred on it: a fifteen-point target is a target
  /// somebody misses.
  static const double target = TomMetrics.mark;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<bool>('isChecked', isChecked))
      ..add(ObjectFlagProperty<ValueChanged<bool>?>.has('onChanged', onChanged))
      ..add(DiagnosticsProperty<Alignment>('alignment', alignment));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    final ValueChanged<bool>? change = onChanged;
    return SizedBox.square(
      dimension: target,
      child: Align(
        alignment: alignment,
        child: GestureDetector(
          onTap: change == null ? null : () => change(!isChecked),
          child: SizedBox.square(
            dimension: box,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: isChecked ? colors.accent : colors.surfaceRaised,
                borderRadius: BorderRadius.circular(TomMetrics.radiusTight),
                border: isChecked
                    ? null
                    : Border.all(color: colors.borderStrong),
              ),
              child: isChecked
                  ? Icon(
                      Icons.check,
                      size: box - 3,
                      color: colors.surfaceRaised,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
