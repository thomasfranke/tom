/// A way forward that is not open yet.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_desktop/screens/home/home_design.dart';
import 'package:tom_ui/tom_ui.dart';

/// A way forward that is not open yet; always disabled, the chip beside it
/// says when.
class HomeSecondaryButtonWidget extends StatelessWidget {
  /// Creates a disabled button saying [label].
  const HomeSecondaryButtonWidget({required this.label, super.key});

  /// What it says.
  final String label;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('label', label));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return OutlinedButton(
      onPressed: null,
      style: OutlinedButton.styleFrom(
        disabledForegroundColor: colors.textMuted,
        side: BorderSide(color: colors.borderStrong),
        fixedSize: const Size(HomeDesign.column, HomeDesign.control),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HomeDesign.controlRadius),
        ),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      child: Text(label),
    );
  }
}
