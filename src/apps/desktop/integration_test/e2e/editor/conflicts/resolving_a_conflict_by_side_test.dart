/// A document with two conflicts, resolved one side at a time.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture twice = fixtures['docs-conflicting-twice'];
  final String roadmap = '${twice.root}/roadmap.md';

  /// How many conflict regions the file on disk holds.
  int regionsOnDisk() =>
      '<<<<<<< '.allMatches(File(roadmap).readAsStringSync()).length;

  scenario(
    'Resolves a conflict in the document, a side at a time',
    group: 'Editor',
    submenu: 'Conflicts',
    describe:
        'A pull stopped with **two** regions in one document, and the person '
        'resolves them one by one. The preview offers both sides with no '
        'marker anywhere; each of the three choices is pressed — two in the '
        'preview, one painted on the `<<<<<<<` line in the source — with '
        'the editor\'s own undo between. Nothing reaches the disk until the '
        'save, which is asked of the file itself.',
    steps: <Step>[
      Step('pull, and open the document with two conflicts', (
        TomRobot robot,
      ) async {
        await robot.launchWindowed(pickFolder: twice.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.pulls();
        await robot.clickInTheTree('roadmap.md');
        await robot.looksAt('Split');

        expect(regionsOnDisk(), 2);
      }),
      Step('the preview offers both sides of each, and no marker', (
        TomRobot robot,
      ) async {
        await robot.seesInThePreview('M2 closes with search and replace.');
        await robot.seesInThePreview('M2 closes with full-text search.');
        // The second conflict is below the fold of a lazy list: its sides
        // are read in the source instead.
        await robot.seesInTheSource('Phase 2 ships on Monday.');
        await robot.seesInTheSource('Phase 2 ships on Tuesday.');
        await robot.seesNotInThePreview('<<<<<<<');
        await robot.seesNotInThePreview('=======');
        await robot.seesNotInThePreview('>>>>>>>');
      }),
      Step('Accept Current Change takes our side of the first, in the '
          'source', (TomRobot robot) async {
        await robot.acceptsInThePreview('Accept Current Change');

        await robot.seesInTheSource('M2 closes with search and replace.');
        await robot.seesNotInTheSource('M2 closes with full-text search.');
        // The second conflict is untouched.
        await robot.seesInTheSource('Phase 2 ships on Monday.');
        await robot.seesInTheSource('Phase 2 ships on Tuesday.');
      }),
      Step('it is unsaved, and the disk still holds both conflicts', (
        TomRobot robot,
      ) async {
        await robot.seesOnScreen(<String>['Unsaved']);
        expect(regionsOnDisk(), 2);
      }),
      Step('undo brings the first conflict back', (TomRobot robot) async {
        await robot.undoes();

        await robot.seesInTheSource('M2 closes with full-text search.');
        await robot.seesInTheSource('M2 closes with search and replace.');
        await robot.seesInTheSource('<<<<<<<');
      }),
      Step('Accept Incoming Change takes theirs instead', (
        TomRobot robot,
      ) async {
        await robot.acceptsInThePreview('Accept Incoming Change');

        await robot.seesInTheSource('M2 closes with full-text search.');
        await robot.seesNotInTheSource('M2 closes with search and replace.');
      }),
      Step('Accept Both Changes, painted on the <<<<<<< line, keeps both', (
        TomRobot robot,
      ) async {
        await robot.looksAt('Source');
        await robot.seesTheConflictMarkedInSource();

        await robot.acceptsInTheSource('Accept Both Changes');

        await robot.seesInTheSource('Phase 2 ships on Monday.');
        await robot.seesInTheSource('Phase 2 ships on Tuesday.');
        await robot.seesNotInTheSource('<<<<<<<');
        await robot.seesNotInTheSource('>>>>>>>');
      }),
      Step('only the save writes it to the file', (TomRobot robot) async {
        expect(regionsOnDisk(), 2, reason: 'the disk changed before a save');

        await robot.saves();

        await robot.seesSavedTo(roadmap, 'Phase 2 ships on Monday.');
        expect(regionsOnDisk(), 0);
        expect(
          File(roadmap).readAsStringSync(),
          allOf(
            contains('M2 closes with full-text search.'),
            isNot(contains('M2 closes with search and replace.')),
            contains('Phase 2 ships on Tuesday.'),
          ),
        );
        robot.seesNothingBroken();
      }),
    ],
  );
}
