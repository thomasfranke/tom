/// The control that empties a field.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_ui/src/theme/tom_colors.dart';

/// The `Field clear` component: a 16-point disc in `text_muted` with the
/// close glyph knocked out of it
/// ([controls](../../../../../../docs/design/components/controls.md)).
///
/// A disc rather than a bare glyph, because it sits inside a field whose text
/// is the same weight and colour: a glyph alone reads as a character somebody
/// typed. What is knocked out is [on], the fill of the field it sits in.
class TomFieldClearWidget extends StatelessWidget {
  /// Creates the control, knocked out of [on].
  const TomFieldClearWidget({required this.on, super.key});

  /// The fill of the field this sits in, which is what the glyph is drawn in.
  final Color on;

  /// The disc.
  static const double box = 16;

  /// The glyph inside it.
  static const double glyph = 10;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('on', on));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return SizedBox.square(
      dimension: box,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.textMuted,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.close, size: glyph, color: on),
      ),
    );
  }
}
