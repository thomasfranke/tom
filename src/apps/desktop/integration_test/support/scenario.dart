/// A scenario: a named flow, declared as steps, reported as it runs.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'evidence.dart';
import 'fixture.dart';
import 'robot.dart';

/// The marker every line of the protocol starts with, which is how the CLI
/// tells a step report from anything else `flutter test` printed.
///
/// Not a word anyone would type, so a label cannot drive the progress bar.
const String stepMarker = '⦙tom-e2e⦙';

/// How long one step may take before the run gives up on it.
///
/// The backstop for the one wait that is not bounded: a step that never
/// returns would otherwise take the suite with it and say nothing.
const Duration stepLimit = Duration(seconds: 90);

/// One named thing the scenario does.
///
/// The name is what the progress screen shows and what names a failure, so
/// it is written for a dashboard: *"choose the docs folder"*, not
/// *"tapChooseFolder"*.
final class Step {
  /// A step called [name] that performs [body].
  const Step(this.name, this.body);

  /// What the progress screen shows while this runs.
  final String name;

  /// What it does, given the robot.
  final Future<void> Function(TomRobot robot) body;
}

/// Declares an end-to-end scenario and runs its [steps] in order.
///
/// The flow is data: a scenario lists what happens, and how lives in
/// [TomRobot] where the next scenario reuses it. Every step is known before
/// the first runs, which is what a `12/71` progress bar needs. [describe]
/// says what the scenario is *for*, under the name on the progress screen.
void scenario(
  String name, {
  required String describe,
  required List<Step> steps,
  String group = 'Home',
}) {
  // A real event loop: under `flutter test` alone the clock is fake, and real
  // file I/O and `Process.run` never complete.
  final TestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // The live binding skips the frames between pumps; a watched run asks for
  // all of them so the window moves rather than jumps.
  if (TomRobot.hold > Duration.zero &&
      binding is LiveTestWidgetsFlutterBinding) {
    binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  }
  testWidgets(name, (WidgetTester tester) async {
    _report(<String, Object?>{
      'event': 'begin',
      'name': name,
      'describe': describe,
      'group': group,
      'steps': steps.length,
    });
    // Its own preferences, wiped first: a scenario must not inherit the last
    // one's, nor write into the folder a person's own copy of the app uses.
    final String settingsPath = scenarioSettingsPath(name);
    final File store = File(settingsPath);
    if (store.existsSync()) {
      store.deleteSync();
    }
    final Evidence evidence = Evidence(name, tester: tester);
    final TomRobot robot = TomRobot(
      tester,
      settingsPath: settingsPath,
      evidence: evidence,
    );
    final Stopwatch watch = Stopwatch()..start();
    for (int index = 0; index < steps.length; index++) {
      final Step step = steps[index];
      // Frames are named after their step, so a failure points at pictures
      // of itself.
      evidence.step = '${index + 1}-${step.name}';
      _report(<String, Object?>{
        'event': 'step',
        'index': index + 1,
        'of': steps.length,
        'name': step.name,
      });
      try {
        await step.body(robot).timeout(stepLimit);
        // Photographed between steps, never inside one: reading a frame back
        // asks for one to be rasterised, and inside a step's pump-and-settle
        // the settling never settles.
        await evidence.capture();
      } on Object catch (error) {
        // The failure's own frame — except after a timeout. `timeout` cannot
        // cancel the body, which is still inside the binding; a capture here
        // gives it room to run into teardown and report a second error over
        // the timeout.
        if (error is! TimeoutException) {
          await evidence.capture();
        }
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
/// `print`, because it is the one thing that survives `flutter test`'s json
/// reporter unaided and still reads outside the CLI.
void _report(Map<String, Object?> event) =>
    // ignore: avoid_print — this *is* the protocol; see `stepMarker`.
    print('$stepMarker${jsonEncode(event)}');
