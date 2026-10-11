/// Fetch, push, and the push the remote got to first.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture behind = fixtures['docs-behind-remote'];
  late String localHead;
  final String reviewing = '${behind.root}/reviewing.md';
  const String mine = '# Mine\n\nWritten here, never committed.\n';

  /// What git says, asked outside the app entirely.
  String git(String repository, List<String> arguments) =>
      (Process.runSync('git', <String>['-C', repository, ...arguments]).stdout
              as String)
          .trim();

  /// What the bare repository — the remote — has on `main`.
  List<String> onTheRemote() => git(behind.remoteRoot, <String>[
    'log',
    '--format=%s',
    'main',
  ]).split('\n').where((String line) => line.isNotEmpty).toList();

  scenario(
    'Fetches, and finds the branch has fallen behind',
    group: 'Git',
    submenu: 'Remote',
    describe:
        'Fetch exists so that ahead/behind means something. The space opens '
        'knowing only what it has — one commit nobody else has seen — and '
        'the two the remote gained are invisible until somebody asks. **It '
        'changes no file on disk**, which is what makes it safe to offer as '
        'a plain button, and the scenario checks that too.',
    steps: <Step>[
      Step('open a space whose remote has moved on', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: behind.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
      }),
      Step('it starts out knowing only what it has', (TomRobot robot) async {
        // `behind` is zero because nobody has fetched, not because the
        // branches agree.
        await robot.seesTheDrift(ahead: 1);
      }),
      Step('fetching finds the two the remote gained', (TomRobot robot) async {
        await robot.fetches();

        await robot.seesTheDrift(ahead: 1, behind: 2);
      }),
      Step('and it brought no file into the working tree', (
        TomRobot robot,
      ) async {
        expect(
          File('${behind.root}/reviewing.md').existsSync(),
          isFalse,
          reason: 'fetch wrote a file the remote had; that is a pull',
        );
        robot
          ..seesNotInTheTree('reviewing.md')
          ..seesNothingBroken();
      }),
    ],
  );

  scenario(
    'Refuses a push the remote got to first, and pulls instead',
    group: 'Git',
    submenu: 'Remote',
    describe:
        'The whole reason push and pull are not one Sync button. The remote '
        'moved first, so the push is refused — and the refusal is a screen '
        'rather than an error: it says who got there first, that **nothing '
        'committed was lost**, and offers the one thing that mends it. '
        'After the pull the same button works, and the last assertion asks '
        'the **remote itself** what arrived.',
    steps: <Step>[
      Step('open the space, set to rebase, and see where it stands', (
        TomRobot robot,
      ) async {
        // The machine's own preference, set before the app starts: a pull
        // here must merge whatever `pull.rebase` says.
        git(behind.repositoryRoot, <String>['config', 'pull.rebase', 'true']);
        localHead = git(behind.repositoryRoot, <String>['rev-parse', 'HEAD']);
        await robot.launchWindowed(pickFolder: behind.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.fetches();
        await robot.seesTheDrift(ahead: 1, behind: 2);
        robot.seesNoRefusal();
      }),
      Step('pushing is refused, and says so in words', (TomRobot robot) async {
        await robot.pushes();

        await robot.seesThePushRefused(commits: 2);
        expect(onTheRemote(), isNot(contains('docs: start the release notes')));
      }),
      Step('pulling brings their commits in', (TomRobot robot) async {
        await robot.pulls();

        // The two sides wrote different files, so the pull merges cleanly; a
        // conflict is the pull that stops (`resolving_a_conflict_test.dart`).
        await robot.seesTheDrift(ahead: 2);
        await robot.seesInTheTree(<String>['reviewing.md', 'approvals.md']);
      }),
      Step('and it was a merge, whatever the machine is set to', (
        TomRobot robot,
      ) async {
        // Two parents, and the first is the commit that was made here: a
        // rebase would have rewritten it.
        final List<String> parents = git(behind.repositoryRoot, <String>[
          'rev-list',
          '--parents',
          '-n',
          '1',
          'HEAD',
        ]).split(' ');
        expect(parents, hasLength(3), reason: 'HEAD is not a merge commit');
        expect(parents[1], localHead);
      }),
      Step('and the band says how many arrived', (TomRobot robot) async {
        await robot.seesTheBandSaying(<String>['Pulled ', 'still to publish.']);
      }),
      Step('and then the push lands', (TomRobot robot) async {
        await robot.pushes();

        await robot.seesTheDrift();
        // A push that landed says so and offers nothing: a button returning
        // to `Push` looks exactly like a push that never left.
        await robot.seesTheBandSaying(<String>[
          'Published 2 commits to origin/',
        ]);
        robot.seesNoRefusal(allowingBand: true);
      }),
      Step('which the remote itself confirms', (TomRobot robot) async {
        // Asked of the remote itself: everything above could pass with a
        // button that merely stopped complaining.
        expect(onTheRemote(), contains('docs: start the release notes'));
        robot.seesNothingBroken();
      }),
    ],
  );

  scenario(
    'Publishes a new branch from the band that confirms its commit',
    group: 'Git',
    submenu: 'Remote',
    describe:
        'A branch made here tracks nothing, so it has nothing to be ahead of '
        'and the band that confirms a commit used to offer no way on. It '
        'offers `Push` now, which publishes the branch to `origin` and '
        'follows it from then on. The branch is made with git before the '
        'app starts; the remote itself is asked afterwards.',
    steps: <Step>[
      Step('open a space on a branch that tracks nothing', (
        TomRobot robot,
      ) async {
        git(behind.repositoryRoot, <String>[
          'switch',
          '--quiet',
          '-c',
          'notes',
        ]);
        File('${behind.root}/notes.md').writeAsStringSync('# Notes\n');
        await robot.launchWindowed(pickFolder: behind.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.seesInTheChanges(<String>['notes.md']);
        expect(
          Process.runSync('git', <String>[
            '-C',
            behind.repositoryRoot,
            'rev-parse',
            '--abbrev-ref',
            'notes@{upstream}',
          ]).exitCode,
          isNot(0),
        );
      }),
      Step('the band that confirms the commit offers Push', (
        TomRobot robot,
      ) async {
        await robot.stages('notes.md');
        await robot.describesTheCommit('docs: start the notes');
        await robot.commits();

        await robot.seesTheBandSaying(<String>[
          'Committed “docs: start the notes”.',
        ]);
        await robot.seesInTheBand(<String>['Push']);
      }),
      Step('pressing it publishes the branch and follows it', (
        TomRobot robot,
      ) async {
        await robot.answersTheBand('Push');

        await robot.seesTheBandSaying(<String>['Published to origin/notes.']);
        await robot.seesNotInTheBand('Push');
        expect(
          git(behind.repositoryRoot, <String>[
            'rev-parse',
            '--abbrev-ref',
            'notes@{upstream}',
          ]),
          'origin/notes',
        );
        expect(
          git(behind.remoteRoot, <String>['log', '--format=%s', 'notes']),
          contains('docs: start the notes'),
        );
        robot.seesNothingBroken();
      }),
    ],
  );

  scenario(
    'Refuses a pull over uncommitted work, and leaves the file alone',
    group: 'Git',
    submenu: 'Remote',
    describe:
        'The remote added `reviewing.md`, and here a file of that name was '
        'written and never committed: git will not pull over it. The band '
        'names the file, says nothing changed and keeps `Try again`; the '
        'file is byte for byte what it was and no merge was started. With '
        'the file moved out of the way, the same button pulls.',
    steps: <Step>[
      Step('write an uncommitted file the remote also has, and open', (
        TomRobot robot,
      ) async {
        File(reviewing).writeAsStringSync(mine);
        localHead = git(behind.repositoryRoot, <String>['rev-parse', 'HEAD']);
        await robot.launchWindowed(pickFolder: behind.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.seesInTheChanges(<String>['reviewing.md']);
      }),
      Step('pulling is refused, and the band names the file', (
        TomRobot robot,
      ) async {
        await robot.pulls();

        await robot.seesTheBandSaying(<String>[
          'Git refused the pull: it would overwrite',
          'uncommitted changes to ',
          'reviewing.md',
          'Nothing changed here',
        ]);
        await robot.seesInTheBand(<String>['Try again']);
      }),
      Step('the file is as it was, and no merge began', (TomRobot robot) async {
        expect(File(reviewing).readAsStringSync(), mine);
        expect(
          git(behind.repositoryRoot, <String>['rev-parse', 'HEAD']),
          localHead,
        );
        expect(
          Process.runSync('git', <String>[
            '-C',
            behind.repositoryRoot,
            'rev-parse',
            '--quiet',
            '--verify',
            'MERGE_HEAD',
          ]).exitCode,
          isNot(0),
          reason: 'a merge was started',
        );
        robot.seesNothingBroken();
      }),
      Step('with the file out of the way, Try again pulls', (
        TomRobot robot,
      ) async {
        File(reviewing).renameSync('$reviewing.mine');

        await robot.answersTheBand('Try again');

        await robot.seesInTheTree(<String>['reviewing.md', 'approvals.md']);
        await robot.seesTheDrift(ahead: 2);
        expect(
          File(reviewing).readAsStringSync(),
          contains('Somebody else wrote this'),
        );
      }),
    ],
  );
}
