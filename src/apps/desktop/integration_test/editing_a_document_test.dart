/// Source mode: typing into a real file and putting it back on disk.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture docsInRepo = fixtures['docs-in-repo'];

  scenario(
    'Edits a document and saves it',
    group: 'Editor',
    describe:
        'The claim the whole product rests on, end to end: **the file on '
        'disk is the truth**. A document is opened, typed into, shown '
        'changed in the preview with no refresh step, marked as unsaved '
        'everywhere that says so, and then written — and the last assertion '
        'is against the bytes on disk, not against anything the app '
        'remembers.',
    steps: <Step>[
      // `untracked.md` and not one of the others, on purpose: this scenario
      // writes to the prepared environment, and a fixture it left rewritten
      // would be a fixture the next scenario asserts the wrong thing about.
      // Nothing else reads this file's *content*.
      Step('open a document in the docs folder', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.clickInTheTree('untracked.md');
        await robot.seesTheOpenDocument('untracked.md');
      }),
      Step('the source pane holds the file as it is written', (
        TomRobot robot,
      ) async {
        // Source, not a rendering of it: there is no WYSIWYG mode
        // (Decision 3).
        await robot.seesInTheSource('# Untracked');
      }),
      Step('typing reaches the preview with no refresh step', (
        TomRobot robot,
      ) async {
        await robot.typesInTheSource('# Typed in TOM\n\nAnd rendered.\n');

        await robot.seesInThePreview('Typed in TOM');
      }),
      Step('and the document is marked unsaved, everywhere it is said', (
        TomRobot robot,
      ) async {
        await robot.seesUnsaved('untracked.md');
      }),
      Step('saving clears the mark', (TomRobot robot) async {
        await robot.saves();

        await robot.seesNothingUnsaved('untracked.md');
      }),
      Step('and the file on disk is what the editor held', (
        TomRobot robot,
      ) async {
        // The only assertion in the suite that leaves the app entirely:
        // everything above could pass with a buffer that never landed.
        expect(
          File('${docsInRepo.root}/untracked.md').readAsStringSync(),
          '# Typed in TOM\n\nAnd rendered.\n',
        );
        robot.seesNothingBroken();
      }),
    ],
  );

  scenario(
    'Reads a document with the source out of the way',
    group: 'Editor',
    describe:
        'Reading is not a lesser mode: for anyone who does not write '
        'markdown by hand, the rendered view is the product and the editor '
        'is the part they never open. The mode bar is what gives it the '
        'whole document area — and the shell hides the source without ever '
        'learning which panel that is.',
    steps: <Step>[
      Step('open a document', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.clickInTheTree('writing.md');
        await robot.seesInThePreview('Writing');
      }),
      Step('a space opens with both panes', (TomRobot robot) async {
        robot.seesThePanes(source: true, preview: true);
      }),
      Step('preview-only leaves the preview alone on screen', (
        TomRobot robot,
      ) async {
        await robot.looksAt('Preview');

        robot.seesThePanes(source: false, preview: true);
      }),
      Step('and the explorer is still there, because nothing takes over', (
        TomRobot robot,
      ) async {
        // There is no full-screen takeover that hides the tree
        // (docs/product/workspace/doc.md).
        await robot.seesInTheTree(<String>['index.md']);
      }),
      Step('source-only is the other way round', (TomRobot robot) async {
        await robot.looksAt('Source');

        robot
          ..seesThePanes(source: true, preview: false)
          ..seesNothingBroken();
      }),
    ],
  );
}
