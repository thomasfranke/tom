/// The host a pull request is opened on, read from where origin points.
library;

import 'dart:io';

import '../../../support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture proposing = fixtures['docs-proposing'];

  /// Points origin somewhere else, between two launches.
  void pointsOriginAt(String address) {
    final ProcessResult result = Process.runSync('git', <String>[
      '-C',
      proposing.repositoryRoot,
      'remote',
      'set-url',
      'origin',
      address,
    ]);
    if (result.exitCode != 0) {
      throw StateError('set-url $address: ${result.stderr}');
    }
  }

  Future<void> opensThePage(TomRobot robot) async {
    await robot.launchWindowed(pickFolder: proposing.root);
    await robot.chooseFolder();
    await robot.seesTheShell();
    await robot.opensThePullRequest();
  }

  scenario(
    'Names the host it opens on',
    group: 'Git',
    submenu: 'Pull request',
    describe:
        'GitHub, GitLab and Bitbucket are recognised from the address '
        'origin holds, and the page names the one it will open — in its '
        'button and in the address the browser is handed — instead of '
        'saying GitHub to everybody.',
    steps: <Step>[
      Step('a GitLab origin offers Open on GitLab', (TomRobot robot) async {
        pointsOriginAt('https://gitlab.com/acme/docs.git');
        await opensThePage(robot);

        await robot.seesOnScreen(<String>['PROPOSING ONTO', 'Open on GitLab']);
        await robot.seesNotOnScreen('Open on GitHub');
      }),
      Step('pressing it hands the browser a GitLab address', (
        TomRobot robot,
      ) async {
        await robot.tapText('Open on GitLab');

        await robot.seesTheBrowserAskedForAnAddressWith(<String>[
          'gitlab.com/acme/docs',
        ]);
      }),
      Step('a Bitbucket origin offers Open on Bitbucket', (
        TomRobot robot,
      ) async {
        pointsOriginAt('git@bitbucket.org:acme/docs.git');
        await opensThePage(robot);

        await robot.seesOnScreen(<String>[
          'PROPOSING ONTO',
          'Open on Bitbucket',
        ]);
        await robot.seesNotOnScreen('Open on GitLab');
      }),
      Step('pressing it hands the browser a Bitbucket address', (
        TomRobot robot,
      ) async {
        await robot.tapText('Open on Bitbucket');

        await robot.seesTheBrowserAskedForAnAddressWith(<String>[
          'bitbucket.org/acme/docs',
        ]);
      }),
      Step('and nothing is broken', (TomRobot robot) async {
        robot.seesNothingBroken();
      }),
    ],
  );
}
