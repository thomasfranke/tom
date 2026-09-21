/// A scenario: a named flow, declared as steps, reported as it runs.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'fixture.dart';
import 'robot.dart';

/// The marker every line of the protocol starts with.
///
/// The CLI reads `flutter test --reporter=json`, where a `print` inside a
/// test arrives as an event carrying its message. This prefix is how the
/// dashboard tells a step report from anything else the test or the
/// framework happened to print.
///
/// Deliberately not a word anyone would type: a scenario that printed
/// "step" in a label must not be able to drive the progress bar.
const String stepMarker = '⦙tom-e2e⦙';

/// One named thing the scenario does.
///
/// The name is the whole point. It is what the progress screen shows while
/// it runs and what names the failure when it does not, so it is written for
/// someone reading a dashboard, not for someone reading code: *"choose the
/// docs folder"*, not *"tapChooseFolder"*.
final class Step {
  /// Creates a step called [name] that performs [body].
  const Step(this.name, this.body);

  /// What the progress screen shows while this runs.
  final String name;

  /// What it does, given the robot.
  final Future<void> Function(TomRobot robot) body;
}

/// Declares an end-to-end scenario and runs its [steps] in order.
///
/// **The flow is data, not code.** A scenario lists what happens; *how* each
/// of those things happens lives in [TomRobot], where the next scenario
/// reuses it. That split is what keeps a suite of flows from becoming twenty
/// copies of the same taps.
///
/// Knowing every step before the first one runs is what makes a progress bar
/// possible at all — `12/71` needs the 71 up front, and a scenario that
/// discovered its own length could only ever show a spinner.
///
/// [describe] is shown on the progress screen under the name. It says what
/// the scenario is *for*, in the words someone would use to explain why the
/// test exists; the step names already say what it does.
void scenario(
  String name, {
  required String describe,
  required List<Step> steps,
  String group = 'Home',
}) {
  // The binding is what separates this from a widget test. Under
  // `flutter test` alone the world runs on a fake clock where real file I/O
  // and a real `Process.run` never complete — so an app that reads a folder
  // and drives git would wait forever for its own first frame. This one
  // runs on a device, with a real event loop.
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(name, (WidgetTester tester) async {
    _report(<String, Object?>{
      'event': 'begin',
      'name': name,
      'describe': describe,
      'group': group,
      'steps': steps.length,
    });
    // Its own preferences, wiped before the first step: a scenario must not
    // inherit what the last one remembered, and must never write into the
    // application-support folder a person's own copy of the app uses.
    final String settingsPath = scenarioSettingsPath(name);
    final File store = File(settingsPath);
    if (store.existsSync()) {
      store.deleteSync();
    }
    final TomRobot robot = TomRobot(tester, settingsPath: settingsPath);
    final Stopwatch watch = Stopwatch()..start();
    for (int index = 0; index < steps.length; index++) {
      final Step step = steps[index];
      _report(<String, Object?>{
        'event': 'step',
        'index': index + 1,
        'of': steps.length,
        'name': step.name,
      });
      try {
        await step.body(robot);
      } on Object catch (error) {
        // The step name travels with the failure, because "expected one
        // widget, found none" is unreadable without knowing which of
        // seventy-one moments it was.
        _report(<String, Object?>{
          'event': 'failed',
          'index': index + 1,
          'name': step.name,
          'error': error.toString(),
          'elapsedMs': watch.elapsedMilliseconds,
        });
        fail('step ${index + 1}/${steps.length} — ${step.name}\n$error');
      }
    }
    _report(<String, Object?>{
      'event': 'finished',
      'steps': steps.length,
      'elapsedMs': watch.elapsedMilliseconds,
    });
  });
}

/// Writes one line of the protocol.
///
/// `print` rather than a channel of its own: it is the one thing that
/// survives the trip through `flutter test`'s json reporter without the
/// harness needing anything special, and a run outside the CLI still shows
/// something a person can read.
void _report(Map<String, Object?> event) =>
    // ignore: avoid_print — this *is* the protocol; see `stepMarker`.
    print('$stepMarker${jsonEncode(event)}');
