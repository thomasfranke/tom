/// One of the window's containers, and which edge it runs off.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_ui/src/theme/tom_colors.dart';
import 'package:tom_ui/src/theme/tom_metrics.dart';

/// Which side of the window a column leaves by.
enum TomColumnEdgeEnum {
  /// It runs off the left edge — the explorer.
  left,

  /// It runs off the right edge — the git column.
  right,

  /// It touches neither — the document area, with a gutter either side.
  neither,
}

/// A column's own surface: raised, rounded, with a 1px edge.
///
/// **It runs under the bars and off the window**, by [TomMetrics.gutter] at
/// top, bottom and its outer side, so no edge of it frames the window — the
/// corners a reader sees are the two inside the window
/// (`docs/design/screens/measurements.md`).
///
/// The child is laid out in the box given, not in the container: the boards
/// place a column's contents against the window and let the container slide
/// out from under them.
class TomColumnBoxWidget extends StatelessWidget {
  /// Draws [child] on a container leaving by [edge].
  const TomColumnBoxWidget({
    required this.edge,
    required this.child,
    super.key,
  });

  /// Which side of the window this column leaves by.
  final TomColumnEdgeEnum edge;

  /// What sits on it.
  final Widget child;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<TomColumnEdgeEnum>('edge', edge));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    const double bleed = TomMetrics.gutter;
    return Stack(
      // The container is meant to leave the box it is given; the bars are
      // drawn after it and cover what it leaves by.
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned(
          // The explorer's own box carries the gutter that follows it, which
          // is why its container ends short of it while the git column's
          // starts flush: the boards lay a column's contents against the
          // window and slide the container out from under them.
          left: edge == TomColumnEdgeEnum.left ? -bleed : 0,
          right: switch (edge) {
            TomColumnEdgeEnum.left => bleed,
            TomColumnEdgeEnum.right => -bleed,
            TomColumnEdgeEnum.neither => 0,
          },
          top: -bleed,
          bottom: -bleed,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceRaised,
              border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(TomMetrics.radius),
            ),
          ),
        ),
        // Inset by the edge it draws, on the side the boards measure from.
        //
        // A `DecoratedBox` paints its border *over* the child, so a document
        // column whose child starts at its own left edge starts one point
        // inside the line — and the whole row above the document reads a
        // point left of every board. The two columns that leave the window
        // are not measured from their container at all, so they keep the
        // window's own zero.
        Positioned(
          left: edge == TomColumnEdgeEnum.neither ? 1 : 0,
          right: 0,
          top: 0,
          bottom: 0,
          child: child,
        ),
      ],
    );
  }
}
