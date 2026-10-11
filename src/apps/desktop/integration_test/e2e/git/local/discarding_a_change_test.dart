/// The ↶ at the end of a changes row: one file put back, after asking.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../support/harness.dart';

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
    group: 'Git',
    submenu: 'Local',
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

  scenario(
    'Puts back only what is not staged',
    group: 'Git',
    submenu: 'Local',
    describe:
        'A row under `CHANGES` goes back to what is staged — not to the last '
        'commit — and the question says so, because what is staged is work '
        'somebody chose to keep. `Cancel` changes nothing; answered, the '
        'working tree equals the index and **git itself** still holds the '
        'staged change.',
    steps: <Step>[
      Step('stage one new file and leave one edit unstaged', (
        TomRobot robot,
      ) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.seesInTheChanges(<String>['untracked.md', 'writing.md']);
        await robot.stages('untracked.md');

        expect(
          git(<String>['diff', '--cached', '--name-only']),
          'docs/untracked.md',
        );
      }),
      Step('its ↶ says what is staged stays', (TomRobot robot) async {
        await robot.discardsTheChange('writing.md');

        await robot.seesOnScreen(<String>[
          'Discard changes to writing.md?',
          'Everything not staged is lost. What is already staged stays.',
        ]);
      }),
      Step('Cancel changes nothing', (TomRobot robot) async {
        await robot.tapInTheDialog('Cancel');

        await robot.seesInTheChanges(<String>['writing.md', 'untracked.md']);
        expect(
          File('${docsInRepo.root}/guides/writing.md').readAsStringSync(),
          contains('One line added, uncommitted.'),
        );
        expect(git(<String>['status', '--porcelain']), contains('writing.md'));
      }),
      Step('answered, the working tree equals the index', (
        TomRobot robot,
      ) async {
        await robot.discardsTheChange('writing.md');
        await robot.tapInTheDialog('Discard changes');

        await robot.seesNotInTheChanges('writing.md');
        expect(git(<String>['diff', '--name-only']), isEmpty);
        expect(
          File('${docsInRepo.root}/guides/writing.md').readAsStringSync(),
          isNot(contains('One line added, uncommitted.')),
        );
      }),
      Step('and what was staged is still staged', (TomRobot robot) async {
        expect(
          git(<String>['diff', '--cached', '--name-only']),
          'docs/untracked.md',
        );
        await robot.seesInTheChanges(<String>['untracked.md']);
        robot.seesNothingBroken();
      }),
    ],
  );

  scenario(
    'Keeps a file that was committed after its row was drawn',
    group: 'Git',
    submenu: 'Local',
    describe:
        'A row drawn as *new* promises that its ↶ deletes a file git never '
        'had. The app has a terminal, so the row can be older than the '
        'repository: here the file is committed outside the app between the '
        'row being drawn and its ↶ being pressed. **Git is asked again at '
        'the moment of deleting**, the file is kept, the column says why, '
        'and the list is read again.',
    steps: <Step>[
      Step('open a space listing a file git never had', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.seesInTheChanges(<String>['untracked.md']);
      }),
      Step('it is committed outside the app, and its ↶ still offers to '
          'delete it', (TomRobot robot) async {
        // In a terminal, as far as the app knows: nothing watches the folder.
        git(<String>['add', 'docs/untracked.md']);
        git(<String>['commit', '--quiet', '-m', 'docs: committed meanwhile']);
        expect(git(<String>['ls-files', 'docs/untracked.md']), isNotEmpty);

        await robot.discardsTheChange('untracked.md');
        await robot.seesOnScreen(<String>['Delete untracked.md?']);
      }),
      Step('answered, the file is kept and the column says why', (
        TomRobot robot,
      ) async {
        await robot.tapInTheDialog('Delete');

        await robot.seesTheGitColumnSaying(
          'untracked.md is in the last commit, so it was not deleted. The '
          'list has been read again.',
        );
        expect(File('${docsInRepo.root}/untracked.md').existsSync(), isTrue);
        expect(
          git(<String>['log', '--format=%s', '-1']),
          'docs: committed meanwhile',
        );
      }),
      Step('and its row is gone, because the list was read again', (
        TomRobot robot,
      ) async {
        await robot.seesNotInTheChanges('untracked.md');
        await robot.seesInTheChanges(<String>['writing.md']);
        robot.seesNothingBroken();
      }),
    ],
  );
}
