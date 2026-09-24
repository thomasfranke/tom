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
/// Two states the product draws as two screens
/// (`docs/product/home/mocks/`): the empty state, and the one way opening a
/// folder fails. The wording here is the wireframes' own — they are the
/// source for what is on the screen, and when code and wireframe disagree
/// the wireframe is right (`docs/technical/design/README.md`).
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
              // The ground is only under the empty state: it is drawn off the
              // wordmark, and the refusal does not show one.
              HomeReady(recents: final List<RecentSpaceEntity> recents) =>
                CommitTrunkWidget(
                  // The log down the line is the ground's own (TOM's history),
                  // not the spaces: those are on the card in front of it, and
                  // saying the same thing twice is what makes a screen busy.
                  child: HomeCanvasWidget(
                    // 98 above and 166 below, on the 900-tall window the
                    // design was drawn for. Kept as a ratio rather than as a
                    // top padding so a taller window does not leave the block
                    // hugging the chrome.
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
