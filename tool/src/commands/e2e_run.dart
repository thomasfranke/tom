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
/// the one thing the two sides share. Deliberately not a word anyone would
/// type: a scenario that printed "step" in a label must not be able to drive
/// the progress bar.
const stepMarker = '⦙tom-e2e⦙';

/// Where a run of the whole suite has got to.
///
/// Carried into each scenario's screen so the header can say *2 of 6* and
/// how many have passed. Without it a suite reads as a stack of unrelated
/// runs, and the question someone actually has — *is this going well?* —
/// has to be answered by scrolling.
final class SuiteProgress {
  SuiteProgress(this.total) : _started = DateTime.now();

  /// How many scenarios the run holds.
  final int total;

  /// When the run was asked for.
  ///
  /// Here rather than in the screen, because the screen is thrown away
  /// between scenarios and this number is the whole wait: someone deciding
  /// whether to sit through the rest of the suite is asking how long it has
  /// been running, not how long this one file has.
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
///
/// One scenario at a time means one screen at a time: appending them leaves
/// the eye scrolling to find what is running now, and the finished ones say
/// nothing the summary will not say better.
void clearScreen() {
  if (stdout.hasTerminal) stdout.write('\x1B[2J\x1B[H');
}

/// Runs [scenario] and paints its progress until it is done.
///
/// One scenario at a time, which is not a limitation of the screen: each
/// file launches the app, and on macOS the next launch fails while the
/// previous window is still going. Running them one by one is also what the
/// menu asks for — someone picking a row wants that row.
Future<int> runScenario(
  Scenario scenario, {
  bool quiet = false,
  SuiteProgress? suite,
}) async {
  final screen = _ScenarioScreen(scenario, quiet: quiet, suite: suite)..start();
  _forget(scenario);

  final process = await Process.start('flutter', <String>[
    'test',
    '$scenarioDirectory/${scenario.file}'.replaceFirst('src/apps/desktop/', ''),
    '-d',
    'macos',
    '--plain-name',
    scenario.name,
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
  final log = _keep(scenario, transcript.toString());
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

/// Throws away what the last run of [scenario] left, before this one starts.
///
/// **A log outlives the run that wrote it, and that is how it lies.** The
/// transcript is written when the scenario ends, so a run killed during the
/// build — or one that never got that far — leaves the *previous* run's log
/// under the same name, with its events and its verdict intact. Two
/// scenarios in one file share the name too, so the survivor may not even be
/// the same scenario. Reading it then reports a pass that did not happen.
///
/// Deleting first costs nothing: a run that reaches the end writes its own,
/// and one that does not should leave no answer rather than an old one.
void _forget(Scenario scenario) {
  final file = File('${repoRoot().path}/${_logPath(scenario)}');
  if (file.existsSync()) file.deleteSync();
}

/// Where everything a scenario printed is kept, and its path.
///
/// **The screen shows the handful of lines worth reading; this is the rest.**
/// A run that fails on a machine is diagnosed by running it again, which is
/// three minutes and only works if it fails again — and the failures worth
/// keeping are exactly the ones that do not. So every run leaves its whole
/// transcript behind, overwritten by the next run of that scenario.
///
/// Gitignored, and beside the results rather than inside `.e2e/`: `prepare`
/// throws that folder away, and a log of what happened is not something
/// anything rebuilds.
String _keep(Scenario scenario, String transcript) {
  final path = _logPath(scenario);
  File('${repoRoot().path}/$path')
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(transcript);
  return path;
}

/// Where [scenario]'s transcript lives, relative to the repository.
///
/// Named after the *file*, so two scenarios declared together share it —
/// which is why [_forget] exists.
String _logPath(Scenario scenario) =>
    '$logDirectory/${scenario.file.replaceAll(RegExp(r'\.dart$'), '')}.log';

/// Where the transcripts go.
const logDirectory = '.e2e-logs';

/// Waits until the app the scenario opened is actually gone.
///
/// `flutter test` returns when the *test* finishes, which is not when the
/// window it opened has closed. The next scenario's build copies the app
/// bundle into place with `rsync`, and that fails while the old process is
/// still holding it:
///
/// ```
/// rsync(15409): error: rsync_receiver
/// Failed to package …/src/apps/desktop.
/// ** BUILD FAILED **
/// ```
///
/// — which arrives as a scenario reporting `0/0 steps`, having asserted
/// nothing at all. It is the whole reason a suite that passes one file at a
/// time can fail two of six when run end to end.
///
/// It waits and never kills. The pattern is this repository's own debug
/// bundle, so an installed TOM is not matched; a developer running *this*
/// build while the suite runs would be, and waiting for them is right —
/// their window breaks the same build.
Future<void> _waitForTheWindowToClose() async {
  // Anchored at the end, because the same path is a *substring* of what the
  // linker is doing: it writes `…/MacOS/TOM.debug.dylib`, and an unanchored
  // pattern waits for the compiler as well as for the app.
  final bundle =
      '${repoRoot().path.replaceAll('.', r'\.')}'
      '/src/apps/desktop/build/macos/Build/Products/'
      r'Debug/TOM\.app/Contents/MacOS/TOM([[:space:]]|$)';
  final deadline = DateTime.now().add(const Duration(seconds: 20));
  while (DateTime.now().isBefore(deadline)) {
    final running = await Process.run('pgrep', <String>['-f', bundle]);
    // pgrep exits non-zero when nothing matches, which is what is wanted.
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

/// Whether [line] is worth keeping to show after a failure.
///
/// The framework prints a great deal; what a person needs is the assertion
/// and the step it happened in, and those are the lines that say so.
///
/// The last three are not assertions at all — they are the app never
/// starting, which used to show as a scenario with `0/0 steps` and nothing
/// underneath it. A failure whose screen says nothing is read as a flake,
/// and this one is not: it is the previous window still holding the bundle.
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
/// Not a `Dashboard` subclass: that one paints a *row per target*, and this
/// paints one scenario in detail — a name, what it is for, where it is, and
/// how long it has taken.
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
  /// A repaint every second, and not for decoration: the longest silence in
  /// a run is the build, which reports nothing for half a minute. A clock
  /// that only moved when a step arrived would stop exactly where someone
  /// starts wondering whether anything is still happening.
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
    // Always, and not only when nothing was recognised: the lines above are
    // the ones worth reading, and this is where the rest of them went.
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

  /// The two lines above a scenario when it is one of many.
  ///
  /// Counts rather than a list: what is wanted here is whether the run is
  /// going well and how much is left, and a roll of finished names answers
  /// neither.
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
      // The header every other screen carries. This one paints its own,
      // because it cleared the terminal the CLI had drawn it on.
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
