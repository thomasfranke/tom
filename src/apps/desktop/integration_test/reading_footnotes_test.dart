/// A footnote: the marker where it was cited, the note at the foot.
library;

import 'support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture docsInRepo = fixtures['docs-in-repo'];

  scenario(
    'Reads a document whose notes are at its foot',
    group: 'Editor',
    describe:
        'The construct a preview built **one container per block** cannot '
        'render by itself: the marker is in one block and the note is in '
        'another, so neither half can resolve the other alone. The scenario '
        'opens a document with two of them and reads both halves off the '
        'screen — the numbers where the claims are, the notes under a rule '
        'at the end, and no `[^label]` anywhere.',
    steps: <Step>[
      Step('open a document that cites two notes', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.clickInTheTree('001-why-markdown.md');
        // The status bar names the path inside the space, not the file.
        await robot.seesTheOpenDocument('adr/001-why-markdown.md');
      }),
      Step('the source still holds what the author wrote', (
        TomRobot robot,
      ) async {
        // The syntax is the truth and the preview is a reading of it.
        await robot.seesInTheSource('[^tools]');
        await robot.seesInTheSource('[^tools]: Three editors');
      }),
      Step('the preview draws a number where the claim is', (
        TomRobot robot,
      ) async {
        await robot.looksAt('Preview');

        // Raised and smaller, so it is drawn beside the sentence rather
        // than inside its span: the serif face the prose is set in has no
        // superscript of its own.
        await robot.seesInThePreview('it survives whatever tool is');
        await robot.seesTheFootnoteMarkers(<String>['1', '2']);
      }),
      Step('and no marker survives as the syntax that made it', (
        TomRobot robot,
      ) async {
        await robot.seesNotInThePreview('[^tools]');
        await robot.seesNotInThePreview('[^chain]');
      }),
      Step('the notes themselves are at the foot, numbered', (
        TomRobot robot,
      ) async {
        await robot.seesTheFootnotes(<String>['1.', '2.']);
        await robot.seesInThePreview('Three editors were tried');
        robot.seesNothingBroken();
      }),
    ],
  );
}
