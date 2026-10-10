/// What sits in a gutter: the strip that widens a column.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The gutter beside a column, grabbable along its whole height.
///
/// **Nothing is drawn on it**: the islands' own edges say where a column
/// ends, and the cursor says the gutter can be dragged — every 1b board
/// leaves the gutter empty (`docs/design/screens/divergences.md`).
///
/// A gutter whose column is closed stays at the window's edge, because the
/// way to bring the column back must not close with it.
class WorkspaceGripWidget extends ConsumerWidget {
  /// Creates the gutter for the column at [edge], currently [width] wide.
  const WorkspaceGripWidget({
    required this.width,
    this.edge = TomColumnEdgeEnum.left,
    super.key,
  });

  /// The column's width now; a drag moves from here.
  final double width;

  /// Which column it widens: the left one grows as the pointer moves right,
  /// the right one as it moves left.
  final TomColumnEdgeEnum edge;

  /// The gutter's own width, which is also what can be grabbed.
  static const double grip = TomMetrics.gutter;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('width', width))
      ..add(EnumProperty<TomColumnEdgeEnum>('edge', edge));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final WorkspaceNotifier workspace = ref.read(workspaceProvider.notifier);
    return MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        // Measured from where the pointer went down, not from where the drag
        // was recognised: the default swallows the touch slop, and a rule
        // that trails the pointer by eighteen points never catches up.
        dragStartBehavior: DragStartBehavior.down,
        onHorizontalDragUpdate: (DragUpdateDetails drag) =>
            edge == TomColumnEdgeEnum.right
            ? workspace.widenAside(width - drag.delta.dx)
            : workspace.widenExplorer(width + drag.delta.dx),
        child: const SizedBox(width: grip),
      ),
    );
  }
}
