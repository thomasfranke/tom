/// Finding words inside the open document, and replacing them one by one.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture docsInRepo = fixtures['docs-in-repo'];
  final String path = '${docsInRepo.root}/guides/writing.md';
  late String original;

  scenario(
    'Replaces a word inside the open document',
    group: 'Search',
    describe:
        'The other half of the box: the same words, asked of the open '
        'document instead of the space, and answered by the buffer rather '
        'than by the index. ⌥⌘F opens what they become, each '
        'occurrence shows the change before it is made, and the one under '
        'the pointer is the one that can be replaced or skipped.',
    steps: <Step>[
      Step('open the docs folder and a document in it', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        // No folder is opened first: the tree arrives with every one of them
        // open, so clicking `guides` would close it.
        await robot.clickInTheTree('writing.md');

        await robot.seesTheOpenDocument('guides/writing.md');
        original = File(path).readAsStringSync();
      }),
      Step('asked of this file, the answer comes from the buffer', (
        TomRobot robot,
      ) async {
        await robot.typesInTheSearch('paragraph');
        await robot.searchesTheOpenFile();

        // Two in one line, under the document's own first heading.
        await robot.seesInTheOccurrences(<String>[
          '2 occurrences in writing.md',
          'Writing',
        ]);
      }),
      Step('pressing an occurrence goes to it: the match is selected', (
        TomRobot robot,
      ) async {
        await robot.looksAt('Source');
        await robot.clicksTheOccurrence('Writing');

        await robot.seesTheSourceSelecting('paragraph');
      }),
      Step('⌥⌘F opens what the words become', (TomRobot robot) async {
        await robot.opensTheReplacement();
        await robot.typesTheReplacement('section');

        await robot.seesInTheOccurrences(<String>['section']);
      }),
      Step('replacing the current one writes it into the document', (
        TomRobot robot,
      ) async {
        await robot.replacesTheCurrentOne();

        await robot.seesInTheOccurrences(<String>[
          '1 occurrence in writing.md',
        ]);
      }),
      Step('the replacement is in the buffer, and not on the disk', (
        TomRobot robot,
      ) async {
        await robot.looksAt('Source');

        await robot.seesInTheSource('A section that runs');
        // The column is the search's, so the tree's dot is not on screen.
        await robot.seesOnScreen(<String>['Unsaved']);
        expect(File(path).readAsStringSync(), original);
      }),
      Step('and the editor’s own undo puts it back', (TomRobot robot) async {
        // No control of its own: the replacement went into the buffer the
        // way a keystroke does, so ⌘Z walks back through it
        // (`docs/product/search/replacing/doc.md`).
        await robot.undoes();

        await robot.seesInTheOccurrences(<String>[
          '2 occurrences in writing.md',
        ]);
      }),
      Step('Replace all changes every occurrence, on screen only', (
        TomRobot robot,
      ) async {
        await robot.replacesEveryOne();

        await robot.seesNotInTheSource('paragraph');
        await robot.seesInTheSource('A section that runs');
        await robot.seesInTheSource('two sections');
        // Re-found against the new text: nothing left to count.
        await robot.seesNotInTheOccurrences('2 occurrences in writing.md');
        await robot.seesOnScreen(<String>['Unsaved']);
        expect(File(path).readAsStringSync(), original);
      }),
      Step('one ⌘Z brings every one of them back', (TomRobot robot) async {
        await robot.undoes();

        await robot.seesInTheSource('A paragraph that runs');
        await robot.seesInTheSource('two paragraphs');
        await robot.seesInTheOccurrences(<String>[
          '2 occurrences in writing.md',
        ]);
      }),
      Step('an empty box deletes what it finds', (TomRobot robot) async {
        await robot.typesTheReplacement('');
        await robot.replacesEveryOne();

        await robot.seesNotInTheSource('paragraph');
        await robot.seesInTheSource('A  that runs');
        await robot.undoes();
        await robot.seesInTheSource('A paragraph that runs');
        await robot.typesTheReplacement('section');
      }),
      Step('in Preview an occurrence tints the block it belongs to', (
        TomRobot robot,
      ) async {
        await robot.looksAt('Preview');
        await robot.clicksTheOccurrence('Writing');

        await robot.seesTheRevealedBlock('paragraph');
      }),
      Step('a save writes the replacements to the file', (
        TomRobot robot,
      ) async {
        await robot.looksAt('Source');
        await robot.replacesEveryOne();
        await robot.saves();

        await robot.seesSavedTo(path, 'A section that runs');
        expect(File(path).readAsStringSync(), isNot(contains('paragraph')));
        await robot.seesNotOnScreen('Unsaved');
      }),
      Step('and nothing is broken', (TomRobot robot) async {
        robot.seesNothingBroken();
      }),
    ],
  );
}
