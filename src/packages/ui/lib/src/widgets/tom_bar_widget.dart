/// A bar across the window.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_ui/src/theme/tom_colors.dart';

/// One of the window's two bars: a fixed height on the window's own fill.
///
/// **No rule and no fill of its own**: the columns are islands with their
/// own edges, so a bar is told apart by what is not on it rather than by a
/// line (`docs/design/visual-language/rationale.md`).
class TomBarWidget extends StatelessWidget {
  /// Creates a bar [height] tall.
  const TomBarWidget({required this.height, required this.child, super.key});

  /// How tall.
  final double height;

  /// What the bar holds.
  final Widget child;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('height', height));
  }

  @override
  Widget build(BuildContext context) => Container(
    // Not redundant: a `Container` with no width sizes itself to its child,
    // and a top bar with no space open has no child at all.
    width: double.infinity,
    height: height,
    color: TomColors.of(context).surface,
    child: child,
  );
}
