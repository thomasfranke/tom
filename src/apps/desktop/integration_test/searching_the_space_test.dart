/// Full-text search: finding a document by what is written inside it.
library;

import 'support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture docsInRepo = fixtures['docs-in-repo'];

  scenario(
    'Reaches the search from the keyboard',
    group: 'Search',
    describe:
        'The ⌘K the search box shows while it is idle: pressed anywhere in '
        'the window it puts the keyboard in the box — and when the explorer '
        'is shut, it opens it first, because the box lives there.',
    steps: <Step>[
      Step('open the docs folder, and shut the explorer', (
        TomRobot robot,
      ) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.togglesTheColumn('Hide explorer');
      }),
      Step('⌘K opens it again, with the keyboard in the search', (
        TomRobot robot,
      ) async {
        await robot.pressesTheSearchShortcut();
        await robot.seesTheSearchFocused();
      }),
      Step('and what is typed is searched for', (TomRobot robot) async {
        await robot.typesInTheSearch('paragraph');
        await robot.seesInTheResults(<String>['writing.md']);
      }),
      Step('and nothing is broken', (TomRobot robot) async {
        robot.seesNothingBroken();
      }),
    ],
  );

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
      Step('with nothing typed the column is still the tree', (
        TomRobot robot,
      ) async {
        await robot.seesInTheTree(<String>['index.md']);
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
