/// A bar across the window, and which edge its rule sits on.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_ui/src/theme/tom_colors.dart';

/// Which edge a bar's rule sits on.
enum TomBarEdgeEnum {
  /// The rule is above the bar — a status bar.
  top,

  /// The rule is below it — a top bar.
  bottom,
}

/// One of the window's two bars: a fixed height, a raised fill, one hairline.
///
/// **The rule is inside the height**, because that is what the boards measure:
/// a top bar drawn 52 tall with a rule under it takes 53, and everything below
/// it is a point low for the rest of the window
/// (`docs/design/screens/measurements.md`).
class TomBarWidget extends StatelessWidget {
  /// Creates a bar [height] tall with its rule on [rule].
  const TomBarWidget({
    required this.height,
    required this.rule,
    required this.child,
    super.key,
  });

  /// How tall, rule included.
  final double height;

  /// Where the hairline goes.
  final TomBarEdgeEnum rule;

  /// What the bar holds.
  final Widget child;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('height', height))
      ..add(EnumProperty<TomBarEdgeEnum>('rule', rule));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    final BorderSide side = BorderSide(color: colors.border);
    return Container(
      // Not redundant: a `Container` with no width sizes itself to its child,
      // and a top bar with no space open has no child at all.
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        border: Border(
          top: rule == TomBarEdgeEnum.top ? side : BorderSide.none,
          bottom: rule == TomBarEdgeEnum.bottom ? side : BorderSide.none,
        ),
      ),
      child: child,
    );
  }
}
