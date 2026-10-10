/// Cloning by URL: a space from a repository that is not on the machine yet.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture toClone = fixtures['docs-to-clone'];
  final String clones = '${E2eFixtures.directory}/clones';
  final String landed = '$clones/docs-to-clone';

  scenario(
    'Clones a repository by its address and opens it',
    describe:
        'The third way in. The address is pasted on Home, the folder is '
        'asked for next, and the clone opens as a space with no further '
        'step. A wrong address first, because a refusal that keeps the '
        'address is what makes trying again one press — and the last step '
        'asks git, outside the app, where the clone points.',
    steps: <Step>[
      Step('start on Home, with a folder to clone into', (
        TomRobot robot,
      ) async {
        final Directory parent = Directory(clones);
        if (parent.existsSync()) {
          parent.deleteSync(recursive: true);
        }
        parent.createSync(recursive: true);
        await robot.launchWindowed(pickFolder: clones);
        await robot.seesHome();
      }),
      Step('an address with no repository is refused in place', (
        TomRobot robot,
      ) async {
        await robot.clonesFromUrl('${toClone.remoteRoot}-missing');

        await robot.seesTheCloneRefused(
          'There is no repository at that address.',
        );
      }),
      Step('the right address clones, and the space opens', (
        TomRobot robot,
      ) async {
        await robot.clonesFromUrl(toClone.remoteRoot);

        await robot.seesTheShell();
        await robot.seesInTheTree(<String>['handbook.md']);
      }),
      Step('the clone is a real repository, tracking the address', (
        TomRobot robot,
      ) async {
        expect(File('$landed/handbook.md').existsSync(), isTrue);
        final ProcessResult origin = Process.runSync('git', <String>[
          '-C',
          landed,
          'remote',
          'get-url',
          'origin',
        ]);
        expect((origin.stdout as String).trim(), toClone.remoteRoot);
        robot.seesNothingBroken();
      }),
    ],
  );
}
