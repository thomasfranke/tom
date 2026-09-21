// A live test dashboard: one fixed line per package, each with its own
// progress bar, driven by package:test's `--reporter=json` protocol.
//
//   dart run tool/src/commands/run_tests.dart [--coverage] <target>...
//
// <target> is either a bare package name — a folder under src/packages/,
// "desktop" or "mobile" for the Flutter apps, or "arch" for the architecture
// graph test
// (src/test/integrity/) — in which case its whole test/ tree runs, or
// `pkg=file1,file2` to run only those test files (paths relative to the
// package's own directory). tool/run_changed_tests.dart is what emits the
// latter form. Pass `--coverage` to also instrument each package's run and
// report its line coverage percentage once it finishes — skipped for any
// target with no lib/ (namely "arch", which has no package of its own to
// instrument).
//
// Why a JSON consumer rather than piping `-r expanded` straight through:
// the default reporter tells you about one test at a time, in one package at
// a time, with no sense of how many files or packages remain. This one reads
// the same event stream `dart test` already emits and redraws a fixed block —
// one row per package, each carrying its own "3/9 files" progress bar — in
// place, with every failure printed above the block the instant it happens
// rather than scrolled past waiting for the run to end.
//
// Status is one circled glyph per row (see Status in the theme), coloured by
// the palette rather than by the character — read at a glance down the
// column, and one terminal cell wide, which an emoji is not.
//
// No external packages — only dart:io and dart:convert — so it runs with
// nothing but the SDK already on the machine, from any directory.

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
];

const _apps = ['desktop', 'mobile'];

void main(List<String> rawArgs) async {
  final coverage = rawArgs.contains('--coverage');
  // Set by tool/run_changed_tests.dart, which shows its own banner before
  // doing the (slower, on a big diff) work of mapping changed files to
  // tests — showing this one too would just repeat it after the fact.
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

  /// The program to actually spawn for [command].
  ///
  /// The field stays the plain name because the rest of this script branches
  /// on it — coverage is collected one way under `dart` and another under
  /// `flutter` — while what gets executed resolves to the SDK running this
  /// script. See [dartExecutable] for why the two are not the same thing.
  String get executable => command == 'dart' ? dartExecutable : command;
}

/// Parses one CLI arg: either a bare package name (the whole test/ tree runs)
/// or `pkg=file1,file2` — comma-separated test file paths, relative to that
/// package's own directory, to run instead of the whole tree. The latter is
/// how tool/run_changed_tests.dart hands off exactly the tests a diff maps to.
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
    // Like `arch`, a folder under src/test/ rather than a package: the CLI
    // lives in tool/, outside the workspace, so its tests cannot live beside
    // it. See src/test/cli/cli_test.dart for why.
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
        'dart',
        files,
      );
  }
}

// The repository root used to be counted in levels from this file. It is
// found by marker now (see ../repo.dart), because counting is what broke when
// this script moved into tool/src/commands/.

/// How many `_test.dart` files [target] will run.
///
/// The same three cases [_hasTests] already distinguishes, counted rather
/// than merely detected: an explicit list of files is its own length, a
/// narrowed kind is a folder to walk, and an unnarrowed target is its whole
/// `test/` tree.
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
    // A directory counts as much as a file: `pkg=test/unit` is how a run
    // narrowed to one kind of test is expressed, and a package that has no
    // such folder is reported as skipped rather than failing the run — "no
    // e2e tests here yet" is information, not an error.
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

/// A brief banner shown before the dashboard takes over, covering setup
/// (target resolution, the test/ scans `_hasTests` does) with a live
/// "compiling" ticker instead of a silent terminal. The floor delay keeps it
/// visible for a beat even when that setup is instant — otherwise it would
/// flash and vanish, which reads as nothing having happened at all.
Future<void> _showCompiling() async {
  stdout.writeln('• Running build hooks...');

  // The banner exists to fill a silence someone is watching. Nobody watches a
  // log, so in plain mode the line above is the whole banner — no clock, and
  // no floor delay to make it linger.
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
/// run progresses. `suiteTotal` arrives from the `allSuites` event, so it
/// stays 0 — an indeterminate bar — until package:test has parsed the suite.
class _Row {
  _Row(this.label, {required this.hasTests, required this.fileTotal});
  final String label;
  final bool hasTests;

  /// How many test files this package will run, counted from disk before
  /// the first one loads.
  ///
  /// From the filesystem rather than from package:test's events, because
  /// it parses suites lazily: a total taken from the protocol arrives in
  /// instalments while the bar is already moving, and a bar whose
  /// denominator grows walks backwards. A `_test.dart` file is a suite, and
  /// counting them is something this side can do up front.
  final int fileTotal;

  _RowState state = _RowState.queued;
  DateTime? startedAt;
  Duration? elapsed;

  /// Test files finished — every test in them accounted for.
  ///
  /// Exact, not a guess. The protocol's root group says how many tests a file
  /// holds, so a file is done when that many have come back. The heuristic
  /// this replaced completed a file as soon as every test it had *started*
  /// had finished, which is true between any two tests of a sequential file —
  /// so a file was done after its first test, and the bar sat at `4/4` for
  /// the rest of the run.
  int filesDone = 0;

  int passed = 0;
  int failed = 0;

  /// Set while the tests are over and `format_coverage` is still running.
  ///
  /// Without it the row sits at a full bar, marked running, for as long as
  /// that takes — which reads as a run that finished and hung rather than as
  /// the measuring step it is.
  bool measuringCoverage = false;

  int? coverageHit;
  int? coverageTotal;
  double? get coverage => coverageTotal != null && coverageTotal! > 0
      ? coverageHit! / coverageTotal! * 100
      : null;
}

/// Runs one package's tests, streaming its `--reporter=json` output into
/// `row` and letting `dashboard` redraw after every event. Returns false if
/// the suite failed. With `coverage: true`, and only for targets that have a
/// lib/ to instrument, also collects `row.coverage` once the run succeeds.
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

        // A line that is not an event is skipped rather than fatal: the
        // runner occasionally prints something that is not JSON, and a
        // dashboard that died over it would lose a passing suite. Typed
        // rather than a bare catch, because there are exactly two ways this
        // fails — the text is not JSON, or the JSON is not an object — and a
        // bare catch would also swallow a bug in the handling below.
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
            // The root group of a file — the one with no parent — counts every
            // test in it. Nested groups count their own share of the same
            // tests, so reading those too would multiply the total.
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

            // Hidden tests — the one package:test emits for loading a file —
            // are not in the root group's count, so counting them here would
            // finish a file one test early.
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

/// `flutter test --coverage` writes lcov directly; `dart test
/// --coverage=coverage` only dumps raw per-isolate JSON, so it still needs
/// `package:coverage`'s formatter to turn that into the same lcov.info —
/// that package rides in transitively via `test`, so nothing extra to
/// declare (see src/pubspec.yaml's shared lockfile).
///
/// `--ignore-files` drops `*.freezed.dart`/`*.g.dart`: their generated
/// toString/copyWith/props are never called by name from a test, so counting
/// them would cap every package with a union type well under any realistic
/// threshold — see the same constant in `tool/coverage_gate.dart`.
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

  /// How wide the files column will ever need to be.
  ///
  /// Known before anything runs, because both halves are: a row's widest
  /// spelling is the one where every file is done. That matters in a log,
  /// where each row is printed once as it settles and never repainted — a
  /// width measured only over the rows finished so far leaves the first ones
  /// narrow and the column ragged for good.
  late final int _filesWidth = rows
      .map((row) => '${row.fileTotal}/${row.fileTotal}'.length)
      .fold(0, (a, b) => a > b ? a : b);

  /// How wide the tests column has to be for the rows that have settled.
  ///
  /// Measured as they arrive, unlike the files column, because nothing says
  /// up front how many tests a file holds. Re-measured on every paint, so an
  /// interactive run stays aligned; a log cannot, and that is the cost of
  /// printing a row before the next one exists.
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

    // ETA rather than elapsed: extrapolated from the average of packages that
    // have actually finished, minus how far the one running now already is
    // into that average — a package sitting at "no tests yet" is instant and
    // would otherwise drag the average down for no reason, so it is excluded.
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
        // Both counts, in the same order and the same unit as while it ran:
        // the files the bar measured, then the tests inside them. One turning
        // into the other at the finish line read as the number changing its
        // mind — and a file short of its total is how a suite that failed to
        // load shows up at all.
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
