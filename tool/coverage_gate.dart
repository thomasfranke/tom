// Fails the build if line coverage on any package that has both `lib/src`
// code and tests falls under the threshold.
//
//   dart run tool/coverage_gate.dart [--threshold=95]
//
// A package whose `lib/src` has no `.dart` files yet (application, data,
// presentation, as of Phase 0), or that has code but no tests yet, is
// skipped rather than counted as 0% — the gate is about code that has tests
// falling short, not about punishing a layer for not being built or tested
// yet. It starts being measured the moment it gains its first test, with no
// change needed here.
//
// No external packages beyond `coverage` (already resolvable in the
// workspace through `test`'s own dependency on it) — see
// docs/architecture/layers.md#testing.

import 'dart:io';

// Freezed's generated toString/copyWith/props are never exercised directly —
// the tests hit the hand-written factories, not the generated methods by
// name — so counting them would cap every package with a union type well
// under any realistic threshold. Excluded by pattern rather than a per-file
// pragma: the files are regenerated on every `make runner` run, so a
// comment inside them would not survive.
const String generatedFileGlobs = '**.freezed.dart,**.g.dart';

const List<String> _pkgOrder = <String>[
  'core',
  'domain',
  'application',
  'infra',
  'data',
  'presentation',
];

void main(List<String> args) async {
  final double threshold = _threshold(args);
  final Directory root = _repoRoot();
  final Directory packages = Directory('${root.path}/src/packages');

  var overallFail = false;
  var gatedTotal = 0;
  var gatedPassed = 0;
  var linesHit = 0;
  var linesFound = 0;

  stdout.writeln();
  stdout.writeln(
    '• Coverage gate — threshold ${threshold.toStringAsFixed(1)}%:',
  );
  stdout.writeln();

  // Same label column as the flutter-test dashboard (tool/run_tests.dart):
  // bare package name, padded to the longest one, so the numbers line up.
  final int labelWidth = _pkgOrder
      .map((String p) => p.length)
      .reduce((int a, int b) => a > b ? a : b);

  for (final String pkg in _pkgOrder) {
    final Directory dir = Directory('${packages.path}/$pkg');
    final bool hasCode = _dartFilesUnder(
      Directory('${dir.path}/lib/src'),
    ).isNotEmpty;
    final String label = pkg.padRight(labelWidth);

    if (!hasCode) {
      stdout.writeln('  🟠 $label  no lib/src yet, not gated');
      continue;
    }

    final _Coverage? result = await _measure(dir);
    if (result == null) {
      stdout.writeln('  🟠 $label  no tests yet, not gated');
      continue;
    }
    gatedTotal++;
    if (!result.testsPassed) {
      overallFail = true;
      stdout.writeln('  🔴 $label  tests failed, coverage not measured');
      continue;
    }

    final bool ok = result.percentage >= threshold;
    if (!ok) overallFail = true;
    if (ok) gatedPassed++;
    linesHit += result.linesHit;
    linesFound += result.linesFound;
    final String icon = ok ? '🟢' : '🔴';
    stdout.writeln(
      '  $icon $label  ${result.percentage.toStringAsFixed(1)}% '
      '(${result.linesHit}/${result.linesFound} lines)',
    );
  }

  stdout.writeln();
  stdout.writeln('  • Summary:');
  stdout.writeln('    • $gatedPassed/$gatedTotal gated');
  if (linesFound > 0) {
    stdout.writeln('    • ◔ ${(linesHit / linesFound * 100).round()}%');
  }
  stdout.writeln('    • ${overallFail ? '🔴 failed' : '🟢 passed'}');
  exit(overallFail ? 1 : 0);
}

double _threshold(List<String> args) {
  for (final String arg in args) {
    if (arg.startsWith('--threshold=')) {
      final double? value = double.tryParse(arg.split('=').last);
      if (value != null) return value;
    }
  }
  return 95;
}

class _Coverage {
  const _Coverage(this.testsPassed, this.linesFound, this.linesHit);

  final bool testsPassed;
  final int linesFound;
  final int linesHit;

  double get percentage => linesFound == 0 ? 100 : 100 * linesHit / linesFound;
}

/// Runs a package's tests with coverage, converts to lcov, and sums it.
///
/// Reuses `coverage/lcov.info` if it already exists rather than deleting and
/// regenerating it: `verify`/CI always run `flutter-test` (which produces
/// this same file per package under `COVERAGE=1`, the default) immediately
/// before `coverage-gate`, and a failing test run there halts the chain
/// before this ever executes — so a file found here is trustworthy, and
/// reusing it saves rerunning every package's suite a second time just to
/// gate it. `make coverage-gate` invoked on its own, with no such file
/// present, still runs the suite itself.
///
/// Returns `null` if the package has no `_test.dart` files — coverage over
/// zero tests is not a measurement, it is a package waiting for its first
/// test, and the two must not look the same in the report.
Future<_Coverage?> _measure(Directory dir) async {
  final Directory testDir = Directory('${dir.path}/test');
  final bool hasTests =
      testDir.existsSync() &&
      testDir
          .listSync(recursive: true)
          .whereType<File>()
          .any((File f) => f.path.endsWith('_test.dart'));
  if (!hasTests) return null;

  final File existingLcov = File('${dir.path}/coverage/lcov.info');
  if (existingLcov.existsSync()) {
    final (int linesFound, int linesHit) = _sumLcov(existingLcov);
    return _Coverage(true, linesFound, linesHit);
  }

  final Directory coverageDir = Directory('${dir.path}/coverage');
  try {
    final ProcessResult testRun = await Process.run('dart', <String>[
      'test',
      '--coverage=coverage',
    ], workingDirectory: dir.path);
    if (testRun.exitCode != 0) {
      stdout.writeln(testRun.stdout);
      stdout.writeln(testRun.stderr);
      return const _Coverage(false, 0, 0);
    }

    final ProcessResult format = await Process.run('dart', <String>[
      'run',
      'coverage:format_coverage',
      '--lcov',
      '--in=coverage',
      '--out=coverage/lcov.info',
      '--report-on=lib',
      '--ignore-files=$generatedFileGlobs',
    ], workingDirectory: dir.path);
    if (format.exitCode != 0) {
      stdout.writeln(format.stdout);
      stdout.writeln(format.stderr);
      return const _Coverage(false, 0, 0);
    }

    final File lcov = File('${dir.path}/coverage/lcov.info');
    if (!lcov.existsSync()) return const _Coverage(true, 0, 0);

    final (int linesFound, int linesHit) = _sumLcov(lcov);
    return _Coverage(true, linesFound, linesHit);
  } finally {
    if (coverageDir.existsSync()) coverageDir.deleteSync(recursive: true);
  }
}

(int linesFound, int linesHit) _sumLcov(File lcov) {
  var linesFound = 0;
  var linesHit = 0;
  for (final String line in lcov.readAsLinesSync()) {
    if (line.startsWith('LF:')) linesFound += int.parse(line.substring(3));
    if (line.startsWith('LH:')) linesHit += int.parse(line.substring(3));
  }
  return (linesFound, linesHit);
}

Iterable<File> _dartFilesUnder(Directory dir) {
  if (!dir.existsSync()) return const <File>[];
  return dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((File f) => f.path.endsWith('.dart'));
}

Directory _repoRoot() {
  // tool/coverage_gate.dart -> tool/ -> repo root, regardless of cwd.
  final Directory scriptDir = File(Platform.script.toFilePath()).parent;
  return scriptDir.parent;
}
