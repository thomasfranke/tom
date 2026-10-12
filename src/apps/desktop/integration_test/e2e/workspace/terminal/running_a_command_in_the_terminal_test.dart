/// The Terminal tab: the person's own shell, at the repository's root.
library;

import '../../../support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture docsInRepo = fixtures['docs-in-repo'];

  scenario(
    'Runs git in the terminal under the document',
    group: 'Workspace',
    submenu: 'Terminal',
    describe:
        'What the app does not do is still a git command away, and should not '
        'cost a second window. The panel under the document has a Terminal '
        "tab beside Commands: the person's own shell, started the first time "
        "the tab is shown, at the root of the space's repository rather than "
        'the folder that was opened. What is typed there runs there, and is '
        'not written into the commands TOM ran.',
    steps: <Step>[
      Step('open the docs folder inside a repository', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
      }),
      Step('⌘J opens the panel on Commands', (TomRobot robot) async {
        await robot.pressesTheCommandsShortcut();
        await robot.seesTheCommands(<String>['git status']);
      }),
      Step('the Terminal tab starts the shell at the repository root', (
        TomRobot robot,
      ) async {
        await robot.choosesTheBottomTab('Terminal');
        await robot.seesTheTerminalRunning(
          folder: docsInRepo.repositoryRoot.split('/').last,
        );
      }),
      Step('git status runs there, and says what changed', (
        TomRobot robot,
      ) async {
        await robot.runsInTheTerminal('git status');
        await robot.seesInTheTerminal('On branch');
        await robot.seesInTheTerminal('docs/untracked.md');
      }),
      Step('a program that negotiates and draws like Claude Code reads plain', (
        TomRobot robot,
      ) async {
        await robot.runsInTheTerminal(
          r"printf '\033[>4m\033[38;2;215;119;87m ▐▛███▜▌\033[0m "
          r"\033[1mbold\033[22m plain\n────────\n'",
        );
        await robot.seesInTheTerminal('▐▛███▜▌ bold plain');
        robot.seesNothingUnderlinedInTheTerminal();
      }),
      Step('what was typed is not among the commands TOM ran', (
        TomRobot robot,
      ) async {
        await robot.choosesTheBottomTab('Commands');
        robot.seesNoCommandReading('git status');
      }),
      Step('back on the terminal, what it drew is still there', (
        TomRobot robot,
      ) async {
        await robot.choosesTheBottomTab('Terminal');
        await robot.seesInTheTerminal('On branch');
      }),
      Step('⌘J closes the panel, and nothing is broken', (
        TomRobot robot,
      ) async {
        await robot.pressesTheCommandsShortcut();
        robot
          ..seesTheCommandsClosed()
          ..seesNothingBroken();
      }),
    ],
  );
}
