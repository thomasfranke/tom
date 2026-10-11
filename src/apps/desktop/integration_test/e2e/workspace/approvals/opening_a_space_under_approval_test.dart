/// Opening a folder, or cloning one, while git waits for a yes.
library;

import 'dart:io';

import '../../../support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture docs = fixtures['docs-behind-remote'];
  final Fixture toClone = fixtures['docs-to-clone'];
  final String clones = '${E2eFixtures.directory}/clones-approval';

  scenario(
    'Opens a local folder under Manual, its files shown while git waits',
    group: 'Workspace',
    submenu: 'Approvals',
    describe:
        'Manual was chosen last time, so every git command waits for a yes — '
        'and a folder on this machine must not wait behind them. Picking it '
        'on Home opens the workspace at once with its tree and its files; '
        'where the repository is, and everything git reads after, wait in '
        'the Commands panel, which opens by itself, as one plan. `Run` on '
        'each lets the git column fill in. The same folder again, `Deny` '
        'leaves the files where they are and the column out of date.',
    steps: <Step>[
      Step('Home asks nothing by itself; the account is read when asked', (
        TomRobot robot,
      ) async {
        robot.seedsTheGitMode('manual');
        await robot.launchWindowed(pickFolder: docs.root);
        await robot.seesHome();
        robot.seesCommandsWaiting(0);
        await robot.seesNotOnScreen('Reading the account');

        await robot.opensTheUnreadAccount();

        await robot.seesTheCommands(<String>['Reading the account']);
        await robot.runsEverythingThatWaits();
      }),
      Step('the folder opens at once, with its files, and git still waits', (
        TomRobot robot,
      ) async {
        await robot.chooseFolder();

        await robot.seesTheShell();
        await robot.seesInTheTree(<String>['index.md', 'writing.md']);
        await robot.seesTheCommands(<String>['git ']);
        await robot.seesOnScreen(<String>['Run', 'Always allow', 'Deny']);
      }),
      Step('Run on each command lets the git column fill in, in one plan', (
        TomRobot robot,
      ) async {
        await robot.runsEverythingThatWaits();

        await robot.seesTheCommands(<String>[
          'Reading the repository · 4 commands',
        ]);
        await robot.seesNotOnScreen('Opening the space');
        await robot.seesInTheTree(<String>['index.md', 'writing.md']);
      }),
      Step('the next time, Deny keeps the files and says it is out of date', (
        TomRobot robot,
      ) async {
        await robot.launchWindowed(pickFolder: docs.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.seesInTheTree(<String>['index.md', 'writing.md']);

        await robot.answersTheWaitingCommand('Deny');

        await robot.seesOnScreen(<String>['denied']);
        await robot.seesInTheTree(<String>['index.md', 'writing.md']);
        await robot.seesNotOnScreen('Choose folder…');
      }),
    ],
  );

  scenario(
    'Opens a local folder under Semi-automatic, and Always allow remembers',
    group: 'Workspace',
    submenu: 'Approvals',
    describe:
        'In Semi-automatic every command starts `false`, so finding the '
        'repository waits behind the panel the same way, and the folder '
        'shows its files meanwhile. `Always allow` on the first command '
        'writes `true` beside it in `git-approvals.json`; the one after it, '
        'another command, still asks.',
    steps: <Step>[
      Step('a folder is picked; its files show and the first command waits', (
        TomRobot robot,
      ) async {
        robot.seedsTheGitMode('semi');
        await robot.launchWindowed(pickFolder: docs.root);
        // Semi reads the account at once: every key starts `false`, so that
        // read waits first and is let through.
        await robot.runsEverythingThatWaits();
        await robot.chooseFolder();

        await robot.seesTheShell();
        await robot.seesInTheTree(<String>['index.md', 'writing.md']);
        await robot.seesTheCommands(<String>['git ']);
      }),
      Step('Always allow writes that command, and the next still asks', (
        TomRobot robot,
      ) async {
        await robot.answersTheWaitingCommand('Always allow');

        // What else asks still asks: it is let through one by one.
        await robot.runsEverythingThatWaits();
        robot.seesTheApprovalsFileSaying(<String>['": true']);
      }),
    ],
  );

  scenario(
    'Clones under Manual, from the panel on Home',
    group: 'Workspace',
    submenu: 'Approvals',
    describe:
        'The clone is a command that waits: the panel is on Home with '
        '`git clone`, and `Deny` puts the address field back as it was, '
        'with nothing cloned. `Run` clones, and the new folder then opens '
        'with its files while the reads that follow wait their turn.',
    steps: <Step>[
      Step('the clone waits on Home', (TomRobot robot) async {
        Directory(clones).createSync(recursive: true);
        robot.seedsTheGitMode('manual');
        await robot.launchWindowed(pickFolder: clones);
        await robot.clonesFromUrl(toClone.remoteRoot);

        await robot.seesTheCommands(<String>[' clone --progress']);
        await robot.seesOnScreen(<String>['Run', 'Deny']);
      }),
      Step('Deny leaves Home as it was before the press', (
        TomRobot robot,
      ) async {
        await robot.answersTheWaitingCommand('Deny');

        await robot.seesOnScreen(<String>['denied']);
        await robot.seesNotOnScreen('EXPLORER');
      }),
    ],
  );
}
