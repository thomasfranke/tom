/// A folder git knows nothing about opens, and only git's column says so.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture loose = fixtures['not-a-repository'];

  scenario(
    'Opens a folder that is not inside a repository',
    group: 'Workspace',
    submenu: 'Without a repository',
    describe:
        'A space is a folder, not a repository. A folder with no git above it '
        'opens like any other — the tree, the editor, the preview and a save '
        'all work — and the right column is the one place that says nothing '
        'here is versioned, with no control that could not work. Git is asked '
        'once, to find there is no repository, and never again.',
    steps: <Step>[
      Step('open a folder with no repository above it', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: loose.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
      }),
      Step('the tree lists it, folders first', (TomRobot robot) async {
        await robot.seesInTheTree(<String>['guides', 'notes.md']);
      }),
      Step('the right column says so, and offers nothing git would do', (
        TomRobot robot,
      ) async {
        await robot.seesNoRepository();
        // The one git control that stays, muted.
        await robot.seesOnScreen(<String>['Pull request']);
      }),
      Step('a document opens in source and preview', (TomRobot robot) async {
        await robot.clickInTheTree('notes.md');
        await robot.seesTheOpenDocument('notes.md');
        await robot.seesInTheSource('# Notes');
        await robot.seesInThePreview('No repository above this folder.');
      }),
      Step('typing reaches the preview, and the document is unsaved', (
        TomRobot robot,
      ) async {
        await robot.typesInTheSource('# Notes\n\nEdited with no git.\n');
        await robot.seesInThePreview('Edited with no git.');
        await robot.seesUnsaved('notes.md');
      }),
      Step('saving writes the file on disk', (TomRobot robot) async {
        await robot.saves();
        await robot.seesNothingUnsaved('notes.md');
        // Read off the disk: the buffer is not the proof.
        expect(
          File('${loose.root}/notes.md').readAsStringSync(),
          '# Notes\n\nEdited with no git.\n',
        );
      }),
      Step('the commands hold the one check, and no other git', (
        TomRobot robot,
      ) async {
        await robot.pressesTheCommandsShortcut();
        await robot.seesTheCommands(<String>['git rev-parse']);
        for (final String never in <String>[
          'git status',
          'git log',
          'git diff',
          'git show',
          'git for-each-ref',
        ]) {
          robot.seesNoCommand(never);
        }
      }),
      Step('and the column still says the same, nothing broken', (
        TomRobot robot,
      ) async {
        await robot.seesNoRepository();
        robot.seesNothingBroken();
      }),
    ],
  );
}
