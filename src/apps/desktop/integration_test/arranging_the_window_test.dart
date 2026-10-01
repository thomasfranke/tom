/// The chrome the reader arranges: the columns, their widths, the theme.
library;

import 'support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture docsInRepo = fixtures['docs-in-repo'];

  scenario(
    'Arranges the window: the columns, their width and the git panel',
    group: 'Workspace',
    describe:
        'Three controls at the right of the bar and one switch at the head '
        'of the git column are the whole of it. A hidden column is a column '
        'and not a mode — what was on screen comes back unchanged — the '
        'left one is dragged to whatever width the reader wants, and the '
        'right one shows one git panel at a time rather than stacking two.',
    steps: <Step>[
      Step('open the docs folder inside a repository', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();

        await robot.seesTheShell();
      }),
      Step('the git column offers both panels and shows the first', (
        TomRobot robot,
      ) async {
        await robot.seesOnScreen(<String>['Git', 'History']);
        await robot.seesNotOnScreen('Open a document to see what changed it.');
      }),
      Step('choosing the other one puts it there instead', (
        TomRobot robot,
      ) async {
        await robot.showsTheGitPanel('History');

        await robot.seesOnScreen(<String>[
          'Open a document to see what changed it.',
        ]);
      }),
      Step('the left column is dragged wider', (TomRobot robot) async {
        await robot.widensTheExplorer(80);

        await robot.seesInTheTree(<String>['index.md']);
      }),
      Step('and either column can be put away and brought back', (
        TomRobot robot,
      ) async {
        await robot.togglesTheColumn('Hide explorer');
        robot.seesNotInTheTree('index.md');

        await robot.togglesTheColumn('Show explorer');
        await robot.seesInTheTree(<String>['index.md']);
      }),
      Step('and nothing is broken', (TomRobot robot) async {
        robot.seesNothingBroken();
      }),
    ],
  );
}
