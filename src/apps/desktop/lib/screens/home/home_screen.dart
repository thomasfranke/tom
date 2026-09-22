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
import 'package:tom_desktop/theme/tom_colors.dart';
import 'package:tom_desktop/widgets/commit_trunk_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

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
                  // The line's own history is the only history this screen
                  // has: the spaces that were opened, newest first. Invented
                  // hashes belong to the website, not to someone's app.
                  commits: _commits(recents),
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

/// The remembered spaces as entries on the trunk behind them.
///
/// Three at most: the line has room for three before it reaches the status
/// bar, and a fourth would be a list rather than a ground.
List<TrunkCommit> _commits(List<RecentSpaceEntity> recents) => <TrunkCommit>[
  for (final RecentSpaceEntity recent in recents.take(3))
    TrunkCommit(subject: recent.name, meta: _ago(recent.lastOpened)),
];

/// When something happened, in the words a log uses.
///
/// Rounded down on purpose: the point is *how long ago*, and a space opened
/// 30 hours ago reads better as yesterday than as a number of hours.
String _ago(DateTime moment) {
  final Duration since = DateTime.now().toUtc().difference(moment);
  return switch (since.inDays) {
    0 => 'today',
    1 => 'yesterday',
    < 7 => '${since.inDays} days ago',
    < 14 => 'last week',
    < 60 => '${since.inDays ~/ 7} weeks ago',
    _ => '${since.inDays ~/ 30} months ago',
  };
}
