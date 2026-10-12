/// [DartIoGitClientImpl] reading, at the edges: every shape a status record
/// takes, the diffs of a binary and a deletion, names git could misread, a
/// detached or unborn `HEAD`, and the states a worktree and a stopped
/// cherry-pick leave.
///
/// A sibling of `dart_io_git_client_impl_test.dart` (decision T3). Git runs
/// under [GitWorld]'s empty configuration.
library;

// Arranging a repository is a run of statements on one world.
// ignore_for_file: cascade_invocations

import 'dart:io';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

import '../../../support/git_world.dart';

void main() {
  late GitWorld world;
  late DartIoGitClientImpl client;

  setUp(() {
    world = GitWorld()..seed();
    client = world.client();
  });

  tearDown(() => world.dispose());

  /// The records of `status` past its `# branch` headers, split on the NUL
  /// git ends each with.
  Future<List<String>> records() async => valueOf(await client.status())
      .split(GitClient.nulSeparator)
      .where((String r) => r.isNotEmpty && !r.startsWith('# '))
      .toList();

  const List<String> oddNames = <String>[
    'with space.md',
    'notas de versão é.md',
    '-n.md',
    'quote"d.md',
    'tab\there.md',
    '日本語.md',
  ];

  group('status, in every shape git writes', () {
    test('a staged rename is one record naming both files', () async {
      world.git(<String>['mv', 'a.md', 'renamed.md']);

      final List<String> all = await records();

      expect(all.where((String r) => r.startsWith('2 R.')), hasLength(1));
      expect(all, contains('a.md'), reason: 'the old name follows the record');
      expect(all.join('|'), contains(' renamed.md'));
    });

    test('a rename that is also edited is still a rename', () async {
      world.git(<String>['mv', 'a.md', 'renamed.md']);
      world.write('renamed.md', '# A, renamed and edited\n');

      expect(
        (await records()).where((String r) => r.startsWith('2 R')),
        hasLength(1),
      );
    });

    test('a staged copy names the file it was copied from', () async {
      world.configure('[diff]\n\trenames = copies\n');
      world.write('a.md', '# A\n\nmore, so the original is edited too\n');
      world.write('copy.md', '# A\n');
      world.git(<String>['add', 'a.md', 'copy.md']);

      final List<String> all = await records();

      expect(
        all.where((String r) => r.startsWith('2 C')),
        hasLength(1),
        reason: all.join('|'),
      );
    });

    test('a staged edit that was edited again reads MM', () async {
      world.write('a.md', '# A, staged\n');
      world.git(<String>['add', 'a.md']);
      world.write('a.md', '# A, staged, then more\n');

      expect((await records()).single, startsWith('1 MM '));
    });

    test('staged then deleted from disk reads AD', () async {
      world.write('b.md', '# B\n');
      world.git(<String>['add', 'b.md']);
      File('${world.repo}/b.md').deleteSync();

      expect((await records()).last, startsWith('1 AD '));
    });

    test(
      'a file turned into a link reads as a type change',
      () async {
        File('${world.repo}/a.md').deleteSync();
        Link('${world.repo}/a.md').createSync('elsewhere');

        expect((await records()).last, startsWith('1 .T '));
      },
      skip: Platform.isWindows ? 'links need privileges on Windows' : false,
    );

    test('a path both sides edited is one u record', () async {
      world.conflict();

      final List<String> all = await records();

      expect(all.where((String r) => r.startsWith('u UU ')), hasLength(1));
      expect(world.read('a.md'), contains('<<<<<<<'));
    });

    test('modify/delete and add/add read as their own pairs', () async {
      world.commitFile('gone.md', '# Gone\n');
      world.git(<String>['switch', '--quiet', '--create', 'topic']);
      world.git(<String>['rm', '--quiet', 'gone.md']);
      world.write('both.md', '# Topic\n');
      world.git(<String>['add', 'both.md']);
      world.git(<String>['commit', '--quiet', '--message', 'Topic']);
      world.git(<String>['switch', '--quiet', 'main']);
      world.write('gone.md', '# Gone, edited on main\n');
      world.write('both.md', '# Main\n');
      world.git(<String>['add', '.']);
      world.git(<String>['commit', '--quiet', '--message', 'Main']);
      world.run(<String>['merge', 'topic']);

      final List<String> all = await records();

      expect(
        all.any((String r) => r.startsWith('u DU ') || r.startsWith('u UD ')),
        isTrue,
        reason: all.join('|'),
      );
      expect(all.any((String r) => r.startsWith('u AA ')), isTrue);
    });

    for (final String name in oddNames) {
      test(
        'an untracked ${name.replaceAll('\t', r'\t')} comes through raw',
        () async {
          world.write(name, 'x\n');

          expect(await records(), contains('? $name'));
        },
      );
    }

    test('a staged name with a space and one outside ASCII', () async {
      world.write('notas de versão é.md', 'x\n');
      world.git(<String>['add', '--', 'notas de versão é.md']);

      final String record = (await records()).single;

      expect(record, startsWith('1 A. '));
      expect(record, endsWith(' notas de versão é.md'));
    });
  });

  group('diffs from a fork point', () {
    setUp(() {
      world.commitFile('gone.md', '# Gone\n');
      world.commitFile('old name.md', 'same\n');
      world.git(<String>['switch', '--quiet', '--create', 'topic']);
      world.git(<String>['rm', '--quiet', 'gone.md']);
      world.git(<String>['mv', 'old name.md', 'novo nome é.md']);
      File('${world.repo}/pic.png').writeAsBytesSync(
        Uint8List.fromList(<int>[0x89, 0x50, 0x4e, 0x47, 0, 1, 2, 0xff]),
      );
      world.write('a.md', '# A\nline\n');
      world.git(<String>['add', '--all']);
      world.git(<String>['commit', '--quiet', '--message', 'Topic']);
    });

    List<String> fields(String text) => text
        .split(GitClient.nulSeparator)
        .where((String f) => f.isNotEmpty)
        .toList();

    test(
      'numstat counts a binary as dashes, a deletion as removed lines',
      () async {
        final List<String> all = fields(
          valueOf(await client.diffNumstat('main')),
        );

        expect(all, contains('-\t-\tpic.png'));
        expect(all, contains('0\t1\tgone.md'));
        expect(all, contains('1\t0\ta.md'));
      },
    );

    test('a rename is a deletion and an addition, never a rename', () async {
      final List<String> numstat = fields(
        valueOf(await client.diffNumstat('main')),
      );
      final List<String> status = fields(
        valueOf(await client.diffNameStatus('main')),
      );

      expect(numstat, contains('0\t1\told name.md'));
      expect(numstat, contains('1\t0\tnovo nome é.md'));
      expect(status, containsAllInOrder(<String>['D', 'old name.md']));
      expect(status, containsAllInOrder(<String>['A', 'novo nome é.md']));
      expect(status.where((String f) => f.startsWith('R')), isEmpty);
    });

    test('name-status says A, M and D', () async {
      final List<String> all = fields(
        valueOf(await client.diffNameStatus('main')),
      );

      expect(all, containsAllInOrder(<String>['M', 'a.md']));
      expect(all, containsAllInOrder(<String>['D', 'gone.md']));
      expect(all, containsAllInOrder(<String>['A', 'pic.png']));
    });

    test(
      'a type change reads T',
      () async {
        File('${world.repo}/a.md').deleteSync();
        Link('${world.repo}/a.md').createSync('elsewhere');
        world.git(<String>['add', '--all']);
        world.git(<String>['commit', '--quiet', '--message', 'Link']);

        expect(
          fields(valueOf(await client.diffNameStatus('main'))),
          containsAllInOrder(<String>['T', 'a.md']),
        );
      },
      skip: Platform.isWindows ? 'links need privileges on Windows' : false,
    );

    test(
      'a base that does not resolve is a failure with git\'s words',
      () async {
        final GitClientFailure failure = failureOf(
          await client.diffNumstat('nowhere'),
        );

        expect(failure, isA<GitClientCommandFailed>());
        expect((failure as GitClientCommandFailed).stderr, contains('nowhere'));
      },
    );

    test(
      'on a branch with no commits it is a failure, not an empty answer',
      () async {
        final String fresh = '${world.base}/fresh';
        world.init(fresh);

        expect(
          failureOf(await world.client(inside: fresh).diffNameStatus('main')),
          isA<GitClientCommandFailed>(),
        );
      },
    );

    test('from a folder below the root the paths stay the root\'s', () async {
      final DartIoGitClientImpl below = world.client(
        inside: '${world.repo}/docs',
      );
      Directory('${world.repo}/docs').createSync();

      expect(
        fields(valueOf(await below.diffNumstat('main'))),
        contains('1\t0\ta.md'),
      );
    });
  });

  group('show, showBytes and showStagedBytes on a name git could misread', () {
    for (final String name in oddNames) {
      test(name.replaceAll('\t', r'\t'), () async {
        world.commitFile(name, 'committed\n');
        world.write(name, 'staged\n');
        world.git(<String>['add', '--', name]);
        world.write(name, 'typed since\n');

        expect(valueOf(await client.show('HEAD', name)), 'committed\n');
        expect(
          String.fromCharCodes(valueOf(await client.showBytes('HEAD', name))),
          'committed\n',
        );
        expect(
          String.fromCharCodes(valueOf(await client.showStagedBytes(name))),
          'staged\n',
        );
      });

      test(
        '${name.replaceAll('\t', r'\t')} is a missing path when absent',
        () async {
          expect(
            failureOf(await client.show('HEAD', name)),
            isA<GitClientPathNotInRevision>(),
          );
        },
      );
    }

    test(
      'a folder is not a file: git lists it, and the client hands that over',
      () async {
        world.commitFile('docs/c.md', '# C\n');

        expect(valueOf(await client.show('HEAD', 'docs')), contains('c.md'));
      },
    );

    test(
      'showStagedBytes on a conflicted path is a failure, not a file',
      () async {
        world.conflict();

        expect(
          failureOf(await client.showStagedBytes('a.md')),
          isA<GitClientCommandFailed>(),
        );
      },
    );

    test(
      'a revision that does not exist is a failure, not a missing path',
      () async {
        expect(
          failureOf(await client.show('nowhere', 'a.md')),
          isA<GitClientCommandFailed>(),
        );
      },
    );
  });

  group('the revisions a name can be', () {
    test('a tag resolves, annotated or not', () async {
      world.git(<String>['tag', 'light']);
      world.git(<String>['tag', '--annotate', '--message', 'v', 'heavy']);

      expect(valueOf(await client.resolves('light')), isTrue);
      expect(valueOf(await client.resolves('heavy')), isTrue);
    });

    test('a blob does not, though it is an object', () async {
      final String blob = world
          .git(<String>['rev-parse', 'HEAD:a.md'])
          .stdout
          .toString()
          .trim();

      expect(valueOf(await client.resolves(blob)), isFalse);
    });

    test('merge-base of a revision that does not exist is a failure', () async {
      expect(
        failureOf(await client.mergeBase('nowhere')),
        isA<GitClientCommandFailed>(),
      );
    });

    test('merge-base on a branch with no commits is a failure too', () async {
      final String fresh = '${world.base}/fresh';
      world.init(fresh);

      expect(
        failureOf(await world.client(inside: fresh).mergeBase('main')),
        isA<GitClientCommandFailed>(),
      );
    });
  });

  group('branches and standings, where HEAD is not on a branch', () {
    test('a detached HEAD is listed, and carries the star', () async {
      world.git(<String>['switch', '--quiet', '--detach']);

      final String listed = valueOf(await client.branches());

      expect(listed, contains('(HEAD detached at '));
      expect(listed, contains('main${GitClient.unitSeparator} '));
    });

    test('standings from a detached HEAD still stand every branch', () async {
      world.git(<String>['branch', 'other']);
      world.git(<String>['switch', '--quiet', '--detach']);

      final String stood = valueOf(await client.branchStandings());

      expect(stood, contains('refs/heads/main'));
      expect(stood, contains('refs/heads/other'));
    });

    test('a branch with no commits lists nothing', () async {
      final String fresh = '${world.base}/fresh';
      world.init(fresh);

      expect(valueOf(await world.client(inside: fresh).branches()), isEmpty);
    });

    test('an orphan branch has nothing to stand against', () async {
      world.git(<String>['switch', '--quiet', '--orphan', 'fresh-start']);

      expect(valueOf(await client.branchStandings()), isEmpty);
    });

    test('a name outside ASCII is listed as written', () async {
      world.git(<String>['branch', 'feat/ação']);

      expect(valueOf(await client.branches()), contains('feat/ação'));
    });

    test('the upstream is the third field', () async {
      final String remote = '${world.base}/remote.git';
      world.init(remote, bare: true);
      world.git(<String>['remote', 'add', 'origin', remote]);
      world.git(<String>[
        'push',
        '--quiet',
        '--set-upstream',
        'origin',
        'main',
      ]);

      final String listed = valueOf(await client.branches());

      expect(
        listed,
        contains(
          'main${GitClient.unitSeparator}*${GitClient.unitSeparator}origin/main',
        ),
      );
    });
  });

  group('createBranch and switchBranch, at the edges', () {
    test('creating a name that exists fails and stays where it was', () async {
      world.git(<String>['branch', 'topic']);

      expect(
        failureOf(await client.createBranch('topic')),
        isA<GitClientCommandFailed>(),
      );

      expect(valueOf(await client.currentBranch()), 'main');
    });

    test('creating on a branch with no commits names the branch', () async {
      final String fresh = '${world.base}/fresh';
      world.init(fresh);
      final DartIoGitClientImpl unborn = world.client(inside: fresh);

      await unborn.createBranch('draft');

      expect(valueOf(await unborn.currentBranch()), 'draft');
    });

    test('uncommitted work comes along to the new branch', () async {
      world.write('a.md', '# A, mine\n');
      world.write('new.md', '# New\n');

      expect(
        await client.createBranch('draft'),
        isA<Success<void, GitClientFailure>>(),
      );

      expect(valueOf(await client.currentBranch()), 'draft');
      expect(world.read('a.md'), '# A, mine\n');
      expect(world.read('new.md'), '# New\n');
    });

    test(
      'a refused switch leaves the edit and the branch where they were',
      () async {
        world.git(<String>['switch', '--quiet', '--create', 'other']);
        world.commitFile('a.md', '# A, other\n', message: 'Other');
        world.git(<String>['switch', '--quiet', 'main']);
        world.write('a.md', '# A, mine\n');

        expect(
          failureOf(await client.switchBranch('other')),
          isA<GitClientCommandFailed>(),
        );

        expect(world.read('a.md'), '# A, mine\n');
        expect(valueOf(await client.currentBranch()), 'main');
      },
    );

    test('a name only the remote has becomes a tracking branch', () async {
      final String remote = '${world.base}/remote.git';
      world.init(remote, bare: true);
      world.git(<String>['remote', 'add', 'origin', remote]);
      world.git(<String>['switch', '--quiet', '--create', 'shared']);
      world.git(<String>['push', '--quiet', 'origin', 'shared']);
      world.git(<String>['switch', '--quiet', 'main']);
      world.git(<String>['branch', '--delete', '--force', 'shared']);
      world.git(<String>['fetch', '--quiet']);

      expect(
        await client.switchBranch('shared'),
        isA<Success<void, GitClientFailure>>(),
      );

      expect(valueOf(await client.currentBranch()), 'shared');
      expect(
        world
            .git(<String>['rev-parse', '--abbrev-ref', '@{upstream}'])
            .stdout
            .toString()
            .trim(),
        'origin/shared',
      );
    });

    test(
      'switching during a merge that left conflicts fails and keeps the merge',
      () async {
        world.conflict();
        world.git(<String>['branch', 'elsewhere']);

        expect(
          failureOf(await client.switchBranch('elsewhere')),
          isA<GitClientCommandFailed>(),
        );

        expect(valueOf(await client.mergeInProgress()), isTrue);
      },
    );

    // A branch name is not an option. `BranchNameValueObject` accepts a leading
    // dash, so the client is where a name like this must be kept from acting.
    for (final String name in <String>[
      '--detach',
      '-',
      '-f',
      '--force',
      '--track',
    ]) {
      test('createBranch "$name" creates nothing and moves nothing', () async {
        world.git(<String>['switch', '--quiet', '--create', 'previous']);
        world.git(<String>['switch', '--quiet', 'main']);
        final String before =
            world.git(<String>['branch', '--list']).stdout as String;

        await client.createBranch(name);

        expect(valueOf(await client.currentBranch()), 'main');
        expect(world.git(<String>['branch', '--list']).stdout, before);
      });

      test('switchBranch "$name" moves nothing', () async {
        world.git(<String>['switch', '--quiet', '--create', 'previous']);
        world.git(<String>['switch', '--quiet', 'main']);

        await client.switchBranch(name);

        expect(valueOf(await client.currentBranch()), 'main');
      });
    }
  });

  group('the branch a branch was started from', () {
    test('goes with the branch when it is renamed', () async {
      world.git(<String>['switch', '--quiet', '--create', 'draft']);
      await client.recordBranchBase('draft', 'main');

      world.git(<String>['branch', '--move', 'draft', 'final']);

      expect(valueOf(await client.branchBase('final')), 'main');
      expect(valueOf(await client.branchBase('draft')), isEmpty);
    });

    test('is replaced by the next recording', () async {
      await client.recordBranchBase('main', 'one');
      await client.recordBranchBase('main', 'two');

      expect(valueOf(await client.branchBase('main')), 'two');
    });

    test('can be recorded for a branch that does not exist yet', () async {
      expect(
        await client.recordBranchBase('later', 'main'),
        isA<Success<void, GitClientFailure>>(),
      );

      expect(valueOf(await client.branchBase('later')), 'main');
    });

    test(
      'a branch name with a slash and letters outside ASCII round-trips',
      () async {
        await client.recordBranchBase('feat/ação', 'main');

        expect(valueOf(await client.branchBase('feat/ação')), 'main');
      },
    );

    test('the account is replaced by the next choice', () async {
      await client.recordGithubAccount('ana');
      await client.recordGithubAccount('bia');

      expect(valueOf(await client.githubAccount()), 'bia');
    });

    test('recording the account outside a repository fails', () async {
      final String plain = '${world.base}/plain';
      Directory(plain).createSync();

      expect(
        failureOf(await world.client(inside: plain).recordGithubAccount('ana')),
        isA<GitClientFailure>(),
      );
    });

    test('with no identity anywhere both halves are empty', () async {
      final String anon = '${world.base}/anon';
      world.init(anon, identity: false);

      expect(
        valueOf(await world.client(inside: anon).identity()),
        GitClient.unitSeparator,
      );
    });
  });

  group('the remote, as the person\'s config spells it', () {
    late String remote;

    setUp(() {
      remote = '${world.base}/remote.git';
      world.init(remote, bare: true);
    });

    test('insteadOf is expanded in the address read back', () async {
      world.git(<String>['remote', 'add', 'origin', 'gh:ana/notes.git']);
      world.git(<String>['config', 'url.https://github.com/.insteadOf', 'gh:']);

      expect(
        valueOf(await client.remoteUrl()),
        'https://github.com/ana/notes.git',
      );
    });

    test('pushurl does not replace the address read', () async {
      world.git(<String>[
        'remote',
        'add',
        'origin',
        'https://github.com/ana/notes.git',
      ]);
      world.git(<String>['remote', 'set-url', '--push', 'origin', remote]);

      expect(
        valueOf(await client.remoteUrl()),
        'https://github.com/ana/notes.git',
      );
    });

    test('a remote not called origin is no remote', () async {
      world.git(<String>['remote', 'add', 'upstream', remote]);

      expect(valueOf(await client.remoteUrl()), isEmpty);
    });

    test('master is guessed when it is the one the remote has', () async {
      world.git(<String>['remote', 'add', 'origin', remote]);
      world.git(<String>['push', '--quiet', 'origin', 'main:master']);
      world.git(<String>['fetch', '--quiet']);

      expect(valueOf(await client.defaultBranch()), 'master');
    });

    test('a default branch with a slash is kept whole', () async {
      world.git(<String>[
        'symbolic-ref',
        'HEAD',
        'refs/heads/release/1',
      ], inside: remote);
      world.git(<String>['remote', 'add', 'origin', remote]);
      world.git(<String>['push', '--quiet', 'origin', 'main:release/1']);
      world.git(<String>['fetch', '--quiet']);
      world.git(<String>['remote', 'set-head', 'origin', '--auto']);

      expect(valueOf(await client.defaultBranch()), 'release/1');
    });
  });

  group('log, at the edges', () {
    test('a path that was deleted still has its history', () async {
      world.commitFile('gone.md', '# Gone\n', message: 'Add gone');
      world.git(<String>['rm', '--quiet', 'gone.md']);
      world.git(<String>['commit', '--quiet', '--message', 'Remove gone']);

      final String text = valueOf(await client.log(path: 'gone.md'));

      expect(text, contains('Remove gone'));
      expect(text, contains('Add gone'));
    });

    test('from a detached HEAD walks back from there', () async {
      world.commitFile('b.md', '# B\n', message: 'Add B');
      world.git(<String>['switch', '--quiet', '--detach', 'HEAD~1']);

      final String text = valueOf(await client.log());

      expect(text, contains('Add A'));
      expect(text, isNot(contains('Add B')));
    });

    test(
      'a history across a rename and an odd name keeps both halves',
      () async {
        world.commitFile(
          'notas de versão é.md',
          'one\ntwo\nthree\nfour\n',
          message: 'Add notes',
        );
        world.git(<String>[
          'mv',
          'notas de versão é.md',
          'notes with space.md',
        ]);
        world.git(<String>['commit', '--quiet', '--message', 'Rename notes']);

        final String text = valueOf(
          await client.log(path: 'notes with space.md'),
        );

        expect(text, contains('Rename notes'));
        expect(text, contains('Add notes'));
      },
    );

    test('since a revision that does not exist is a failure', () async {
      expect(
        failureOf(await client.log(since: 'nowhere')),
        isA<GitClientCommandFailed>(),
      );
    });

    test('a path git has never heard of is an empty history', () async {
      expect(valueOf(await client.log(path: 'never.md')).trim(), isEmpty);
    });
  });

  group('a merge, read from where the client stands', () {
    test('mergeMessage from a folder below the root', () async {
      world.conflict();
      Directory('${world.repo}/docs').createSync();

      final String draft = valueOf(
        await world.client(inside: '${world.repo}/docs').mergeMessage(),
      );

      expect(draft, contains("Merge branch 'topic'"));
    });

    group('in a worktree', () {
      late String tree;
      late DartIoGitClientImpl inside;

      setUp(() {
        world.git(<String>['switch', '--quiet', '--create', 'topic']);
        world.commitFile('a.md', '# A, topic\n', message: 'Topic');
        world.git(<String>['switch', '--quiet', 'main']);
        tree = '${world.base}/tree';
        world.git(<String>[
          'worktree',
          'add',
          '--quiet',
          '-b',
          'branch-in-tree',
          tree,
        ]);
        world.commitFile('a.md', '# A, tree\n', message: 'Tree', inside: tree);
        inside = world.client(inside: tree);
      });

      test('is not a merge until one starts there', () async {
        expect(valueOf(await inside.mergeInProgress()), isFalse);
        expect(valueOf(await inside.mergeMessage()), isEmpty);
      });

      test(
        'a conflict there is seen there, and not from the main folder',
        () async {
          world.run(<String>['merge', 'topic'], inside: tree);

          expect(valueOf(await inside.mergeInProgress()), isTrue);
          expect(
            valueOf(await inside.mergeMessage()),
            contains("Merge branch 'topic'"),
          );
          expect(valueOf(await client.mergeInProgress()), isFalse);
        },
      );

      test('aborting there puts that tree back', () async {
        world.run(<String>['merge', 'topic'], inside: tree);

        expect(
          await inside.abortMerge(),
          isA<Success<void, GitClientFailure>>(),
        );

        expect(world.read('a.md', inside: tree), '# A, tree\n');
        expect(valueOf(await inside.mergeInProgress()), isFalse);
      });

      test('status and branches read the tree\'s own branch', () async {
        expect(valueOf(await inside.currentBranch()), 'branch-in-tree');
        expect(valueOf(await inside.branches()), contains('branch-in-tree'));
        expect(valueOf(await inside.status()), contains('branch-in-tree'));
      });
    });

    test('abortMerge keeps an edit the merge never touched', () async {
      world.commitFile('c.md', '# C\n', message: 'Add C');
      world.git(<String>['switch', '--quiet', '--create', 'topic']);
      world.commitFile('a.md', '# A, topic\n', message: 'Topic');
      world.git(<String>['switch', '--quiet', 'main']);
      world.commitFile('a.md', '# A, main\n', message: 'Main');
      world.write('c.md', '# C, edited meanwhile\n');
      world.run(<String>['merge', 'topic']);

      expect(await client.abortMerge(), isA<Success<void, GitClientFailure>>());

      expect(world.read('c.md'), '# C, edited meanwhile\n');
      expect(world.read('a.md'), '# A, main\n');
    });

    test('abortMerge with nothing to abort says so in git\'s words', () async {
      final GitClientFailure failure = failureOf(await client.abortMerge());

      expect(failure, isA<GitClientCommandFailed>());
      expect(
        (failure as GitClientCommandFailed).stderr,
        contains('MERGE_HEAD'),
      );
    });
  });

  // A cherry-pick, a revert or a rebase stopped on a conflict leaves conflicted
  // entries in the status and no `MERGE_HEAD`. The client answers the question
  // it is asked — is a merge going on — and says no; the conflicted entries are
  // the status's to report.
  group('another operation stopped on a conflict', () {
    setUp(() {
      world.git(<String>['switch', '--quiet', '--create', 'topic']);
      world.commitFile('a.md', '# A, topic\n', message: 'Topic');
      world.git(<String>['switch', '--quiet', 'main']);
      world.commitFile('a.md', '# A, main\n', message: 'Main');
    });

    test(
      'a cherry-pick is not a merge, though the status lists the conflict',
      () async {
        world.run(<String>['cherry-pick', 'topic']);

        expect(valueOf(await client.mergeInProgress()), isFalse);
        expect(await records(), contains(startsWith('u UU ')));
      },
    );

    test('a revert is not a merge either', () async {
      world.run(<String>['revert', '--no-edit', 'HEAD~1']);

      expect(valueOf(await client.mergeInProgress()), isFalse);
    });

    test('a rebase is not a merge, and its branch reads as detached', () async {
      world.git(<String>['switch', '--quiet', 'topic']);
      world.run(<String>['rebase', 'main']);

      expect(valueOf(await client.mergeInProgress()), isFalse);
      expect(valueOf(await client.currentBranch()), isEmpty);
      expect(await records(), contains(startsWith('u UU ')));
    });

    test('abortMerge does not abort them', () async {
      world.run(<String>['cherry-pick', 'topic']);

      expect(
        failureOf(await client.abortMerge()),
        isA<GitClientCommandFailed>(),
      );
      expect(
        File('${world.repo}/.git/CHERRY_PICK_HEAD').existsSync(),
        isTrue,
        reason: 'the stopped cherry-pick is still there',
      );
    });
  });
}
