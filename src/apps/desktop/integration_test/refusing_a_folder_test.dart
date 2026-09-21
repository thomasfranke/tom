/// The one way opening a folder fails.
library;

import 'support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture loose = fixtures['not-a-repository'];
  final Fixture docsInRepo = fixtures['docs-in-repo'];

  scenario(
    'Refuses a folder that is not inside a repository',
    group: 'Validations',
    describe:
        'A named failure with an explanation, never a crash and never a '
        'quieter mode. The screen also says that creating a repository is '
        'not something TOM does, so nobody goes looking for the button.',
    steps: <Step>[
      Step('start with nothing open', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: loose.root);
      }),
      Step('choose a folder with no repository above it', (
        TomRobot robot,
      ) async {
        await robot.chooseFolder();
      }),
      Step('the refusal names the folder and explains', (TomRobot robot) async {
        await robot.seesNotARepository(loose.root);
      }),
      Step('the shell never appeared', (TomRobot robot) async {
        robot.seesNothingBroken();
      }),
    ],
  );

  scenario(
    'Offers another folder after refusing one',
    group: 'Validations',
    describe:
        'Refusing is a state to move on from, not a dead end: the screen '
        'offers the picker again, and choosing a real space from there works '
        'as if the refusal had not happened.',
    steps: <Step>[
      Step('start with nothing open', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: loose.root);
      }),
      Step('choose a folder with no repository above it', (
        TomRobot robot,
      ) async {
        await robot.chooseFolder();
      }),
      Step('see the refusal', (TomRobot robot) async {
        await robot.seesNotARepository(loose.root);
      }),
      // The picker is answered once per launch, so a second choice needs the
      // app started again pointed somewhere else. That is a limit of the
      // harness, and it is stated here rather than hidden in the robot.
      Step('start again, pointed at a real space', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
      }),
      Step('choose it', (TomRobot robot) async {
        await robot.chooseFolder();
      }),
      Step('the shell takes the window', (TomRobot robot) async {
        await robot.seesTheShell();
        robot.seesNothingBroken();
      }),
    ],
  );
}
