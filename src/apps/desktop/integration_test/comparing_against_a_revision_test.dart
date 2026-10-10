/// The same rendered diff, against the branch the checked-out one came from.
library;

import 'support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture branched = fixtures['docs-branched'];

  scenario(
    'Compares a document against the branch it came from',
    group: 'Diff',
    describe:
        'Nobody picks the base: it is **the branch the current one came '
        'from** (`docs/product/diff/branch-diff/doc.md`). The fixture\'s '
        '`feat/glossary` was started from `develop`, which was started from '
        '`main`, both by plain git — so the app has to deduce it. The guide '
        'is the proof: the same on `develop` and the feature, different on '
        '`main`, so it carries a mark only if the wrong branch was chosen. '
        'The process document is the other proof: `develop` rewrote it after '
        'the feature was cut, so it carries a mark only if the diff were read '
        'at `develop`\'s tip rather than where the feature left it. A branch '
        'started here then compares against the one it left.',
    steps: <Step>[
      Step('on main the document is clean and nothing is named', (
        TomRobot robot,
      ) async {
        await robot.launchWindowed(pickFolder: branched.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.clickInTheTree('index.md');
        await robot.seesInThePreview('The index, as main has it.');

        await robot.seesNoDiffMarks();
        await robot.seesTheDefaultComparison();
      }),
      Step('on the feature branch the base is develop, on its own', (
        TomRobot robot,
      ) async {
        await robot.switchesTo('feat/glossary');
        await robot.seesTheBranchControl('feat/glossary');

        await robot.seesTheComparison('Compared to develop');
      }),
      Step('what the branch rewrote is marked', (TomRobot robot) async {
        await robot.seesInThePreview(
          'The index, as the glossary branch rewrote it.',
        );

        await robot.seesTheDiffMarks(<String>['M']);
      }),
      Step('what develop already had is not', (TomRobot robot) async {
        // Against main this guide would be rewritten; against develop it is
        // the same text, which is what a deduction that chose main would get
        // wrong.
        await robot.clickInTheTree('writing.md');
        await robot.seesInThePreview('The guide, as develop rewrote it.');

        await robot.seesNoDiffMarks();
      }),
      Step('nor what develop did after the branch left it', (
        TomRobot robot,
      ) async {
        // develop rewrote this document after the feature was cut: read at
        // develop's tip it would be marked, read where the branch left
        // develop it is the feature's own, untouched.
        await robot.clickInTheTree('process.md');
        await robot.seesInThePreview(
          'The process, as every branch started with it.',
        );

        await robot.seesNoDiffMarks();
      }),
      Step('a branch started here compares against the one it left', (
        TomRobot robot,
      ) async {
        await robot.startsABranch('feat/more');
        await robot.seesTheBranchControl('feat/more');

        await robot.seesTheComparison('Compared to feat/glossary');
        robot.seesNothingBroken();
      }),
    ],
  );

  scenario(
    'Turns the marks off and back on from the Diff chip',
    group: 'Diff',
    describe:
        'The chip is a switch and nothing else '
        '(`docs/product/diff/rendered-diff/turning-it-off/doc.md`): a press '
        'takes the marks away and opens nothing to choose from, and the next '
        'brings them back against the same base — off is a reading position, '
        'not another comparison.',
    steps: <Step>[
      Step('a document the branch rewrote, marked', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: branched.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.switchesTo('feat/glossary');
        await robot.clickInTheTree('index.md');

        await robot.seesTheDiffMarks(<String>['M']);
      }),
      Step('a press takes the marks away and offers nothing', (
        TomRobot robot,
      ) async {
        await robot.pressesTheDiffChip();

        await robot.seesNoDiffMarks();
        robot.seesNothingToChooseFrom();
      }),
      Step('the next brings them back against the same base', (
        TomRobot robot,
      ) async {
        await robot.pressesTheDiffChip();

        await robot.seesTheDiffMarks(<String>['M']);
        await robot.seesTheComparison('Compared to develop');
        robot.seesNothingBroken();
      }),
    ],
  );
}
