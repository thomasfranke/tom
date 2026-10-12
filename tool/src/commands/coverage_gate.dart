// Fails the build if any gated package's line coverage is under the bar.
//
//   dart run tool/src/commands/coverage_gate.dart [--kind=unit|all] [--threshold=90]
//
// `unit` (the default) runs only each package's unit tests and counts only
// them: the bar is that the code is proved without a real git, disk or
// socket. `all` runs the whole `test/` and reports that figure.
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

/// What the gate counts: only unit tests, or the whole `test/`.
enum CoverageKind { unit, all }

/// The kind a run with no `--kind` gets.
const CoverageKind defaultCoverageKind = CoverageKind.unit;

/// The bar, in percent of lines, a run with no `--threshold` holds every
/// package to (the maintainer, 2026-10-11).
const double defaultCoverageThreshold = 90;

/// The verdict on one measured package. There is no list of exceptions: every
/// package is held to the same bar (roadmap Stage 14).
enum CoverageVerdict {
  /// At or over the bar.
  passed,

  /// Under the bar.
  belowBar,
}

/// Judges [percent] against [threshold].
CoverageVerdict judgeCoverage({
  required double percent,
  required double threshold,
}) => percent >= threshold ? CoverageVerdict.passed : CoverageVerdict.belowBar;

/// The line the gate prints for a failing package, naming it and the number.
String coverageFailureMessage({
  required String package,
  required double percent,
  required double threshold,
  required CoverageKind kind,
}) {
  final String number = '${percent.toStringAsFixed(1)}%';
  final String bar = '${threshold.toStringAsFixed(1)}%';
  return '$package is at $number, under the $bar bar for ${kind.name} tests';
}

/// One package: where it lives, how its tests run and which of them the
/// kind counts.
class _Gated {
  const _Gated(this.name, this.relativeDir, {this.flutter = false});
  final String name;
  final String relativeDir;

  /// Runs under `flutter test`: it draws, so it needs the binding.
  final bool flutter;

  /// What to hand `test` for [kind], or empty when it has nothing of that
  /// kind. `all` is the whole `test/`.
  List<String> testPaths(Directory dir, CoverageKind kind) {
    if (kind == CoverageKind.all) return const <String>['test'];
    return switch (name) {
      // Widget tests are its unit tests.
      'ui' => const <String>['test'],
      // `integration/` there drives a real repository; the rest is widget
      // tests, which are the application's unit tests.
      'desktop' => <String>[
        for (final FileSystemEntity e in Directory(
          '${dir.path}/test',
        ).listSync())
          if (e is Directory && !e.path.endsWith('/integration'))
            'test/${e.uri.pathSegments.where((String s) => s.isNotEmpty).last}',
      ],
      _ =>
        Directory('${dir.path}/test/unit').existsSync()
            ? const <String>['test/unit']
            : const <String>[],
    };
  }
}

// `ui` and `desktop` join with the unit bar (Stage 14): what they draw is
// proved by widget tests, which count as unit tests there.
const List<_Gated> _gated = <_Gated>[
  _Gated('core', 'src/packages/core'),
  _Gated('domain', 'src/packages/domain'),
  _Gated('application', 'src/packages/application'),
  _Gated('infra', 'src/packages/infra'),
  _Gated('data', 'src/packages/data'),
  _Gated('presentation', 'src/packages/presentation'),
  _Gated('ui', 'src/packages/ui', flutter: true),
  _Gated('desktop', 'src/apps/desktop', flutter: true),
];

void main(List<String> args) async {
  final CoverageKind? kind = coverageKindFrom(args);
  if (kind == null) {
    stderr.writeln('cli: --kind is unit or all');
    exit(64);
  }
  final double threshold = _threshold(args);
  final Directory root = repoRoot();

  var overallFail = false;
  var gatedTotal = 0;
  var gatedPassed = 0;
  var linesHit = 0;
  var linesFound = 0;
  final List<String> failures = <String>[];

  stdout.writeln();
  stdout.writeln(
    '• Coverage gate — ${kind.name} tests, '
    'threshold ${threshold.toStringAsFixed(1)}%:',
  );
  stdout.writeln();

  // The same label column as run_tests.dart, so the numbers line up.
  final int labelWidth = _gated
      .map((_Gated g) => g.name.length)
      .reduce((int a, int b) => a > b ? a : b);

  for (final _Gated gated in _gated) {
    final Directory dir = Directory('${root.path}/${gated.relativeDir}');
    final bool hasCode =
        _dartFilesUnder(Directory('${dir.path}/lib/src')).isNotEmpty ||
        (gated.name == 'desktop' &&
            _dartFilesUnder(Directory('${dir.path}/lib')).isNotEmpty);
    final String label = gated.name.padRight(labelWidth);

    if (!hasCode) {
      stdout.writeln(
        '${statusMark(Status.skipped, palette.skipped)}$label  '
        'no lib/src yet, not gated',
      );
      continue;
    }

    final _Coverage? result = await _measure(dir, gated, kind);
    if (result == null) {
      stdout.writeln(
        '${statusMark(Status.skipped, palette.skipped)}$label  '
        'no ${kind.name} tests yet, not gated',
      );
      continue;
    }
    gatedTotal++;
    if (!result.testsPassed) {
      overallFail = true;
      failures.add('${gated.name} tests failed, coverage not measured');
      stdout.writeln(
        '${statusMark(Status.fail, palette.fail)}$label  '
        'tests failed, coverage not measured',
      );
      continue;
    }

    final bool ok =
        judgeCoverage(percent: result.percentage, threshold: threshold) ==
        CoverageVerdict.passed;
    if (!ok) {
      overallFail = true;
      failures.add(
        coverageFailureMessage(
          package: gated.name,
          percent: result.percentage,
          threshold: threshold,
          kind: kind,
        ),
      );
    }
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

  if (failures.isNotEmpty) {
    stdout.writeln();
    stdout.writeln('  • Failing:');
    for (final String failure in failures) {
      stdout.writeln('    • $failure');
    }
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

/// The kind `--kind=` names, [defaultCoverageKind] when absent, and null when
/// it names something else.
CoverageKind? coverageKindFrom(List<String> args) {
  for (final String arg in args) {
    if (arg.startsWith('--kind=')) {
      final String value = arg.substring('--kind='.length);
      for (final CoverageKind kind in CoverageKind.values) {
        if (kind.name == value) return kind;
      }
      return null;
    }
  }
  return defaultCoverageKind;
}

double _threshold(List<String> args) {
  for (final String arg in args) {
    if (arg.startsWith('--threshold=')) {
      final double? value = double.tryParse(arg.split('=').last);
      if (value != null) return value;
    }
  }
  return defaultCoverageThreshold;
}

class _Coverage {
  const _Coverage(this.testsPassed, this.linesFound, this.linesHit);

  final bool testsPassed;
  final int linesFound;
  final int linesHit;

  double get percentage => linesFound == 0 ? 100 : 100 * linesHit / linesFound;
}

/// A package's line coverage, measured by running its tests; null when it
/// has none of [kind], since that is not a measurement.
///
/// Always measured afresh, and a `coverage/` found on arrival is deleted
/// first: a file left by an earlier run, of the other kind or of older code,
/// would be counted as this one's.
Future<_Coverage?> _measure(
  Directory dir,
  _Gated gated,
  CoverageKind kind,
) async {
  final List<String> paths = gated.testPaths(dir, kind);
  final bool hasTests = paths.any((String path) {
    final Directory folder = Directory('${dir.path}/$path');
    return folder.existsSync() &&
        folder
            .listSync(recursive: true)
            .whereType<File>()
            .any((File f) => f.path.endsWith('_test.dart'));
  });
  if (!hasTests) return null;

  final Directory coverageDir = Directory('${dir.path}/coverage');
  if (coverageDir.existsSync()) coverageDir.deleteSync(recursive: true);
  try {
    final ProcessResult testRun = gated.flutter
        ? await Process.run('flutter', <String>[
            'test',
            '--coverage',
            ...paths,
          ], workingDirectory: dir.path)
        : await Process.run(dartExecutable, <String>[
            'test',
            '--coverage=coverage',
            ...paths,
          ], workingDirectory: dir.path);
    if (testRun.exitCode != 0) {
      stdout.writeln(testRun.stdout);
      stdout.writeln(testRun.stderr);
      return const _Coverage(false, 0, 0);
    }

    if (!gated.flutter) {
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
    }

    final File lcov = File('${dir.path}/coverage/lcov.info');
    if (!lcov.existsSync()) return const _Coverage(true, 0, 0);

    final (int linesFound, int linesHit) = _sumLcov(lcov);
    return _Coverage(true, linesFound, linesHit);
  } finally {
    if (coverageDir.existsSync()) coverageDir.deleteSync(recursive: true);
  }
}

/// Whether [path] is a file the generators write, which no test calls by
/// name. `flutter test --coverage` has no ignore option, so it is told here.
bool isGeneratedSource(String path) =>
    path.endsWith('.freezed.dart') ||
    path.endsWith('.g.dart') ||
    path.contains('/l10n/generated/');

(int linesFound, int linesHit) _sumLcov(File lcov) {
  var linesFound = 0;
  var linesHit = 0;
  var skipping = false;
  for (final String line in lcov.readAsLinesSync()) {
    if (line.startsWith('SF:')) skipping = isGeneratedSource(line.substring(3));
    if (skipping) continue;
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
