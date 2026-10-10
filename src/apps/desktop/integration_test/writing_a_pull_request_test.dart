/// The pull request: a draft written in the editor, from outside the space.
library;

import 'support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture proposing = fixtures['docs-proposing'];
  final Fixture docsInRepo = fixtures['docs-in-repo'];

  scenario(
    'Writes a pull request',
    group: 'Git — pull request',
    describe:
        'A branch with two commits pushed, on a repository whose origin is '
        'GitHub. The row at the top of the tree opens the branch\'s draft — '
        'seeded from git, the first commit as its heading — in the whole '
        'editor, with the status row where the tabs were and the branch\'s '
        'own column at the right. Deleting the heading takes the title away '
        'and the row says so; leaving for a document keeps the draft, and '
        'coming back finds what was written.',
    steps: <Step>[
      Step('open the docs folder on the branch', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: proposing.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
      }),
      Step('the tree offers the pull request', (TomRobot robot) async {
        await robot.opensThePullRequest();
      }),
      Step('the draft starts from git, and is ready to open', (
        TomRobot robot,
      ) async {
        await robot.seesInThePreview('docs: start the release notes');
        await robot.seesInThePreview('docs: say what changed in the handbook');
        await robot.seesOnScreen(<String>[
          'Ready to open. 2 commits pushed, nothing left to publish.',
        ]);
      }),
      Step('the right column proposes it onto main', (TomRobot robot) async {
        await robot.seesOnScreen(<String>[
          'PROPOSING ONTO',
          'main',
          '2 commits · 2 documents',
          'Open on GitHub',
        ]);
        await robot.seesNotOnScreen('Stage all');
        // This machine has no `gh`, so the host's page is the one action.
        await robot.seesNotOnScreen('Create pull request');
      }),
      Step('the overview counts it in words', (TomRobot robot) async {
        await robot.tapText('Overview');
        await robot.seesOnScreen(<String>['to review', 'WORDS', 'DOCUMENTS']);
      }),
      Step('a draft without its heading has no title', (TomRobot robot) async {
        await robot.looksAt('Source');
        await robot.typesInTheSource('Why this branch exists.\n');
        await robot.seesOnScreen(<String>[
          'The draft has no title — its first line is a # heading.',
        ]);
      }),
      Step('a title back, and the row is ready again', (TomRobot robot) async {
        await robot.typesInTheSource('# Release notes\n\nWhy it exists.\n');
        await robot.seesOnScreen(<String>[
          'Ready to open. 2 commits pushed, nothing left to publish.',
        ]);
      }),
      Step('a document from the tree leaves the page', (TomRobot robot) async {
        await robot.looksAt('Split');
        await robot.clickInTheTree('index.md');
        await robot.seesTheOpenDocument('index.md');
        await robot.seesNotOnScreen('PROPOSING ONTO');
      }),
      Step('and coming back finds what was written', (TomRobot robot) async {
        await robot.opensThePullRequest();
        await robot.seesInThePreview('Release notes');
        await robot.seesInThePreview('Why it exists.');
      }),
      Step('and nothing is broken', (TomRobot robot) async {
        robot.seesNothingBroken();
      }),
    ],
  );

  scenario(
    'Opens a pull request through gh, and finds it open afterwards',
    group: 'Git — pull request',
    describe:
        'The same branch on a machine whose `gh` holds a login — the run\'s '
        'own `gh`, a script that answers from files and reaches no network. '
        'The page asks it first whether the branch already has a pull '
        'request; it has none, so the column offers `Create pull request` '
        'over the host\'s page. Creating hands `gh` the draft, the row says '
        'which number GitHub gave it, the commands panel shows the two `gh` '
        'calls, and after a restart the page finds it already open.',
    steps: <Step>[
      Step('open the docs folder, on a machine with gh', (
        TomRobot robot,
      ) async {
        await robot.launchWindowed(pickFolder: proposing.root, withGh: true);
        await robot.chooseFolder();
        await robot.seesTheShell();
      }),
      Step('gh says none is open, so the page offers to create one', (
        TomRobot robot,
      ) async {
        await robot.opensThePullRequest();
        await robot.seesOnScreen(<String>[
          'Create pull request',
          'Open on GitHub instead',
          'Ready to open. 2 commits pushed, nothing left to publish.',
        ]);
      }),
      Step('creating opens it, and the row names its number', (
        TomRobot robot,
      ) async {
        await robot.pressesThePullRequestAction('Create pull request');
        await robot.seesOnScreen(<String>[
          'Pull request #123 is open on GitHub — this draft is what it was '
              'opened with.',
          'View #123 on GitHub',
        ]);
        await robot.seesNotOnScreen('Create pull request');
      }),
      Step('the draft is still what it was', (TomRobot robot) async {
        await robot.seesInThePreview('docs: start the release notes');
      }),
      Step('the commands panel shows what gh was asked', (
        TomRobot robot,
      ) async {
        await robot.pressesTheCommandsShortcut();
        await robot.seesTheCommands(<String>['gh pr list', 'gh pr create']);
        await robot.closesTheCommands();
      }),
      Step('View opens it on GitHub', (TomRobot robot) async {
        await robot.pressesThePullRequestAction('View #123 on GitHub');
        await robot.seesTheBrowserAskedFor(
          'https://github.com/acme/docs/pull/123',
        );
      }),
      Step('after a restart, the page finds it already open', (
        TomRobot robot,
      ) async {
        await robot.launchWindowed(pickFolder: proposing.root, withGh: true);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.opensThePullRequest();
        await robot.seesOnScreen(<String>['View #123 on GitHub']);
        await robot.seesNotOnScreen('Create pull request');
      }),
      Step('and nothing is broken', (TomRobot robot) async {
        robot.seesNothingBroken();
      }),
    ],
  );

  scenario(
    'Says why a pull request cannot be opened without a remote',
    group: 'Git — pull request',
    describe:
        'A repository with no remote: there is no host to propose to. The '
        'row is still drawn — a control that appears only sometimes teaches '
        'nothing about when it will — but muted, with **the reason under its '
        'name**, and pressing it opens nothing.',
    steps: <Step>[
      Step('open a repository with no remote', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
      }),
      Step('the row says why it cannot act', (TomRobot robot) async {
        await robot.seesThePullRequestUnavailable('No remote to propose to');
      }),
      Step('and nothing is broken', (TomRobot robot) async {
        robot.seesNothingBroken();
      }),
    ],
  );
}
