/// Moving between branches, starting one, and what happens to open work.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture withBranches = fixtures['docs-with-branches'];

  /// What git says, asked outside the app entirely.
  String git(List<String> arguments) =>
      (Process.runSync('git', <String>[
                '-C',
                withBranches.repositoryRoot,
                ...arguments,
              ]).stdout
              as String)
          .trim();

  /// The branch git itself has checked out.
  String checkedOut() => git(<String>['rev-parse', '--abbrev-ref', 'HEAD']);

  scenario(
    'Switches branches, and the documents follow',
    group: 'Git — branches',
    describe:
        'The whole product rule in one pass: the branch is visible, the '
        'popover offers the others, and **switching updates every open '
        'document**. The two branches hold different files on purpose, so a '
        'switch that never touched the working tree could not pass — the '
        'explorer gains a document that exists only on the feature branch, '
        'and the open one is re-read rather than left showing the old '
        'branch. The last step asks **git itself** where `HEAD` is.',
    steps: <Step>[
      Step('open a space with a second branch in it', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: withBranches.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
      }),
      Step('both bars say which branch it is on', (TomRobot robot) async {
        // The status bar carries it from the moment a space is open, and the
        // control says the same thing — one reading, drawn twice
        // (`docs/product/git-workflow/branch-switch/doc.md`).
        await robot.seesTheBranch('main');
        await robot.seesTheBranchControl('main');
      }),
      Step('the document shows what main has', (TomRobot robot) async {
        await robot.clickInTheTree('index.md');

        await robot.seesInThePreview('The index, as main has it.');
        robot.seesNotInTheTree('rendered-diff.md');
      }),
      Step('the popover offers the branches there are', (TomRobot robot) async {
        await robot.opensTheBranches();

        robot.seesTheBranches(<String>['main', 'feat/rendered-diff']);
        await robot.closesTheBranches();
      }),
      Step('switching brings the other branch\'s files in', (
        TomRobot robot,
      ) async {
        await robot.switchesTo('feat/rendered-diff');

        await robot.seesTheBranch('feat/rendered-diff');
        await robot.seesInTheTree(<String>['rendered-diff.md']);
      }),
      Step('and the open document is re-read, not left behind', (
        TomRobot robot,
      ) async {
        // The rule that costs the most to get right: the buffer is the one
        // thing that would still be showing the branch that was left.
        await robot.seesInThePreview('as the feature branch rewrote it');
      }),
      Step('switching back undoes all of it', (TomRobot robot) async {
        await robot.switchesTo('main');

        await robot.seesTheBranch('main');
        await robot.seesInThePreview('The index, as main has it.');
        robot
          ..seesNotInTheTree('rendered-diff.md')
          ..seesNothingBroken();
      }),
      Step('which git itself confirms', (TomRobot robot) async {
        expect(checkedOut(), 'main');
      }),
    ],
  );

  scenario(
    'Refuses to switch away from unsaved work, and starts a branch',
    group: 'Git — branches',
    describe:
        'The half of the rule that is about not losing anything: switching '
        'is **blocked** while a document has unsaved changes, and the app '
        'asks before rather than reporting after. *Stay* leaves both the '
        'branch and the edit alone; *discard* switches and the document '
        'comes back off the disk. Then the other way of arriving somewhere '
        'new — starting a branch, which checks it out immediately, so there '
        'is no state where one exists and `HEAD` is still elsewhere.',
    steps: <Step>[
      Step('open a document and type into it', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: withBranches.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.looksAt('Source');
        await robot.clickInTheTree('index.md');
        await robot.typesInTheSource(
          '# Documentation\n\nTyped, never saved.\n',
        );

        await robot.seesUnsaved('index.md');
      }),
      Step('switching stops to ask rather than replacing it', (
        TomRobot robot,
      ) async {
        await robot.switchesTo('feat/rendered-diff');

        await robot.seesTheUnsavedQuestion('index.md');
        await robot.seesTheBranch('main');
      }),
      Step('staying leaves the branch and the edit alone', (
        TomRobot robot,
      ) async {
        await robot.staysOnTheBranch();

        await robot.seesTheBranch('main');
        await robot.seesUnsaved('index.md');
        expect(checkedOut(), 'main');
      }),
      Step('discarding switches, and the document comes off the disk', (
        TomRobot robot,
      ) async {
        await robot.switchesTo('feat/rendered-diff');
        await robot.seesTheUnsavedQuestion('index.md');

        await robot.discardsTheEdit();

        await robot.seesTheBranch('feat/rendered-diff');
        await robot.seesInTheSource('as the feature branch rewrote it');
        await robot.seesNothingUnsaved('index.md');
      }),
      Step('starting a branch moves onto it immediately', (
        TomRobot robot,
      ) async {
        await robot.startsABranch('feat/from-the-app');

        await robot.seesTheBranch('feat/from-the-app');
        await robot.seesTheBranchControl('feat/from-the-app');
      }),
      Step('which git confirms, from the branch it was started on', (
        TomRobot robot,
      ) async {
        // Started at the current HEAD, so it carries the feature branch's
        // document rather than main's.
        expect(checkedOut(), 'feat/from-the-app');
        expect(
          File('${withBranches.root}/rendered-diff.md').existsSync(),
          isTrue,
          reason: 'the new branch did not start where HEAD was',
        );
        robot
          ..seesNoQuestion()
          ..seesNothingBroken();
      }),
    ],
  );
}
