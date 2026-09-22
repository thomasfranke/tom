/// The primary way forward.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_desktop/screens/home/home_design.dart';
import 'package:tom_desktop/theme/tom_colors.dart';

/// The primary way forward.
class HomePrimaryButtonWidget extends StatelessWidget {
  /// Creates a button saying [label].
  const HomePrimaryButtonWidget({
    required this.label,
    required this.onPressed,
    this.width = HomeDesign.column,
    super.key,
  });

  /// What it says.
  final String label;

  /// What it does.
  final VoidCallback onPressed;

  /// How wide the design draws it.
  final double width;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('label', label))
      ..add(DoubleProperty('width', width))
      ..add(ObjectFlagProperty<VoidCallback>.has('onPressed', onPressed));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: colors.accent,
        foregroundColor: colors.surfaceRaised,
        fixedSize: Size(width, HomeDesign.control),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HomeDesign.controlRadius),
        ),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      child: Text(label),
    );
  }
}
