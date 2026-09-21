/// Everything a scenario can do to the app, and everything it can see.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_desktop/bootstrap/run_tom.dart';
import 'package:tom_desktop/bootstrap/tom_module.dart';
import 'e2e_module.dart';

/// Drives the assembled app.
///
/// **This file is the reuse.** A scenario is a list of named steps and
/// nothing else; every tap, every wait and every assertion lives here, so
/// the tenth scenario costs a list and not another copy of "find the button,
/// tap it, settle". When the Home layout changes, one file changes.
///
/// It talks to the app the way a person does — through what is on screen —
/// and never reaches into a provider or a repository. A harness that read
/// the state directly would go green on an app whose screen never updated.
final class TomRobot {
  /// Wraps [tester], storing this scenario's preferences at [settingsPath].
  TomRobot(this.tester, {required this.settingsPath});

  /// The harness driving the widget tree.
  final WidgetTester tester;

  /// Where this scenario's preferences live.
  ///
  /// One file per scenario, cleared before the first step. Within a
  /// scenario it survives a relaunch — which is what "remembers a space"
  /// needs — and between scenarios nothing leaks, so the order they run in
  /// cannot change what they assert.
  final String settingsPath;

  /// Starts the app, with the folder dialog answering [pickFolder].
  ///
  /// The real modules and the real object graph — `tomApp` is what `main()`
  /// runs — plus one module that answers the native dialog no test can
  /// open. Mounted rather than started, because a scenario calls this more
  /// than once to prove something survived a restart, and `runApp` a second
  /// time does not replace a tree that is already there.
  ///
  /// The one thing it leaves out is the window: a title and a minimum size,
  /// which has no screen to assert about.
  Future<void> launch({String? pickFolder}) async {
    // Unmounted first, and this is not ceremony. Flutter updates an element
    // in place when the widget at that position is of the same type, so
    // pumping a second `ProviderScope` keeps the *first* one's container —
    // and with it every provider's state. A scenario that restarted the app
    // would find it exactly where it left it, which is the opposite of what
    // it is asserting.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pumpWidget(
      tomApp(
        modules: <TomModule>[
          E2eModule(folder: pickFolder, settingsPath: settingsPath),
        ],
      ),
    );
    await settle();
  }

  /// Starts the app sized for a desktop window.
  ///
  /// The shell is three regions side by side and has a minimum width it
  /// holds together in; a default test surface is narrower than a phone and
  /// would report overflows that no user can produce.
  Future<void> launchWindowed({
    String? pickFolder,
    Size size = const Size(1280, 840),
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await launch(pickFolder: pickFolder);
  }

  /// Waits until the app stops animating.
  ///
  /// With a timeout, because the default is ten minutes: an animation that
  /// never ends — a spinner on a screen with nothing coming, which this app
  /// has already had once — otherwise hangs the whole run rather than
  /// failing the step that caused it.
  Future<void> settle() async {
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 15),
    );
  }

  /// Pumps until [ready] holds, and gives up quietly when it does not.
  ///
  /// **Settling is not waiting.** `pumpAndSettle` returns as soon as no
  /// frame is scheduled, and the app's work is not a frame: opening a space
  /// runs `git` in another process, and a screen with nothing animating on
  /// it settles in a millisecond while that is still in flight. A scenario
  /// that asserted right there was reading the screen before the answer had
  /// arrived — which passed on a warm machine and failed on a busy one, at
  /// whichever step happened to lose the race.
  ///
  /// It gives up rather than throwing, so the assertion that follows fails
  /// with what was actually on screen instead of with a timeout.
  Future<void> _waitUntil(
    bool Function() ready, {
    Duration limit = const Duration(seconds: 10),
  }) async {
    final Stopwatch clock = Stopwatch()..start();
    while (!ready() && clock.elapsed < limit) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  /// Whether [finder] currently matches anything.
  bool _showing(Finder finder) => finder.evaluate().isNotEmpty;

  // ── What the user does ────────────────────────────────────────────────

  /// Presses *Choose folder…* on Home.
  ///
  /// What the dialog answers was decided at [launch]: the module overriding
  /// it is installed before the app starts, because the app reads it once.
  Future<void> chooseFolder() async {
    await tapText('Choose folder…');
  }

  /// Presses *Choose another folder…* on the refusal screen.
  Future<void> chooseAnotherFolder() async {
    await tapText('Choose another folder…');
  }

  /// Opens a space from the recent list, by the name it shows.
  Future<void> openRecent(String name) async {
    await tapText(name);
  }

  /// Drops a space from the recent list, by the name of its row.
  ///
  /// The row is found by its name and the button by its tooltip, rather than
  /// by position: a list that reordered would otherwise forget the wrong
  /// space and still pass.
  Future<void> forgetRecent(String name) async {
    final Finder row = find.ancestor(
      of: find.text(name),
      matching: find.byType(Row),
    );
    await tester.tap(
      find.descendant(of: row.last, matching: find.byTooltip(_forget)),
    );
    await settle();
  }

  /// Taps whatever shows [label], and lets the app settle.
  Future<void> tapText(String label) async {
    await tester.tap(find.text(label));
    await settle();
  }

  // ── What the user sees ────────────────────────────────────────────────

  /// Asserts Home is showing, with nothing open.
  Future<void> seesHome() async {
    await _waitUntil(() => _showing(find.text('Choose folder…')));
    expect(find.text('Choose folder…'), findsOneWidget, reason: 'not on Home');
    expect(find.text('no space open'), findsOneWidget);
  }

  /// Asserts the shell has taken over — a space is open.
  ///
  /// By the explorer, which the product says is always on screen once a
  /// space is open and never hidden by anything.
  Future<void> seesTheShell() async {
    await _waitUntil(() => _showing(find.text('EXPLORER')));
    expect(
      find.text('EXPLORER'),
      findsOneWidget,
      reason: 'the shell is not showing; is a space actually open?',
    );
    expect(find.text('Choose folder…'), findsNothing);
  }

  /// Asserts the refusal screen is showing, for a folder with no repository.
  Future<void> seesNotARepository(String folder) async {
    await _waitUntil(
      () => _showing(find.text('That folder is not inside a Git repository')),
    );
    expect(
      find.text('That folder is not inside a Git repository'),
      findsOneWidget,
    );
    expect(find.text(folder), findsOneWidget);
    expect(
      find.text('Creating a repository is not something TOM does.'),
      findsOneWidget,
      reason: 'the screen must say TOM will not create one',
    );
  }

  /// Asserts the recent list offers [names], in that order.
  Future<void> seesRecent(List<String> names) async {
    await _waitUntil(() => _showing(find.text('RECENT')));
    expect(find.text('RECENT'), findsOneWidget, reason: 'no recent list');
    for (final String name in names) {
      expect(find.text(name), findsOneWidget, reason: '$name is not offered');
    }
    for (int i = 1; i < names.length; i++) {
      expect(
        tester.getCenter(find.text(names[i - 1])).dy,
        lessThan(tester.getCenter(find.text(names[i])).dy),
        reason: '${names[i - 1]} should be above ${names[i]}',
      );
    }
  }

  /// Asserts nothing is offered to go back to.
  ///
  /// Waits for the list to *go*, which is the same race read backwards:
  /// forgetting writes the preferences file, and the row is still on screen
  /// until that comes back.
  Future<void> seesNoRecent() async {
    await _waitUntil(() => !_showing(find.text('RECENT')));
    expect(find.text('RECENT'), findsNothing);
  }

  /// Asserts the app is not showing an unhandled error.
  ///
  /// Cheap, and worth doing at the end of every scenario: a red screen makes
  /// most assertions fail in confusing ways, and this names it directly.
  void seesNothingBroken() {
    expect(tester.takeException(), isNull);
    expect(find.byType(ErrorWidget), findsNothing);
  }

  static const String _forget = 'Forget this space';
}
