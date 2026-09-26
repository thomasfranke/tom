/// The first screen anyone sees.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/screens/home/widgets/home_canvas_widget.dart';
import 'package:tom_desktop/screens/home/widgets/home_refused_widget.dart';
import 'package:tom_desktop/screens/home/widgets/home_status_strip_widget.dart';
import 'package:tom_desktop/screens/home/widgets/home_top_strip_widget.dart';
import 'package:tom_desktop/screens/home/widgets/home_welcome_widget.dart';
import 'package:tom_desktop/screens/home/widgets/home_working_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// Home: open a space, or go back to one.
///
/// The empty state and the refusal, in the boards' own words
/// (`docs/design/screens/desktop/home/`); when the code and the board
/// disagree the board is right (`docs/design/README.md`).
class HomeScreen extends ConsumerWidget {
  /// Creates the screen.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final HomeState state = ref.watch(homeProvider);
    final TomColors colors = TomColors.of(context);
    return Scaffold(
      backgroundColor: colors.surface,
      body: Column(
        children: <Widget>[
          const HomeTopStripWidget(),
          Expanded(
            child: switch (state) {
              HomeInitial() || HomeLoading() => const HomeCanvasWidget(
                above: 1,
                below: 1,
                child: HomeWorkingWidget(),
              ),
              // The trunk is drawn off the wordmark, which the refusal does
              // not show.
              HomeReady(recents: final List<RecentSpaceEntity> recents) =>
                CommitTrunkWidget(
                  child: HomeCanvasWidget(
                    // The design's empty space on its 900-tall window, used
                    // as a ratio so a taller window does not hug the chrome.
                    above: 98,
                    below: 166,
                    child: HomeWelcomeWidget(recents: recents),
                  ),
                ),
              HomeFailed(failure: final AppFailure failure) => HomeCanvasWidget(
                above: 248,
                below: 288.5,
                child: HomeRefusedWidget(failure: failure),
              ),
            },
          ),
          const HomeStatusStripWidget(),
        ],
      ),
    );
  }
}
