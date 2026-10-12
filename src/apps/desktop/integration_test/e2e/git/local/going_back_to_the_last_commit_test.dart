/// The git column's `⋮`: its rows, and the discard that asks first.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../support/harness.dart';

/// The git menu's third row, which names the platform's own file manager
/// (`file_manager_words.dart`'s `openRepositoryLabel`): `Finder` on macOS,
/// `Files` everywhere this suite runs.
final String _openRepositoryLabel = Platform.isMacOS
    ? 'Open repository in Finder'
    : 'Open repository in Files';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture docsInRepo = fixtures['docs-in-repo'];
  late String untrackedText;

  /// What git says about the fixture, asked outside the app entirely.
  String gitSays(List<String> arguments) =>
      (Process.runSync('git', <String>[
                '-C',
                docsInRepo.repositoryRoot,
                ...arguments,
              ]).stdout
              as String)
          .trim();

  scenario(
    'Goes back to the last commit from the git menu',
    group: 'Git',
    submenu: 'Local',
    describe:
        'What the `⋮` at the head of the git column offers, against a real '
        'repository holding one modified document and one untracked one. '
        '`Discard all changes` asks first and names how many documents go '
        'back; answered, the modified one is the last commit again — in the '
        'changes list and in the preview on screen — and the untracked one '
        'is still there, because git never recorded it — even when it had '
        'been staged, and with its content. The terminal and the file manager '
        'are asked for the repository\'s root; the run\'s desktop writes the '
        'request down, so nothing opens on whoever runs it.',
    steps: <Step>[
      Step('open the docs folder, and the document that changed', (
        TomRobot robot,
      ) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.clickInTheTree('writing.md');
        await robot.seesInThePreview('One line added, uncommitted.');
      }),
      Step('the git menu offers three rows, then the discard apart', (
        TomRobot robot,
      ) async {
        await robot.opensTheMenu('Git menu');
        await robot.seesInTheMenu(<String>[
          'Reload',
          'Open in terminal',
          _openRepositoryLabel,
          'Discard all changes',
        ]);
      }),
      Step('Open in terminal asks for a terminal in the repository\'s root', (
        TomRobot robot,
      ) async {
        await robot.tapText('Open in terminal');

        await robot.seesATerminalAskedFor(docsInRepo.repositoryRoot);
      }),
      Step('Open repository in Finder asks for the repository\'s folder', (
        TomRobot robot,
      ) async {
        await robot.choosesFromTheMenu('Git menu', _openRepositoryLabel);

        await robot.seesTheFileManagerAskedFor(docsInRepo.repositoryRoot);
      }),
      Step('a new file is staged, so the discard has something to spare', (
        TomRobot robot,
      ) async {
        untrackedText = File(
          '${docsInRepo.root}/untracked.md',
        ).readAsStringSync();
        await robot.stages('untracked.md');

        expect(
          gitSays(<String>['diff', '--cached', '--name-only']),
          isNotEmpty,
        );
      }),
      Step('the discard asks first, naming how many go back', (
        TomRobot robot,
      ) async {
        await robot.choosesFromTheMenu('Git menu', 'Discard all changes');
        await robot.seesOnScreen(<String>[
          'Discard all changes?',
          '1 document goes back to the last commit.',
          'New files are kept, untracked.',
        ]);
      }),
      Step('Keep the changes changes nothing', (TomRobot robot) async {
        await robot.tapInTheDialog('Keep the changes');

        await robot.seesInTheChanges(<String>['writing.md', 'untracked.md']);
        expect(
          gitSays(<String>['status', '--porcelain']),
          contains('writing.md'),
        );
        expect(
          File('${docsInRepo.root}/guides/writing.md').readAsStringSync(),
          contains('One line added, uncommitted.'),
        );
      }),
      Step('asked again and answered, the document is the last commit again', (
        TomRobot robot,
      ) async {
        await robot.choosesFromTheMenu('Git menu', 'Discard all changes');
        await robot.tapInTheDialog('Discard all changes');
        await robot.seesNotInTheChanges('writing.md');
        await robot.seesNotInThePreview('One line added, uncommitted.');
      }),
      Step('and the staged new file survives, untracked, with its content', (
        TomRobot robot,
      ) async {
        await robot.seesInTheChanges(<String>['untracked.md']);
        expect(
          gitSays(<String>['status', '--porcelain']),
          '?? docs/untracked.md',
        );
        expect(
          File('${docsInRepo.root}/untracked.md').readAsStringSync(),
          untrackedText,
        );
      }),
      Step('and nothing is broken', (TomRobot robot) async {
        robot.seesNothingBroken();
      }),
    ],
  );

  final Fixture conflicting = fixtures['docs-conflicting-remote'];

  /// Runs git on the conflicting fixture, outside the app entirely.
  ProcessResult git(List<String> arguments) => Process.runSync('git', <String>[
    '-C',
    conflicting.repositoryRoot,
    ...arguments,
  ]);

  bool midMerge() =>
      File('${conflicting.repositoryRoot}/.git/MERGE_HEAD').existsSync();

  scenario(
    'Refuses to discard everything once a merge has started',
    group: 'Git',
    submenu: 'Local',
    describe:
        'Mid-merge, `Discard all changes` would end the merge and write over '
        'the conflicted files, so the menu does not offer it. A menu is drawn '
        'from a reading, though, and the app has a terminal: here the merge '
        'starts **after** the menu opened. The press is refused where the '
        'action runs, the merge and every file are as they were, and the '
        'menu read again no longer offers it.',
    steps: <Step>[
      Step('open a space with one document changed', (TomRobot robot) async {
        // Changed before the app starts, so its first reading lists it.
        File(
          '${conflicting.root}/index.md',
        ).writeAsStringSync('# Handbook\n\nChanged and not committed.\n');
        await robot.launchWindowed(pickFolder: conflicting.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.seesInTheChanges(<String>['index.md']);
      }),
      Step('the git menu offers the discard, as nothing is being merged', (
        TomRobot robot,
      ) async {
        await robot.opensTheMenu('Git menu');
        await robot.seesInTheMenu(<String>[
          'Reload',
          'Open in terminal',
          _openRepositoryLabel,
          'Discard all changes',
        ]);
      }),
      Step('a pull in a terminal stops in a conflict, behind the open menu', (
        TomRobot robot,
      ) async {
        git(<String>['pull', '--no-rebase']);

        expect(midMerge(), isTrue);
        expect(
          (git(<String>['diff', '--name-only', '--diff-filter=U']).stdout
                  as String)
              .trim(),
          'docs/roadmap.md',
        );
      }),
      Step('pressed and confirmed, the discard is refused and says why', (
        TomRobot robot,
      ) async {
        await robot.tapText('Discard all changes');
        await robot.tapInTheDialog('Discard all changes');

        await robot.seesTheGitColumnSaying(
          'A merge is in progress — resolve it first.',
        );
      }),
      Step('the merge, the conflict and the uncommitted change are all as '
          'they were', (TomRobot robot) async {
        expect(midMerge(), isTrue);
        expect(
          File('${conflicting.root}/roadmap.md').readAsStringSync(),
          contains('<<<<<<< HEAD'),
        );
        expect(
          File('${conflicting.root}/index.md').readAsStringSync(),
          '# Handbook\n\nChanged and not committed.\n',
        );
        await robot.seesInTheChanges(<String>['roadmap.md', 'index.md']);
      }),
      Step('and the menu, read again, no longer offers it', (
        TomRobot robot,
      ) async {
        await robot.opensTheMenu('Git menu');
        await robot.seesInTheMenu(<String>[
          'Reload',
          'Open in terminal',
          _openRepositoryLabel,
        ]);
        await robot.dismissesTheMenu();
        robot.seesNothingBroken();
      }),
    ],
  );
}
