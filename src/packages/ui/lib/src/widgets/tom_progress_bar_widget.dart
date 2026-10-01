/// A request in flight, across the top of the column that owns it.
library;

import 'package:flutter/material.dart';
import 'package:tom_ui/src/theme/tom_colors.dart';

/// The progress bar of
/// [components](../../../../../../docs/design/components/controls.md): a
/// three-point track with one segment travelling along it.
///
/// **It means the network**, which is what a verb alone does not say — data
/// is coming from somebody else's machine. It spans the panel rather than
/// sitting on a control, because the column owns every request and is never
/// doing two things at once
/// ([while a request runs](../../../../../../docs/product/git-workflow/push-pull/while-a-request-runs/doc.md)).
///
/// Indeterminate on purpose: git reports no fraction, and a bar that filled
/// to the end and sat there would be claiming one.
class TomProgressBarWidget extends StatefulWidget {
  /// Creates the bar.
  const TomProgressBarWidget({super.key});

  /// How tall the track is.
  static const double height = 3;

  /// How wide the travelling segment is.
  static const double segment = 96;

  /// How long it takes to cross.
  static const Duration crossing = Duration(milliseconds: 1400);

  @override
  State<TomProgressBarWidget> createState() => _TomProgressBarWidgetState();
}

class _TomProgressBarWidgetState extends State<TomProgressBarWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _travel = AnimationController(
    vsync: this,
    duration: TomProgressBarWidget.crossing,
  )..repeat();

  @override
  void dispose() {
    _travel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return SizedBox(
      height: TomProgressBarWidget.height,
      child: ColoredBox(
        color: colors.accentSoft,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints room) =>
              AnimatedBuilder(
                animation: _travel,
                builder: (BuildContext context, Widget? child) => Align(
                  // From off one edge to off the other, so the segment enters
                  // and leaves rather than appearing at a stop.
                  alignment: Alignment(_travel.value * 2 - 1, 0),
                  child: SizedBox(
                    width: TomProgressBarWidget.segment.clamp(0, room.maxWidth),
                    child: ColoredBox(color: colors.accent),
                  ),
                ),
              ),
        ),
      ),
    );
  }
}
