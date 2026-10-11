/// The pull request row when there is nothing to propose, and why.
library;

import 'dart:io';

import '../../../support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture proposing = fixtures['docs-proposing'];

  /// What git is told from outside the app, between two launches.
  void git(List<String> arguments) {
    final ProcessResult result = Process.runSync('git', <String>[
      '-C',
      proposing.repositoryRoot,
      ...arguments,
    ]);
    if (result.exitCode != 0) {
      throw StateError('git ${arguments.join(' ')}: ${result.stderr}');
    }
  }

  Future<void> opensTheSpace(TomRobot robot) async {
    await robot.launchWindowed(pickFolder: proposing.root);
    await robot.chooseFolder();
    await robot.seesTheShell();
  }

  scenario(
    'Says why there is nothing to propose',
    group: 'Git',
    submenu: 'Pull request',
    describe:
        'The `Pull request` row stays drawn when it cannot act, muted, with '
        'its reason under its name, and pressing it asks nothing: on the '
        'branch a pull request goes into, on a branch with no commits over '
        'it, and with an origin that is on no known host or on none at '
        'all. Each is provoked in the repository with git between two '
        'launches.',
    steps: <Step>[
      Step('on main, the row says there is nothing to propose', (
        TomRobot robot,
      ) async {
        git(<String>['checkout', '--quiet', 'main']);
        await opensTheSpace(robot);

        await robot.seesOnScreen(<String>['On main — nothing to propose']);
      }),
      Step('and pressing it opens no page', (TomRobot robot) async {
        await robot.triesToOpenThePullRequest();

        await robot.seesNotOnScreen('PROPOSING ONTO');
        await robot.seesOnScreen(<String>['On main — nothing to propose']);
      }),
      Step('a branch level with main has nothing over it, and says so', (
        TomRobot robot,
      ) async {
        git(<String>['checkout', '--quiet', '-b', 'feat/level']);
        await opensTheSpace(robot);
        await robot.opensThePullRequest();

        await robot.seesOnScreen(<String>[
          'Nothing to propose yet: this branch has no commits over main.',
        ]);
      }),
      Step('an origin on no known host says it is not on one', (
        TomRobot robot,
      ) async {
        git(<String>['checkout', '--quiet', 'feat/release-notes']);
        git(<String>[
          'remote',
          'set-url',
          'origin',
          'https://git.example.org/acme/docs.git',
        ]);
        await opensTheSpace(robot);

        await robot.seesOnScreen(<String>['origin is not on a known host']);
        await robot.triesToOpenThePullRequest();
        await robot.seesNotOnScreen('PROPOSING ONTO');
      }),
      Step('no origin at all says there is no remote to propose to', (
        TomRobot robot,
      ) async {
        git(<String>['remote', 'remove', 'origin']);
        await opensTheSpace(robot);

        await robot.seesOnScreen(<String>['No remote to propose to']);
        await robot.triesToOpenThePullRequest();
        await robot.seesNotOnScreen('PROPOSING ONTO');
      }),
      Step('and nothing is broken', (TomRobot robot) async {
        robot.seesNothingBroken();
      }),
    ],
  );
}
