/// The mark that dates a control: it is here, it works later.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_ui/src/theme/tom_colors.dart';

/// A 30×20 outline saying which milestone something arrives in.
///
/// The design hangs one beside every control that is drawn before it works —
/// *Clone from URL* on Home, the search field in the explorer — because a
/// control that appears later moves everything under it.
class MilestoneChipWidget extends StatelessWidget {
  /// Creates a chip reading [label].
  const MilestoneChipWidget({required this.label, super.key});

  /// The milestone: `M1`, `M2`, `M3`.
  final String label;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('label', label));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return Container(
      width: 30,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: colors.borderStrong),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          height: 1.4,
          fontWeight: FontWeight.w600,
          color: colors.textMuted,
        ),
      ),
    );
  }
}
