/// The first screen anyone sees.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/screens/home/widgets/home_canvas_widget.dart';
import 'package:tom_desktop/screens/home/widgets/home_commands_widget.dart';
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
    void toggleBottom() => ref.read(workspaceProvider.notifier).toggleBottom();
    return CallbackShortcuts(
      // ⌘J / Ctrl+J, as in a workspace: the panel is reachable before a
      // space is open.
      bindings: <ShortcutActivator, VoidCallback>{
        if (defaultTargetPlatform == TargetPlatform.macOS)
          const SingleActivator(LogicalKeyboardKey.keyJ, meta: true):
              toggleBottom
        else
          const SingleActivator(LogicalKeyboardKey.keyJ, control: true):
              toggleBottom,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: colors.surface,
          body: Column(
            children: <Widget>[
              const HomeTopStripWidget(),
              Expanded(
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(child: _content(state)),
                    // Over Home's foot and not part of its layout: Home does
                    // not move when the panel opens.
                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: HomeCommandsWidget(),
                    ),
                  ],
                ),
              ),
              const HomeStatusStripWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(HomeState state) => switch (state) {
    HomeInitial() || HomeLoading() => const HomeCanvasWidget(
      above: 1,
      below: 1,
      child: HomeWorkingWidget(),
    ),
    // The trunk is drawn off the wordmark, which the refusal does not show.
    HomeReady(
      recents: final List<RecentSpaceEntity> recents,
      clone: final HomeCloneState clone,
      notOpened: final String? notOpened,
    ) =>
      CommitTrunkWidget(
        child: HomeCanvasWidget(
          // The board's own empty space, measured off the render rather than
          // the markup, and used as a ratio so a taller window does not hug
          // the chrome.
          above: 94,
          below: 119,
          child: HomeWelcomeWidget(
            recents: recents,
            clone: clone,
            notOpened: notOpened,
          ),
        ),
      ),
    HomeFailed(failure: final AppFailure failure) => HomeCanvasWidget(
      above: 248,
      below: 288.5,
      child: HomeRefusedWidget(failure: failure),
    ),
  };
}
