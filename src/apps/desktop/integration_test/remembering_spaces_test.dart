/// The recent list: what Home offers to go back to.
library;

import 'support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture docsInRepo = fixtures['docs-in-repo'];

  scenario(
    'Remembers a space, and offers it on the next visit',
    describe:
        'One click back into a space is the reason Home has a list at all. '
        'Opening one records it; starting again offers it by name.',
    steps: <Step>[
      Step('open a space', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
      }),
      Step('the shell takes the window', (TomRobot robot) async {
        await robot.seesTheShell();
      }),
      Step('start the app again', (TomRobot robot) async {
        await robot.launchWindowed();
      }),
      Step('Home offers the space it remembers', (TomRobot robot) async {
        await robot.seesHome();
        await robot.seesRecent(<String>[docsInRepo.name]);
      }),
      Step('clicking it opens the space again', (TomRobot robot) async {
        await robot.openRecent(docsInRepo.name);
        await robot.seesTheShell();
        robot.seesNothingBroken();
      }),
    ],
  );

  scenario(
    'Forgets a space without touching the folder',
    describe:
        'What the user reaches for when a row points somewhere that is gone. '
        'Forgetting removes the row and nothing else — the folder is still '
        'there to pick again.',
    steps: <Step>[
      Step('open a space so there is one to forget', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        // Remembering is part of opening, so the space is on the list only
        // once the shell is up — restarting before that would forget it
        // for the wrong reason.
        await robot.seesTheShell();
      }),
      Step('start the app again', (TomRobot robot) async {
        await robot.launchWindowed();
      }),
      Step('it is offered', (TomRobot robot) async {
        await robot.seesRecent(<String>[docsInRepo.name]);
      }),
      Step('forget it', (TomRobot robot) async {
        await robot.forgetRecent(docsInRepo.name);
      }),
      Step('the list is empty, and Home still offers the picker', (
        TomRobot robot,
      ) async {
        await robot.seesNoRecent();
        await robot.seesHome();
        robot.seesNothingBroken();
      }),
    ],
  );
}
