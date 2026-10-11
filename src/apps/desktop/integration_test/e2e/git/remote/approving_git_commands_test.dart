/// Who says yes before git runs: nobody, a list, or the person every time.
library;

import 'package:flutter_test/flutter_test.dart';

import '../../../support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture behind = fixtures['docs-behind-remote'];

  scenario(
    'Asks before git runs, in Manual and Semi-automatic',
    group: 'Git',
    submenu: 'Remote',
    describe:
        'The three modes of `GIT COMMANDS`. In **Automatic**, the default, '
        'nothing waits. In **Manual** every command waits — the reads '
        'included — and the Commands panel opens by itself with `Run`, '
        '`Always allow` and `Deny`: a denial stops the action and leaves '
        'git untouched, `Always allow` in Manual first asks whether to leave '
        'it, and switching writes `true` beside that one command in '
        '`git-approvals.json`. In **Semi-automatic** that command runs '
        'unasked from then on and says `allowed`, while every other command '
        'still waits.',
    steps: <Step>[
      Step('open a space whose remote has moved on; nothing asks', (
        TomRobot robot,
      ) async {
        await robot.launchWindowed(pickFolder: behind.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.seesTheDrift(ahead: 1);

        robot
          ..seesTheCommandsClosed()
          ..seesCommandsWaiting(0);
      }),
      Step('the popover offers the three modes, Automatic chosen', (
        TomRobot robot,
      ) async {
        await robot.opensThePreferences();

        await robot.seesOnScreen(<String>[
          'GIT COMMANDS',
          'Automatic',
          'Semi',
          'Manual',
          'Open git-approvals.json',
          'Every command runs as soon as it is asked for; the Commands panel '
              'only keeps the record.',
        ]);
      }),
      Step('Manual applies when pressed, and says what it does', (
        TomRobot robot,
      ) async {
        await robot.choosesTheGitMode('Manual');

        await robot.seesOnScreen(<String>[
          'Every command waits for your approval, reads included.',
        ]);
        await robot.opensThePreferences();
        await robot.seesNotOnScreen('GIT COMMANDS');
      }),
      Step('fetching waits: the panel opens itself and the button says so', (
        TomRobot robot,
      ) async {
        // Switching mode makes the window read again (the diff's base), and
        // that read waits too: it is let through before the fetch is asked.
        await robot.runsEverythingThatWaits();
        await robot.startsThe('Fetch');

        await robot.seesTheCommands(<String>['git remote get-url origin']);
        await robot.seesOnScreen(<String>[
          'Waiting for approval',
          'Run',
          'Always allow',
          'Deny',
          'Manual · 1 waiting',
        ]);
        expect(robot.commandsRun('git fetch'), 0);
      }),
      Step('Deny stops the action and git is left alone', (
        TomRobot robot,
      ) async {
        await robot.answersTheWaitingCommand('Deny');

        await robot.seesOnScreen(<String>['denied']);
        await robot.seesNotOnScreen('Waiting for approval');
        expect(robot.commandsRun('git fetch'), 0);
        // What the window does next is read again, and that waits too.
        await robot.runsEverythingThatWaits();
        await robot.seesTheDrift(ahead: 1);
      }),
      Step('fetching again, Run lets the first command through', (
        TomRobot robot,
      ) async {
        await robot.startsThe('Fetch');
        await robot.answersTheWaitingCommand('Run');

        await robot.seesTheCommands(<String>['git fetch']);
        // Listed, and still waiting: it has not run.
        expect(robot.commandsRun('git fetch'), 1);
        robot.seesCommandsWaiting(1);
      }),
      Step('Always allow in Manual asks first, and staying changes nothing', (
        TomRobot robot,
      ) async {
        await robot.answersTheWaitingCommand('Always allow');

        await robot.seesOnScreen(<String>[
          'Switch to Semi-automatic?',
          'Stay in Manual',
        ]);
        await robot.tapText('Stay in Manual');

        await robot.seesNotOnScreen('Switch to Semi-automatic?');
        await robot.seesOnScreen(<String>['Run', 'Always allow', 'Deny']);
        robot.seesCommandsWaiting(1);
      }),
      Step('switching allows that one command and runs it', (
        TomRobot robot,
      ) async {
        await robot.answersTheWaitingCommand('Always allow');
        await robot.tapText('Switch to Semi-automatic');
        await robot.runsEverythingThatWaits();

        await robot.seesTheDrift(ahead: 1, behind: 2);
        robot.seesTheApprovalsFileSaying(<String>['"git fetch": true']);
      }),
      Step('in Semi-automatic the allowed fetch runs unasked, and says so', (
        TomRobot robot,
      ) async {
        await robot.startsThe('Fetch');
        // The read in front of it is not on the list, so it waits.
        await robot.answersTheWaitingCommand('Run');
        await robot.runsEverythingThatWaits();

        await robot.seesTheCommands(<String>['allowed ·']);
        robot.seesCommandsWaiting(0);
      }),
    ],
  );
}
