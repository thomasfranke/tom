/// The breadcrumb's menu: going to another space, and going home.
library;

import 'support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture docsInRepo = fixtures['docs-in-repo'];
  final Fixture theRepo = fixtures['repo-itself'];

  scenario(
    'Leaves a space, and goes to another without going home',
    group: 'Workspace',
    describe:
        'A space is always leavable, and the breadcrumb is the way out: it '
        'already names the space, so nothing else in the bar has to. The '
        'menu it opens lists what was open before — marking the one on '
        'screen — and carries `Close space` at its foot. Going to another '
        'one from there skips the trip through Home, which is a step with '
        'nothing in it.',
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
          'Close space',
        ]);
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
        await robot.typesInTheSource('# Not saved yet\n');
        await robot.opensTheSpaceMenu();
        await robot.closesTheSpace();

        await robot.seesInTheSpaceMenu(<String>['has unsaved changes']);
        await robot.answersTheUnsavedQuestion('Stay in this space');
        await robot.seesTheShell();
      }),
      Step('and discarding it returns to the opening screen', (
        TomRobot robot,
      ) async {
        await robot.opensTheSpaceMenu();
        await robot.closesTheSpace();
        await robot.answersTheUnsavedQuestion('Discard and close');

        await robot.seesHome();
      }),
      Step('and nothing is broken', (TomRobot robot) async {
        robot.seesNothingBroken();
      }),
    ],
  );
}
