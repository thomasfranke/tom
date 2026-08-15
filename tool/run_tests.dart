// A live test dashboard: one fixed line per package, each with its own
// progress bar, driven by package:test's `--reporter=json` protocol.
//
//   dart run tool/run_tests.dart [--coverage] <target>...
//
// <target> is either a bare package name — a folder under src/packages/,
// "desktop" for the Flutter app, or "arch" for the architecture graph test
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
// Status is a single colored-dot emoji (🟢/🔴/🟡/⚪/🟠) — a traffic-light
// read at a glance across however many rows are in the block.
//
// No external packages — only dart:io and dart:convert — so it runs with
// nothing but the SDK already on the machine, from any directory.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

const _pkgOrder = [
  'core',
  'domain',
  'application',
  'infra',
  'data',
  'presentation',
];

const _barWidth = 20;

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
    stderr.writeln('Usage: dart run tool/run_tests.dart [--coverage] <pkg>...');
    exit(64);
  }

  final root = _repoRoot();
  final src = Directory('${root.path}/src');
  final targets = args.map((a) => _resolve(src, a)).toList();
  final rows = [for (final t in targets) _Row(t.label, hasTests: _hasTests(t))];
  for (final row in rows) {
    if (!row.hasTests) row.state = _RowState.skipped;
  }

  if (!noBanner) await _showCompiling();

  final dashboard = _Dashboard(rows, DateTime.now());
  dashboard.render();
  final ticker = Timer.periodic(
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

  ticker.cancel();
  dashboard.render();

  final totalPassed = rows.fold(0, (a, r) => a + r.passed);
  final totalTests = totalPassed + rows.fold(0, (a, r) => a + r.failed);
  final covHit = rows.fold(0, (a, r) => a + (r.coverageHit ?? 0));
  final covTotal = rows.fold(0, (a, r) => a + (r.coverageTotal ?? 0));
  final totalElapsed = _fmtDuration(DateTime.now().difference(dashboard.started));

  stdout.writeln();
  stdout.writeln('• Summary:');
  stdout.writeln('  • $totalPassed/$totalTests');
  stdout.writeln('  • ⏱ $totalElapsed');
  if (covTotal > 0) {
    stdout.writeln('  • ◔ ${(covHit / covTotal * 100).round()}%');
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
    stdout.writeln('🔴 Failed files:');
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
    case 'desktop':
      return _Target(
        'desktop',
        Directory('${src.path}/apps/desktop'),
        'flutter',
        files,
      );
    default:
      if (!_pkgOrder.contains(pkg)) {
        stderr.writeln(
          "Unknown package '$pkg'. Available: ${_pkgOrder.join(', ')}, desktop, arch",
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

Directory _repoRoot() {
  // tool/run_tests.dart -> tool/ -> repo root, regardless of cwd.
  final scriptDir = File(Platform.script.toFilePath()).parent;
  return scriptDir.parent;
}

bool _hasTests(_Target target) {
  if (target.extraArgs.isNotEmpty) {
    return target.extraArgs.every(
      (f) => File('${target.dir.path}/$f').existsSync(),
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
  await Future.delayed(const Duration(milliseconds: 300));
  ticker.cancel();
  stdout.write('\r\x1B[K');
}

enum _RowState { queued, skipped, running, done }

/// One line of the fixed dashboard, mutated in place as its package's test
/// run progresses. `suiteTotal` arrives from the `allSuites` event, so it
/// stays 0 — an indeterminate bar — until package:test has parsed the suite.
class _Row {
  _Row(this.label, {required this.hasTests});
  final String label;
  final bool hasTests;

  _RowState state = _RowState.queued;
  DateTime? startedAt;
  Duration? elapsed;

  int suiteTotal = 0;
  int suiteDone = 0;
  int passed = 0;
  int failed = 0;

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
  final process = await Process.start(target.command, [
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

  // File-completion is a heuristic: package:test's protocol has no explicit
  // "this suite is done" event, so a suite counts as complete once every
  // test started for it has also finished. That is exactly right for suites
  // whose tests are all known up front — true for every test file in this
  // project — and simply under-counts, rather than crashing, for anything
  // stranger.
  final suitePath = <int, String>{};
  final suiteStarted = <int, int>{};
  final suiteDone = <int, int>{};
  final suiteComplete = <int>{};
  final testSuite = <int, int>{};
  final testName = <int, String>{};
  final testError = <int, String>{};

  await process.stdout
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .forEach((line) {
        if (line.trim().isEmpty) return;
        Map<String, dynamic> event;
        try {
          event = jsonDecode(line) as Map<String, dynamic>;
        } catch (_) {
          return; // a non-JSON line (rare) — ignore rather than crash the run
        }

        switch (event['type']) {
          case 'allSuites':
            row.suiteTotal = event['count'] as int;
          case 'suite':
            final suite = event['suite'] as Map<String, dynamic>;
            suitePath[suite['id'] as int] = suite['path'] as String;
          case 'testStart':
            final test = event['test'] as Map<String, dynamic>;
            final id = test['id'] as int;
            final suiteId = test['suiteID'] as int;
            testSuite[id] = suiteId;
            testName[id] = test['name'] as String? ?? 'test';
            suiteStarted[suiteId] = (suiteStarted[suiteId] ?? 0) + 1;
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

            if (suiteId != null) {
              suiteDone[suiteId] = (suiteDone[suiteId] ?? 0) + 1;
              if (suiteDone[suiteId]! >= (suiteStarted[suiteId] ?? 0)) {
                suiteComplete.add(suiteId);
                row.suiteDone = suiteComplete.length;
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
    final cov = await _collectCoverage(target);
    row.coverageHit = cov?.hit;
    row.coverageTotal = cov?.total;
    dashboard.render();
  }

  return exitCode == 0;
}

/// `flutter test --coverage` writes lcov directly; `dart test
/// --coverage=coverage` only dumps raw per-isolate JSON, so it still needs
/// `package:coverage`'s formatter to turn that into the same lcov.info —
/// that package rides in transitively via `test`, so nothing extra to
/// declare (see src/pubspec.yaml's shared lockfile).
Future<({int hit, int total})?> _collectCoverage(_Target target) async {
  if (target.command == 'dart') {
    final result = await Process.run('dart', [
      'run',
      'coverage:format_coverage',
      '--lcov',
      '--in=coverage',
      '--out=coverage/lcov.info',
      '--report-on=lib',
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
class _Dashboard {
  _Dashboard(this.rows, this.started)
    : _labelWidth = rows
          .map((r) => r.label.length)
          .reduce((a, b) => a > b ? a : b);

  final List<_Row> rows;
  final DateTime started;
  final List<String> failures = [];
  final int _labelWidth;
  int _paintedLines = 0;

  void render() {
    _erase();
    final countsWidth = rows
        .where((r) => r.state == _RowState.done)
        .map((r) => '${r.passed}/${r.passed + r.failed}'.length)
        .fold(0, (a, b) => a > b ? a : b);
    final lines = [_header(), ...rows.map((r) => _renderRow(r, countsWidth))];
    stdout.writeln(lines.join('\n'));
    _paintedLines = lines.length;
  }

  void logFailure(String pkg, String path, String name, String? error) {
    final file = '$pkg — $path';
    failures.add(file);
    final buf = StringBuffer()
      ..writeln('  🔴 $file')
      ..writeln('     $name');
    if (error != null && error.isNotEmpty) buf.writeln('     $error');
    log(buf.toString().trimRight());
  }

  void log(String text) {
    _erase();
    stdout.writeln(text);
    render();
  }

  void _erase() {
    if (_paintedLines == 0) return;
    stdout.write('\x1B[${_paintedLines}A\x1B[J');
    _paintedLines = 0;
  }

  // Stays "Running tests" even once everything is done — "Summary" is the
  // one below, with the totals; switching this one too would print it twice.
  String _header() {
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
    final eta = _fmtDuration(Duration(milliseconds: etaMs.round()));
    return '• Running tests — $doneCount/${rows.length} packages, ~$eta remaining:';
  }

  String _renderRow(_Row row, int countsWidth) {
    final label = row.label.padRight(_labelWidth);
    switch (row.state) {
      case _RowState.skipped:
        return '  🟠 $label  no tests yet';
      case _RowState.queued:
        return '  ⚪ $label  ${_bar(0, 0)}';
      case _RowState.running:
        final elapsed = _fmtDuration(DateTime.now().difference(row.startedAt!));
        final total = row.suiteTotal > 0 ? '${row.suiteTotal}' : '?';
        return '  🟡 $label  ${_bar(row.suiteDone, row.suiteTotal)} '
            '${row.suiteDone}/$total  •  +${row.passed} ✗${row.failed}  •  ⏱ $elapsed';
      case _RowState.done:
        final elapsed = _fmtDuration(row.elapsed ?? Duration.zero);
        final total = row.passed + row.failed;
        final counts = '${row.passed}/$total'.padRight(countsWidth);
        final icon = row.failed == 0 ? '🟢' : '🔴';
        final cov = row.coverage != null ? '◔ ${row.coverage!.round()}%  ' : '';
        return '  $icon $label  ${_bar(1, 1)} '
            '$counts  $cov⏱ $elapsed';
    }
  }

  String _bar(int done, int total) {
    final filled = total > 0
        ? ((done / total) * _barWidth).round().clamp(0, _barWidth)
        : 0;
    return '█' * filled + '░' * (_barWidth - filled);
  }
}

String _fmtDuration(Duration d) {
  final m = d.inMinutes;
  final s = d.inSeconds % 60;
  return m > 0 ? '${m}m${s.toString().padLeft(2, '0')}s' : '${s}s';
}
