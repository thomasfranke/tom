/// Staging one file, describing it, and recording it in a real repository.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture docsInRepo = fixtures['docs-in-repo'];

  /// What git says about the fixture, asked outside the app entirely.
  String git(List<String> arguments) =>
      (Process.runSync('git', <String>[
                '-C',
                docsInRepo.repositoryRoot,
                ...arguments,
              ]).stdout
              as String)
          .trim();

  scenario(
    'Commits one of two changes',
    group: 'Git — local',
    describe:
        'Staging is whole files, one at a time or all at once — never a '
        'hunk. This stages one of the two files the fixture leaves dirty, '
        'describes it, commits, and then asks **git itself** what landed: '
        'one new commit with that message, the other file still waiting.',
    steps: <Step>[
      Step('open a space with two things changed in it', (
        TomRobot robot,
      ) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        // The repository's list, not the space's: both of these happen to
        // be inside `docs/`, and a file outside it would be here too.
        await robot.seesInTheChanges(<String>['untracked.md', 'writing.md']);
      }),
      Step('the status bar says which branch it is on', (TomRobot robot) async {
        await robot.seesTheBranch('main');
      }),
      Step('staging one file leaves the other alone', (TomRobot robot) async {
        await robot.stages('untracked.md');

        await robot.seesInTheChanges(<String>['untracked.md', 'writing.md']);
        expect(
          git(<String>['diff', '--cached', '--name-only']),
          'docs/untracked.md',
        );
      }),
      Step('describing it and committing records what was staged', (
        TomRobot robot,
      ) async {
        await robot.describesTheCommit('docs: add the untracked note');
        await robot.commits();

        expect(
          git(<String>['log', '-1', '--format=%s']),
          'docs: add the untracked note',
        );
      }),
      Step('and the list now shows only what is still waiting', (
        TomRobot robot,
      ) async {
        // After a commit the file list reflects the tree it left behind
        // (docs/product/git-workflow/commit/doc.md).
        await robot.seesNotInTheChanges('untracked.md');
        await robot.seesInTheChanges(<String>['writing.md']);
        robot.seesNothingBroken();
      }),
    ],
  );

  scenario(
    'Refuses to commit without a message, and stages everything at once',
    group: 'Git — local',
    describe:
        'The two halves of the product rule that are not about one file: a '
        'commit **requires a message**, and the refusal is the button being '
        'unavailable rather than an error after the attempt; and staging is '
        'everything at once or one at a time, never finer. *All* is built '
        'from the list on screen, so what it acts on is exactly what was '
        'being looked at.',
    steps: <Step>[
      Step('open a space with two things changed in it', (
        TomRobot robot,
      ) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.seesInTheChanges(<String>['untracked.md', 'writing.md']);
      }),
      Step('with nothing staged there is nothing to commit', (
        TomRobot robot,
      ) async {
        await robot.seesCommitUnavailable();
      }),
      Step('staging everything takes both, in one gesture', (
        TomRobot robot,
      ) async {
        await robot.stagesEverything();

        expect(
          git(<String>['diff', '--cached', '--name-only']).split('\n')..sort(),
          <String>['docs/guides/writing.md', 'docs/untracked.md'],
        );
      }),
      Step('and it is still refused until it is described', (
        TomRobot robot,
      ) async {
        // Staged is half of it: a commit requires a message
        // (docs/product/git-workflow/commit/doc.md).
        await robot.seesCommitUnavailable();

        await robot.describesTheCommit('docs: everything at once');

        await robot.commits();
        expect(
          git(<String>['log', '-1', '--format=%s']),
          'docs: everything at once',
        );
      }),
      Step('which leaves the tree with nothing left to say', (
        TomRobot robot,
      ) async {
        await robot.seesACleanTree();
        robot.seesNothingBroken();
      }),
    ],
  );
}
