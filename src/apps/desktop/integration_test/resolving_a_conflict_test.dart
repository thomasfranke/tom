/// The pull that stops in the middle, and what the app says about it.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture conflicting = fixtures['docs-conflicting-remote'];

  /// What git says, asked outside the app entirely.
  String git(List<String> arguments) =>
      (Process.runSync('git', <String>[
                '-C',
                conflicting.repositoryRoot,
                ...arguments,
              ]).stdout
              as String)
          .trim();

  /// Whether git is sitting mid-merge, which is the state the whole
  /// scenario is about.
  bool midMerge() =>
      File('${conflicting.repositoryRoot}/.git/MERGE_HEAD').existsSync();

  scenario(
    'A pull that conflicts is named, and can be undone',
    group: 'Git — remote',
    describe:
        'The one pull outcome the app cannot hide. Both sides rewrote the '
        'same line, so git stops mid-merge and writes **both** versions into '
        'the working tree. What the scenario proves is that the state is the '
        "*repository's* and not the session's: the band says how many "
        'documents conflict, the changes list marks them `C`, the commit is '
        'taken away while a marker is still there, and `Abort the pull` puts '
        'the working tree back without touching what was already committed.',
    steps: <Step>[
      Step('open a space whose remote rewrote the same line', (
        TomRobot robot,
      ) async {
        await robot.launchWindowed(pickFolder: conflicting.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
      }),
      Step('nothing is conflicted before anybody pulls', (
        TomRobot robot,
      ) async {
        expect(midMerge(), isFalse);
        await robot.seesACleanTree();
      }),
      Step('pull, and git stops in the middle', (TomRobot robot) async {
        await robot.pulls();
        // Asked of git rather than of the screen: the band is the app's
        // reading of this, and the two must not be the same source.
        expect(midMerge(), isTrue);
        expect(
          git(<String>['diff', '--name-only', '--diff-filter=U']),
          'docs/roadmap.md',
        );
      }),
      Step('the band says the pull stopped, and how much is left', (
        TomRobot robot,
      ) async {
        await robot.seesTheBandSaying(<String>[
          'The pull stopped: 1 document conflict.',
        ]);
      }),
      Step('it says nothing committed was lost, which is what people ask', (
        TomRobot robot,
      ) async {
        await robot.seesTheBandSaying(<String>[
          'Nothing you committed has been lost.',
        ]);
      }),
      Step('the conflicted document is marked in the changes list', (
        TomRobot robot,
      ) async {
        await robot.seesInTheChanges(<String>['roadmap.md']);
      }),
      Step('the commit is taken away while a marker is still there', (
        TomRobot robot,
      ) async {
        await robot.seesOnScreen(<String>['1 document to resolve']);
        await robot.seesCommitUnavailable();
      }),
      Step('the source pane marks the conflict beside the lines it is on', (
        TomRobot robot,
      ) async {
        await robot.clickInTheTree('roadmap.md');
        await robot.looksAt('Source');
        await robot.seesTheConflictMarkedInSource();
        // The markers stay on screen as git wrote them: somebody who resolves
        // conflicts in a terminal has to recognise what they are looking at
        // (`docs/product/editor/conflicted-document/doc.md`).
        await robot.seesInTheSource('<<<<<<< HEAD');
      }),
      Step('asking to abort asks first, and says what it costs', (
        TomRobot robot,
      ) async {
        await robot.tapText('Abort the pull');
        await robot.seesOnScreen(<String>[
          'Abort the pull?',
          'The space goes back to what it was before the pull.',
        ]);
        // The question alone changes nothing.
        expect(midMerge(), isTrue);
      }),
      Step('keeping the conflict leaves the merge exactly where it was', (
        TomRobot robot,
      ) async {
        await robot.tapInTheDialog('Keep the conflict');
        expect(midMerge(), isTrue);
        await robot.seesTheBandSaying(<String>[
          'The pull stopped: 1 document conflict.',
        ]);
      }),
      Step('aborting puts the working tree back', (TomRobot robot) async {
        await robot.tapText('Abort the pull');
        await robot.seesOnScreen(<String>['Abort the pull?']);
        await robot.tapInTheDialog('Abort the pull');
        expect(midMerge(), isFalse);
      }),
      Step('and the commit made here survived the abort', (
        TomRobot robot,
      ) async {
        // Aborting undoes the merge, never the work: the local commit is
        // still the tip.
        expect(
          git(<String>['log', '--format=%s', '-1']),
          'docs: M2 closes with replace',
        );
        await robot.seesACleanTree();
      }),
    ],
  );
}
