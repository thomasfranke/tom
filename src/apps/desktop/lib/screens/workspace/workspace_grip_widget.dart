/// What sits in a gutter: the one line left on screen, and the grip on it.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The gutter between two containers: a hairline at its far edge, the
/// [TomColumnGripWidget] on it, and the whole strip grabbable.
///
/// **A width nobody can see is a width nobody drags**, which is why the dots
/// are drawn rather than the hairline thickened: the line is the boards' and
/// what is grabbed is the strip it sits in
/// (`docs/design/components/controls.md`).
///
/// A gutter whose column is closed keeps both, at the window's edge, because
/// the way to bring the column back must not close with it.
class WorkspaceGripWidget extends ConsumerWidget {
  /// Creates the gutter for a column currently [width] wide.
  ///
  /// [isDraggable] is false for a column whose width is not the reader's
  /// yet: the line is still drawn, the dots are not.
  const WorkspaceGripWidget({
    required this.width,
    this.isDraggable = true,
    super.key,
  });

  /// The column's width now; a drag moves from here.
  final double width;

  /// Whether dragging this gutter does anything.
  final bool isDraggable;

  /// The gutter's own width, which is also what can be grabbed.
  static const double grip = TomMetrics.gutter;

  /// The hairline's offset inside the gutter — its far edge.
  static const double rule = grip - 1;

  /// The dots' offset inside the gutter.
  static const double dots = 3;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('width', width))
      ..add(DiagnosticsProperty<bool>('isDraggable', isDraggable));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    final Widget drawn = Stack(
      children: <Widget>[
        Positioned(
          left: rule,
          top: 0,
          bottom: 0,
          width: 1,
          child: ColoredBox(color: colors.border),
        ),
        if (isDraggable)
          const Positioned(
            left: dots,
            top: 0,
            bottom: 0,
            child: Center(child: TomColumnGripWidget()),
          ),
      ],
    );
    if (!isDraggable) {
      return SizedBox(width: grip, child: drawn);
    }
    return MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        // Measured from where the pointer went down, not from where the drag
        // was recognised: the default swallows the touch slop, and a rule
        // that trails the pointer by eighteen points never catches up.
        dragStartBehavior: DragStartBehavior.down,
        onHorizontalDragUpdate: (DragUpdateDetails drag) => ref
            .read(workspaceProvider.notifier)
            .widenExplorer(width + drag.delta.dx),
        child: SizedBox(width: grip, child: drawn),
      ),
    );
  }
}
