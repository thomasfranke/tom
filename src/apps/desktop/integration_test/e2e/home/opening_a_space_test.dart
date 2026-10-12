/// Opening a space: the first thing anyone does with TOM.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../support/harness.dart';

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
    'Asks git for its version once, however many spaces are opened',
    describe:
        'The machine\'s git does not change while TOM runs, so `git '
        '--version` is read at the first opening and kept: opening a second '
        'space writes no second row in the Commands panel (and, under '
        'approvals, asks nobody again).',
    steps: <Step>[
      Step('open a space, which asks git its version', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();

        expect(robot.commandsRun('git --version'), 1);
      }),
      Step('leave it and open the same one again', (TomRobot robot) async {
        await robot.closesTheSpace();
        await robot.seesHome();
        await robot.chooseFolder();
        await robot.seesTheShell();
      }),
      Step('git was not asked a second time', (TomRobot robot) async {
        expect(robot.commandsRun('git --version'), 1);
        robot.seesNothingBroken();
      }),
    ],
  );

  scenario(
    'Refuses a git older than the one TOM needs, and says which it found',
    describe:
        'An older git fails later and further from the cause, so it is '
        'refused before it is asked anything else. The app is pointed at a '
        'script that answers `--version` as 2.39.2 and hands every other '
        'command to the real git; the real check runs, and Home says what '
        'was found instead of opening the space.',
    steps: <Step>[
      Step('start on a machine whose git is 2.39.2', (TomRobot robot) async {
        final String real =
            (Process.runSync('which', <String>['git']).stdout as String).trim();
        final File script = File(
          '${File(robot.settingsPath).parent.path}/older-git/git',
        );
        script.parent.createSync(recursive: true);
        script.writeAsStringSync(
          '#!/bin/sh\n'
          'if [ "\$1" = "--version" ]; then\n'
          '  echo "git version 2.39.2"; exit 0\n'
          'fi\n'
          'exec $real "\$@"\n',
        );
        Process.runSync('chmod', <String>['+x', script.path]);

        await robot.launchWindowed(
          pickFolder: docsInRepo.root,
          gitExecutable: script.path,
        );
        await robot.seesHome();
      }),
      Step('choosing a folder is refused, naming the version', (
        TomRobot robot,
      ) async {
        await robot.chooseFolder();

        await robot.seesOnScreen(<String>[
          'TOM needs git 2.41 or newer.',
          'This machine has 2.39.2.',
        ]);
        expect(find.text('EXPLORER'), findsNothing);
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
