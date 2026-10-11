/// What [GitRepositoryImpl] reads from real repositories in every shape git
/// writes: each status record, history across a rename, branches in every
/// state, the person's identity and account, a base deduced from real
/// standings — and the volumes a documentation repository reaches.
@TestOn('!windows')
library;

// Arranging a repository is a run of statements on one world.
// ignore_for_file: cascade_invocations

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';

import '../../support/git_world.dart';

void main() {
  late GitWorld world;
  late String repo;

  setUp(() {
    world = GitWorld();
    repo = world.init('${world.base}/repo');
  });

  tearDown(() => world.dispose());

  /// What status says of each path, `state/staged`, sorted by path.
  Map<String, String> shapes(GitStatusValueObject status) => <String, String>{
    for (final StatusEntryValueObject e in status.entries)
      e.path.value: '${e.state.name}/${e.isStaged ? 'staged' : 'unstaged'}',
  };

  group('status, in every shape git writes', () {
    late GitRepositoryImpl repository;

    setUp(() {
      world.write(repo, 'docs/a.md', '# A\nline\nline\nline\n');
      world.write(repo, 'docs/b.md', '# B\n');
      world.write(repo, 'docs/c.md', '# C\n');
      world.write(repo, 'docs/d.md', '# D\n');
      world.write(repo, 'docs/link-target.md', '# Link\n');
      world.commitAll(repo, 'Start');
      repository = world.repository('$repo/docs');
    });

    test('unstaged edit and unstaged deletion', () async {
      world.write(repo, 'docs/a.md', '# A, edited\n');
      File('$repo/docs/b.md').deleteSync();

      expect(shapes(valueOf(await repository.status())), <String, String>{
        'docs/a.md': 'modified/unstaged',
        'docs/b.md': 'deleted/unstaged',
      });
    });

    test('a staged edit edited again shows its staged side', () async {
      world.write(repo, 'docs/a.md', '# A, staged\n');
      world.git(<String>['add', 'docs/a.md'], inside: repo);
      world.write(repo, 'docs/a.md', '# A, typed since\n');

      expect(shapes(valueOf(await repository.status())), <String, String>{
        'docs/a.md': 'modified/staged',
      });
    });

    test('a file staged as new and then deleted from the disk', () async {
      world.write(repo, 'docs/e.md', '# E\n');
      world.git(<String>['add', 'docs/e.md'], inside: repo);
      File('$repo/docs/e.md').deleteSync();

      expect(shapes(valueOf(await repository.status())), <String, String>{
        'docs/e.md': 'added/staged',
      });
    });

    test('a staged deletion', () async {
      world.git(<String>['rm', '--quiet', 'docs/b.md'], inside: repo);

      expect(shapes(valueOf(await repository.status())), <String, String>{
        'docs/b.md': 'deleted/staged',
      });
    });

    test('a rename carries the old name', () async {
      world.git(<String>['mv', 'docs/a.md', 'docs/renamed.md'], inside: repo);

      final StatusEntryValueObject row = valueOf(
        await repository.status(),
      ).entries.single;

      expect(row.path, rel('docs/renamed.md'));
      expect(row.state, FileStateEnum.renamed);
      expect(row.isStaged, isTrue);
      expect(row.previousPath, rel('docs/a.md'));
    });

    test('a file turned into a link is a modification', () async {
      File('$repo/docs/d.md').deleteSync();
      Link('$repo/docs/d.md').createSync('link-target.md');
      world.git(<String>['add', 'docs/d.md'], inside: repo);

      expect(shapes(valueOf(await repository.status())), <String, String>{
        'docs/d.md': 'modified/staged',
      });
    });

    test('a copy, when the person asked git to find them, is an addition '
        'with no old name', () async {
      world.configureMore('[status]\n\trenames = copies\n');
      world.write(repo, 'docs/a.md', '# A\nline\nline\nline\nchanged\n');
      world.write(repo, 'docs/copy.md', '# A\nline\nline\nline\n');
      world.git(<String>['add', 'docs/a.md', 'docs/copy.md'], inside: repo);

      final GitStatusValueObject status = valueOf(await repository.status());

      final StatusEntryValueObject copy = status.entries.singleWhere(
        (StatusEntryValueObject e) => e.path.value == 'docs/copy.md',
      );
      expect(copy.state, FileStateEnum.added);
      expect(copy.previousPath, isNull);
    });

    test('names git would quote come back as they are', () async {
      for (final String name in const <String>[
        'docs/my notes.md',
        'docs/versão é.md',
        'docs/-dash.md',
        'docs/say "hi".md',
        'docs/日本語.md',
      ]) {
        world.write(repo, name, '# New\n');
      }

      expect(
        valueOf(
          await repository.status(),
        ).entries.map((StatusEntryValueObject e) => e.path.value).toSet(),
        <String>{
          'docs/my notes.md',
          'docs/versão é.md',
          'docs/-dash.md',
          'docs/say "hi".md',
          'docs/日本語.md',
        },
      );
    });

    test('a file in a folder git has never seen is listed by file', () async {
      world.write(repo, 'docs/fresh/one.md', '# One\n');
      world.write(repo, 'docs/fresh/two.md', '# Two\n');

      expect(shapes(valueOf(await repository.status())), <String, String>{
        'docs/fresh/one.md': 'untracked/unstaged',
        'docs/fresh/two.md': 'untracked/unstaged',
      });
    });

    test(
      'a person\'s status.showUntrackedFiles=no does not hide them',
      () async {
        world.configureMore('[status]\n\tshowUntrackedFiles = no\n');
        world.write(repo, 'docs/fresh.md', '# Fresh\n');

        expect(shapes(valueOf(await repository.status())), <String, String>{
          'docs/fresh.md': 'untracked/unstaged',
        });
      },
    );

    test(
      'line endings the person\'s autocrlf rewrites are not changes',
      () async {
        world.configureMore('[core]\n\tautocrlf = true\n');
        world.write(repo, 'docs/crlf.md', '# One\r\ntwo\r\n');
        world.commitAll(repo, 'CRLF');

        expect(valueOf(await repository.status()).isClean, isTrue);
        expect(
          valueOf(
            await repository.contentAt(
              revision: 'HEAD',
              path: rel('docs/crlf.md'),
            ),
          ),
          '# One\ntwo\n',
        );
      },
    );

    test('line endings kept as they are come back as they are', () async {
      world.write(repo, 'docs/crlf.md', '# One\r\ntwo\r\n');
      world.commitAll(repo, 'CRLF');

      expect(
        valueOf(
          await repository.contentAt(
            revision: 'HEAD',
            path: rel('docs/crlf.md'),
          ),
        ),
        '# One\r\ntwo\r\n',
      );
    });

    test('every kind of conflict is one conflicted entry', () async {
      // Four ways to disagree: both edit, both add, one edits what the
      // other deletes, and the other way round.
      world.write(repo, 'docs/e.md', '# E\n');
      world.commitAll(repo, 'E');
      world.git(<String>['switch', '--quiet', '-c', 'other'], inside: repo);
      world.write(repo, 'docs/a.md', '# A, theirs\n');
      world.write(repo, 'docs/new.md', '# New, theirs\n');
      File('$repo/docs/b.md').deleteSync();
      world.write(repo, 'docs/e.md', '# E, theirs\n');
      world.commitAll(repo, 'Theirs');
      world.git(<String>['switch', '--quiet', 'main'], inside: repo);
      world.write(repo, 'docs/a.md', '# A, ours\n');
      world.write(repo, 'docs/new.md', '# New, ours\n');
      world.write(repo, 'docs/b.md', '# B, ours\n');
      File('$repo/docs/e.md').deleteSync();
      world.commitAll(repo, 'Ours');
      expect(world.run(<String>['merge', 'other'], inside: repo).exitCode, 1);

      expect(shapes(valueOf(await repository.status())), <String, String>{
        'docs/a.md': 'conflicted/unstaged',
        'docs/b.md': 'conflicted/unstaged',
        'docs/e.md': 'conflicted/unstaged',
        'docs/new.md': 'conflicted/unstaged',
      });
    });

    test('an upstream that was deleted on the remote keeps its name and '
        'counts nothing', () async {
      final ({String remote, String work}) made = world.remoteWithClone();
      world.git(<String>[
        'switch',
        '--quiet',
        '-c',
        'feat/x',
      ], inside: made.work);
      world.git(<String>[
        'push',
        '--quiet',
        '-u',
        'origin',
        'feat/x',
      ], inside: made.work);
      world.git(<String>[
        'push',
        '--quiet',
        'origin',
        '--delete',
        'feat/x',
      ], inside: made.work);
      world.git(<String>['fetch', '--prune', '--quiet'], inside: made.work);

      final GitStatusValueObject status = valueOf(
        await world.repository(made.work).status(),
      );

      expect(status.upstream, branch('origin/feat/x'));
      expect(status.ahead, 0);
      expect(status.behind, 0);
    });
  });

  group('history', () {
    late GitRepositoryImpl repository;

    setUp(() => repository = world.repository(repo));

    test('keeps a multi-line body whole', () async {
      world.write(repo, 'a.md', '# A\n');
      world.git(<String>['add', 'a.md'], inside: repo);
      world.git(<String>[
        'commit',
        '--quiet',
        '--message',
        'Subject line',
        '--message',
        'First paragraph\nstill the first.',
        '--message',
        'Second paragraph.',
      ], inside: repo);

      final CommitEntity commit = valueOf(await repository.history()).single;

      expect(commit.subject, 'Subject line');
      expect(commit.body, contains('First paragraph\nstill the first.'));
      expect(commit.body, contains('\n\nSecond paragraph.'));
    });

    test('lists a file\'s commits from below the root, and a path with '
        'spaces', () async {
      world.commitFile(repo, 'docs/my notes.md', '# One\n', message: 'One');
      world.commitFile(repo, 'docs/other.md', '# Other\n', message: 'Other');
      world.commitFile(repo, 'docs/my notes.md', '# Two\n', message: 'Two');

      final List<String> subjects = valueOf(
        await world
            .repository('$repo/docs')
            .history(path: rel('docs/my notes.md')),
      ).map((CommitEntity c) => c.subject).toList();

      expect(subjects, <String>['Two', 'One']);
    });

    // Decision 48: file history follows a rename; the contract says
    // "across renames".
    test('follows a file across a rename', () async {
      world.commitFile(
        repo,
        'docs/old.md',
        '# Old\nsome text\nmore\n',
        message: 'Create',
      );
      world.git(<String>['mv', 'docs/old.md', 'docs/new.md'], inside: repo);
      world.git(<String>['commit', '--quiet', '-m', 'Rename'], inside: repo);
      world.commitFile(
        repo,
        'docs/new.md',
        '# Old\nsome text\nmore\nmore\n',
        message: 'Edit',
      );

      final List<String> subjects = valueOf(
        await repository.history(path: rel('docs/new.md')),
      ).map((CommitEntity c) => c.subject).toList();

      expect(subjects, <String>['Edit', 'Rename', 'Create']);
    });

    test('a path git never had is an empty history', () async {
      world.commitFile(repo, 'a.md', '# A\n');

      expect(valueOf(await repository.history(path: rel('nope.md'))), isEmpty);
    });
  });

  group('branches', () {
    late GitRepositoryImpl repository;

    setUp(() => repository = world.repository(repo));

    test('an empty repository lists none', () async {
      expect(valueOf(await repository.branches()), isEmpty);
    });

    test('carry their upstream', () async {
      final ({String remote, String work}) made = world.remoteWithClone();
      world.git(<String>[
        'switch',
        '--quiet',
        '-c',
        'local-only',
      ], inside: made.work);
      final GitRepositoryImpl cloned = world.repository(made.work);

      final Map<String, BranchEntity> byName = <String, BranchEntity>{
        for (final BranchEntity b in valueOf(await cloned.branches()))
          b.name.value: b,
      };

      expect(byName['main']!.upstream, branch('origin/main'));
      expect(byName['main']!.isCurrent, isFalse);
      expect(byName['local-only']!.upstream, isNull);
      expect(byName['local-only']!.isCurrent, isTrue);
    });

    test('on a detached HEAD, none is current and the detached record is '
        'not a branch', () async {
      world.commitFile(repo, 'a.md', '# A\n');
      world.git(<String>['switch', '--quiet', '--detach'], inside: repo);

      final List<BranchEntity> listed = valueOf(await repository.branches());

      expect(listed.map((BranchEntity b) => b.name.value), <String>['main']);
      expect(listed.any((BranchEntity b) => b.isCurrent), isFalse);
    });

    test('names with a slash and non-ASCII letters survive', () async {
      world.commitFile(repo, 'a.md', '# A\n');
      world.git(<String>['branch', 'feat/açaí'], inside: repo);

      expect(
        valueOf(
          await repository.branches(),
        ).map((BranchEntity b) => b.name.value),
        containsAll(<String>['main', 'feat/açaí']),
      );
    });

    test('standings of an empty repository are none', () async {
      expect(valueOf(await repository.standings()), isEmpty);
    });

    test('standings on a detached HEAD still stand every branch against '
        'it', () async {
      world.commitFile(repo, 'a.md', '# A\n');
      world.git(<String>['switch', '--quiet', '-c', 'later'], inside: repo);
      world.commitFile(repo, 'b.md', '# B\n');
      world.git(<String>[
        'switch',
        '--quiet',
        '--detach',
        'main',
      ], inside: repo);

      final Map<String, BranchStandingValueObject> byName =
          <String, BranchStandingValueObject>{
            for (final BranchStandingValueObject s in valueOf(
              await repository.standings(),
            ))
              s.branch.spec: s,
          };

      expect(byName['later']!.ahead, 1);
      expect(byName['main']!.ahead, 0);
      expect(byName['main']!.behind, 0);
    });
  });

  group('the machine\'s identity, the remote and the account', () {
    late GitRepositoryImpl repository;

    setUp(() => repository = world.repository(repo));

    test('the identity is both halves of the configuration', () async {
      final CommitIdentityValueObject identity = valueOf(
        await repository.commitIdentity(),
      );

      expect(identity.name, 'Test');
      expect(identity.email, 'test@example.com');
    });

    test('an identity nobody configured is two nulls', () async {
      world.configure('');

      final CommitIdentityValueObject identity = valueOf(
        await repository.commitIdentity(),
      );

      expect(identity.name, isNull);
      expect(identity.email, isNull);
    });

    test('an identity with only a name has no email', () async {
      world.configure('[user]\n\tname = Ada\n');

      final CommitIdentityValueObject identity = valueOf(
        await repository.commitIdentity(),
      );

      expect(identity.name, 'Ada');
      expect(identity.email, isNull);
    });

    test('a repository\'s own identity wins over the global one', () async {
      world.git(<String>['config', 'user.name', 'Local Ada'], inside: repo);

      expect(valueOf(await repository.commitIdentity()).name, 'Local Ada');
    });

    test(
      'the remote address is null with no remote, then what was set',
      () async {
        expect(valueOf(await repository.remoteAddress()), isNull);

        world.git(<String>[
          'remote',
          'add',
          'origin',
          'git@github.com:acme/docs.git',
        ], inside: repo);

        expect(
          valueOf(await repository.remoteAddress()),
          'git@github.com:acme/docs.git',
        );
      },
    );

    test('the head is null unborn, then the commit\'s sha', () async {
      expect(valueOf(await repository.head()), isNull);

      world.commitFile(repo, 'a.md', '# A\n');

      expect(
        valueOf(await repository.head()),
        CommitShaValueObject.tryParse(
          world.git(<String>['rev-parse', 'HEAD'], inside: repo),
        ),
      );
    });

    test('the chosen account is none, then written where git finds it, '
        'then replaced', () async {
      expect(valueOf(await repository.chosenAccount()), isNull);

      valueOf(await repository.chooseAccount('ada'));

      expect(valueOf(await repository.chosenAccount()), 'ada');
      expect(
        world.git(<String>[
          'config',
          '--local',
          '--get',
          'tom.githubAccount',
        ], inside: repo),
        'ada',
      );

      valueOf(await repository.chooseAccount('hopper'));

      expect(valueOf(await repository.chosenAccount()), 'hopper');
    });

    test('the account is read from below the root too', () async {
      valueOf(await repository.chooseAccount('ada'));
      Directory('$repo/docs').createSync();

      expect(
        valueOf(await world.repository('$repo/docs').chosenAccount()),
        'ada',
      );
    });

    test('a folder that is no repository cannot take an account', () async {
      Directory('${world.base}/plain').createSync();

      expect(
        failureOf(
          await world.repository('${world.base}/plain').chooseAccount('ada'),
        ),
        isA<GitNotARepository>(),
      );
    });
  });

  group('the base of a branch, deduced from real standings', () {
    late GitRepositoryImpl repository;

    Future<BranchRefValueObject?> baseOfCurrent() async {
      final BranchEntity current = valueOf(
        await repository.branches(),
      ).firstWhere((BranchEntity it) => it.isCurrent);
      return const BranchBaseService().choose(
        current: current.name,
        upstream: current.upstream,
        defaultBranch: valueOf(await repository.defaultBranch()),
        recorded: valueOf(await repository.recordedBase(current.name)),
        standings: valueOf(await repository.standings()),
      );
    }

    late String work;

    setUp(() {
      work = world.remoteWithClone().work;
      repository = world.repository(work);
    });

    test('never the branch\'s own copy on the remote', () async {
      world.git(<String>['switch', '--quiet', '-c', 'feat/x'], inside: work);
      world.commitFile(work, 'x.md', '# X\n');
      world.git(<String>[
        'push',
        '--quiet',
        '-u',
        'origin',
        'feat/x',
      ], inside: work);

      expect((await baseOfCurrent())?.spec, 'main');
    });

    test(
      'two branches at the same distance: the default branch wins',
      () async {
        world.git(<String>['branch', 'develop'], inside: work);
        world.git(<String>['switch', '--quiet', '-c', 'feat/x'], inside: work);
        world.commitFile(work, 'x.md', '# X\n');

        expect((await baseOfCurrent())?.spec, 'main');
      },
    );

    test('a recorded base that no longer exists is not believed', () async {
      world.git(<String>['switch', '--quiet', '-c', 'feat/x'], inside: work);
      world.commitFile(work, 'x.md', '# X\n');
      valueOf(await repository.recordBase(branch('feat/x'), branch('gone')));

      expect((await baseOfCurrent())?.spec, 'main');
    });

    test('a recorded base that exists wins over a nearer branch', () async {
      world.git(<String>['switch', '--quiet', '-c', 'develop'], inside: work);
      world.commitFile(work, 'd.md', '# D\n');
      world.git(<String>['switch', '--quiet', '-c', 'feat/x'], inside: work);
      world.commitFile(work, 'x.md', '# X\n');
      valueOf(await repository.recordBase(branch('feat/x'), branch('main')));

      expect((await baseOfCurrent())?.spec, 'main');
    });

    test('a detached HEAD has none', () async {
      world.git(<String>['switch', '--quiet', '--detach'], inside: work);

      final GitStatusValueObject status = valueOf(await repository.status());
      expect(status.isDetached, isTrue);
      expect(
        const BranchBaseService().choose(
          current: status.branch,
          standings: valueOf(await repository.standings()),
        ),
        isNull,
      );
    });
  });

  group('volume', () {
    test('five thousand untracked files are five thousand entries', () async {
      world.commitFile(repo, 'a.md', '# A\n');
      for (int i = 0; i < 5000; i++) {
        File('$repo/bulk/f${i.toString().padLeft(4, '0')}.md')
          ..parent.createSync(recursive: true)
          ..writeAsStringSync('# $i\n');
      }

      final GitStatusValueObject status = valueOf(
        await world.repository('$repo/bulk').status(),
      );

      expect(status.entries, hasLength(5000));
      expect(
        status.entries.every(
          (StatusEntryValueObject e) => e.state == FileStateEnum.untracked,
        ),
        isTrue,
      );
    });

    test(
      'a five megabyte file reads back whole, as text and as bytes',
      () async {
        final String line = '${'x' * 79}\n';
        final String text = line * (5 * 1024 * 1024 ~/ 80);
        world.commitFile(repo, 'big.md', text);
        final GitRepositoryImpl repository = world.repository(repo);

        final String read = valueOf(
          await repository.contentAt(revision: 'HEAD', path: rel('big.md')),
        );
        final Uint8List bytes = valueOf(
          await repository.bytesAt(revision: 'HEAD', path: rel('big.md')),
        );

        expect(read.length, text.length);
        expect(bytes.length, utf8.encode(text).length);
      },
    );

    test('three thousand commits are listed whole, and a limit still '
        'caps them', () async {
      world.commitFile(repo, 'a.md', '# A\n', message: 'first');
      final StringBuffer stream = StringBuffer();
      for (int i = 0; i < 3000; i++) {
        final String message = 'commit $i';
        stream
          ..writeln('commit refs/heads/main')
          ..writeln('mark :${i + 1}')
          ..writeln('committer Test <test@example.com> ${1700000000 + i} +0000')
          ..writeln('data ${message.length}')
          ..writeln(message)
          ..writeln(i == 0 ? 'from refs/heads/main^0' : 'from :$i')
          ..writeln();
      }
      final Process importer = await Process.start(
        world.gitExecutable,
        <String>['fast-import', '--quiet'],
        workingDirectory: repo,
        environment: world.environment,
      );
      importer.stdin.write(stream);
      await importer.stdin.close();
      await importer.stdout.drain<void>();
      await importer.stderr.drain<void>();
      expect(await importer.exitCode, 0);
      final GitRepositoryImpl repository = world.repository(repo);

      final List<CommitEntity> all = valueOf(await repository.history());
      final List<CommitEntity> few = valueOf(
        await repository.history(limit: 20),
      );

      expect(all, hasLength(3001));
      expect(all.first.subject, 'commit 2999');
      expect(few, hasLength(20));
    });
  });

  group('a git older than the product needs', () {
    test('standings fail as a failure of the question, not as an empty '
        'list', () async {
      world.commitFile(repo, 'a.md', '# A\n');
      final String older = world.fakeGit(
        'git-old',
        'for argument in "\$@"; do\n'
            '  case "\$argument" in\n'
            '    *ahead-behind*)\n'
            '      echo "fatal: unknown field name: ahead-behind:HEAD" >&2\n'
            '      exit 128 ;;\n'
            '  esac\n'
            'done\n'
            'exec "${world.gitExecutable}" "\$@"',
      );
      final GitRepositoryImpl repository = world.repository(
        repo,
        executable: older,
      );

      expect(
        failureOf(await repository.standings()),
        isA<GitOperationFailed>(),
      );
      // Everything that does not need the field still works.
      expect(valueOf(await repository.branches()), isNotEmpty);
      expect(valueOf(await repository.status()).isClean, isTrue);
    });
  });
}
