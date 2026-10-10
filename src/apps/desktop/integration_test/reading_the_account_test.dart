/// The account button: who commits, and the GitHub login the machine holds.
library;

import 'support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture proposing = fixtures['docs-proposing'];

  scenario(
    'Says who commits, and that nothing is known without a GitHub login',
    group: 'Workspace',
    describe:
        'The honest empty state. TOM signs nobody in and keeps no token: '
        'the account is whatever `gh`, git and `ssh` already hold — and this '
        'run hides all three, with a PATH holding git alone and an empty '
        'home. So the popover names who git commits as, says no GitHub '
        'credentials are on this computer, and draws the repository\'s five '
        'columns as dashes rather than guessing. The repository\'s name '
        'still opens its page, which needs no login.',
    steps: <Step>[
      Step('on Home, the account is the machine\'s', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: proposing.root);
        await robot.opensTheAccount();
        await robot.seesOnScreen(<String>['COMMITS AS', 'GITHUB']);
        // No repository is open, so there is none to speak of.
        await robot.seesNotOnScreen('THIS REPOSITORY');
        await robot.closesTheAccount();
      }),
      Step('open a docs folder whose origin is on GitHub', (
        TomRobot robot,
      ) async {
        await robot.chooseFolder();
        await robot.seesTheShell();
      }),
      Step('the account names the repository', (TomRobot robot) async {
        await robot.opensTheAccount();
        await robot.seesOnScreen(<String>[
          'COMMITS AS',
          'GITHUB',
          'THIS REPOSITORY',
          'github.com/acme/docs',
        ]);
      }),
      Step('no login on this computer, so nothing is known here', (
        TomRobot robot,
      ) async {
        await robot.seesNoGithubCredentials();
      }),
      Step('the repository\'s name opens its page', (TomRobot robot) async {
        await robot.opensTheRepositoryFromTheAccount('github.com/acme/docs');
        await robot.seesTheBrowserAskedFor('https://github.com/acme/docs');
      }),
      Step('the button closes what it opened', (TomRobot robot) async {
        await robot.closesTheAccount();
        await robot.seesNotOnScreen('COMMITS AS');
      }),
      Step('and nothing is broken', (TomRobot robot) async {
        robot.seesNothingBroken();
      }),
    ],
  );
}
