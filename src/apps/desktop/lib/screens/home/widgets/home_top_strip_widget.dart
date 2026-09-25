/// The bar above everything, on Home.
library;

import 'package:flutter/material.dart';
import 'package:tom_desktop/screens/home/widgets/home_bar_widget.dart';
import 'package:tom_ui/tom_ui.dart';

/// The bar above everything, empty and drawn anyway.
///
/// Home has the same chrome as every screen, so opening a space changes
/// what is in the window and not its shape.
class HomeTopStripWidget extends StatelessWidget {
  /// Creates the strip.
  const HomeTopStripWidget({super.key});

  @override
  Widget build(BuildContext context) => HomeBarWidget(
    colors: TomColors.of(context),
    height: TomMetrics.topBar,
    rule: HomeBarEdgeEnum.bottom,
    child: const SizedBox.shrink(),
  );
}
