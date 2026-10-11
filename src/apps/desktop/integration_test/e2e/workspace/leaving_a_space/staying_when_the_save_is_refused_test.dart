/// A save the disk refuses on the way out of a space: the space stays.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture docsInRepo = fixtures['docs-in-repo'];
  final String document = '${docsInRepo.root}/untracked.md';

  /// What the document held before anybody typed.
  late String onDisk;

  /// Takes the right to write away from the folder, or gives it back.
  void lock({required bool locked}) {
    Process.runSync('chmod', <String>[
      if (locked) '555' else '755',
      docsInRepo.root,
    ]);
  }

  scenario(
    'Stays in the space when the save before leaving is refused',
    group: 'Workspace',
    submenu: 'Leaving a space',
    describe:
        '`Save and close` writes first and leaves second. If the disk '
        'refuses the write, leaving would be the one way to lose the edit, '
        'so the space stays open: the edit is still in the buffer, the file '
        'is as it was, and nothing on screen claims it was saved. Writable '
        'again, the same answer saves and goes home.',
    steps: <Step>[
      Step('open a document, type into it, and ask to close the space', (
        TomRobot robot,
      ) async {
        addTearDown(() => lock(locked: false));
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.clickInTheTree('untracked.md');
        await robot.seesInTheSource('# Untracked');
        onDisk = File(document).readAsStringSync();
        await robot.typesInTheSource('# Kept\n');
        lock(locked: true);

        await robot.closesTheSpace();

        await robot.seesInTheSpaceMenu(<String>[
          'untracked.md has unsaved changes',
          'Save and close',
        ]);
      }),
      Step('Save and close is refused by the disk, and the space stays', (
        TomRobot robot,
      ) async {
        await robot.answersTheUnsavedQuestion('Save and close');

        await robot.seesTheShell();
        await robot.seesInTheSource('# Kept');
        expect(File(document).readAsStringSync(), onDisk);
        await robot.seesUnsaved('untracked.md');
      }),
      Step('writable again, the same answer saves and goes home', (
        TomRobot robot,
      ) async {
        lock(locked: false);

        await robot.closesTheSpace();
        await robot.answersTheUnsavedQuestion('Save and close');

        await robot.seesHome();
        expect(File(document).readAsStringSync(), '# Kept\n');
        robot.seesNothingBroken();
      }),
    ],
  );
}
