/// One of the window's columns, and which side of the window it is on.
library;

import 'package:flutter/material.dart';
import 'package:tom_ui/src/theme/tom_colors.dart';
import 'package:tom_ui/src/theme/tom_metrics.dart';

/// Which side of the window a column is on.
enum TomColumnEdgeEnum {
  /// The left — the explorer.
  left,

  /// The right — the git column.
  right,

  /// Neither — the document area, between the two.
  neither,
}

/// A column's own surface: an island, raised and rounded, with a 1px edge.
///
/// The edge is painted **over** the child rather than around it, so what the
/// boards measure from the island's edge is measured from the child's own
/// zero, and the child is clipped to the corners.
class TomColumnBoxWidget extends StatelessWidget {
  /// Draws [child] on an island.
  const TomColumnBoxWidget({required this.child, super.key});

  /// What sits on it.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    final BorderRadius corners = BorderRadius.circular(TomMetrics.radiusIsland);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: corners,
      ),
      foregroundDecoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: corners,
      ),
      child: child,
    );
  }
}
