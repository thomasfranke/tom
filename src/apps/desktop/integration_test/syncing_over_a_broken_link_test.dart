/// The link to the remote, down: what the foot of the git column says.
library;

import 'support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture unreachable = fixtures['docs-unreachable-remote'];

  scenario(
    'Says the link is down, and keeps committing',
    group: 'Git — remote',
    describe:
        'A remote that cannot be reached, on a real repository whose origin '
        'points at a host that never resolves. A fetch fails the way it does '
        'with no network: the foot of the git column says No network, the '
        'three requests go unavailable — the network can come back, so later '
        'rather than never — and committing is never taken away. The git '
        'menu\'s Reload is what offers the three again.',
    steps: <Step>[
      Step('open the docs folder whose remote is out of reach', (
        TomRobot robot,
      ) async {
        await robot.launchWindowed(pickFolder: unreachable.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
      }),
      Step('a healthy-looking column says nothing about the link', (
        TomRobot robot,
      ) async {
        await robot.seesNotOnScreen('No network');
      }),
      Step('fetching says the network is not there', (TomRobot robot) async {
        await robot.fetches();
        await robot.seesOnScreen(<String>['No network']);
      }),
      Step('and the three are unavailable, the commit box is not', (
        TomRobot robot,
      ) async {
        await robot.seesTheRemoteActionsUnavailable();
      }),
      Step('Reload offers them again', (TomRobot robot) async {
        await robot.choosesFromTheMenu('Git menu', 'Reload');
        await robot.seesNotOnScreen('No network');
      }),
      Step('and nothing is broken', (TomRobot robot) async {
        robot.seesNothingBroken();
      }),
    ],
  );
}
