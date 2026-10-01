/// The file tree: finding a document in a real folder and opening it.
library;

import 'support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture docsInRepo = fixtures['docs-in-repo'];
  final Fixture repoItself = fixtures['repo-itself'];

  scenario(
    'Navigates the tree of a docs folder',
    group: 'Workspace',
    describe:
        'What the explorer is for: a real folder on disk, walked once, drawn '
        'as a tree. It shows every file the folder holds — the image beside '
        'the documents included — and opens only the markdown, which is the '
        'one difference between what the tree draws and what the editor '
        'reads.',
    steps: <Step>[
      Step('open the docs folder inside a repository', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
      }),
      Step('the top bar says which repository the folder is in', (
        TomRobot robot,
      ) async {
        robot.seesTheSpaceIsIn('docs-in-repo');
      }),
      Step('the tree shows the folder, one level in', (TomRobot robot) async {
        await robot.seesInTheTree(<String>[
          'adr',
          'guides',
          'reference',
          'index.md',
          'untracked.md',
        ]);
      }),
      Step('and what is inside its folders, because they start open', (
        TomRobot robot,
      ) async {
        await robot.seesInTheTree(<String>[
          '001-why-markdown.md',
          'writing.md',
          'reviewing.md',
          'commands.md',
        ]);
      }),
      Step('including the files the editor cannot open', (
        TomRobot robot,
      ) async {
        await robot.seesInTheTree(<String>['logo.svg']);
      }),
      Step('closing a folder hides what is inside it', (TomRobot robot) async {
        await robot.clickInTheTree('guides');

        robot.seesNotInTheTree('writing.md');
        await robot.seesInTheTree(<String>['commands.md']);
      }),
      Step('opening it again brings them back', (TomRobot robot) async {
        await robot.clickInTheTree('guides');

        await robot.seesInTheTree(<String>['writing.md']);
      }),
      Step('clicking a document opens it, and the status bar says which', (
        TomRobot robot,
      ) async {
        await robot.clickInTheTree('writing.md');

        await robot.seesTheOpenDocument('guides/writing.md');
      }),
      Step('and the preview renders what is in it', (TomRobot robot) async {
        await robot.seesInThePreview('Writing');
      }),
      Step('and nothing is broken', (TomRobot robot) async {
        robot.seesNothingBroken();
      }),
    ],
  );

  scenario(
    'Keeps git out of the tree',
    group: 'Workspace',
    describe:
        'The one folder the tree hides, and the only case where it is even '
        'inside the space: a repository opened at its own root. The walk '
        'never descends into `.git/` — which is what keeps a listing of a '
        'mature repository affordable — so what is inside it cannot appear '
        'either.',
    steps: <Step>[
      Step('open a repository at its own root', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: repoItself.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
      }),
      Step('the tree shows what the repository holds', (TomRobot robot) async {
        await robot.seesInTheTree(<String>['daily', 'index.md']);
      }),
      Step('and nothing of git at all', (TomRobot robot) async {
        robot
          ..seesNotInTheTree('.git')
          // `HEAD` is inside every `.git/`, so finding it means the walk
          // went in.
          ..seesNotInTheTree('HEAD')
          ..seesNothingBroken();
      }),
    ],
  );
}
