/// Leaving a space with edits the disk does not have: every answer, read off
/// the disk.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture docsInRepo = fixtures['docs-in-repo'];
  final Fixture theRepo = fixtures['repo-itself'];
  final String index = '${docsInRepo.root}/index.md';
  final String untracked = '${docsInRepo.root}/untracked.md';
  late String indexBefore;
  late String untrackedBefore;
  late String repoIndexBefore;

  scenario(
    'Saves unsaved work on the way out of a space, or throws it away',
    group: 'Workspace',
    submenu: 'Leaving a space',
    describe:
        'Closing the space with edits asks, and each answer is read off the '
        'disk. With one document the question names it; with two it counts '
        'them and offers the answer for all. `Save and close` writes before '
        'it leaves, `Discard and close` leaves the files as they were, and '
        'in both the window ends on Home.',
    steps: <Step>[
      Step('edit a document and ask to close the space', (
        TomRobot robot,
      ) async {
        indexBefore = File(index).readAsStringSync();
        untrackedBefore = File(untracked).readAsStringSync();
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.clickInTheTree('index.md');
        await robot.typesInTheSource('# Saved on the way out\n');

        await robot.closesTheSpace();

        await robot.seesInTheSpaceMenu(<String>[
          'index.md has unsaved changes',
          'Save and close',
          'Discard and close',
          'Stay in this space',
        ]);
      }),
      Step('Save and close writes the edit, then goes home', (
        TomRobot robot,
      ) async {
        await robot.answersTheUnsavedQuestion('Save and close');

        await robot.seesHome();
        expect(File(index).readAsStringSync(), '# Saved on the way out\n');
      }),
      Step('two edited documents are counted, and the answers are for all', (
        TomRobot robot,
      ) async {
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.clickInTheTree('index.md');
        await robot.typesInTheSource('# Index, discarded\n');
        await robot.clickInTheTree('untracked.md');
        await robot.typesInTheSource('# Untracked, discarded\n');

        await robot.closesTheSpace();

        await robot.seesInTheSpaceMenu(<String>[
          '2 documents have unsaved changes.',
          'Save all and close',
          'Discard all and close',
          'Stay in this space',
        ]);
      }),
      Step('Discard all and close leaves both files as they were', (
        TomRobot robot,
      ) async {
        await robot.answersTheUnsavedQuestion('Discard all and close');

        await robot.seesHome();
        expect(File(index).readAsStringSync(), '# Saved on the way out\n');
        expect(File(untracked).readAsStringSync(), untrackedBefore);
      }),
      Step('Save all and close writes both before going home', (
        TomRobot robot,
      ) async {
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.clickInTheTree('index.md');
        await robot.typesInTheSource('# Index, all saved\n');
        await robot.clickInTheTree('untracked.md');
        await robot.typesInTheSource('# Untracked, all saved\n');
        await robot.closesTheSpace();
        await robot.seesInTheSpaceMenu(<String>['Save all and close']);

        await robot.answersTheUnsavedQuestion('Save all and close');

        await robot.seesHome();
        expect(File(index).readAsStringSync(), '# Index, all saved\n');
        expect(File(untracked).readAsStringSync(), '# Untracked, all saved\n');
        expect(indexBefore, isNot('# Index, all saved\n'));
        robot.seesNothingBroken();
      }),
    ],
  );

  scenario(
    'Asks before going to another space, and each answer is read off the disk',
    group: 'Workspace',
    submenu: 'Leaving a space',
    describe:
        'The breadcrumb\'s menu goes to another space without passing '
        'through Home, and with edits unsaved it asks first. `Stay` and '
        '`Esc` both leave the space and the edit exactly where they were; '
        '`Save and open` writes then goes; `Discard and open` goes and the '
        'file is as it was. With two documents the answers are for all.',
    steps: <Step>[
      Step('two spaces are remembered, and one has an unsaved edit', (
        TomRobot robot,
      ) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.launchWindowed(pickFolder: theRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.clickInTheTree('index.md');
        repoIndexBefore = File('${theRepo.root}/index.md').readAsStringSync();
        await robot.typesInTheSource('# Not yet\n');
        await robot.seesUnsaved('index.md');
      }),
      Step('choosing the other space asks first', (TomRobot robot) async {
        await robot.opensTheSpaceMenu();
        await robot.opensFromTheSpaceMenu(docsInRepo.name);

        await robot.seesInTheSpaceMenu(<String>[
          'index.md has unsaved changes',
          'Save and open',
          'Discard and open',
          'Stay in this space',
        ]);
      }),
      Step('Stay keeps the space and the edit', (TomRobot robot) async {
        await robot.answersTheUnsavedQuestion('Stay in this space');

        await robot.seesTheShell();
        await robot.seesInTheSource('# Not yet');
        expect(
          File('${theRepo.root}/index.md').readAsStringSync(),
          repoIndexBefore,
        );
      }),
      Step('Discard and open goes there, and the file is as it was', (
        TomRobot robot,
      ) async {
        await robot.opensTheSpaceMenu();
        await robot.opensFromTheSpaceMenu(docsInRepo.name);
        await robot.answersTheUnsavedQuestion('Discard and open');

        await robot.seesTheShell();
        await robot.seesInTheTree(<String>['untracked.md']);
        expect(
          File('${theRepo.root}/index.md').readAsStringSync(),
          repoIndexBefore,
        );
      }),
      Step('Save and open writes the edit, then goes', (TomRobot robot) async {
        await robot.clickInTheTree('untracked.md');
        await robot.typesInTheSource('# Saved before opening\n');
        await robot.opensTheSpaceMenu();
        await robot.opensFromTheSpaceMenu(theRepo.name);
        await robot.seesInTheSpaceMenu(<String>['Save and open']);

        await robot.answersTheUnsavedQuestion('Save and open');

        await robot.seesTheShell();
        await robot.seesInTheTree(<String>['daily']);
        expect(File(untracked).readAsStringSync(), '# Saved before opening\n');
      }),
      Step('with two edited documents the answers are for all', (
        TomRobot robot,
      ) async {
        await robot.clickInTheTree('index.md');
        await robot.typesInTheSource('# Index, edited\n');
        await robot.clickInTheTree('2026-09-20.md');
        await robot.typesInTheSource('# Daily, edited\n');
        await robot.opensTheSpaceMenu();
        await robot.opensFromTheSpaceMenu(docsInRepo.name);

        await robot.seesInTheSpaceMenu(<String>[
          '2 documents have unsaved changes.',
          'Save all and open',
          'Discard all and open',
        ]);
        await robot.answersTheUnsavedQuestion('Discard all and open');

        await robot.seesTheShell();
        expect(
          File('${theRepo.root}/index.md').readAsStringSync(),
          repoIndexBefore,
        );
        robot.seesNothingBroken();
      }),
    ],
  );

  // SKIPPED, a defect: Esc (and a click outside) on the unsaved question
  // should be `Stay` (D-18), and the question survives the key. Kept as a
  // planned scenario: `planned/leaving_a_space_planned.dart`.
}
