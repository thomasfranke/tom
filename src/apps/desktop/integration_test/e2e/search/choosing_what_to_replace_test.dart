/// The second box of the search: how it is opened, what it shows before
/// anything is written, and which occurrence its actions are on.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture docsInRepo = fixtures['docs-in-repo'];
  final String path = '${docsInRepo.root}/guides/writing.md';
  late String original;

  Step openWriting() =>
      Step('open the docs folder and a document in it', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.clickInTheTree('writing.md');

        await robot.seesTheOpenDocument('guides/writing.md');
        original = File(path).readAsStringSync();
      });

  scenario(
    'Opens replace from anywhere, and puts it away',
    group: 'Search',
    describe:
        'The second box has two ways in and the same two ways out: ⌥⌘F, '
        'pressed with the explorer shut, opens the column on `This file` '
        'with both boxes, and the glyph beside the clear — lit while the '
        'box is open — does the same by hand.',
    steps: <Step>[
      openWriting(),
      Step('shut the explorer, and press the shortcut', (TomRobot robot) async {
        await robot.togglesTheColumn('Hide explorer');
        await robot.opensTheReplacement();
      }),
      Step('the column is back, on This file, with two boxes', (
        TomRobot robot,
      ) async {
        robot.seesTheReplacementBox(open: true);
        await robot.seesTheScopeControl();
      }),
      Step('once there are words, the glyph is lit, on This file', (
        TomRobot robot,
      ) async {
        await robot.typesInTheSearch('paragraph');

        // Occurrences in the document, not hits in the space: the scope the
        // shortcut chose.
        await robot.seesInTheOccurrences(<String>[
          '2 occurrences in writing.md',
        ]);
        await robot.seesTheReplaceToggle(open: true);
      }),
      Step('pressing the glyph puts the second box away', (
        TomRobot robot,
      ) async {
        await robot.pressesTheReplaceToggle();

        robot.seesTheReplacementBox(open: false);
        await robot.seesTheReplaceToggle(open: false);
        await robot.seesInTheOccurrences(<String>[
          '2 occurrences in writing.md',
        ]);
      }),
      Step('pressing it again opens it, and the keys close it', (
        TomRobot robot,
      ) async {
        await robot.pressesTheReplaceToggle();
        robot.seesTheReplacementBox(open: true);

        await robot.closesTheReplacementWithTheKeys();
        await robot.seesTheReplaceToggle(open: false);
      }),
      Step('opening and closing it wrote nothing', (TomRobot robot) async {
        expect(File(path).readAsStringSync(), original);
        await robot.seesNotOnScreen('Unsaved');
        robot.seesNothingBroken();
      }),
    ],
  );

  scenario(
    'Shows the change before it is made',
    group: 'Search',
    describe:
        'Each occurrence draws what replacing would do — the old words '
        'struck through, the new ones after them — and nothing is struck '
        'until the second box is open. An empty box is a deletion, and is '
        'drawn as one.',
    steps: <Step>[
      openWriting(),
      Step('asked of this file, with no second box, nothing is struck', (
        TomRobot robot,
      ) async {
        await robot.typesInTheSearch('paragraph');
        await robot.searchesTheOpenFile();

        await robot.seesInTheOccurrences(<String>[
          '2 occurrences in writing.md',
        ]);
        robot.seesNoChangeDrawn();
      }),
      Step('opening the box strikes the old words', (TomRobot robot) async {
        await robot.opensTheReplacement();

        await robot.seesTheChangeBeforeItIsMade('paragraph');
      }),
      Step('what is typed follows them', (TomRobot robot) async {
        await robot.typesTheReplacement('section');

        await robot.seesTheChangeBeforeItIsMade('paragraph', 'section');
      }),
      Step('and changing it changes the drawing', (TomRobot robot) async {
        await robot.typesTheReplacement('chapter');

        await robot.seesTheChangeBeforeItIsMade('paragraph', 'chapter');
      }),
      Step('drawing it changed nothing', (TomRobot robot) async {
        expect(File(path).readAsStringSync(), original);
        await robot.seesInTheSource('A paragraph that runs');
        await robot.seesNotOnScreen('Unsaved');
        robot.seesNothingBroken();
      }),
    ],
  );

  scenario(
    'Keeps the two actions on one occurrence',
    group: 'Search',
    describe:
        'Replacing is a decision per occurrence, so the pair `Replace this '
        'one` and `Skip this one` is on one row only — the one under the '
        'pointer — and skipping drops that occurrence from the list while '
        'leaving its text alone.',
    steps: <Step>[
      openWriting(),
      Step('two occurrences, the second box open', (TomRobot robot) async {
        await robot.typesInTheSearch('paragraph');
        await robot.searchesTheOpenFile();
        await robot.opensTheReplacement();
        await robot.typesTheReplacement('section');

        await robot.seesInTheOccurrences(<String>[
          '2 occurrences in writing.md',
        ]);
      }),
      Step('the pair is on the first, and on it alone', (TomRobot robot) async {
        await robot.seesTheActionsOnOccurrence(0);
      }),
      Step('the pointer moves it to the second', (TomRobot robot) async {
        await robot.pointsAtTheOccurrence(1);

        await robot.seesTheActionsOnOccurrence(1);
      }),
      Step('Skip this one drops it from the list and leaves its text', (
        TomRobot robot,
      ) async {
        await robot.skipsTheCurrentOne();

        await robot.seesInTheOccurrences(<String>[
          '1 occurrence in writing.md',
        ]);
        await robot.looksAt('Source');
        await robot.seesInTheSource('two paragraphs');
        await robot.seesInTheSource('A paragraph that runs');
        expect(File(path).readAsStringSync(), original);
        await robot.seesNotOnScreen('Unsaved');
      }),
      Step('the one that is left still carries the pair', (
        TomRobot robot,
      ) async {
        await robot.seesTheActionsOnOccurrence(0);
        robot.seesNothingBroken();
      }),
    ],
  );
}
