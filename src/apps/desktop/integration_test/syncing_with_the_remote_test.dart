/// Fetch, push, and the push the remote got to first.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture behind = fixtures['docs-behind-remote'];

  /// What git says, asked outside the app entirely.
  String git(String repository, List<String> arguments) =>
      (Process.runSync('git', <String>['-C', repository, ...arguments]).stdout
              as String)
          .trim();

  /// What the bare repository — the remote — has on `main`.
  List<String> onTheRemote() => git(behind.remoteRoot, <String>[
    'log',
    '--format=%s',
    'main',
  ]).split('\n').where((String line) => line.isNotEmpty).toList();

  scenario(
    'Fetches, and finds the branch has fallen behind',
    group: 'Git — remote',
    describe:
        'Fetch exists so that ahead/behind means something. The space opens '
        'knowing only what it has — one commit nobody else has seen — and '
        'the two the remote gained are invisible until somebody asks. **It '
        'changes no file on disk**, which is what makes it safe to offer as '
        'a plain button, and the scenario checks that too.',
    steps: <Step>[
      Step('open a space whose remote has moved on', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: behind.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
      }),
      Step('it starts out knowing only what it has', (TomRobot robot) async {
        // `behind` is zero because nobody has fetched, not because the
        // branches agree.
        await robot.seesTheDrift(ahead: 1);
      }),
      Step('fetching finds the two the remote gained', (TomRobot robot) async {
        await robot.fetches();

        await robot.seesTheDrift(ahead: 1, behind: 2);
      }),
      Step('and it brought no file into the working tree', (
        TomRobot robot,
      ) async {
        expect(
          File('${behind.root}/reviewing.md').existsSync(),
          isFalse,
          reason: 'fetch wrote a file the remote had; that is a pull',
        );
        robot
          ..seesNotInTheTree('reviewing.md')
          ..seesNothingBroken();
      }),
    ],
  );

  scenario(
    'Refuses a push the remote got to first, and pulls instead',
    group: 'Git — remote',
    describe:
        'The whole reason push and pull are not one Sync button. The remote '
        'moved first, so the push is refused — and the refusal is a screen '
        'rather than an error: it says who got there first, that **nothing '
        'committed was lost**, and offers the one thing that mends it. '
        'After the pull the same button works, and the last assertion asks '
        'the **remote itself** what arrived.',
    steps: <Step>[
      Step('open the space and see where it stands', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: behind.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.fetches();
        await robot.seesTheDrift(ahead: 1, behind: 2);
        robot.seesNoRefusal();
      }),
      Step('pushing is refused, and says so in words', (TomRobot robot) async {
        await robot.pushes();

        await robot.seesThePushRefused(commits: 2);
        expect(onTheRemote(), isNot(contains('docs: start the release notes')));
      }),
      Step('pulling brings their commits in', (TomRobot robot) async {
        await robot.pulls();

        // The two sides wrote different files, so the pull merges cleanly; a
        // conflict is a screen nothing draws yet.
        await robot.seesTheDrift(ahead: 2);
        await robot.seesInTheTree(<String>['reviewing.md', 'approvals.md']);
      }),
      Step('and then the push lands', (TomRobot robot) async {
        await robot.pushes();

        await robot.seesTheDrift();
        robot.seesNoRefusal();
      }),
      Step('which the remote itself confirms', (TomRobot robot) async {
        // Asked of the remote itself: everything above could pass with a
        // button that merely stopped complaining.
        expect(onTheRemote(), contains('docs: start the release notes'));
        robot.seesNothingBroken();
      }),
    ],
  );
}
