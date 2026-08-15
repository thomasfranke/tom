// Fails the build if line coverage on any package that has real `lib/src`
// code falls under the threshold.
//
//   dart run tool/coverage_gate.dart [--threshold=95]
//
// A package whose `lib/src` has no `.dart` files yet (application, data,
// presentation, as of Phase 0) is skipped rather than counted as 0% — the
// gate is about work that exists having tests, not about punishing a layer
// for not being built yet. It starts being measured the moment it gains its
// first file, with no change needed here.
//
// No external packages beyond `coverage` (already resolvable in the
// workspace through `test`'s own dependency on it) — see
// docs/architecture/layers.md#testing.

import 'dart:io';

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
  stdout.writeln(
    'Coverage gate — threshold ${threshold.toStringAsFixed(1)}%\n',
  );

  for (final String pkg in _pkgOrder) {
    final Directory dir = Directory('${packages.path}/$pkg');
    final bool hasCode = _dartFilesUnder(
      Directory('${dir.path}/lib/src'),
    ).isNotEmpty;

    if (!hasCode) {
      stdout.writeln('⏭️  tom_$pkg — no lib/src yet, not gated');
      continue;
    }

    final _Coverage? result = await _measure(dir);
    if (result == null) {
      stdout.writeln('⏭️  tom_$pkg — no tests yet, not gated');
      continue;
    }
    if (!result.testsPassed) {
      overallFail = true;
      stdout.writeln('❌ tom_$pkg — tests failed, coverage not measured');
      continue;
    }

    final bool ok = result.percentage >= threshold;
    if (!ok) overallFail = true;
    final String icon = ok ? '✅' : '❌';
    stdout.writeln(
      '$icon tom_$pkg — ${result.percentage.toStringAsFixed(1)}% '
      '(${result.linesHit}/${result.linesFound} lines)',
    );
  }

  stdout.writeln();
  if (overallFail) {
    stdout.writeln('Coverage gate failed.');
  } else {
    stdout.writeln('Coverage gate passed.');
  }
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

  final Directory coverageDir = Directory('${dir.path}/coverage');
  if (coverageDir.existsSync()) coverageDir.deleteSync(recursive: true);

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
    ], workingDirectory: dir.path);
    if (format.exitCode != 0) {
      stdout.writeln(format.stdout);
      stdout.writeln(format.stderr);
      return const _Coverage(false, 0, 0);
    }

    final File lcov = File('${dir.path}/coverage/lcov.info');
    if (!lcov.existsSync()) return const _Coverage(true, 0, 0);

    var linesFound = 0;
    var linesHit = 0;
    for (final String line in lcov.readAsLinesSync()) {
      if (line.startsWith('LF:')) linesFound += int.parse(line.substring(3));
      if (line.startsWith('LH:')) linesHit += int.parse(line.substring(3));
    }
    return _Coverage(true, linesFound, linesHit);
  } finally {
    if (coverageDir.existsSync()) coverageDir.deleteSync(recursive: true);
  }
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
