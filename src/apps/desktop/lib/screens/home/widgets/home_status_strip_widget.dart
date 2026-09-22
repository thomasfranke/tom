/// Home's status bar.
library;

import 'package:flutter/material.dart';
import 'package:tom_desktop/screens/home/widgets/home_bar_widget.dart';
import 'package:tom_desktop/theme/tom_colors.dart';
import 'package:tom_desktop/theme/tom_metrics.dart';

/// Home's status bar.
///
/// Both mocks draw it, and both say the same thing — which is the honest
/// amount of status there is with nothing open.
class HomeStatusStripWidget extends StatelessWidget {
  /// Creates the strip.
  const HomeStatusStripWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return HomeBarWidget(
      colors: colors,
      height: TomMetrics.statusBar,
      rule: HomeBarEdgeEnum.top,
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
