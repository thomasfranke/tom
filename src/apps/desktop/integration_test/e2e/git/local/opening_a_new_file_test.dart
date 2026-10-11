/// A file git has never seen: opened, compared with nothing, and no red row.
library;

import 'package:flutter_test/flutter_test.dart';

import '../../../support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture docsInRepo = fixtures['docs-in-repo'];

  scenario(
    'Opens a new file without a failed command',
    group: 'Git',
    submenu: 'Local',
    describe:
        'A document that exists only on disk has no earlier version, and that '
        'is an ordinary answer, not an error: opening it marks every block '
        'added and the Commands panel lists no red row — TOM does not ask git '
        'for a committed text the status already says is not there '
        '(`docs/product/diff/rendered-diff/what-is-compared/doc.md`).',
    steps: <Step>[
      Step('open the space with an untracked document in it', (
        TomRobot robot,
      ) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.seesInTheChanges(<String>['untracked.md']);
      }),
      Step('the untracked document opens with every block marked added', (
        TomRobot robot,
      ) async {
        await robot.clickInTheTree('untracked.md');
        await robot.seesTheOpenDocument('untracked.md');

        // A heading and a paragraph: two blocks, both added.
        await robot.seesTheDiffMarks(<String>['A', 'A']);
      }),
      Step('git was never asked, and the Commands panel has no red row', (
        TomRobot robot,
      ) async {
        await robot.pressesTheCommandsShortcut();

        await robot.seesTheCommands(<String>['status']);
        expectNothingAskedAbout(robot, 'untracked.md');
        robot.seesNoFailedCommand();
      }),
      Step('a document created in the app draws no red row either', (
        TomRobot robot,
      ) async {
        await robot.createsADocument('draft.md');
        await robot.seesTheOpenDocument('draft.md');

        // The status may not list it yet when it opens, so git can be asked
        // once: its "no such path" is then a declared answer, not red.
        robot
          ..seesNoFailedCommand()
          ..seesNothingBroken();
      }),
    ],
  );
}

/// No `git show` was started for [name].
void expectNothingAskedAbout(TomRobot robot, String name) {
  expect(
    robot.commandsRun('show HEAD:docs/$name'),
    0,
    reason: 'git was asked for a version of $name that cannot exist',
  );
}
