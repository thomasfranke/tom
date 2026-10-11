/// A push to a branch the remote protects.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture protected = fixtures['docs-protected-branch'];

  /// What the bare repository — the remote — has on the branch.
  List<String> onTheRemote() =>
      (Process.runSync('git', <String>[
                '-C',
                protected.remoteRoot,
                'log',
                '--format=%s',
                'feat/protected',
              ]).stdout
              as String)
          .trim()
          .split('\n')
          .where((String line) => line.isNotEmpty)
          .toList();

  scenario(
    'Says the remote protects the branch, and offers a pull request',
    group: 'Git',
    submenu: 'Remote',
    describe:
        'A remote that refuses every push in the words GitHub uses for a '
        'protected branch, from a hook the bare repository really runs. The '
        'band names the refusal, says nothing was lost, offers `Show the '
        'command` and the pull request — the way into a protected branch — '
        'and never `Try again`, which would answer the same for ever. The '
        'remote itself is asked afterwards that the commit never arrived.',
    steps: <Step>[
      Step('open the docs folder, on a branch with a commit to publish', (
        TomRobot robot,
      ) async {
        await robot.launchWindowed(pickFolder: protected.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.stages('index.md');
        await robot.describesTheCommit('docs: add the untracked note');
        await robot.commits();
      }),
      Step('pushing is refused, and the band says the branch is protected', (
        TomRobot robot,
      ) async {
        await robot.pushes();

        await robot.seesTheBandSaying(<String>[
          'The remote refused this branch.',
          'Nothing was published, and nothing you committed has been lost.',
        ]);
      }),
      Step('its remedies are the command and the pull request, not a retry', (
        TomRobot robot,
      ) async {
        await robot.seesInTheBand(<String>['Show the command', 'Pull request']);
        await robot.seesNotInTheBand('Try again');
      }),
      Step('and the remote itself never got the commit', (
        TomRobot robot,
      ) async {
        expect(onTheRemote(), isNot(contains('docs: add the untracked note')));
        robot.seesNothingBroken();
      }),
    ],
  );
}
