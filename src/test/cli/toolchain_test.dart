// Unit tests for the CLI's pure functions — the ones a black-box run can only
// reach through a whole command, and only by accident.
//
// Imported by relative path because `tool/` is not a package. That does not
// invert anything: the dependency runs this way only, from the test to the
// tool. Inside `tool/` there is still nothing but `dart:*` and relative
// imports, which is what lets it be the thing that resolves the workspace.
library;

import 'package:test/test.dart';

import '../../../tool/src/cli/dashboard.dart';
import '../../../tool/src/commands/toolchain.dart';

void main() {
  group('Version.parse', () {
    test('reads a bare version', () {
      expect(Version.parse('3.12.2'), const Version(3, 12, 2));
    });

    test('finds the version inside what a tool actually prints', () {
      // Every tool spells it differently, and the three numbers are the only
      // part all of them agree on.
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
      // The whole reason this type exists: `3.9.0` sorts after `3.12.0` as a
      // string and before it as a version.
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
      // Under 1.0.0 there is no major to move, so the minor carries the
      // breakage — pub's rule, and the reason this is not a one-liner.
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

  group('progressBar', () {
    test('fills in proportion', () {
      expect(progressBar(0, 4), '░' * barWidth);
      expect(progressBar(4, 4), '█' * barWidth);
      expect(progressBar(2, 4).split('█').length - 1, barWidth ~/ 2);
    });

    test('draws an unknown total as empty, never as full', () {
      // A bar that started full to mean "nothing known yet" would look like
      // the opposite of what it is.
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
