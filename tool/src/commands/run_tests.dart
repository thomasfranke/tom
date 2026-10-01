// A live test dashboard, one line per package with its own progress bar,
// driven by package:test's `--reporter=json` protocol.
//
//   dart run tool/src/commands/run_tests.dart [--coverage] <target>...
//
// What a target can be is `_resolve`'s to say.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../cli/dashboard.dart';
import '../repo.dart';
import '../theme/theme.dart';
import '../tty.dart';
import 'process.dart';

const _pkgOrder = [
  'core',
  'domain',
  'application',
  'infra',
  'data',
  'presentation',
  'ui',
];

const _apps = ['desktop', 'mobile'];

// Lives under packages/ and still needs `flutter test`: it draws
// (Decision 26). Where a target lives and what runs it are two questions.
const _drawnPackages = ['ui'];

void main(List<String> rawArgs) async {
  final coverage = rawArgs.contains('--coverage');
  // Set by run_changed_tests.dart, which has already shown its own banner.
  final noBanner = rawArgs.contains('--no-banner');
  final args = rawArgs
      .where((a) => a != '--coverage' && a != '--no-banner')
      .toList();
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run tool/src/commands/run_tests.dart [--coverage] <pkg>...',
    );
    exit(64);
  }

  final root = repoRoot();
  final src = Directory('${root.path}/src');
  final targets = args.map((a) => _resolve(src, a)).toList();
  final rows = [
    for (final t in targets)
      _Row(t.label, hasTests: _hasTests(t), fileTotal: _testFileCount(t)),
  ];
  for (final row in rows) {
    if (!row.hasTests) row.state = _RowState.skipped;
  }

  if (!noBanner) await _showCompiling();

  final dashboard = _Dashboard(rows, DateTime.now());
  dashboard.render();
  // No ticker without a terminal: its only job is to advance a clock in place,
  // and in a log it would print the same frame four times a second.
  final ticker = isPlain
      ? null
      : Timer.periodic(
          const Duration(milliseconds: 250),
          (_) => dashboard.render(),
        );

  var overallFail = false;
  for (var i = 0; i < targets.length; i++) {
    final row = rows[i];
    if (!row.hasTests) continue;
    row.state = _RowState.running;
    row.startedAt = DateTime.now();
    dashboard.render();
    final ok = await _runOne(targets[i], row, dashboard, coverage: coverage);
    row.state = _RowState.done;
    row.elapsed = DateTime.now().difference(row.startedAt!);
    if (!ok) overallFail = true;
    dashboard.render();
  }

  ticker?.cancel();
  dashboard.render();

  final totalPassed = rows.fold(0, (a, r) => a + r.passed);
  final totalTests = totalPassed + rows.fold(0, (a, r) => a + r.failed);
  final covHit = rows.fold(0, (a, r) => a + (r.coverageHit ?? 0));
  final covTotal = rows.fold(0, (a, r) => a + (r.coverageTotal ?? 0));
  final totalElapsed = formatDuration(
    DateTime.now().difference(dashboard.started),
  );

  stdout.writeln();
  stdout.writeln('  • Summary:');
  stdout.writeln('    • $totalPassed/$totalTests');
  stdout.writeln('    • ⏱ $totalElapsed');
  if (covTotal > 0) {
    stdout.writeln('    • ◔ ${(covHit / covTotal * 100).round()}%');
  }

  if (dashboard.failures.isNotEmpty) {
    final counts = <String, int>{};
    for (final f in dashboard.failures) {
      counts[f] = (counts[f] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        return byCount != 0 ? byCount : a.key.compareTo(b.key);
      });
    stdout.writeln();
    stdout.writeln('${palette.fail}${Status.fail}${Ansi.reset} Failed files:');
    for (final e in sorted) {
      stdout.writeln('  ${e.value}  ${e.key}');
    }
  }

  exit(overallFail ? 1 : 0);
}

class _Target {
  _Target(this.label, this.dir, this.command, this.extraArgs);
  final String label;
  final Directory dir;
  final String command; // "dart" or "flutter"
  final List<String> extraArgs;

  /// The program to spawn for [command].
  ///
  /// The field stays the plain name because coverage is collected one way
  /// under `dart` and another under `flutter`; what runs is [dartExecutable].
  String get executable => command == 'dart' ? dartExecutable : command;
}

/// One argument as a target: a bare name — a package, `desktop`, `mobile`,
/// `arch` or `cli` — runs the whole `test/` tree, and `pkg=file1,file2` runs
/// only those paths, relative to the package, which is the form
/// run_changed_tests.dart hands off.
_Target _resolve(Directory src, String spec) {
  final eq = spec.indexOf('=');
  final pkg = eq < 0 ? spec : spec.substring(0, eq);
  final files = eq < 0
      ? const <String>[]
      : spec.substring(eq + 1).split(',').where((f) => f.isNotEmpty).toList();

  switch (pkg) {
    case 'arch':
      return _Target(
        'architecture',
        src,
        'dart',
        files.isNotEmpty ? files : ['test/integrity/architecture_test.dart'],
      );
    // Like `arch`, a folder under src/test/ rather than a package: tool/ has
    // no pubspec, so its tests cannot live beside it (`runCliTests`).
    case 'cli':
      return _Target(
        'cli',
        src,
        'dart',
        files.isNotEmpty ? files : ['test/cli'],
      );
    default:
      if (_apps.contains(pkg)) {
        return _Target(
          pkg,
          Directory('${src.path}/apps/$pkg'),
          'flutter',
          files,
        );
      }
      if (!_pkgOrder.contains(pkg)) {
        stderr.writeln(
          "Unknown package '$pkg'. Available: ${_pkgOrder.join(', ')}, "
          "${_apps.join(', ')}, arch, cli",
        );
        exit(64);
      }
      return _Target(
        pkg,
        Directory('${src.path}/packages/$pkg'),
        _drawnPackages.contains(pkg) ? 'flutter' : 'dart',
        files,
      );
  }
}

/// How many `_test.dart` files [target] will run: a listed file is one, a
/// listed folder is walked, an unnarrowed target is its whole `test/`.
int _testFileCount(_Target target) {
  final roots = target.extraArgs.isEmpty ? const ['test'] : target.extraArgs;

  var count = 0;
  for (final root in roots) {
    final path = '${target.dir.path}/$root';
    if (File(path).existsSync()) {
      count++;
      continue;
    }
    final directory = Directory(path);
    if (!directory.existsSync()) continue;
    count += directory
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('_test.dart'))
        .length;
  }
  return count;
}

bool _hasTests(_Target target) {
  if (target.extraArgs.isNotEmpty) {
    // A directory counts as much as a file: `pkg=test/unit` narrows a run to
    // one kind, and a package with no such folder is skipped, not failed.
    return target.extraArgs.every(
      (f) =>
          File('${target.dir.path}/$f').existsSync() ||
          Directory('${target.dir.path}/$f').existsSync(),
    );
  }
  final testDir = Directory('${target.dir.path}/test');
  return testDir.existsSync() &&
      testDir
          .listSync(recursive: true)
          .whereType<File>()
          .any((f) => f.path.endsWith('_test.dart'));
}

/// A live "compiling" ticker over the setup, so the terminal is not silent.
///
/// The floor delay keeps it on screen for a beat when setup is instant.
Future<void> _showCompiling() async {
  stdout.writeln('• Running build hooks...');

  // Nobody watches a log, so in plain mode the line above is the whole banner.
  if (isPlain) return;

  stdout.writeln();
  final start = DateTime.now();
  void redraw() {
    final d = DateTime.now().difference(start);
    final mm = d.inMinutes.toString().padLeft(2, '0');
    final ss = (d.inSeconds % 60).toString().padLeft(2, '0');
    stdout.write('\r\x1B[K⏳ compiling…  $mm:$ss');
  }

  redraw();
  final ticker = Timer.periodic(const Duration(seconds: 1), (_) => redraw());
  await Future<void>.delayed(const Duration(milliseconds: 300));
  ticker.cancel();
  stdout.write('\r\x1B[K');
}

enum _RowState { queued, skipped, running, done }

/// One line of the fixed dashboard, mutated in place as its package's test
/// run progresses.
class _Row {
  _Row(this.label, {required this.hasTests, required this.fileTotal});
  final String label;
  final bool hasTests;

  /// How many test files this package will run, counted from disk.
  ///
  /// Not from package:test's events: it parses suites lazily, so a total
  /// taken from the protocol arrives in instalments and the bar walks
  /// backwards.
  final int fileTotal;

  _RowState state = _RowState.queued;
  DateTime? startedAt;
  Duration? elapsed;

  /// Test files finished, every test in them accounted for.
  ///
  /// Exact, from the root group's test count: "every test started has
  /// finished" is true between any two tests of a sequential file.
  int filesDone = 0;

  int passed = 0;
  int failed = 0;

  /// Set while the tests are over and `format_coverage` is still running,
  /// so the row does not read as a run that finished and hung.
  bool measuringCoverage = false;

  int? coverageHit;
  int? coverageTotal;
  double? get coverage => coverageTotal != null && coverageTotal! > 0
      ? coverageHit! / coverageTotal! * 100
      : null;
}

/// Runs one package's tests, streaming its `--reporter=json` events into
/// [row]; false when the suite failed. Coverage is collected only for a
/// target with a lib/ to instrument.
Future<bool> _runOne(
  _Target target,
  _Row row,
  _Dashboard dashboard, {
  required bool coverage,
}) async {
  final wantCoverage =
      coverage && Directory('${target.dir.path}/lib').existsSync();
  final passthrough = Platform.environment['TEST_ARGS'];
  final process = await Process.start(target.executable, [
    'test',
    '--reporter=json',
    if (wantCoverage && target.command == 'dart') '--coverage=coverage',
    if (wantCoverage && target.command == 'flutter') '--coverage',
    ...target.extraArgs,
    if (passthrough != null && passthrough.isNotEmpty)
      ...passthrough.split(' '),
  ], workingDirectory: target.dir.path);

  final stderrBuf = StringBuffer();
  process.stderr.transform(utf8.decoder).listen(stderrBuf.write);

  final suitePath = <int, String>{};
  final testSuite = <int, int>{};

  // How many tests each file holds, and how many have come back — the pair
  // that says when a file is actually done.
  final suiteTests = <int, int>{};
  final suiteFinished = <int, int>{};
  final suiteComplete = <int>{};
  final testName = <int, String>{};
  final testError = <int, String>{};

  await process.stdout
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .forEach((line) {
        if (line.trim().isEmpty) return;

        // A line that is not an event is skipped rather than fatal: the runner
        // occasionally prints something that is not JSON. Typed rather than a
        // bare catch, so a bug in the handling below is not swallowed too.
        final Object? decoded;
        try {
          decoded = jsonDecode(line);
        } on FormatException {
          return;
        }
        if (decoded is! Map<String, dynamic>) return;
        final event = decoded;

        switch (event['type']) {
          case 'group':
            // Only the root group counts every test in the file; nested groups
            // count their share of the same tests and would multiply the total.
            final group = event['group'] as Map<String, dynamic>;
            if (group['parentID'] == null) {
              suiteTests[group['suiteID'] as int] =
                  group['testCount'] as int? ?? 0;
            }
          case 'suite':
            final suite = event['suite'] as Map<String, dynamic>;
            suitePath[suite['id'] as int] = suite['path'] as String;
          case 'testStart':
            final test = event['test'] as Map<String, dynamic>;
            final id = test['id'] as int;
            final suiteId = test['suiteID'] as int;
            testSuite[id] = suiteId;
            testName[id] = test['name'] as String? ?? 'test';
          case 'error':
            final id = event['testID'] as int?;
            if (id != null) {
              testError[id] = (event['error'] as String? ?? '')
                  .split('\n')
                  .first;
            }
          case 'testDone':
            final id = event['testID'] as int;
            final result = event['result'] as String;
            final hidden = event['hidden'] as bool? ?? false;
            final skipped = event['skipped'] as bool? ?? false;
            final suiteId = testSuite[id];

            // The hidden test package:test emits for loading a file is not in
            // the root group's count.
            if (suiteId != null && !hidden) {
              suiteFinished[suiteId] = (suiteFinished[suiteId] ?? 0) + 1;
              final total = suiteTests[suiteId];
              if (total != null && suiteFinished[suiteId]! >= total) {
                suiteComplete.add(suiteId);
                row.filesDone = suiteComplete.length;
              }
            }

            if (skipped || hidden || result == 'success') {
              if (!hidden) row.passed++;
            } else {
              row.failed++;
              final path = suiteId != null ? (suitePath[suiteId] ?? '?') : '?';
              dashboard.logFailure(
                row.label,
                path,
                testName[id] ?? 'test',
                testError[id],
              );
            }
        }
        dashboard.render();
      });

  final exitCode = await process.exitCode;
  if (exitCode != 0 && stderrBuf.isNotEmpty) {
    dashboard.log(stderrBuf.toString().trim());
  }

  if (wantCoverage) {
    row.measuringCoverage = true;
    dashboard.render();
    final cov = await _collectCoverage(target);
    row.coverageHit = cov?.hit;
    row.coverageTotal = cov?.total;
    row.measuringCoverage = false;
    dashboard.render();
  }

  return exitCode == 0;
}

/// The lcov for [target], parsed: `flutter test --coverage` writes it, while
/// `dart test --coverage` dumps raw JSON that `format_coverage` still has to
/// turn into one. Generated files are ignored for the reason
/// coverage_gate.dart gives on `generatedFileGlobs`.
Future<({int hit, int total})?> _collectCoverage(_Target target) async {
  if (target.command == 'dart') {
    final result = await Process.run(dartExecutable, [
      'run',
      'coverage:format_coverage',
      '--lcov',
      '--in=coverage',
      '--out=coverage/lcov.info',
      '--report-on=lib',
      '--ignore-files=**.freezed.dart,**.g.dart',
    ], workingDirectory: target.dir.path);
    if (result.exitCode != 0) return null;
  }
  final lcov = File('${target.dir.path}/coverage/lcov.info');
  if (!lcov.existsSync()) return null;
  return _parseLcov(lcov);
}

({int hit, int total})? _parseLcov(File lcov) {
  var hit = 0, total = 0;
  for (final line in lcov.readAsLinesSync()) {
    if (!line.startsWith('DA:')) continue;
    total++;
    final count = int.tryParse(line.substring(3).split(',').last) ?? 0;
    if (count > 0) hit++;
  }
  return total > 0 ? (hit: hit, total: total) : null;
}

/// Redraws a fixed block — a header plus one row per package — in place,
/// making room above it for failures printed live via [logFailure]/[log].
class _Dashboard extends Dashboard<_Row> {
  _Dashboard(super.rows, super.started);

  final List<String> failures = [];

  @override
  String labelOf(_Row row) => row.label;

  @override
  bool isSettled(_Row row) =>
      row.state == _RowState.done || row.state == _RowState.skipped;

  /// Files finished over files to run — the pair the bar is drawn from.
  String _fileCounts(_Row row) => '${row.filesDone}/${row.fileTotal}';

  /// Tests passed over tests run.
  String _testCounts(_Row row) => '${row.passed}/${row.passed + row.failed}';

  /// How wide the files column will ever need to be, known before anything
  /// runs.
  ///
  /// In a log each row is printed once as it settles, so a width measured
  /// over the rows finished so far would leave the column ragged for good.
  late final int _filesWidth = rows
      .map((row) => '${row.fileTotal}/${row.fileTotal}'.length)
      .fold(0, (a, b) => a > b ? a : b);

  /// How wide the tests column has to be for the rows that have settled,
  /// re-measured on every paint because nothing says up front how many tests
  /// a file holds.
  int get _testsWidth => rows
      .where((row) => row.state == _RowState.done)
      .map((row) => _testCounts(row).length)
      .fold(0, (a, b) => a > b ? a : b);

  void logFailure(String pkg, String path, String name, String? error) {
    final file = '$pkg — $path';
    failures.add(file);
    final buf = StringBuffer()
      ..writeln('  ${palette.fail}${Status.fail}${Ansi.reset}  $file')
      ..writeln('     $name');
    if (error != null && error.isNotEmpty) buf.writeln('     $error');
    log(buf.toString().trimRight());
  }

  // Stays "Running tests" even once everything is done — "Summary" is the
  // one below, with the totals; switching this one too would print it twice.
  @override
  String header() {
    final doneRows = rows.where(
      (r) => r.state == _RowState.done || r.state == _RowState.skipped,
    );
    final doneCount = doneRows.length;

    if (doneCount == rows.length) {
      // No elapsed time here — the Summary block below already has it.
      return '• Running tests — $doneCount/${rows.length} packages:';
    }

    // ETA rather than elapsed, extrapolated from the packages that finished;
    // a package at "no tests yet" is instant and would drag the average down.
    final timed = doneRows.where(
      (r) => r.state == _RowState.done && r.elapsed != null,
    );
    if (timed.isEmpty) {
      return '• Running tests — $doneCount/${rows.length} packages, estimating…:';
    }

    final avgMs =
        timed.fold<int>(0, (a, r) => a + r.elapsed!.inMilliseconds) /
        timed.length;
    final remaining = rows.length - doneCount;

    _Row? running;
    for (final r in rows) {
      if (r.state == _RowState.running) {
        running = r;
        break;
      }
    }
    final runningMs = running?.startedAt != null
        ? DateTime.now().difference(running!.startedAt!).inMilliseconds
        : 0;

    final etaMs = (avgMs * remaining - runningMs).clamp(0.0, avgMs * remaining);
    final eta = formatDuration(Duration(milliseconds: etaMs.round()));
    return '• Running tests — $doneCount/${rows.length} packages, ~$eta remaining:';
  }

  @override
  String renderRow(_Row row) {
    final label = row.label.padRight(labelWidth);
    switch (row.state) {
      case _RowState.skipped:
        return '${statusMark(Status.skipped, palette.skipped)}$label  '
            'no tests yet';
      case _RowState.queued:
        return '${statusMark(Status.queued, palette.queued)}$label  '
            '${progressBar(0, 0)}';
      case _RowState.running:
        final elapsed = formatDuration(
          DateTime.now().difference(row.startedAt!),
        );
        final progress = row.measuringCoverage
            ? 'measuring coverage…'
            : '${_fileCounts(row)} files';
        return '${statusMark(Status.running, palette.running)}$label  '
            '${progressBar(row.filesDone, row.fileTotal)} '
            '$progress  •  +${row.passed} ✗${row.failed}  '
            '•  ⏱ $elapsed';
      case _RowState.done:
        final elapsed = formatDuration(row.elapsed ?? Duration.zero);
        // Both counts, in the order and unit shown while it ran; a file short
        // of its total is how a suite that failed to load shows up at all.
        final files = _fileCounts(row).padRight(_filesWidth);
        final tests = _testCounts(row).padRight(_testsWidth);
        final mark = row.failed == 0
            ? statusMark(Status.ok, palette.ok)
            : statusMark(Status.fail, palette.fail);
        final cov = row.coverage != null ? '◔ ${row.coverage!.round()}%  ' : '';
        return '$mark$label  ${progressBar(row.filesDone, row.fileTotal)} '
            '$files files  •  $tests tests  $cov⏱ $elapsed';
    }
  }
}
