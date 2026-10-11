/// A repository that has no origin: git still works, the network does not.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture docsInRepo = fixtures['docs-in-repo'];

  scenario(
    'Has no remote to talk to',
    group: 'Git',
    submenu: 'Remote',
    describe:
        'A repository nobody ever pushed anywhere: the foot of the git '
        'column says `No remote configured`, `Fetch`, `Pull` and `Push` are '
        'present and unavailable rather than gone, nothing is counted on '
        '`Push`, and committing — which needs no remote — still works.',
    steps: <Step>[
      Step('open the docs folder of a repository with no origin', (
        TomRobot robot,
      ) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.seesInTheChanges(<String>['untracked.md', 'writing.md']);
      }),
      Step('the foot says there is no remote', (TomRobot robot) async {
        await robot.seesOnScreen(<String>['No remote configured']);
      }),
      Step('the three are there and cannot be pressed, with nothing counted', (
        TomRobot robot,
      ) async {
        await robot.seesTheRemoteActionsUnavailable();
        await robot.seesTheDrift();
      }),
      Step('a commit is still made', (TomRobot robot) async {
        await robot.stages('untracked.md');
        await robot.describesTheCommit('docs: committed with no remote');

        await robot.commits();

        expect(
          (Process.runSync('git', <String>[
                    '-C',
                    docsInRepo.repositoryRoot,
                    'log',
                    '--format=%s',
                    '-1',
                  ]).stdout
                  as String)
              .trim(),
          'docs: committed with no remote',
        );
        await robot.seesTheBandSaying(<String>[
          'Committed “docs: committed with no remote”.',
        ]);
      }),
      Step('and the foot still says there is nowhere to send it', (
        TomRobot robot,
      ) async {
        await robot.seesOnScreen(<String>['No remote configured']);
        await robot.seesTheRemoteActionsUnavailable();
        robot.seesNothingBroken();
      }),
    ],
  );
}
