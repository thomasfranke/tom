/// A push the remote got to first, before anything was fetched, and the
/// pills of the band that says so.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture behind = fixtures['docs-behind-remote'];

  List<String> onTheRemote() =>
      (Process.runSync('git', <String>[
                '-C',
                behind.remoteRoot,
                'log',
                '--format=%s',
                'main',
              ]).stdout
              as String)
          .split('\n')
          .where((String line) => line.isNotEmpty)
          .toList();

  Future<void> opensTheSpace(TomRobot robot) async {
    await robot.launchWindowed(pickFolder: behind.root);
    await robot.chooseFolder();
    await robot.seesTheShell();
  }

  scenario(
    'Refuses a push it has not counted yet',
    group: 'Git',
    submenu: 'Remote',
    describe:
        'Nothing has been fetched, so the app does not know the remote moved '
        'on and offers `Push` as if it were free. The remote refuses, and '
        'the answer is the same screen as a counted refusal — someone '
        'pushed first, nothing committed was lost, `Pull` is the way out — '
        'and the remote is asked afterwards that it received nothing.',
    steps: <Step>[
      Step('open a space that has never fetched', (TomRobot robot) async {
        await opensTheSpace(robot);
        await robot.seesTheDrift(ahead: 1);
      }),
      Step('pushing is refused in words, with the way out', (
        TomRobot robot,
      ) async {
        await robot.pushes();

        await robot.seesTheBandSaying(<String>[
          'Someone pushed',
          'nothing you committed has been lost',
        ]);
        await robot.seesInTheBand(<String>['Pull']);
      }),
      Step('and the remote received nothing', (TomRobot robot) async {
        expect(onTheRemote(), isNot(contains('docs: start the release notes')));
        robot.seesNothingBroken();
      }),
    ],
  );

  scenario(
    'Presses every pill of a band',
    group: 'Git',
    submenu: 'Remote',
    describe:
        'A refused push leaves a band with two pills and each does what it '
        'says: `Show the command` opens the Commands panel on the `git '
        'push` that was refused, `Pull` brings the remote\'s commits in and '
        'says how many arrived, and the `Push` that follows publishes what '
        'is left.',
    steps: <Step>[
      Step('open the space and be refused', (TomRobot robot) async {
        await opensTheSpace(robot);
        await robot.pushes();

        await robot.seesInTheBand(<String>['Pull', 'Show the command']);
      }),
      Step('Show the command opens the panel on the git push', (
        TomRobot robot,
      ) async {
        await robot.showsTheCommandFromTheBand();

        await robot.seesTheCommands(<String>['git push']);
        await robot.closesTheCommands();
      }),
      Step('the band Pull pulls, and says how many arrived', (
        TomRobot robot,
      ) async {
        // The panel may have taken the band with it: be refused again.
        if (!robot.bandOffers('Pull')) {
          await robot.pushes();
        }
        await robot.pressesInTheBand('Pull');

        await robot.seesTheBandSaying(<String>['Pulled ', 'still to publish.']);
        await robot.seesTheDrift(ahead: 2);
      }),
      Step('the band Push publishes what is left', (TomRobot robot) async {
        await robot.seesInTheBand(<String>['Push']);
        await robot.pressesInTheBand('Push');

        await robot.seesTheDrift();
        expect(onTheRemote(), contains('docs: start the release notes'));
        robot.seesNothingBroken();
      }),
    ],
  );
}
