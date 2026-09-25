/// The commits that touched the open document, and one of those versions.
library;

import 'support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture withHistory = fixtures['docs-with-history'];

  scenario(
    'Lists what changed this document, and nothing else',
    group: 'Git — history',
    describe:
        'The panel answers "who changed **this**", which is the whole '
        'difference between it and a log. The fixture\'s repository has four '
        'commits and the index has three — the fourth wrote a different file '
        '— so a panel that listed the repository would be caught here and '
        'nowhere else. Each entry carries the three facts the product asks '
        'for: the message, who wrote it, and when.',
    steps: <Step>[
      Step('open a space whose index has been rewritten', (
        TomRobot robot,
      ) async {
        await robot.launchWindowed(pickFolder: withHistory.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
      }),
      Step('with nothing open there is nothing to ask about', (
        TomRobot robot,
      ) async {
        await robot.seesInTheHistory(<String>[
          'Open a document to see what changed it.',
        ]);
      }),
      Step('opening the index lists the commits that touched it', (
        TomRobot robot,
      ) async {
        await robot.clickInTheTree('index.md');

        await robot.seesInTheHistory(<String>[
          'docs: fix a typo in the index',
          'docs: expand the index',
          'docs: write the index',
        ]);
      }),
      Step('and not the two that touched something else', (
        TomRobot robot,
      ) async {
        // What the fixture exists for: five commits in the repository, three
        // on this document.
        robot
          ..seesNotInTheHistory('docs: add a writing guide')
          ..seesNotInTheHistory('docs: the first pass')
          ..seesNothingBroken();
      }),
      Step('another document is another history', (TomRobot robot) async {
        await robot.clickInTheTree('writing.md');

        await robot.seesInTheHistory(<String>['docs: add a writing guide']);
        robot
          ..seesNotInTheHistory('docs: expand the index')
          ..seesNothingBroken();
      }),
    ],
  );

  scenario(
    'Opens a past version rendered, and comes back to now',
    group: 'Git — history',
    describe:
        'A history entry opens **that version of the document, rendered** — '
        'not diff text (`docs/product/git-workflow/file-history/doc.md`). '
        'The bar above the document says which commit is on screen and stops '
        'offering the three modes while it is: nothing types into the past. '
        'Coming back restores the working copy *and* the mode that was being '
        'worked in, which is why the choice is never overwritten.',
    steps: <Step>[
      Step('open a document and read it as it is now', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: withHistory.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.clickInTheTree('index.md');

        await robot.seesInThePreview('as the working copy has it');
        await robot.seesTheWorkingCopy();
      }),
      Step('opening an older commit shows that version', (
        TomRobot robot,
      ) async {
        await robot.opensTheVersion('docs: expand the index');

        await robot.seesInThePreview('as the second commit left it');
      }),
      Step('and the bar says which one, and offers no mode', (
        TomRobot robot,
      ) async {
        await robot.seesReadingAVersion();
      }),
      Step('the oldest version is the oldest text', (TomRobot robot) async {
        // Each version's text names itself, so a pane that re-read the
        // working copy could not pass.
        await robot.opensTheVersion('docs: write the index');

        await robot.seesInThePreview('as the first commit wrote it');
      }),
      Step('coming back to now restores the working copy', (
        TomRobot robot,
      ) async {
        await robot.goesBackToNow();

        await robot.seesTheWorkingCopy();
        await robot.seesInThePreview('as the working copy has it');
      }),
      Step('and it can be opened again afterwards', (TomRobot robot) async {
        await robot.opensTheVersion('docs: expand the index');

        await robot.seesInThePreview('as the second commit left it');
        await robot.seesReadingAVersion();
        robot.seesNothingBroken();
      }),
    ],
  );
}
