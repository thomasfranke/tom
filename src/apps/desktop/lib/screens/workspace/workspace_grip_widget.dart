/// What the left column is dragged by.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_presentation/tom_presentation.dart';

/// An invisible strip over the rule between the left column and the document
/// area, which is what widens the column
/// (`docs/product/workspace/regions/doc.md`).
///
/// It draws nothing: the hairline is the column's own, and thickening it to
/// something grabbable would put a bar in the window that the boards do not
/// have. What is drawn and what is grabbed are not the same rectangle.
class WorkspaceGripWidget extends ConsumerWidget {
  /// Creates the grip for a column currently [width] wide.
  const WorkspaceGripWidget({required this.width, super.key});

  /// The column's width now; a drag moves from here.
  final double width;

  /// How much of the window can be grabbed, centred on the rule.
  static const double grip = 8;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('width', width));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => MouseRegion(
    cursor: SystemMouseCursors.resizeLeftRight,
    child: GestureDetector(
      behavior: HitTestBehavior.translucent,
      // Measured from where the pointer went down, not from where the drag
      // was recognised: the default swallows the touch slop, and a rule that
      // trails the pointer by eighteen points never catches up.
      dragStartBehavior: DragStartBehavior.down,
      onHorizontalDragUpdate: (DragUpdateDetails drag) => ref
          .read(workspaceProvider.notifier)
          .widenExplorer(width + drag.delta.dx),
      child: const SizedBox(width: grip),
    ),
  );
}
