// Fails the build if any gated package's line coverage is under the threshold.
//
//   dart run tool/src/commands/coverage_gate.dart [--threshold=95]
//
// A package with no code under `lib/src` yet, or no tests yet, is skipped
// rather than counted as 0%: it joins the gate with its first test.

import 'dart:io';

import '../cli/dashboard.dart';
import '../repo.dart';
import '../theme/theme.dart';
import 'process.dart';

// Generated Freezed methods are never called by name from a test, so counting
// them would cap every package with a union type under any realistic
// threshold. By pattern rather than a pragma, because the files are rewritten
// on every codegen run.
const String generatedFileGlobs = '**.freezed.dart,**.g.dart';

// The pure Dart layers. `ui` is left out with the two applications: what it
// holds is drawn, and a widget's line count says little about the drawing
// (Decision 26).
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
  final Directory root = repoRoot();
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

  // The same label column as run_tests.dart, so the numbers line up.
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
      stdout.writeln(
        '${statusMark(Status.skipped, palette.skipped)}$label  '
        'no lib/src yet, not gated',
      );
      continue;
    }

    final _Coverage? result = await _measure(dir);
    if (result == null) {
      stdout.writeln(
        '${statusMark(Status.skipped, palette.skipped)}$label  '
        'no tests yet, not gated',
      );
      continue;
    }
    gatedTotal++;
    if (!result.testsPassed) {
      overallFail = true;
      stdout.writeln(
        '${statusMark(Status.fail, palette.fail)}$label  '
        'tests failed, coverage not measured',
      );
      continue;
    }

    final bool ok = result.percentage >= threshold;
    if (!ok) overallFail = true;
    if (ok) gatedPassed++;
    linesHit += result.linesHit;
    linesFound += result.linesFound;
    final String mark = ok
        ? statusMark(Status.ok, palette.ok)
        : statusMark(Status.fail, palette.fail);
    stdout.writeln(
      '$mark$label  ${result.percentage.toStringAsFixed(1)}% '
      '(${result.linesHit}/${result.linesFound} lines)',
    );
  }

  stdout.writeln();
  stdout.writeln('  • Summary:');
  stdout.writeln('    • $gatedPassed/$gatedTotal gated');
  if (linesFound > 0) {
    stdout.writeln('    • ◔ ${(linesHit / linesFound * 100).round()}%');
  }
  final verdict = overallFail
      ? '${palette.fail}${Status.fail}${Ansi.reset} failed'
      : '${palette.ok}${Status.ok}${Ansi.reset} passed';
  stdout.writeln('    • $verdict');
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

/// A package's line coverage, measured by running its tests; null when it
/// has no `_test.dart` at all, since that is not a measurement.
///
/// An existing `coverage/lcov.info` is reused rather than regenerated:
/// `verify` and CI run the suite immediately before this gate and halt on a
/// failure, so a file found here is trustworthy and saves a second full run.
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
    final ProcessResult testRun = await Process.run(dartExecutable, <String>[
      'test',
      '--coverage=coverage',
    ], workingDirectory: dir.path);
    if (testRun.exitCode != 0) {
      stdout.writeln(testRun.stdout);
      stdout.writeln(testRun.stderr);
      return const _Coverage(false, 0, 0);
    }

    final ProcessResult format = await Process.run(dartExecutable, <String>[
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
