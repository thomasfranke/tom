/// The breadcrumb's menu: going to another space, and going home.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture docsInRepo = fixtures['docs-in-repo'];
  final Fixture theRepo = fixtures['repo-itself'];
  late String indexOnDisk;

  scenario(
    'Leaves a space, and goes to another without going home',
    group: 'Workspace',
    submenu: 'Leaving a space',
    describe:
        'A space is always leavable: a home button before the breadcrumb is '
        'the way out, one press to the opening screen. The menu the '
        'breadcrumb opens lists what was open before — marking the one on '
        'screen — and going to another one from there skips the trip '
        'through Home, which is a step with nothing in it.',
    steps: <Step>[
      Step('open a docs folder inside a repository', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();

        await robot.seesTheShell();
      }),
      Step('and then a second space, so there are two to choose between', (
        TomRobot robot,
      ) async {
        // Relaunched rather than switched: the folder dialog answers one
        // folder per run, and the recents outlive the restart.
        await robot.launchWindowed(pickFolder: theRepo.root);
        await robot.chooseFolder();

        await robot.seesTheShell();
      }),
      Step('the breadcrumb opens a menu of both, and marks the one open', (
        TomRobot robot,
      ) async {
        await robot.opensTheSpaceMenu();

        await robot.seesInTheSpaceMenu(<String>[
          'RECENT SPACES',
          docsInRepo.name,
          theRepo.name,
        ]);
        await robot.seesTheOpenSpaceTickedAndInert(theRepo.name);
      }),
      Step('choosing the other one goes straight there', (
        TomRobot robot,
      ) async {
        await robot.opensFromTheSpaceMenu(docsInRepo.name);

        await robot.seesTheShell();
        await robot.seesInTheTree(<String>['index.md']);
      }),
      Step('leaving with unsaved work asks first, and staying is an answer', (
        TomRobot robot,
      ) async {
        await robot.clickInTheTree('index.md');
        indexOnDisk = File('${docsInRepo.root}/index.md').readAsStringSync();
        await robot.typesInTheSource('# Not saved yet\n');
        // Pressed with the menu closed: the question opens it.
        await robot.closesTheSpace();

        // It names the document it is about.
        await robot.seesInTheSpaceMenu(<String>[
          'index.md has unsaved changes',
        ]);
      }),
      Step('Stay in this space keeps the space and the edit', (
        TomRobot robot,
      ) async {
        await robot.answersTheUnsavedQuestion('Stay in this space');
        await robot.seesTheShell();
        await robot.seesInTheSource('# Not saved yet');
      }),
      Step('the question is asked again', (TomRobot robot) async {
        await robot.closesTheSpace();
        await robot.seesInTheSpaceMenu(<String>[
          'index.md has unsaved changes',
        ]);
      }),
      Step('and discarding it returns to the opening screen', (
        TomRobot robot,
      ) async {
        await robot.answersTheUnsavedQuestion('Discard and close');

        await robot.seesHome();
        // What was typed never reached the file.
        expect(
          File('${docsInRepo.root}/index.md').readAsStringSync(),
          indexOnDisk,
        );
      }),
      Step('and nothing is broken', (TomRobot robot) async {
        robot.seesNothingBroken();
      }),
    ],
  );

  scenario(
    'Closes the window only once unsaved work was answered for',
    group: 'Workspace',
    submenu: 'Leaving a space',
    describe:
        'Closing the window is leaving too, and it is the one way out that '
        'used to ask nothing. The window\'s own close is held back while a '
        'tab has edits the disk does not, and the question leaving a space '
        'asks is asked instead — stay, discard or save — with the file on '
        'disk checked after each answer.',
    steps: <Step>[
      Step('with nothing unsaved the window closes at once', (
        TomRobot robot,
      ) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();

        await robot.closesTheWindow();

        await robot.seesTheWindowClosed();
      }),
      Step('with an unsaved document it stays open and asks', (
        TomRobot robot,
      ) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.clickInTheTree('untracked.md');
        await robot.typesInTheSource('# Not saved yet\n');

        await robot.closesTheWindow();

        await robot.seesInTheSpaceMenu(<String>[
          'has unsaved changes',
          'Closing the window leaves TOM',
          'Save and close',
          'Discard and close',
          'Stay in this space',
        ]);
        robot.seesTheWindowStillOpen(times: 1);
      }),
      Step('Stay keeps the window, the space and the edit', (
        TomRobot robot,
      ) async {
        await robot.answersTheUnsavedQuestion('Stay in this space');

        await robot.seesTheShell();
        await robot.seesUnsaved('untracked.md');
        robot.seesTheWindowStillOpen(times: 1);
      }),
      Step('Discard and close closes it, and the file is as it was', (
        TomRobot robot,
      ) async {
        await robot.closesTheWindow();
        await robot.answersTheUnsavedQuestion('Discard and close');

        await robot.seesTheWindowClosed(times: 2);
        expect(
          File('${docsInRepo.root}/untracked.md').readAsStringSync(),
          isNot(contains('Not saved yet')),
        );
      }),
      Step('Save and close writes the edit first, then closes', (
        TomRobot robot,
      ) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.clickInTheTree('untracked.md');
        await robot.typesInTheSource('# Saved on the way out\n');
        await robot.closesTheWindow();
        await robot.answersTheUnsavedQuestion('Save and close');

        await robot.seesTheWindowClosed(times: 3);
        expect(
          File('${docsInRepo.root}/untracked.md').readAsStringSync(),
          '# Saved on the way out\n',
        );
        robot.seesNothingBroken();
      }),
    ],
  );
}
