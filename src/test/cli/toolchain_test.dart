/// Unit tests for the CLI's pure functions, imported by relative path because
/// `tool/` is not a package; the dependency runs from test to tool only.
library;

import 'package:test/test.dart';

import '../../../tool/src/cli/dashboard.dart';
import '../../../tool/src/commands/doctor.dart';
import '../../../tool/src/commands/process.dart';
import '../../../tool/src/commands/tests.dart';
import '../../../tool/src/commands/toolchain.dart';

void main() {
  group('Version.parse', () {
    test('reads a bare version', () {
      expect(Version.parse('3.12.2'), const Version(3, 12, 2));
    });

    test('finds the version inside what a tool actually prints', () {
      // The three numbers are the only part every tool spells the same way.
      expect(
        Version.parse('Dart SDK version: 3.12.2 (stable) (Tue Jun 9 2026)'),
        const Version(3, 12, 2),
      );
      expect(Version.parse('git version 2.54.0'), const Version(2, 54, 0));
      expect(
        Version.parse('3.14.0 (build 3.14.0-95.2.beta)'),
        const Version(3, 14, 0),
      );
      expect(Version.parse('^3.12.0'), const Version(3, 12, 0));
    });

    test('answers null when there is no version to find', () {
      expect(Version.parse('genhtml: LCOV version 2.0'), isNull);
      expect(Version.parse(''), isNull);
    });
  });

  group('Version ordering', () {
    test('compares numerically, not as text', () {
      // `3.9.0` sorts after `3.12.0` as a string and before it as a version.
      expect(const Version(3, 9, 0) < const Version(3, 12, 0), isTrue);
      expect(const Version(3, 44, 5) < const Version(3, 47, 5), isTrue);
      expect(const Version(4, 0, 0) > const Version(3, 99, 99), isTrue);
    });

    test('equal versions are equal, and hash alike', () {
      expect(const Version(3, 12, 2), const Version(3, 12, 2));
      expect(
        const Version(3, 12, 2).hashCode,
        const Version(3, 12, 2).hashCode,
      );
    });

    test('prints the three numbers back', () {
      expect(const Version(3, 47, 5).toString(), '3.47.5');
    });
  });

  group('Version.satisfiesCaret', () {
    test('admits a later patch and minor of the same major', () {
      expect(
        const Version(3, 13, 4).satisfiesCaret(const Version(3, 12, 0)),
        isTrue,
      );
      expect(
        const Version(3, 12, 0).satisfiesCaret(const Version(3, 12, 0)),
        isTrue,
      );
    });

    test('refuses anything below the floor', () {
      expect(
        const Version(3, 11, 9).satisfiesCaret(const Version(3, 12, 0)),
        isFalse,
      );
    });

    test('refuses the next major', () {
      expect(
        const Version(4, 0, 0).satisfiesCaret(const Version(3, 12, 0)),
        isFalse,
      );
    });

    test('moves the boundary to the minor below 1.0.0', () {
      // Pub's rule: under 1.0.0 the minor carries the breakage.
      expect(
        const Version(0, 12, 9).satisfiesCaret(const Version(0, 12, 0)),
        isTrue,
      );
      expect(
        const Version(0, 13, 0).satisfiesCaret(const Version(0, 12, 0)),
        isFalse,
      );
    });
  });

  group('gitVerdict', () {
    test('fails with no git at all', () {
      final ({String detail, bool ok}) verdict = gitVerdict(null);

      expect(verdict.ok, isFalse);
      expect(verdict.detail, contains('not on PATH'));
    });

    test('fails below 2.41, saying what was found and what is needed', () {
      final ({String detail, bool ok}) verdict = gitVerdict(
        const Version(2, 39, 5),
      );

      expect(verdict.ok, isFalse);
      expect(verdict.detail, contains('2.39.5'));
      expect(verdict.detail, contains('2.41.0 or newer'));
      expect(verdict.detail, contains('ahead-behind'));
    });

    test('passes at 2.41 exactly, and above', () {
      expect(gitVerdict(const Version(2, 41, 0)).ok, isTrue);
      expect(gitVerdict(const Version(2, 54, 0)).ok, isTrue);
      expect(gitVerdict(const Version(3, 0, 0)).ok, isTrue);
    });

    test('says the version it found when it passes', () {
      expect(gitVerdict(const Version(2, 54, 0)).detail, contains('2.54.0'));
    });

    test('reads the version out of what Apple and Windows print', () {
      expect(
        gitVerdict(Version.parse('git version 2.39.5 (Apple Git-154)')).ok,
        isFalse,
      );
      expect(
        gitVerdict(Version.parse('git version 2.41.0.windows.1')).ok,
        isTrue,
      );
    });
  });

  group('testRunArguments', () {
    test('the whole run opens with the graph and closes with the CLI', () {
      final List<String> arguments = testRunArguments(targets: allTargets);

      expect(arguments.first, '--coverage');
      expect(arguments[1], arch);
      expect(arguments.last, cli);
      expect(arguments, containsAllInOrder(allTargets));
    });

    test('a run narrowed to packages asks about neither', () {
      final List<String> arguments = testRunArguments(
        targets: <String>['core', 'domain'],
        coverage: false,
      );

      expect(arguments, <String>['core', 'domain']);
    });

    test('a run narrowed to a kind asks about neither', () {
      final List<String> arguments = testRunArguments(
        kind: 'unit',
        targets: allTargets,
        coverage: false,
      );

      expect(arguments, isNot(contains(arch)));
      expect(arguments, isNot(contains(cli)));
      expect(arguments.first, 'core=test/unit');
    });
  });

  group('progressBar', () {
    test('fills in proportion', () {
      expect(progressBar(0, 4), '░' * barWidth);
      expect(progressBar(4, 4), '█' * barWidth);
      expect(progressBar(2, 4).split('█').length - 1, barWidth ~/ 2);
    });

    test('draws an unknown total as empty, never as full', () {
      // A full bar for "nothing known yet" reads as the opposite.
      expect(progressBar(0, 0), '░' * barWidth);
    });

    test('never overflows its width', () {
      expect(progressBar(9, 4).length, barWidth);
    });
  });

  group('formatDuration', () {
    test('reads as seconds under a minute', () {
      expect(formatDuration(const Duration(seconds: 6)), '6s');
    });

    test('pads the seconds once there are minutes', () {
      expect(formatDuration(const Duration(minutes: 2, seconds: 4)), '2m04s');
    });
  });
}
