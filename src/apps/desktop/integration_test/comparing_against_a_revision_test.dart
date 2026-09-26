/// The same rendered diff, against another branch or another commit.
library;

import 'support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture withBranches = fixtures['docs-with-branches'];
  final Fixture withHistory = fixtures['docs-with-history'];

  scenario(
    'Compares a document against another branch',
    group: 'Diff',
    describe:
        'The rendered diff pointed somewhere else: the working copy against '
        'a **branch** rather than the last commit '
        '(`docs/product/diff/branch-diff/doc.md`). The fixture\'s two '
        'branches hold different versions of the index, so a comparison that '
        'quietly stayed on `HEAD` could not pass — on `main` the document is '
        'clean and carries no mark, and against the feature branch its one '
        'paragraph is rewritten. Taking the base back makes it clean again.',
    steps: <Step>[
      Step('a clean document on main carries no decoration', (
        TomRobot robot,
      ) async {
        await robot.launchWindowed(pickFolder: withBranches.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.clickInTheTree('index.md');
        await robot.seesInThePreview('The index, as main has it.');

        await robot.seesNoDiffMarks();
        await robot.seesTheDefaultComparison();
      }),
      Step('the surface offers the branches and this file\'s commits', (
        TomRobot robot,
      ) async {
        await robot.opensTheComparison();

        await robot.seesOnOffer(<String>['main', 'feat/rendered-diff']);
      }),
      Step('against the other branch the paragraph is rewritten', (
        TomRobot robot,
      ) async {
        // The heading is the same on both sides and stays undecorated; the
        // one paragraph that differs is what carries the mark.
        await robot.comparesAgainst('feat/rendered-diff');

        await robot.seesTheDiffMarks(<String>['M']);
        await robot.seesTheComparison('feat/rendered-diff');
      }),
      Step('and the document itself is still the working copy', (
        TomRobot robot,
      ) async {
        // Nothing was checked out: comparing is reading, and the branch the
        // window is on has not moved.
        await robot.seesInThePreview('The index, as main has it.');
        await robot.seesTheBranch('main');
      }),
      Step('taking the base back leaves it clean again', (
        TomRobot robot,
      ) async {
        await robot.stopsComparing();

        await robot.seesNoDiffMarks();
        await robot.seesTheDefaultComparison();
        robot.seesNothingBroken();
      }),
    ],
  );

  scenario(
    'Compares a document against an earlier commit',
    group: 'Diff',
    describe:
        'The other half the product asks for: **any two commits**. The '
        'fixture writes the index three times, so the working copy compared '
        'against the second commit shows the one paragraph that changed — '
        'and a past version opened from the history, which is compared '
        'against nothing by default, is compared when somebody asks for it.',
    steps: <Step>[
      Step('open a document whose index has a history', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: withHistory.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.clickInTheTree('index.md');

        await robot.seesInThePreview('as the working copy has it');
        await robot.seesNoDiffMarks();
      }),
      Step('against an earlier commit the paragraph is rewritten', (
        TomRobot robot,
      ) async {
        await robot.comparesAgainst('docs: write the index');

        await robot.seesTheDiffMarks(<String>['M']);
        await robot.seesTheComparison('Compared to');
      }),
      Step('a past version on screen is compared to that commit too', (
        TomRobot robot,
      ) async {
        // Two commits, neither of them the working copy — which is the claim
        // a version opened from history could not make before.
        await robot.opensTheVersion('docs: expand the index');

        await robot.seesInThePreview('as the second commit left it');
        await robot.seesTheDiffMarks(<String>['M']);
      }),
      Step('and coming back to now keeps the base', (TomRobot robot) async {
        await robot.goesBackToNow();

        await robot.seesInThePreview('as the working copy has it');
        await robot.seesTheDiffMarks(<String>['M']);
        robot.seesNothingBroken();
      }),
    ],
  );
}
