/// Tests for the scenarios that are planned and not written: how the CLI
/// finds them, how the menu shows them, and that nothing ever runs one.
///
/// Black box where discovery is concerned: the catalogue finds the repository
/// from the script that runs it, which a test is not.
library;

import 'dart:io';

import 'package:test/test.dart';

import '../../../tool/src/commands/e2e_catalogue.dart';

void main() {
  group('counting', () {
    const Scenario written = Scenario(
      name: 'Written',
      group: 'Home',
      describe: '',
      file: 'a_test.dart',
      needsEnvironment: false,
    );
    const Scenario planned = Scenario(
      name: 'Planned',
      group: 'Home',
      describe: '',
      file: 'planned/a_planned.dart',
      needsEnvironment: false,
      survey: '4-09',
    );

    test('a scenario with a survey id is a plan, and one without is not', () {
      expect(written.isPlanned, isFalse);
      expect(planned.isPlanned, isTrue);
    });

    test('the counts say how many of each', () {
      final ({int planned, int written}) counts = countScenarios(<Scenario>[
        written,
        written,
        planned,
      ]);
      expect(counts.written, 2);
      expect(counts.planned, 1);
      expect(describeCounts(counts), '2 written · 1 planned');
    });

    test('the refusal names the survey id', () {
      expect(plannedRefusal(planned), 'planned — not written yet (4-09)');
    });
  });

  group('discovery, through the list', () {
    final ProcessResult list = _tom(<String>['e2e', 'list']);
    final String text = _plain(list.stdout as String);

    test('says how many are written and how many are planned', () {
      expect(list.exitCode, 0);
      expect(text, matches(RegExp(r'\d+ written · \d+ planned')));
    });

    test('shows a plan under its group with its mark and its id', () {
      expect(text, contains('Holds a request in flight'));
      expect(text, contains('○ planned · 4-09'));
    });

    test('shows a written scenario with a result, not as a plan', () {
      final String row = text
          .split('\n')
          .firstWhere((String l) => l.contains('Creates a document from'));
      expect(row, isNot(contains('planned')));
    });

    test('lists every plan after the written ones of its group', () {
      final int written = text.indexOf('Says the link is down');
      final int planned = text.indexOf('Holds a request in flight');
      expect(written, isNonNegative);
      expect(planned, greaterThan(written));
    });
  });

  group('the menu', () {
    final ProcessResult screen = _tom(<String>[
      '--preview',
      'e2e',
      'Git',
      '›',
      'Remote',
    ]);
    final String text = _plain(screen.stdout as String);

    test('shows a plan under its group, with its own mark', () {
      expect(screen.exitCode, 0);
      expect(text, contains('Holds a request in flight'));
      expect(text, contains('○ planned · 4-09'));
    });

    test('lists the plans after every written scenario', () {
      expect(
        text.indexOf('Says the link is down'),
        lessThan(text.indexOf('Holds a request in flight')),
      );
    });

    test('says how many are written and how many planned', () {
      final ProcessResult groups = _tom(<String>['--preview', 'e2e']);
      expect(
        _plain(groups.stdout as String),
        matches(RegExp(r'\d+ written · \d+ planned')),
      );
    });
  });

  group('running', () {
    test('a plan is refused, naming its survey id, and nothing is built', () {
      final ProcessResult result = _tom(<String>[
        'e2e',
        'Holds a request in flight',
      ]);
      expect(result.exitCode, plannedExitCode);
      expect(
        _plain('${result.stderr}${result.stdout}'),
        contains('planned — not written yet (4-09)'),
      );
      // Refused before the environment: no build, no app.
      expect(result.stdout, isNot(contains('BUILD')));
    });

    test('a name nobody declared is still a usage error', () {
      final ProcessResult result = _tom(<String>['e2e', 'No such scenario']);
      expect(result.exitCode, 64);
      expect(result.stderr, isNot(contains('Holds a request in flight')));
    });
  });
}

/// [text] without its colours.
String _plain(String text) =>
    text.replaceAll(RegExp(r'\x1B\[[0-9;?]*[a-zA-Z]'), '');

ProcessResult _tom(List<String> arguments) => Process.runSync(
  Platform.resolvedExecutable,
  <String>['run', 'tool/cli.dart', ...arguments],
  workingDirectory: _repositoryRoot.path,
);

Directory get _repositoryRoot {
  Directory directory = Directory.current;
  for (int level = 0; level < 8; level++) {
    if (File('${directory.path}/Makefile').existsSync() &&
        File('${directory.path}/src/pubspec.yaml').existsSync()) {
      return directory;
    }
    directory = directory.parent;
  }
  throw StateError('The repository root was not found.');
}
