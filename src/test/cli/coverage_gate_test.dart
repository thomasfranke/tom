/// The coverage gate: what it counts and the bar it holds every package to,
/// written out where a test can hold them.
///
/// The bar is 90 % by unit tests alone (the maintainer, 2026-10-11); the
/// whole-`test/` figure is a report, so a package cannot pass the gate on
/// the strength of a real git or disk.
library;

import 'dart:io';

import 'package:test/test.dart';

import '../../../tool/src/commands/coverage_gate.dart';

void main() {
  group('the kind', () {
    test('is unit when none is given', () {
      expect(defaultCoverageKind, CoverageKind.unit);
      expect(coverageKindFrom(<String>[]), CoverageKind.unit);
      expect(coverageKindFrom(<String>['--threshold=80']), CoverageKind.unit);
    });

    test('all still exists, and nothing else does', () {
      expect(coverageKindFrom(<String>['--kind=all']), CoverageKind.all);
      expect(coverageKindFrom(<String>['--kind=unit']), CoverageKind.unit);
      expect(coverageKindFrom(<String>['--kind=nonesuch']), isNull);
      expect(CoverageKind.values, hasLength(2));
    });

    test('an unknown one is a usage error', () {
      final ProcessResult result = Process.runSync(
        Platform.resolvedExecutable,
        <String>['run', 'tool/cli.dart', 'coverage-gate', '--kind=nonesuch'],
        workingDirectory: '..',
      );
      expect(result.exitCode, 64);
    });
  });

  group('the bar', () {
    test('is 90 % by default', () {
      expect(defaultCoverageThreshold, 90);
    });

    test('lets a package at it through', () {
      expect(judgeCoverage(percent: 90, threshold: 90), CoverageVerdict.passed);
    });

    test('fails a package under it, naming the package and the number', () {
      expect(
        judgeCoverage(percent: 89.94, threshold: 90),
        CoverageVerdict.belowBar,
      );
      final String message = coverageFailureMessage(
        package: 'data',
        percent: 89.94,
        threshold: 90,
        kind: CoverageKind.unit,
      );
      expect(message, contains('data'));
      expect(message, contains('89.9%'));
      expect(message, contains('90.0%'));
    });

    test('has no exceptions: a low package fails whatever it is', () {
      for (final String package in <String>['core', 'infra', 'ui', 'desktop']) {
        expect(
          coverageFailureMessage(
            package: package,
            percent: 52.2,
            threshold: 90,
            kind: CoverageKind.unit,
          ),
          allOf(contains(package), contains('52.2%')),
        );
      }
      expect(
        judgeCoverage(percent: 52.2, threshold: 90),
        CoverageVerdict.belowBar,
      );
    });
  });

  group('the generated code', () {
    test('is not counted', () {
      expect(isGeneratedSource('lib/src/a.freezed.dart'), isTrue);
      expect(isGeneratedSource('lib/src/a.g.dart'), isTrue);
      expect(
        isGeneratedSource('lib/l10n/generated/app_localizations.dart'),
        isTrue,
      );
      expect(isGeneratedSource('lib/src/a.dart'), isFalse);
    });
  });

  test('the pipeline calls the same command the gate runs', () {
    final String workflow = File(
      '../.github/workflows/pr-checks.yml',
    ).readAsStringSync();
    expect(workflow, contains('make coverage-gate'));
  });
}
