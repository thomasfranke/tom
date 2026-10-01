/// The bar above everything, on Home.
library;

import 'package:flutter/material.dart';
import 'package:tom_desktop/screens/preferences/preferences_control_widget.dart';
import 'package:tom_ui/tom_ui.dart';

/// The bar above everything, carrying only the preferences button.
///
/// Home has the same chrome as every screen, so opening a space changes what
/// is in the window and not its shape — and the gear is here because the
/// language is chosen before a space is open
/// (`docs/product/preferences/the-popover/doc.md`).
class HomeTopStripWidget extends StatelessWidget {
  /// Creates the strip.
  const HomeTopStripWidget({super.key});

  @override
  Widget build(BuildContext context) => const TomBarWidget(
    height: TomMetrics.topBar,
    rule: TomBarEdgeEnum.bottom,
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: TomMetrics.pad + TomMetrics.chromeInset,
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: PreferencesControlWidget(),
      ),
    ),
  );
}
