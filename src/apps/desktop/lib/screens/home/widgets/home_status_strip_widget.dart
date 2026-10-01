/// Home's status bar.
library;

import 'package:flutter/material.dart';
import 'package:tom_ui/tom_ui.dart';

/// Home's status bar, saying the one thing there is to say with nothing
/// open.
class HomeStatusStripWidget extends StatelessWidget {
  /// Creates the strip.
  const HomeStatusStripWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return TomBarWidget(
      height: TomMetrics.statusBar,
      rule: TomBarEdgeEnum.top,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(
            left: TomMetrics.pad + TomMetrics.chromeInset,
          ),
          child: Text(
            'no space open',
            style: TextStyle(fontSize: 11, color: colors.textMuted),
          ),
        ),
      ),
    );
  }
}
