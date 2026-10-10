/// The one chevron the app draws, in both directions.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_ui/src/widgets/tom_glyph_widget.dart';

/// A chevron: pointing down when open, right when closed.
///
/// The set's `chevron-down` and `chevron-right`, drawn smaller than the box
/// it sits in: the solid face's chevron is heavy, and at the box's full size
/// it outweighs the label beside it.
class TomChevronWidget extends StatelessWidget {
  /// Creates a chevron in a box of [size], pointing down when [isOpen].
  const TomChevronWidget({
    required this.isOpen,
    required this.color,
    this.size = 16,
    super.key,
  });

  /// The glyph's share of the box.
  static const double inkShare = 0.625;

  /// Whether what it opens is open, which is what it points at.
  final bool isOpen;

  /// The ink.
  final Color color;

  /// The box it is drawn in, 16 where the boards put one.
  final double size;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<bool>('isOpen', isOpen))
      ..add(ColorProperty('color', color))
      ..add(DoubleProperty('size', size));
  }

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: Center(
      child: TomGlyphWidget(
        glyph: isOpen ? TomGlyphEnum.chevronDown : TomGlyphEnum.chevronRight,
        color: color,
        size: size * inkShare,
      ),
    ),
  );
}
