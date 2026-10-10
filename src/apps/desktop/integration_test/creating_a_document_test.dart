/// The explorer's `+`: a new document named in the tree, on a real disk.
library;

import 'package:tom_domain/tom_domain.dart';

import 'support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture docsInRepo = fixtures['docs-in-repo'];

  scenario(
    'Creates a document from the tree',
    group: 'Workspace',
    describe:
        'What the `+` at the head of the explorer is for: a markdown document '
        'named in the tree rather than in a dialog, created on disk and '
        'opened in source. A name the folder already holds is refused where '
        'it was typed, and the file that was created is untracked, so the '
        'tree and the git column say so at once.',
    steps: <Step>[
      Step('open the docs folder inside a repository', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.seesInTheTree(<String>['index.md']);
      }),
      Step('a name the folder already holds is refused in place', (
        TomRobot robot,
      ) async {
        await robot.createsADocument('index');
        await robot.seesTheNameRefused();
      }),
      Step('Escape takes the row away', (TomRobot robot) async {
        await robot.cancelsTheNewDocument();
      }),
      Step('a new name is created, and opened in source', (
        TomRobot robot,
      ) async {
        await robot.createsADocument('ideas');
        await robot.seesTheOpenDocument('ideas.md');
        await robot.seesOnlyTheSource();
      }),
      Step('the tree marks it untracked, and git lists it', (
        TomRobot robot,
      ) async {
        await robot.seesTheTreeMark('ideas.md', FileStateEnum.untracked);
        await robot.seesInTheChanges(<String>['ideas.md']);
      }),
      Step('with a document open, the new one goes beside it', (
        TomRobot robot,
      ) async {
        await robot.clickInTheTree('writing.md');
        await robot.createsADocument('drafting');
        await robot.seesTheOpenDocument('guides/drafting.md');
      }),
      Step('and nothing is broken', (TomRobot robot) async {
        robot.seesNothingBroken();
      }),
    ],
  );
}
