/// Full-text search: finding a document by what is written inside it.
library;

import 'support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture docsInRepo = fixtures['docs-in-repo'];

  scenario(
    'Finds a document by its contents',
    group: 'Search',
    describe:
        'What search is for, and the one thing a file tree cannot do: the '
        'word searched for is in nobody\'s file name, so every hit is a '
        'document whose *text* says it. The index is built while the space '
        'opens, so the panel says it is reading rather than saying nothing '
        'was found, and a result opens the document like any row of the tree.',
    steps: <Step>[
      Step('open the docs folder inside a repository', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
      }),
      Step('with nothing typed the panel says where the box is', (
        TomRobot robot,
      ) async {
        await robot.seesInTheResults(<String>[
          'Type above the tree to search this space.',
        ]);
      }),
      Step('a word only the text says finds the documents that say it', (
        TomRobot robot,
      ) async {
        // "paragraph" is in two guides and in no file name at all.
        await robot.typesInTheSearch('paragraph');

        await robot.seesInTheResults(<String>['writing.md', 'reviewing.md']);
      }),
      Step('and a document that does not say it is not offered', (
        TomRobot robot,
      ) async {
        await robot.seesNotInTheResults('commands.md');
      }),
      Step('and the panel says how many documents that is', (
        TomRobot robot,
      ) async {
        await robot.seesInTheResults(<String>['2 documents']);
      }),
      Step('clicking a result opens that document', (TomRobot robot) async {
        await robot.clickInTheResults('writing.md');

        await robot.seesTheOpenDocument('guides/writing.md');
        await robot.seesInThePreview('Writing');
      }),
      Step('a word nothing says is said to find nothing', (
        TomRobot robot,
      ) async {
        await robot.typesInTheSearch('wikilinks');

        await robot.seesNoResults();
      }),
      Step('and nothing is broken', (TomRobot robot) async {
        robot.seesNothingBroken();
      }),
    ],
  );
}
