/// What sits in the gutter above the bottom panel: the strip that raises it.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The gutter between the document and the panel under it, grabbable along
/// its whole width — the columns' own reading turned on its side, and as
/// empty: the cursor says it can be dragged.
class WorkspaceBottomGripWidget extends ConsumerWidget {
  /// Creates the gutter for a panel [height] tall, which may grow to
  /// [highest].
  const WorkspaceBottomGripWidget({
    required this.height,
    required this.highest,
    super.key,
  });

  /// The panel's height now; a drag moves from here.
  final double height;

  /// The most it may be raised to, so the document always keeps some room.
  final double highest;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('height', height))
      ..add(DoubleProperty('highest', highest));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final WorkspaceNotifier workspace = ref.read(workspaceProvider.notifier);
    return MouseRegion(
      cursor: SystemMouseCursors.resizeUpDown,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        // From where the pointer went down, as the columns' gutters do.
        dragStartBehavior: DragStartBehavior.down,
        onVerticalDragUpdate: (DragUpdateDetails drag) =>
            workspace.raiseBottom(height - drag.delta.dy, highest: highest),
        child: const SizedBox(height: TomMetrics.gutter),
      ),
    );
  }
}
