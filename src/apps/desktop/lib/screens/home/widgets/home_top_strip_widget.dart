/// The bar above everything, on Home.
library;

import 'package:flutter/material.dart';
import 'package:tom_desktop/screens/home/widgets/home_bar_widget.dart';
import 'package:tom_desktop/theme/tom_colors.dart';
import 'package:tom_desktop/theme/tom_metrics.dart';

/// The bar above everything.
///
/// Empty here, and drawn anyway: the design gives Home the same chrome as
/// every other screen, so opening a space changes what is *in* the window
/// and not the shape of it.
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
