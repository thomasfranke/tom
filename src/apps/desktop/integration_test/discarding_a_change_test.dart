/// The ↶ at the end of a changes row: one file put back, after asking.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture docsInRepo = fixtures['docs-in-repo'];

  /// What git says about the fixture, asked outside the app entirely.
  String git(List<String> arguments) =>
      (Process.runSync('git', <String>[
                '-C',
                docsInRepo.repositoryRoot,
                ...arguments,
              ]).stdout
              as String)
          .trim();

  scenario(
    'Puts one file back from the changes list',
    group: 'Git — local',
    describe:
        'Every row of the changes list ends in a ↶, and how far back it goes '
        'is the row\'s: a staged file goes back to the last commit, a file '
        'git never had is deleted. Both ask first, through the dialog every '
        'destructive action uses, and **git itself** is asked afterwards what '
        'is left. Pressing the staged row\'s name opens it with the diff on, '
        'which is how the change is seen before it is thrown away. A row in '
        '`CHANGES` going back to what is staged is the unit and integration '
        'tests\'.',
    steps: <Step>[
      Step('open a space with two things changed in it', (
        TomRobot robot,
      ) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.seesInTheChanges(<String>['untracked.md', 'writing.md']);
      }),
      Step('a staged change opens with the diff on', (TomRobot robot) async {
        await robot.stages('writing.md');
        await robot.opensTheChange('writing.md');

        await robot.seesTheTabs(<String>['writing.md']);
        await robot.seesInThePreview('One line added, uncommitted.');
      }),
      Step('its ↶ asks first, naming the last commit', (TomRobot robot) async {
        await robot.discardsTheChange('writing.md');

        await robot.seesOnScreen(<String>[
          'Discard changes to writing.md?',
          'Everything changed since the last commit is lost, staged or not.',
        ]);
      }),
      Step('answered, the document is the last commit again', (
        TomRobot robot,
      ) async {
        await robot.tapInTheDialog('Discard changes');

        await robot.seesNotInTheChanges('writing.md');
        await robot.seesNotInThePreview('One line added, uncommitted.');
        expect(git(<String>['status', '--porcelain']), '?? docs/untracked.md');
      }),
      Step('a file git never had is deleted, after saying so', (
        TomRobot robot,
      ) async {
        await robot.discardsTheChange('untracked.md');
        await robot.seesOnScreen(<String>[
          'Delete untracked.md?',
          'It was never committed, so it cannot come back.',
        ]);
        await robot.tapInTheDialog('Delete');

        await robot.seesACleanTree();
        expect(File('${docsInRepo.root}/untracked.md').existsSync(), isFalse);
      }),
      Step('and nothing is broken', (TomRobot robot) async {
        robot.seesNothingBroken();
      }),
    ],
  );
}
