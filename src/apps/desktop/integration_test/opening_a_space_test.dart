/// Opening a space: the first thing anyone does with TOM.
library;

import 'support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture docsInRepo = fixtures['docs-in-repo'];
  final Fixture repoItself = fixtures['repo-itself'];

  scenario(
    'Opens a docs folder inside a repository',
    describe:
        'The normal case, and the one a path bug shows up in: the user picks '
        'docs/ and git has to run against the repository above it. The shell '
        'takes the window and Home is gone.',
    steps: <Step>[
      Step('start with nothing open', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
      }),
      Step('see Home, with no space and nothing to go back to', (
        TomRobot robot,
      ) async {
        await robot.seesHome();
        await robot.seesNoRecent();
      }),
      Step('choose the docs folder', (TomRobot robot) async {
        await robot.chooseFolder();
      }),
      Step('the shell takes the window', (TomRobot robot) async {
        await robot.seesTheShell();
      }),
      Step('and nothing is broken', (TomRobot robot) async {
        robot.seesNothingBroken();
      }),
    ],
  );

  scenario(
    'Opens a repository at its own root',
    describe:
        'The other shape of a space, where root and repositoryRoot are the '
        'same folder. It opens exactly like the nested one — which is the '
        'point: the two shapes are one code path.',
    steps: <Step>[
      Step('start with nothing open', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: repoItself.root);
      }),
      Step('choose the repository itself', (TomRobot robot) async {
        await robot.chooseFolder();
      }),
      Step('the shell takes the window', (TomRobot robot) async {
        await robot.seesTheShell();
        robot.seesNothingBroken();
      }),
    ],
  );
}
