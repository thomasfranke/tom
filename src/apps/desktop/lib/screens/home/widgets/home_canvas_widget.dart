/// The body between Home's two bars.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_ui/tom_ui.dart';

/// The body between the two bars, with the content where the design put it.
///
/// Only the ratio of [above] to [below] is used, so the block sits at the
/// same proportion of any window; it scrolls when the window is shorter
/// than the content, which the minimum window height allows.
class HomeCanvasWidget extends StatelessWidget {
  /// Places [child] between [above] and [below].
  const HomeCanvasWidget({
    required this.above,
    required this.below,
    required this.child,
    super.key,
  });

  /// The design's empty space over the content.
  final double above;

  /// The design's empty space under it.
  final double below;

  /// What sits between them.
  final Widget child;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('above', above))
      ..add(DoubleProperty('below', below));
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) =>
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: TomMetrics.pad),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - TomMetrics.pad * 2,
            ),
            child: Align(
              alignment: Alignment(0, above / (above + below) * 2 - 1),
              child: child,
            ),
          ),
        ),
  );
}
