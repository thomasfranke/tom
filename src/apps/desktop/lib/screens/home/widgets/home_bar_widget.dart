/// One of Home's two bars, and which edge its rule sits on.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_ui/tom_ui.dart';

/// Which edge a bar's rule sits on.
enum HomeBarEdgeEnum {
  /// The rule is above the bar — the status strip.
  top,

  /// The rule is below it — the top strip.
  bottom,
}

/// One of the two bars: a fixed height, a raised fill, and one hairline.
///
/// The rule is *inside* the height rather than added to it, because that is
/// what the design measures — a bar plus a divider would make every screen
/// one pixel taller than the drawing it came from.
class HomeBarWidget extends StatelessWidget {
  /// Creates a bar [height] tall with its rule on [rule].
  const HomeBarWidget({
    required this.colors,
    required this.height,
    required this.rule,
    required this.child,
    super.key,
  });

  /// The palette in scope.
  final TomColors colors;

  /// How tall, rule included.
  final double height;

  /// Where the hairline goes.
  final HomeBarEdgeEnum rule;

  /// What the bar holds.
  final Widget child;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<TomColors>('colors', colors))
      ..add(DoubleProperty('height', height))
      ..add(EnumProperty<HomeBarEdgeEnum>('rule', rule));
  }

  @override
  Widget build(BuildContext context) {
    final BorderSide side = BorderSide(color: colors.border);
    return Container(
      // Both, and the width is not redundant: a `Container` with a height
      // and no width sizes itself to its child, and the top bar's child is
      // nothing at all — which drew a bar zero pixels wide.
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        border: Border(
          top: rule == HomeBarEdgeEnum.top ? side : BorderSide.none,
          bottom: rule == HomeBarEdgeEnum.bottom ? side : BorderSide.none,
        ),
      ),
      child: child,
    );
  }
}
