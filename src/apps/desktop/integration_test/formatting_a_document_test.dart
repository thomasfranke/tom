/// The formatting bar: a button press, and the markdown it writes.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture docsInRepo = fixtures['docs-in-repo'];

  scenario(
    'Formats a document from the bar above it',
    group: 'Editor',
    describe:
        'The rule the whole feature rests on: a button writes the **literal '
        'markdown** into the source, and the source stays the truth. The '
        'scenario presses three of the seventeen, reads the syntax back out '
        'of the pane, and then saves — so the last assertion is against the '
        'bytes on disk and not against anything the app remembers.',
    steps: <Step>[
      // `untracked.md` on purpose: this scenario rewrites the file, and no
      // other scenario reads its content.
      Step('open a document, with the bar above it', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.clickInTheTree('untracked.md');
        await robot.seesTheOpenDocument('untracked.md');
      }),
      Step('start from a line of plain prose', (TomRobot robot) async {
        await robot.typesInTheSource('a word here\n');
        await robot.seesInTheSource('a word here');
      }),
      Step('a rule is written as three hyphens, not as a line drawn', (
        TomRobot robot,
      ) async {
        await robot.pressesTheToolbarButton('Rule');

        await robot.seesInTheSource('---');
      }),
      Step('a list marks the line, in the syntax a reader of the file sees', (
        TomRobot robot,
      ) async {
        await robot.pressesTheToolbarButton('List');

        await robot.seesInTheSource('- ');
      }),
      Step('a table arrives with a header, because an empty one is text', (
        TomRobot robot,
      ) async {
        await robot.pressesTheToolbarButton('Table');

        await robot.seesInTheSource('| Column | Column |');
      }),
      Step('the document says it is unsaved, because a press is an edit', (
        TomRobot robot,
      ) async {
        await robot.seesUnsaved('untracked.md');
      }),
      Step('and saving puts that markdown on the disk', (
        TomRobot robot,
      ) async {
        await robot.saves();
        await robot.seesNothingUnsaved('untracked.md');

        // The file itself, asked outside the app: everything above could
        // pass with a pane that only looked right.
        final String written = File(
          '${docsInRepo.root}/untracked.md',
        ).readAsStringSync();
        expect(written, contains('---'));
        expect(written, contains('| Column | Column |'));
        robot.seesNothingBroken();
      }),
    ],
  );
}
