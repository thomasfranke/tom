// Running one end-to-end scenario, and showing where it is while it runs.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../repo.dart';
import '../theme/theme.dart';
import 'e2e_catalogue.dart';

/// The marker the scenarios prefix their reports with.
///
/// It has to agree with `integration_test/support/scenario.dart`, and it is
/// not a word anyone would type, so a label saying "step" cannot drive the
/// progress bar.
const stepMarker = '⦙tom-e2e⦙';

/// Where a run of the whole suite has got to, carried into each scenario's
/// screen so the header can say *2 of 6* and how many have passed.
final class SuiteProgress {
  SuiteProgress(this.total) : _started = DateTime.now();

  /// How many scenarios the run holds.
  final int total;

  /// When the run was asked for.
  ///
  /// Here rather than in the screen, which is thrown away between scenarios:
  /// the question is how long the suite has been running, not this one file.
  final DateTime _started;

  /// How long the whole run has been going.
  Duration get elapsed => DateTime.now().difference(_started);

  /// Which one is running, counting from one.
  int index = 0;

  /// How many have finished.
  int passed = 0;
  int failed = 0;

  /// How far through, as a percentage of scenarios *finished*.
  int get percent =>
      total == 0 ? 0 : (((passed + failed) / total) * 100).round();
}

/// Clears the screen so the next scenario has all of it.
void clearScreen() {
  if (stdout.hasTerminal) stdout.write('\x1B[2J\x1B[H');
}

/// Runs [scenario] and paints its progress until it is done.
Future<int> runScenario(
  Scenario scenario, {
  bool quiet = false,
  SuiteProgress? suite,
  bool watch = false,
}) async {
  final screen = _ScenarioScreen(scenario, quiet: quiet, suite: suite)..start();
  // One stamp for the whole run, handed to the app, so the frames, the video
  // and the log carry the same one.
  final stamp = _stampNow();

  final process = await Process.start('flutter', <String>[
    'test',
    '$scenarioDirectory/${scenario.file}'.replaceFirst('src/apps/desktop/', ''),
    '-d',
    'macos',
    '--plain-name',
    scenario.name,
    // A define rather than a file the run reads: the value belongs to this
    // invocation, and the next one must not inherit it.
    if (watch) '--dart-define=TOM_E2E_HOLD_MS=$_holdWhileWatching',
    '--dart-define=TOM_E2E_STAMP=$stamp',
  ], workingDirectory: '${repoRoot().path}/src/apps/desktop');

  final errors = <String>[];
  final transcript = StringBuffer();
  final lines = <Stream<String>>[
    process.stdout.transform(utf8.decoder).transform(const LineSplitter()),
    process.stderr.transform(utf8.decoder).transform(const LineSplitter()),
  ];
  await Future.wait(<Future<void>>[
    for (final stream in lines)
      stream.forEach((line) {
        transcript.writeln(line);
        final report = _parse(line);
        if (report != null) {
          screen.apply(report);
        } else if (_looksLikeAFailure(line)) {
          errors.add(line.trim());
        }
      }),
  ]);

  final code = await process.exitCode;
  // The outcome is the last word of every file the run leaves; a negative
  // code means killed, not answered.
  final outcome = code == 0
      ? 'passed'
      : code < 0
      ? 'cancelled'
      : 'failed';
  final log = _keep(scenario, transcript.toString(), stamp, outcome);
  await _film(scenario, stamp, outcome);
  screen.finish(passed: code == 0, errors: errors, log: log);
  writeResult(
    scenario.name,
    ScenarioResult(
      passed: code == 0,
      when: DateTime.now().toUtc(),
      version: appVersion(),
      steps: screen.stepsDone,
      elapsed: screen.elapsed,
    ),
  );
  await _waitForTheWindowToClose();
  return code;
}

/// Joins the frames a scenario left into a video, two a second.
///
/// The frames are the evidence and the video a convenience: ffmpeg is not
/// something this repository asks anybody to install.
Future<void> _film(Scenario scenario, String stamp, String outcome) async {
  final directory = Directory(
    '${repoRoot().path}/$evidenceDirectory/${_slug(scenario.name)}',
  );
  if (!directory.existsSync()) return;
  // This run's frames and not the folder's: runs accumulate here.
  final frames = directory
      .listSync()
      .whereType<File>()
      .where((file) => file.uri.pathSegments.last.startsWith('$stamp-shot-'))
      .toList();
  if (frames.length < 2) return;

  final video = '${directory.path}/$stamp-$outcome.mp4';
  try {
    await Process.run('ffmpeg', <String>[
      '-y',
      '-framerate',
      '2',
      '-pattern_type',
      'glob',
      '-i',
      '${directory.path}/$stamp-shot-*.png',
      '-c:v',
      'libx264',
      // h264 refuses an odd width, and a window is whatever size the scenario
      // asked for.
      '-vf',
      'pad=ceil(iw/2)*2:ceil(ih/2)*2',
      '-pix_fmt',
      'yuv420p',
      video,
    ]);
  } on ProcessException {
    // No ffmpeg on this machine; the frames are still there.
  }
}

/// [name] as a path, the way `integration_test/support/evidence.dart` spells
/// it: the app writes the folder and this reads it.
String _slug(String name) => name
    .toLowerCase()
    .replaceAll(RegExp('[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-|-$'), '');

/// Where the app writes what it photographed.
const evidenceDirectory = '.e2e-evidence';

/// How long `--watch` holds the screen after each action, in milliseconds.
///
/// Not a setting: a number somebody can tune is a number nobody agrees on.
const _holdWhileWatching = 700;

/// Keeps everything a scenario printed, and answers its path.
///
/// The screen shows the handful of lines worth reading; this is the rest, for
/// a failure that does not happen again when the run is repeated. Beside the
/// frames rather than inside `.e2e/`, which `prepare` throws away.
String _keep(
  Scenario scenario,
  String transcript,
  String stamp,
  String outcome,
) {
  final path = _logPath(scenario, stamp, outcome);
  File('${repoRoot().path}/$path')
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(transcript);
  return path;
}

/// Where [scenario]'s transcript lives, relative to the repository: beside
/// the frames of the same run, named after the scenario rather than the file
/// two of them share, with the stamp keeping runs apart and the outcome
/// readable from a listing.
String _logPath(Scenario scenario, String stamp, String outcome) =>
    '$evidenceDirectory/${_slug(scenario.name)}/$stamp-$outcome.log';

/// When a run started, to the second, as every file it writes spells it.
///
/// To the second because the stamp is all that keeps two runs apart: the
/// frame counter restarts every run, so two runs in one minute would overwrite
/// each other's frames and be filmed as one. It has to agree with
/// `integration_test/support/evidence.dart`, which stamps itself the same way.
String _stampNow() {
  final now = DateTime.now();
  String two(int value) => value.toString().padLeft(2, '0');
  return '${now.year}-${two(now.month)}-${two(now.day)}'
      'T${two(now.hour)}-${two(now.minute)}-${two(now.second)}';
}

/// Waits until the app the scenario opened is actually gone.
///
/// `flutter test` returns when the test finishes, not when the window closes,
/// and the next scenario's build copies the bundle with `rsync`, which fails
/// while the old process still holds it — a scenario reporting `0/0 steps`
/// having asserted nothing. It waits and never kills: the pattern is this
/// repository's own debug bundle, and a developer's window breaks the same
/// build.
Future<void> _waitForTheWindowToClose() async {
  // Anchored at the end: the linker writes `…/MacOS/TOM.debug.dylib`, and an
  // unanchored pattern would wait for the compiler as well as the app.
  final bundle =
      '${repoRoot().path.replaceAll('.', r'\.')}'
      '/src/apps/desktop/build/macos/Build/Products/'
      r'Debug/TOM\.app/Contents/MacOS/TOM([[:space:]]|$)';
  final deadline = DateTime.now().add(const Duration(seconds: 20));
  while (DateTime.now().isBefore(deadline)) {
    final running = await Process.run('pgrep', <String>['-f', bundle]);
    // pgrep exits non-zero when nothing matches.
    if (running.exitCode != 0) return;
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}

/// One report from a running scenario, or null for anything else.
Map<String, Object?>? _parse(String line) {
  final at = line.indexOf(stepMarker);
  if (at < 0) return null;
  try {
    final decoded = jsonDecode(line.substring(at + stepMarker.length));
    return decoded is Map<String, Object?> ? decoded : null;
  } on FormatException {
    return null;
  }
}

/// Whether [line] is worth showing after a failure: the assertion, the step
/// it happened in, or the app never starting.
///
/// The build lines matter because a scenario with `0/0 steps` and nothing
/// under it reads as a flake, and it is not (see [_waitForTheWindowToClose]).
bool _looksLikeAFailure(String line) =>
    line.contains('Expected:') ||
    line.contains('Actual:') ||
    line.startsWith('step ') ||
    line.contains('Unable to start the app') ||
    line.contains('BUILD FAILED') ||
    line.contains('Failed to package') ||
    line.contains('Build process failed');

/// The block repainted while a scenario runs.
///
/// Not a `Dashboard` subclass: that paints a row per target, and this paints
/// one scenario in detail.
final class _ScenarioScreen {
  _ScenarioScreen(this.scenario, {required this.quiet, this.suite})
    : _started = DateTime.now();

  final Scenario scenario;
  final bool quiet;

  /// Where the whole run has got to, when there is a whole run.
  final SuiteProgress? suite;
  final DateTime _started;

  int _total = 0;
  int _done = 0;
  String _step = 'starting the app…';
  bool _finished = false;
  bool _passed = false;
  int _drawn = 0;
  Timer? _ticker;

  /// Paints the first frame and keeps the clocks moving.
  ///
  /// A repaint every second, because the build reports nothing for half a
  /// minute and a clock that stopped there would look like a hang.
  void start() {
    paint();
    if (quiet || !stdout.hasTerminal) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => paint());
  }

  /// How many steps ran.
  int get stepsDone => _done;

  /// How long it has taken.
  Duration get elapsed => DateTime.now().difference(_started);

  /// Folds one report into what is on screen.
  void apply(Map<String, Object?> report) {
    switch (report['event']) {
      case 'begin':
        _total = report['steps'] as int? ?? 0;
      case 'step':
        _done = (report['index'] as int? ?? 1) - 1;
        _step = report['name'] as String? ?? '';
      case 'failed':
        _step = report['name'] as String? ?? '';
      case 'finished':
        _done = report['steps'] as int? ?? _done;
        _step = 'done';
    }
    paint();
  }

  /// Paints the last frame, and says what went wrong if anything did.
  void finish({
    required bool passed,
    required List<String> errors,
    required String log,
  }) {
    _ticker?.cancel();
    _finished = true;
    _passed = passed;
    if (passed) {
      _done = _total;
      _step = 'done';
    }
    paint();
    if (passed || quiet) return;
    stdout.writeln();
    for (final line in errors.take(8)) {
      stdout.writeln('  ${palette.detail}$line${Ansi.reset}');
    }
    // Always, not only when nothing was recognised: this is where the rest
    // of the output went.
    stdout.writeln('  ${palette.detail}Full output: $log${Ansi.reset}');
  }

  /// Repaints the block where it stands.
  void paint() {
    if (quiet) return;
    if (!stdout.hasTerminal) {
      // Append-only, so a log of a CI run still reads as a sequence.
      if (_finished) {
        stdout.writeln(
          '  ${_passed ? '✓' : '✘'} ${scenario.name} — $_done/$_total steps',
        );
      }
      return;
    }
    _rewind();
    final lines = _compose();
    stdout.write(lines.join('\n'));
    stdout.writeln();
    _drawn = lines.length;
  }

  void _rewind() {
    if (_drawn == 0) return;
    stdout.write('\x1B[${_drawn}A\x1B[0J');
  }

  List<String> _compose() {
    final mark = _finished
        ? (_passed ? '${palette.ok}✓' : '${palette.fail}✘')
        : '${palette.running}▸';
    final state = _finished ? (_passed ? 'finished' : 'failed') : 'running';
    final percent = _total == 0 ? 0 : ((_done / _total) * 100).round();
    return <String>[
      ..._suiteHeader(),
      '',
      '  ${palette.detail}${scenario.group}${Ansi.reset}',
      '',
      '  Test: ${palette.title}${scenario.name}${Ansi.reset}',
      ..._wrapped(scenario.describe),
      '',
      '  $mark $state${Ansi.reset}  ${palette.detail}·${Ansi.reset}  '
          '${scenario.file}',
      '',
      '  ${_bar(percent)}  ${palette.detail}$percent%  $_done/$_total steps · '
          '${_clock(elapsed)}${Ansi.reset}',
      '',
      '  ${palette.detail}$_step${Ansi.reset}',
      '',
    ];
  }

  /// The lines above a scenario when it is one of many: counts, because the
  /// question is whether the run is going well and how much is left.
  List<String> _suiteHeader() {
    final progress = suite;
    if (progress == null) return const <String>[];
    final passed = progress.passed == 0
        ? ''
        : '  ${palette.ok}\u2713 ${progress.passed}${Ansi.reset}';
    final failed = progress.failed == 0
        ? ''
        : '  ${palette.fail}\u2718 ${progress.failed}${Ansi.reset}';
    return <String>[
      // The header every other screen carries, painted here because this one
      // cleared the terminal the CLI had drawn it on.
      '${palette.title}${Layout.appTitle}${Ansi.reset} '
          '${palette.titleSuffix}${Layout.titleSeparator} '
          '${Layout.appSubtitle}${Ansi.reset}',
      '',
      '  ${palette.section}End-to-end${Ansi.reset}  ${palette.detail}'
          '\u00b7  ${progress.index}/${progress.total}  '
          '\u00b7  ${_clock(progress.elapsed)}${Ansi.reset}',
      '',
      '  ${_bar(progress.percent)}  ${palette.detail}${progress.percent}%'
          '${Ansi.reset}$passed$failed',
      '',
      '  ${palette.rule}${'\u2500' * 40}${Ansi.reset}',
    ];
  }

  /// The bar, drawn as a filled block so it reads at a glance.
  String _bar(int percent) {
    const width = 24;
    final filled = (width * percent / 100).round().clamp(0, width);
    return '${palette.prompt}${'█' * filled}${Ansi.reset}'
        '${palette.detail}${'░' * (width - filled)}${Ansi.reset}';
  }

  /// `03:03`, which is how long a person reads a stopwatch as.
  String _clock(Duration d) =>
      '${d.inMinutes.toString().padLeft(2, '0')}:'
      '${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  /// [text] folded to the width the screen uses, indented under the name.
  List<String> _wrapped(String text, {int width = 64}) {
    if (text.isEmpty) return const <String>[];
    final words = text.split(' ');
    final lines = <String>[];
    var line = StringBuffer();
    for (final word in words) {
      if (line.length + word.length + 1 > width) {
        lines.add(line.toString());
        line = StringBuffer();
      }
      if (line.isNotEmpty) line.write(' ');
      line.write(word);
    }
    if (line.isNotEmpty) lines.add(line.toString());
    return <String>[
      for (final line in lines) '      ${palette.detail}$line${Ansi.reset}',
    ];
  }
}
