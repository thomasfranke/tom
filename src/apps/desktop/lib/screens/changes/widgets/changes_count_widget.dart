/// A number in a pill.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_ui/tom_ui.dart';

/// A count, on the accent's soft fill: how far `Push` and `Pull` have to go.
class ChangesCountWidget extends StatelessWidget {
  /// Creates the pill for [count].
  const ChangesCountWidget({required this.count, super.key});

  /// What it says.
  final int count;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('count', count));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return Container(
      constraints: const BoxConstraints(minWidth: 18),
      height: 15,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.accentSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 10,
          height: 1,
          fontWeight: FontWeight.w600,
          color: colors.accent,
        ),
      ),
    );
  }
}
