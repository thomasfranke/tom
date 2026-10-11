/// Tests for how an end-to-end run is judged: the outcome, the exit code,
/// the line a log keeps and the record the list reads. The app is never
/// started here — what is under test is the reading of what it answered.
library;

import 'package:test/test.dart';

import '../../../tool/src/commands/e2e_catalogue.dart';
import '../../../tool/src/commands/e2e_run.dart' show themeDefineFor;

void main() {
  group('themeDefineFor', () {
    test('light and dark become a define, whatever the case', () {
      expect(themeDefineFor('light'), '--dart-define=TOM_E2E_THEME=light');
      expect(themeDefineFor(' Dark '), '--dart-define=TOM_E2E_THEME=dark');
    });

    test('nothing, or anything else, leaves the platform alone', () {
      expect(themeDefineFor(null), isNull);
      expect(themeDefineFor(''), isNull);
      expect(themeDefineFor('sepia'), isNull);
    });
  });

  group('ScenarioOutcome.of', () {
    test('a clean exit after declared steps is a pass', () {
      expect(
        ScenarioOutcome.of(exitCode: 0, declared: 7),
        ScenarioOutcome.passed,
      );
    });

    test('a clean exit with no steps declared did not run', () {
      // The killed hang: `flutter test` answered 0 and the app never began.
      expect(
        ScenarioOutcome.of(exitCode: 0, declared: 0),
        ScenarioOutcome.didNotRun,
      );
    });

    test('a failed build did not run either', () {
      expect(
        ScenarioOutcome.of(exitCode: 1, declared: 0),
        ScenarioOutcome.didNotRun,
      );
    });

    test('a step that did not hold is a failure', () {
      expect(
        ScenarioOutcome.of(exitCode: 1, declared: 7),
        ScenarioOutcome.failed,
      );
    });

    test('a signal is a cancellation, steps or none', () {
      expect(
        ScenarioOutcome.of(exitCode: -15, declared: 7),
        ScenarioOutcome.cancelled,
      );
      expect(
        ScenarioOutcome.of(exitCode: -9, declared: 0),
        ScenarioOutcome.cancelled,
      );
    });
  });

  group('exitCodeAfter', () {
    test('only a pass answers 0', () {
      expect(ScenarioOutcome.passed.exitCodeAfter(0), 0);
      for (final ScenarioOutcome outcome in ScenarioOutcome.values) {
        if (outcome == ScenarioOutcome.passed) {
          continue;
        }
        expect(outcome.exitCodeAfter(0), isNot(0), reason: outcome.label);
      }
    });

    test('keeps the code the process gave when it gave one', () {
      expect(ScenarioOutcome.failed.exitCodeAfter(1), 1);
      expect(ScenarioOutcome.didNotRun.exitCodeAfter(65), 65);
      expect(ScenarioOutcome.cancelled.exitCodeAfter(-15), -15);
    });
  });

  group('scenarioLine', () {
    test('says a pass with its count', () {
      expect(
        scenarioLine(
          'Works in tabs',
          ScenarioOutcome.passed,
          done: 8,
          total: 8,
        ),
        '  ✓ Works in tabs — 8/8 steps',
      );
    });

    test('never draws 0/0 steps as green, and says why', () {
      final String line = scenarioLine(
        'Leaves a space',
        ScenarioOutcome.didNotRun,
        done: 0,
        total: 0,
      );

      expect(line, startsWith('  ✘ Leaves a space — 0/0 steps'));
      expect(line, contains('did not run'));
      expect(line, isNot(contains('✓')));
    });

    test('draws a failure and a cancellation red', () {
      expect(
        scenarioLine('A', ScenarioOutcome.failed, done: 2, total: 7),
        '  ✘ A — 2/7 steps',
      );
      expect(
        scenarioLine('A', ScenarioOutcome.cancelled, done: 2, total: 7),
        contains('✘ A — 2/7 steps · cancelled'),
      );
    });
  });

  group('ScenarioResult', () {
    final DateTime when = DateTime.utc(2026, 10, 8, 12);

    test('round-trips its outcome', () {
      for (final ScenarioOutcome outcome in ScenarioOutcome.values) {
        final ScenarioResult? read = ScenarioResult.fromJson(
          ScenarioResult(
            outcome: outcome,
            when: when,
            version: '0.1.0',
            steps: outcome == ScenarioOutcome.didNotRun ? 0 : 3,
            elapsed: const Duration(seconds: 40),
          ).toJson(),
        );

        expect(read?.outcome, outcome);
        expect(read?.passed, outcome == ScenarioOutcome.passed);
      }
    });

    test('still writes `passed`, for whatever reads the file by that key', () {
      final Map<String, Object?> json = ScenarioResult(
        outcome: ScenarioOutcome.didNotRun,
        when: when,
        version: '0.1.0',
        steps: 0,
        elapsed: Duration.zero,
      ).toJson();

      expect(json['passed'], isFalse);
      expect(json['outcome'], 'did-not-run');
    });

    test('reads an old green record with no steps as a run that never was', () {
      // What the file held after the hang of 2026-10-08 was killed.
      final ScenarioResult? read = ScenarioResult.fromJson(<String, Object?>{
        'passed': true,
        'when': when.toIso8601String(),
        'version': '0.1.0',
        'steps': 0,
        'elapsedMs': 1020000,
      });

      expect(read?.outcome, ScenarioOutcome.didNotRun);
      expect(read?.passed, isFalse);
      expect(read?.outcome.mark, startsWith('✘'));
    });

    test('reads an old record with steps as what it said', () {
      Map<String, Object?> old({required bool passed}) => <String, Object?>{
        'passed': passed,
        'when': when.toIso8601String(),
        'steps': 5,
      };

      expect(
        ScenarioResult.fromJson(old(passed: true))?.outcome,
        ScenarioOutcome.passed,
      );
      expect(
        ScenarioResult.fromJson(old(passed: false))?.outcome,
        ScenarioOutcome.failed,
      );
    });

    test('answers null for what is not a record', () {
      expect(ScenarioResult.fromJson('passed'), isNull);
      expect(
        ScenarioResult.fromJson(<String, Object?>{'passed': true}),
        isNull,
      );
    });
  });

  group('the mark a list row opens with', () {
    test('is green for a pass only', () {
      expect(ScenarioOutcome.passed.mark, '✓');
      for (final ScenarioOutcome outcome in ScenarioOutcome.values) {
        if (outcome != ScenarioOutcome.passed) {
          expect(outcome.mark, startsWith('✘'), reason: outcome.label);
        }
      }
    });
  });
}
