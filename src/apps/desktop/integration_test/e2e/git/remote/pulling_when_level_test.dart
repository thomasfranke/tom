/// A pull with nothing to bring in.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture behind = fixtures['docs-behind-remote'];

  String git(List<String> arguments) =>
      (Process.runSync('git', <String>[
                '-C',
                behind.repositoryRoot,
                ...arguments,
              ]).stdout
              as String)
          .trim();

  scenario(
    'Says a pull found nothing',
    group: 'Git',
    submenu: 'Remote',
    describe:
        'A pull that finds nothing is an answer, not silence: once the '
        'branch is level with its remote the band says `Already level` and '
        'that nothing arrived, no count is left on either button, and the '
        'repository is exactly as it was.',
    steps: <Step>[
      Step('bring a branch level with its remote', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: behind.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.fetches();
        await robot.seesTheDrift(ahead: 1, behind: 2);

        await robot.pulls();
        await robot.pushes();

        await robot.seesTheDrift();
      }),
      Step('pulling now says it found nothing', (TomRobot robot) async {
        final String head = git(<String>['rev-parse', 'HEAD']);

        await robot.pulls();

        await robot.seesTheBandSaying(<String>[
          'Already level with origin/',
          'nothing arrived',
        ]);
        expect(git(<String>['rev-parse', 'HEAD']), head);
      }),
      Step('and no count is left on Push or Pull', (TomRobot robot) async {
        await robot.seesTheDrift();
        expect(git(<String>['status', '--porcelain']), isEmpty);
        robot.seesNothingBroken();
      }),
    ],
  );
}
