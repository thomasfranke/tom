/// What a run leaves behind to look at: the frames the window composited.
library;

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Where the evidence of every scenario goes: one folder per scenario, every
/// run of it stamped.
const String evidenceDirectory = '.e2e-evidence';

/// The frames of one run, written as they happen.
///
/// Read back from the layer the window composited rather than off the
/// screen, so a frame holds the app whatever is in front of it. Runs
/// accumulate under a stamp, so the evidence of a failure survives the run
/// meant to reproduce it.
final class Evidence {
  /// Starts recording [scenario].
  Evidence(this.scenario, {required this.tester}) {
    directory.createSync(recursive: true);
  }

  /// The scenario being recorded, by the name it declares.
  final String scenario;

  /// What is driving the app, and what holds the render tree.
  final WidgetTester tester;

  /// How many frames have been written.
  int taken = 0;

  /// The step the next frames belong to, which is what names them.
  ///
  /// Set by the scenario rather than passed to every capture: the robot
  /// knows an action finished, the reader needs which named moment it was in.
  String step = 'start';

  /// When this run started, as every file it writes spells it.
  ///
  /// Handed in by the CLI so frames, video and log agree; a run straight
  /// through `flutter test` stamps itself.
  static final String stamp = _stampOf(
    const String.fromEnvironment('TOM_E2E_STAMP'),
  );

  /// Where this scenario's runs live.
  Directory get directory =>
      Directory('${_repositoryRoot()}/$evidenceDirectory/${slugOf(scenario)}');

  /// Writes what is on screen now, named after the [step] it is inside.
  ///
  /// Numbered in the order taken, because that order is the recording. It
  /// never fails a scenario: a frame that cannot be read is simply not there.
  Future<void> capture() async {
    taken++;
    // Three digits: the video is joined from a glob read alphabetically, and
    // `shot-100` sorts before `shot-99`.
    final String number = taken.toString().padLeft(3, '0');
    try {
      await _write(number).timeout(patience);
    } on Object {
      // Deliberately swallowed: evidence never fails a scenario.
    }
  }

  /// How long a frame is waited for before the run moves on without it.
  ///
  /// Reading a frame asks the rasterizer for one, and between two pumps the
  /// binding may give the engine none — the wait can be for something that
  /// is not coming.
  static const Duration patience = Duration(seconds: 2);

  /// The frame itself, written as `<stamp>-shot-<number>-<step>.png`.
  Future<void> _write(String number) async {
    final RenderView view = tester.binding.renderViews.first;
    final ui.Image image = await (view.debugLayer! as OffsetLayer).toImage(
      view.paintBounds,
    );
    final ByteData? png = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    image.dispose();
    if (png == null) {
      return;
    }
    File(
      '${directory.path}/$stamp-shot-$number-${slugOf(step)}.png',
    ).writeAsBytesSync(png.buffer.asUint8List());
  }

  /// [text] as a path: lowercase, everything else folded to a dash, because
  /// a step is a sentence and a sentence is a poor file name.
  static String slugOf(String text) => text
      .toLowerCase()
      .replaceAll(RegExp('[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');

  /// [given] when the CLI handed one over, and this machine's clock when not.
  ///
  /// To the second: [taken] restarts at one every run, so the stamp alone
  /// keeps two runs of one scenario apart.
  static String _stampOf(String given) {
    if (given.isNotEmpty) {
      return given;
    }
    final DateTime now = DateTime.now();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${now.year}-${two(now.month)}-${two(now.day)}'
        'T${two(now.hour)}-${two(now.minute)}-${two(now.second)}';
  }

  /// The repository root, found by searching upward for the environment.
  ///
  /// The working directory of a test run is the package's, and the CLI looks
  /// for these frames at the root (the same trap `fixture.dart` names).
  static String _repositoryRoot() {
    Directory directory = Directory.current;
    while (true) {
      if (Directory('${directory.path}/.e2e').existsSync()) {
        return directory.path;
      }
      final Directory parent = directory.parent;
      if (parent.path == directory.path) {
        return Directory.current.path;
      }
      directory = parent;
    }
  }
}
