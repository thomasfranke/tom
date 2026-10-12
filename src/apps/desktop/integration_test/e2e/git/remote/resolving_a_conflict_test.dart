/// The pull that stops in the middle, and what the app says about it.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture conflicting = fixtures['docs-conflicting-remote'];
  late String mergeMessage;

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
    group: 'Git',
    submenu: 'Remote',
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
      Step('and it is the repository\'s state: a restart finds it all the '
          'same', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: conflicting.root);
        await robot.chooseFolder();
        await robot.seesTheShell();

        expect(midMerge(), isTrue);
        await robot.seesInTheChanges(<String>['roadmap.md']);
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

  /// What git still calls unmerged.
  String unmerged() => git(<String>['diff', '--name-only', '--diff-filter=U']);

  /// Rewrites the conflicted document outside the app, the way a hand in
  /// another editor would.
  void rewrites(String Function(String asItIs) how) {
    final File roadmap = File('${conflicting.root}/roadmap.md');
    roadmap.writeAsStringSync(how(roadmap.readAsStringSync()));
  }

  scenario(
    'Resolves a conflict git wrote with its base',
    group: 'Git',
    submenu: 'Remote',
    describe:
        'Somebody whose git is set to `merge.conflictStyle = diff3` gets a '
        'fourth marker line, `|||||||`, and under it the text both sides '
        'started from. A choice used to write that line and that text into '
        'the document, where nothing caught them. The style is set in the '
        'repository before the app starts; the pull, the choice, the save '
        'and the staging are the app\'s — and git is asked what it holds.',
    steps: <Step>[
      Step('the repository is set to write the base, and the pull stops', (
        TomRobot robot,
      ) async {
        git(<String>['config', 'merge.conflictStyle', 'diff3']);
        await robot.launchWindowed(pickFolder: conflicting.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.pulls();

        expect(unmerged(), 'docs/roadmap.md');
        expect(
          File('${conflicting.root}/roadmap.md').readAsStringSync(),
          allOf(contains('\n||||||| '), contains('the rendered diff')),
        );
      }),
      Step('the source shows all four marker lines, as git wrote them', (
        TomRobot robot,
      ) async {
        await robot.clickInTheTree('roadmap.md');

        await robot.seesInTheSource('<<<<<<< HEAD');
        await robot.seesInTheSource('|||||||');
      }),
      Step('the preview offers the two sides, and neither a marker nor the '
          'base', (TomRobot robot) async {
        await robot.seesInThePreview('M2 closes with search and replace.');
        await robot.seesInThePreview('M2 closes with full-text search.');
        await robot.seesNotInThePreview('|||||||');
        await robot.seesNotInThePreview('M2 closes with the rendered diff.');
      }),
      Step('Accept Both Changes keeps both lines and nothing else', (
        TomRobot robot,
      ) async {
        await robot.acceptsInThePreview('Accept Both Changes');

        await robot.seesInTheSource('M2 closes with search and replace.');
        await robot.seesInTheSource('M2 closes with full-text search.');
        await robot.seesNotInTheSource('|||||||');
        await robot.seesNotInTheSource('<<<<<<<');
        await robot.seesNotInTheSource('M2 closes with the rendered diff.');
      }),
      Step('saved and staged, git holds a document with no marker in it', (
        TomRobot robot,
      ) async {
        await robot.saves();
        await robot.stages('roadmap.md');

        expect(unmerged(), isEmpty);
        final String staged = git(<String>['show', ':docs/roadmap.md']);
        expect(staged, isNot(contains('|||||||')));
        expect(staged, isNot(contains('<<<<<<<')));
        expect(staged, isNot(contains('the rendered diff')));
        expect(staged, contains('M2 closes with search and replace.'));
        robot.seesNothingBroken();
      }),
    ],
  );

  scenario(
    'Refuses to stage a document that still holds a conflict marker',
    group: 'Git',
    submenu: 'Remote',
    describe:
        'Staging is how a resolution is declared, so it is where a marker '
        'left behind has to be caught: git would record `<<<<<<<` without a '
        'word. The document is refused by name while git calls it '
        'conflicted and **one marker line** is still in it — a region half '
        'resolved by hand included — and goes through the moment none is.',
    steps: <Step>[
      Step('pull, and git stops with one document conflicted', (
        TomRobot robot,
      ) async {
        await robot.launchWindowed(pickFolder: conflicting.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.pulls();

        expect(unmerged(), 'docs/roadmap.md');
        await robot.seesInTheChanges(<String>['roadmap.md']);
      }),
      Step('ticking it as git wrote it is refused, and the column says why', (
        TomRobot robot,
      ) async {
        await robot.triesToStage('roadmap.md');

        await robot.seesTheGitColumnSaying(
          'roadmap.md still holds a conflict marker — resolve it, then '
          'stage.',
        );
        expect(unmerged(), 'docs/roadmap.md');
      }),
      Step('with one marker line left by hand it is refused the same', (
        TomRobot robot,
      ) async {
        // Both sides kept and two of the three marker lines deleted: no
        // longer a region, still not a document anybody meant to commit.
        rewrites(
          (String asItIs) => asItIs
              .split('\n')
              .where(
                (String line) =>
                    !line.startsWith('<<<<<<<') && !line.startsWith('>>>>>>>'),
              )
              .join('\n'),
        );
        await robot.triesToStage('roadmap.md');

        await robot.seesTheGitColumnSaying(
          'roadmap.md still holds a conflict marker — resolve it, then '
          'stage.',
        );
        expect(unmerged(), 'docs/roadmap.md');
      }),
      Step('with the last one gone it stages, and git calls it resolved', (
        TomRobot robot,
      ) async {
        rewrites(
          (String asItIs) => asItIs
              .split('\n')
              .where((String line) => line != '=======')
              .join('\n'),
        );
        await robot.stages('roadmap.md');

        expect(unmerged(), isEmpty);
        await robot.seesNotOnScreen('1 document to resolve');
        robot.seesNothingBroken();
      }),
    ],
  );

  scenario(
    'Concludes a conflicted pull with a commit',
    group: 'Git',
    submenu: 'Remote',
    describe:
        'The pull that stopped is finished the way git finishes it: with a '
        'commit that has two parents. The box already holds the message git '
        'wrote; a document that still holds a marker is refused; resolved '
        'in the preview, saved and staged, the commit goes through — and '
        '**git itself** is asked what it recorded: two parents, no marker in '
        'the file at `HEAD`, no merge left in progress.',
    steps: <Step>[
      Step('pull, and git stops with one document conflicted', (
        TomRobot robot,
      ) async {
        await robot.launchWindowed(pickFolder: conflicting.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.pulls();

        expect(midMerge(), isTrue);
        mergeMessage = File(
          '${conflicting.repositoryRoot}/.git/MERGE_MSG',
        ).readAsLinesSync().first;
        await robot.seesInTheChanges(<String>['roadmap.md']);
      }),
      Step('the message box already holds what git wrote', (
        TomRobot robot,
      ) async {
        await robot.seesTheSummaryHolding(mergeMessage);
      }),
      Step('the document with its marker cannot be staged', (
        TomRobot robot,
      ) async {
        await robot.triesToStage('roadmap.md');

        await robot.seesTheGitColumnSaying(
          'roadmap.md still holds a conflict marker — resolve it, then '
          'stage.',
        );
        expect(unmerged(), 'docs/roadmap.md');
      }),
      Step('resolved in the preview and saved, it stages', (
        TomRobot robot,
      ) async {
        await robot.clickInTheTree('roadmap.md');
        await robot.acceptsInThePreview('Accept Both Changes');
        await robot.saves();
        await robot.stages('roadmap.md');

        expect(unmerged(), isEmpty);
        await robot.seesOnScreen(<String>['1 of 1 staged']);
      }),
      Step('and the commit is live, still wearing the merge message', (
        TomRobot robot,
      ) async {
        await robot.seesTheSummaryHolding(mergeMessage);
        await robot.seesOnScreen(<String>['Commit to main']);
      }),
      Step('committing ends the merge', (TomRobot robot) async {
        await robot.commits();

        expect(midMerge(), isFalse);
      }),
      Step('git recorded a merge: two parents, and no marker at HEAD', (
        TomRobot robot,
      ) async {
        expect(
          git(<String>['rev-list', '--parents', '-n', '1', 'HEAD']).split(' '),
          hasLength(3),
        );
        expect(
          git(<String>['show', 'HEAD:docs/roadmap.md']),
          isNot(contains('<<<<<<<')),
        );
        // The pull's band is gone; the one that says the commit worked is up.
        await robot.seesTheBandSaying(<String>['Committed']);
        await robot.seesACleanTree();
      }),
      Step('and the branch is two ahead, waiting to be published', (
        TomRobot robot,
      ) async {
        await robot.seesTheDrift(ahead: 2);
        robot.seesNothingBroken();
      }),
    ],
  );
}
