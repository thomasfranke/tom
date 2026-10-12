/// What the search column says when it has nothing to list, and what it
/// leaves alone.
library;

import '../../support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture docsInRepo = fixtures['docs-in-repo'];

  scenario(
    'Says why the open document has nothing to show',
    group: 'Search',
    describe:
        'An empty list is never a bare column: `This file` says which of '
        'three reasons it is — no document is open, nothing is typed, or '
        'the words are not in it — and `Whole space`, pressed back, answers '
        'from the index again.',
    steps: <Step>[
      Step('open the docs folder inside a repository', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.seesTheScopeControl();
      }),
      Step('with no document open, This file says to open one', (
        TomRobot robot,
      ) async {
        // The column is the tree until a word is typed, so the sentence
        // is asked for with one.
        await robot.typesInTheSearch('paragraph');
        await robot.searchesTheOpenFile();

        await robot.seesTheSearchColumnSaying(
          'Open a document to search inside it.',
        );
      }),
      Step('Whole space lists the documents, and one is opened', (
        TomRobot robot,
      ) async {
        await robot.searchesTheWholeSpace();
        await robot.clickInTheResults('writing.md');

        await robot.seesTheOpenDocument('guides/writing.md');
      }),
      Step('with a document and no words, This file says to type', (
        TomRobot robot,
      ) async {
        await robot.clearsTheSearch();
        await robot.searchesTheOpenFile();

        await robot.seesTheSearchColumnSaying('Type to search this document.');
      }),
      Step('words that are not in the document say so, by its name', (
        TomRobot robot,
      ) async {
        await robot.searchesTheOpenFile();
        await robot.typesInTheSearch('wikilinks');

        await robot.seesTheSearchColumnSaying(
          'Nothing in writing.md says that.',
        );
      }),
      Step('a word that is in it lists the occurrences instead', (
        TomRobot robot,
      ) async {
        await robot.typesInTheSearch('paragraph');

        await robot.seesInTheOccurrences(<String>[
          '2 occurrences in writing.md',
        ]);
      }),
      Step('Whole space, pressed back, answers from the index', (
        TomRobot robot,
      ) async {
        await robot.searchesTheWholeSpace();

        await robot.seesInTheResults(<String>['writing.md', 'reviewing.md']);
      }),
      Step('and nothing is broken', (TomRobot robot) async {
        robot.seesNothingBroken();
      }),
    ],
  );

  scenario(
    'Leaves the right column alone while searching',
    group: 'Search',
    describe:
        'Search belongs to the left column, box and results together; the '
        'right one stays git\'s however much is typed, and the scope '
        'control is on screen before anything is typed rather than shown by '
        'focus.',
    steps: <Step>[
      Step('open the docs folder inside a repository', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
      }),
      Step('with nothing typed the scope control is already there', (
        TomRobot robot,
      ) async {
        await robot.seesTheScopeControl();
        await robot.seesInTheChanges(<String>['untracked.md', 'writing.md']);
      }),
      Step('typing fills the left column and the right one is still git', (
        TomRobot robot,
      ) async {
        await robot.typesInTheSearch('paragraph');
        await robot.seesInTheResults(<String>['writing.md']);

        await robot.seesInTheChanges(<String>['untracked.md', 'writing.md']);
        await robot.seesTheScopeControl();
      }),
      Step('asking of the open file changes nothing on the right', (
        TomRobot robot,
      ) async {
        await robot.clickInTheResults('writing.md');
        await robot.searchesTheOpenFile();

        await robot.seesInTheChanges(<String>['untracked.md', 'writing.md']);
      }),
      Step('and nothing is broken', (TomRobot robot) async {
        robot.seesNothingBroken();
      }),
    ],
  );
}
