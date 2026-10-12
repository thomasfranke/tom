/// Cloning by URL: a space from a repository that is not on the machine yet.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tom_presentation/tom_presentation.dart';

import '../../support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture toClone = fixtures['docs-to-clone'];
  final String clones = '${E2eFixtures.directory}/clones';
  final String landed = '$clones/docs-to-clone';
  final String missing = '${toClone.remoteRoot}-missing';
  final String missingLanding = '$clones/${cloneFolderNameOf(missing)}';

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
        await robot.clonesFromUrl(missing);

        await robot.seesTheCloneRefused(
          'There is no repository at that address.',
          address: missing,
        );
        // Nothing is left where the clone would have landed.
        expect(Directory(missingLanding).existsSync(), isFalse);
        expect(Directory(clones).listSync(), isEmpty);
      }),
      Step('a refused clone leaves an empty folder that was there as it was', (
        TomRobot robot,
      ) async {
        Directory(missingLanding).createSync();

        await robot.clonesFromUrl(missing);

        await robot.seesTheCloneRefused(
          'There is no repository at that address.',
          address: missing,
        );
        expect(Directory(missingLanding).existsSync(), isTrue);
        expect(Directory(missingLanding).listSync(), isEmpty);
        Directory(missingLanding).deleteSync();
      }),
      Step('a folder that holds a file is refused by name, and untouched', (
        TomRobot robot,
      ) async {
        Directory(landed).createSync();
        File('$landed/keep.txt').writeAsStringSync('mine\n');

        await robot.clonesFromUrl(toClone.remoteRoot);

        await robot.seesTheCloneRefused(
          ' already exists — choose another folder.',
          address: toClone.remoteRoot,
        );
        expect(File('$landed/keep.txt').readAsStringSync(), 'mine\n');
        expect(Directory(landed).listSync(), hasLength(1));
        Directory(landed).deleteSync(recursive: true);
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
