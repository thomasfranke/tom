/// A save the disk refuses: said on screen, and nothing lost.
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
    'Keeps the edit and says so when the disk refuses the save',
    group: 'Editor',
    submenu: 'Documents',
    describe:
        'The save is the one write the product does to the person\'s files, '
        'and it can be refused — a read-only folder, a full disk. **Nothing '
        'may be lost**: the row above the document says `Not saved`, the '
        'edit is still in the buffer, and the file is byte for byte what it '
        'was. Once the folder is writable again the same save lands.',
    steps: <Step>[
      Step('open a document and type into it', (TomRobot robot) async {
        // Given back whatever happens, so the next run can rebuild the folder.
        addTearDown(() => lock(locked: false));
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.clickInTheTree('untracked.md');
        await robot.seesInTheSource('# Untracked');
        onDisk = File(document).readAsStringSync();
        await robot.typesInTheSource('# Refused\n');
        await robot.seesUnsaved('untracked.md');
      }),
      Step('the folder cannot be written, and the save is refused in words', (
        TomRobot robot,
      ) async {
        lock(locked: true);

        await robot.saves();

        await robot.seesTheSaveRefused();
      }),
      Step('the edit is still in the buffer, and the file is as it was', (
        TomRobot robot,
      ) async {
        await robot.seesInTheSource('# Refused');
        expect(File(document).readAsStringSync(), onDisk);
        expect(
          Directory(
            docsInRepo.root,
          ).listSync().where((FileSystemEntity it) => it.path.contains('.tmp')),
          isEmpty,
          reason: 'a half-written file was left beside the document',
        );
      }),
      Step('writable again, the same save lands', (TomRobot robot) async {
        lock(locked: false);

        await robot.saves();

        await robot.seesSavedTo(document, '# Refused');
        await robot.seesNothingUnsaved('untracked.md');
        robot.seesNothingBroken();
      }),
    ],
  );
}
