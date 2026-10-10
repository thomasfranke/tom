/// The commands panel: every command TOM ran, as it ran it.
library;

import 'support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture unreachable = fixtures['docs-unreachable-remote'];

  scenario(
    'Shows the commands TOM ran, and the one that failed',
    group: 'Workspace',
    describe:
        'A git client that hides git is one nobody can debug. The panel under '
        'the document lists every command the app ran, as it ran it — opened '
        'with ⌘J, never by itself. A row opens onto what the command printed. '
        'Then a fetch fails against a remote that cannot be reached, and the '
        "failure's band offers the way to the command behind it: the panel "
        'opens again on that row, already open onto what git said.',
    steps: <Step>[
      Step('open the docs folder whose remote is out of reach', (
        TomRobot robot,
      ) async {
        await robot.launchWindowed(pickFolder: unreachable.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
      }),
      Step('⌘J opens the commands, which already list what opening read', (
        TomRobot robot,
      ) async {
        await robot.pressesTheCommandsShortcut();
        await robot.seesTheCommands(<String>['git rev-parse', 'git status']);
      }),
      Step('a row opens onto what the command printed', (TomRobot robot) async {
        await robot.opensTheCommand('git rev-parse --show-toplevel');
        await robot.seesTheCommandOpen(
          'git rev-parse --show-toplevel',
          printed: '/',
        );
      }),
      Step('its × puts the panel away', (TomRobot robot) async {
        await robot.closesTheCommands();
      }),
      Step('fetching fails, and the band offers the command', (
        TomRobot robot,
      ) async {
        await robot.fetches();
        await robot.seesOnScreen(<String>['Show the command']);
      }),
      Step('which opens the panel on the failed fetch, open', (
        TomRobot robot,
      ) async {
        await robot.showsTheCommandFromTheBand();
        await robot.seesTheCommands(<String>['git fetch']);
        await robot.seesTheCommandOpen('git fetch', printed: 'tom.invalid');
      }),
      Step('⌘J closes it, and nothing is broken', (TomRobot robot) async {
        await robot.pressesTheCommandsShortcut();
        robot
          ..seesTheCommandsClosed()
          ..seesNothingBroken();
      }),
    ],
  );
}
