/// [GitRepositoryImpl] over a real [DartIoGitClientImpl] and a real repository,
/// the only place the capability's promise and the parser's expectation meet.
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late Directory tempDir;
  late String repoPath;
  late GitRepositoryImpl repository;

  /// Runs git directly, to arrange what the repository is then asked about.
  void git(List<String> arguments, {String? inside}) {
    final ProcessResult result = Process.runSync(
      'git',
      arguments,
      workingDirectory: inside ?? repoPath,
      environment: const <String, String>{'LC_ALL': 'C'},
    );
    if (result.exitCode != 0) {
      throw StateError('git ${arguments.join(' ')}: ${result.stderr}');
    }
  }

  void write(String relativePath, String content) {
    File('$repoPath/$relativePath')
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(content);
  }

  /// What [result] holds, or a failure of the test if it did not succeed.
  T valueOf<T, F extends AppFailure>(Result<T, F> result) => switch (result) {
    Success<T, F>(value: final T value) => value,
    Failure<T, F>(failure: final F failure) => throw StateError(
      'expected a success, got $failure',
    ),
  };

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('tom_git_repository_');
    repoPath = '${tempDir.path}/repo';
    Directory(repoPath).createSync(recursive: true);
    git(<String>['init', '--quiet', '.']);
    // `symbolic-ref` rather than `init --initial-branch`, which needs git
    // 2.28; the tests should not be stricter than the client.
    git(<String>['symbolic-ref', 'HEAD', 'refs/heads/main']);
    for (final List<String> setting in const <List<String>>[
      <String>['user.name', 'Test'],
      <String>['user.email', 'test@example.com'],
      <String>['commit.gpgsign', 'false'],
    ]) {
      git(<String>['config', ...setting]);
    }
    repository = GitRepositoryImpl(
      git: GitDataSource(
        client: DartIoGitClientImpl(workingDirectory: repoPath),
      ),
    );
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  group('a repository with nothing in it yet', () {
    test('has an empty history rather than a failure', () async {
      expect(valueOf(await repository.history()), isEmpty);
    });

    test('reports its branch and a clean tree', () async {
      final GitStatusValueObject status = valueOf(await repository.status());

      expect(status.branch, BranchNameValueObject('main'));
      expect(status.isClean, isTrue);
      expect(status.isDetached, isFalse);
      expect(status.upstream, isNull);
    });
  });

  group('a file the user has not staged', () {
    setUp(() => write('guide.md', '# Guide\n'));

    test('shows up as untracked, unstaged', () async {
      final GitStatusValueObject status = valueOf(await repository.status());

      expect(status.isClean, isFalse);
      expect(
        status.entries.single.path,
        RepoRelativePathValueObject('guide.md'),
      );
      expect(status.entries.single.state, FileStateEnum.untracked);
      expect(status.entries.single.isStaged, isFalse);
      expect(status.hasStagedChanges, isFalse);
    });

    test('is staged as a whole file, and git agrees', () async {
      valueOf(
        await repository.stage(<RepoRelativePathValueObject>[
          RepoRelativePathValueObject('guide.md'),
        ]),
      );

      final GitStatusValueObject status = valueOf(await repository.status());
      expect(status.entries.single.state, FileStateEnum.added);
      expect(status.entries.single.isStaged, isTrue);
      expect(status.hasStagedChanges, isTrue);
    });

    test('unstaging puts it back where it was', () async {
      valueOf(
        await repository.stage(<RepoRelativePathValueObject>[
          RepoRelativePathValueObject('guide.md'),
        ]),
      );
      valueOf(
        await repository.unstage(<RepoRelativePathValueObject>[
          RepoRelativePathValueObject('guide.md'),
        ]),
      );

      expect(
        valueOf(await repository.status()).entries.single.state,
        FileStateEnum.untracked,
      );
    });
  });

  group('after a commit', () {
    setUp(() async {
      write('docs/guide.md', '# Guide\n');
      valueOf(
        await repository.stage(<RepoRelativePathValueObject>[
          RepoRelativePathValueObject('docs/guide.md'),
        ]),
      );
      valueOf(await repository.commit('docs: add the guide'));
    });

    test('the working tree is clean again', () async {
      expect(valueOf(await repository.status()).isClean, isTrue);
    });

    test('the commit is in the history, as an entity', () async {
      final List<CommitEntity> commits = valueOf(await repository.history());

      expect(commits, hasLength(1));
      expect(commits.single.subject, 'docs: add the guide');
      expect(commits.single.body, isEmpty);
      expect(commits.single.author.name, 'Test');
      expect(commits.single.author.email, 'test@example.com');
      expect(commits.single.sha.value, hasLength(40));
    });

    test('the author date keeps the offset git recorded', () async {
      final CommitDateValueObject date = valueOf(
        await repository.history(),
      ).single.date;

      expect(date.utc.isUtc, isTrue);
      expect(
        date.offset,
        DateTime.now().timeZoneOffset,
        reason: 'git records the committer machine offset',
      );
    });

    test('a history narrowed to a path sees only that path', () async {
      write('docs/other.md', '# Other\n');
      valueOf(
        await repository.stage(<RepoRelativePathValueObject>[
          RepoRelativePathValueObject('docs/other.md'),
        ]),
      );
      valueOf(await repository.commit('docs: add another'));

      final List<CommitEntity> commits = valueOf(
        await repository.history(
          path: RepoRelativePathValueObject('docs/guide.md'),
        ),
      );

      expect(commits.map((CommitEntity commit) => commit.subject), <String>[
        'docs: add the guide',
      ]);
    });

    test('a limit caps what comes back, newest first', () async {
      write('docs/other.md', '# Other\n');
      valueOf(
        await repository.stage(<RepoRelativePathValueObject>[
          RepoRelativePathValueObject('docs/other.md'),
        ]),
      );
      valueOf(await repository.commit('docs: add another'));

      final List<CommitEntity> commits = valueOf(
        await repository.history(limit: 1),
      );

      expect(commits.single.subject, 'docs: add another');
    });

    test('contentAt reads the file as it was committed', () async {
      write('docs/guide.md', '# Guide\n\nRewritten.\n');

      expect(
        valueOf(
          await repository.contentAt(
            revision: 'HEAD',
            path: RepoRelativePathValueObject('docs/guide.md'),
          ),
        ),
        '# Guide\n',
      );
    });
  });

  group('a file gone from the disk that git still knows', () {
    final SpaceRelativePathValueObject asked = SpaceRelativePathValueObject(
      'logo.png',
    );
    // Not UTF-8, and no zero byte: only the bytes themselves can say so.
    const List<int> picture = <int>[0xFF, 0xD8, 0xFF, 0xE0, 0x4A, 0x46];

    setUp(() {
      write('guide.md', '# Guide\n');
      git(<String>['add', 'guide.md']);
      git(<String>['commit', '--quiet', '--message', 'docs: add the guide']);
    });

    test('a committed binary reads as binary, by its bytes', () async {
      File('$repoPath/logo.png').writeAsBytesSync(picture);
      git(<String>['add', 'logo.png']);
      git(<String>['commit', '--quiet', '--message', 'docs: add the logo']);
      File('$repoPath/logo.png').deleteSync();

      final Uint8List bytes = valueOf(
        await repository.bytesAt(
          revision: 'HEAD',
          path: RepoRelativePathValueObject('logo.png'),
        ),
      );

      expect(bytes, picture);
      expect(
        FileContentValueObject.ofBytes(asked, bytes),
        const FileContentValueObject.binary(),
      );
    });

    test('a file staged and then deleted is in the index, not HEAD', () async {
      write('notes.txt', 'staged, never committed\n');
      git(<String>['add', 'notes.txt']);
      File('$repoPath/notes.txt').deleteSync();
      final RepoRelativePathValueObject notes = RepoRelativePathValueObject(
        'notes.txt',
      );

      final GitStatusValueObject status = valueOf(await repository.status());
      expect(status.entries.single.path, notes, reason: 'git still lists it');
      expect(
        await repository.bytesAt(revision: 'HEAD', path: notes),
        isA<Failure<Uint8List, GitFailure>>().having(
          (Failure<Uint8List, GitFailure> result) => result.failure,
          'failure',
          isA<GitPathNotInRevision>(),
        ),
      );
      expect(
        FileContentValueObject.ofBytes(
          SpaceRelativePathValueObject('notes.txt'),
          valueOf(await repository.stagedBytes(notes)),
        ),
        FileContentValueObject.text(
          DocumentEntity(
            path: SpaceRelativePathValueObject('notes.txt'),
            content: 'staged, never committed\n',
          ),
        ),
      );
    });

    test('a path neither holds is no version, from the index too', () async {
      expect(
        await repository.stagedBytes(RepoRelativePathValueObject('none.txt')),
        isA<Failure<Uint8List, GitFailure>>().having(
          (Failure<Uint8List, GitFailure> result) => result.failure,
          'failure',
          isA<GitPathNotInRevision>(),
        ),
      );
    });
  });

  group('branches', () {
    setUp(() async {
      write('guide.md', '# Guide\n');
      valueOf(
        await repository.stage(<RepoRelativePathValueObject>[
          RepoRelativePathValueObject('guide.md'),
        ]),
      );
      valueOf(await repository.commit('docs: add the guide'));
    });

    test('listing says which one is current', () async {
      final List<BranchEntity> branches = valueOf(await repository.branches());

      expect(branches.single.name, BranchNameValueObject('main'));
      expect(branches.single.isCurrent, isTrue);
      expect(branches.single.upstream, isNull);
    });

    test('creating one switches to it, as the product expects', () async {
      valueOf(
        await repository.createBranch(
          BranchNameValueObject('feat/rendered-diff'),
        ),
      );

      expect(
        valueOf(await repository.status()).branch,
        BranchNameValueObject('feat/rendered-diff'),
      );
    });

    test('switching back moves HEAD', () async {
      valueOf(
        await repository.createBranch(
          BranchNameValueObject('feat/rendered-diff'),
        ),
      );
      valueOf(await repository.switchBranch(BranchNameValueObject('main')));

      expect(
        valueOf(await repository.status()).branch,
        BranchNameValueObject('main'),
      );
      expect(valueOf(await repository.branches()), hasLength(2));
    });

    test('a detached HEAD is reported as one', () async {
      git(<String>['checkout', '--quiet', '--detach', 'HEAD']);

      final GitStatusValueObject status = valueOf(await repository.status());
      expect(status.isDetached, isTrue);
      expect(status.branch, isNull);
    });
  });

  group('the branch a branch came from', () {
    BranchNameValueObject name(String value) => BranchNameValueObject(value);

    void commit(String message) {
      write('guide.md', '# $message\n');
      git(<String>['add', 'guide.md']);
      git(<String>['commit', '--quiet', '--message', message]);
    }

    /// What the product would compare against, asked of this repository the
    /// way the use case asks it.
    Future<BranchRefValueObject?> base() async {
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

    setUp(() {
      commit('docs: the first pass');
      git(<String>['switch', '--quiet', '--create', 'develop']);
      commit('docs: develop moves');
      git(<String>['switch', '--quiet', '--create', 'feat/glossary']);
      commit('docs: the glossary');
    });

    test(
      'the diff reads it where the branch left it, not at its tip',
      () async {
        // develop moves on after the feature was cut: that work is develop's,
        // and must never read as removed on the feature.
        git(<String>['switch', '--quiet', 'develop']);
        write('notes.md', '# Later on develop\n');
        git(<String>['add', 'notes.md']);
        git(<String>['commit', '--quiet', '--message', 'docs: later']);
        git(<String>['switch', '--quiet', 'feat/glossary']);

        final CommitShaValueObject fork = valueOf(
          await repository.forkPoint(name('develop')),
        )!;

        expect(
          valueOf(
            await repository.contentAt(
              revision: fork.value,
              path: RepoRelativePathValueObject('guide.md'),
            ),
          ),
          '# docs: develop moves\n',
        );
        expect(
          await repository.contentAt(
            revision: fork.value,
            path: RepoRelativePathValueObject('notes.md'),
          ),
          isA<Failure<String, GitFailure>>(),
          reason: 'develop\'s later document is in the fork point',
        );
      },
    );

    test('is recorded in git config and read back', () async {
      valueOf(await repository.recordBase(name('feat/glossary'), name('main')));

      expect(
        valueOf(await repository.recordedBase(name('feat/glossary'))),
        name('main'),
      );
      expect(valueOf(await repository.recordedBase(name('develop'))), isNull);
    });

    test('stands every branch against HEAD', () async {
      final List<BranchStandingValueObject> standings = valueOf(
        await repository.standings(),
      );

      expect(
        standings,
        containsAll(<BranchStandingValueObject>[
          BranchStandingValueObject(
            branch: BranchRefValueObject(name: name('main')),
            ahead: 0,
            behind: 2,
            sharesHistory: true,
          ),
          BranchStandingValueObject(
            branch: BranchRefValueObject(name: name('develop')),
            ahead: 0,
            behind: 1,
            sharesHistory: true,
          ),
        ]),
      );
    });

    test('a remote\'s copy is its own entry, its HEAD left out', () async {
      git(<String>['update-ref', 'refs/remotes/origin/develop', 'develop']);
      git(<String>[
        'symbolic-ref',
        'refs/remotes/origin/HEAD',
        'refs/remotes/origin/develop',
      ]);

      final List<BranchRefValueObject> branches = <BranchRefValueObject>[
        for (final BranchStandingValueObject it in valueOf(
          await repository.standings(),
        ))
          it.branch,
      ];

      expect(
        branches,
        contains(BranchRefValueObject(name: name('develop'), remote: 'origin')),
      );
      expect(
        branches.where((BranchRefValueObject it) => it.name.value == 'HEAD'),
        isEmpty,
      );
    });

    test('an unrelated history shares nothing', () async {
      git(<String>['switch', '--quiet', '--orphan', 'gh-pages']);
      commit('pages');
      git(<String>['switch', '--quiet', 'feat/glossary']);

      final BranchStandingValueObject pages =
          valueOf(await repository.standings()).firstWhere(
            (BranchStandingValueObject it) => it.branch.spec == 'gh-pages',
          );

      expect(pages.sharesHistory, isFalse);
    });

    test('started outside TOM, it is deduced as the nearest', () async {
      expect(await base(), BranchRefValueObject(name: name('develop')));
    });

    test('recorded, it wins over the nearest', () async {
      valueOf(await repository.recordBase(name('feat/glossary'), name('main')));

      expect(await base(), BranchRefValueObject(name: name('main')));
    });

    test('a branch started from this one is not its base', () async {
      git(<String>['switch', '--quiet', 'develop']);
      git(<String>['switch', '--quiet', '--create', 'feat/later']);
      commit('docs: later');
      git(<String>['switch', '--quiet', 'develop']);

      // `feat/glossary` and `feat/later` both came from here; main is where
      // develop itself came from.
      expect(await base(), BranchRefValueObject(name: name('main')));
    });

    test('on the remote\'s own branch there is none', () async {
      git(<String>['update-ref', 'refs/remotes/origin/main', 'main']);
      git(<String>[
        'symbolic-ref',
        'refs/remotes/origin/HEAD',
        'refs/remotes/origin/main',
      ]);
      git(<String>['switch', '--quiet', 'main']);

      expect(await base(), isNull);
    });
  });

  group('failures come back in the product vocabulary', () {
    /// What [result] failed with, or a failure of the test if it succeeded.
    F failureOf<T, F extends AppFailure>(Result<T, F> result) =>
        switch (result) {
          Success<T, F>() => throw StateError(
            'expected a failure, got a success',
          ),
          Failure<T, F>(failure: final F failure) => failure,
        };

    test('committing nothing fails, without leaking infrastructure', () async {
      final AppFailure failure = failureOf(await repository.commit('nothing'));

      expect(failure, isA<GitFailure>());
      expect(failure, isNot(isA<GitClientFailure>()));
    });

    test('a folder outside any repository names the folder', () async {
      final String outside = '${tempDir.path}/outside';
      Directory(outside).createSync();
      final GitRepositoryImpl elsewhere = GitRepositoryImpl(
        git: GitDataSource(
          client: DartIoGitClientImpl(workingDirectory: outside),
        ),
      );

      expect(
        failureOf(await elsewhere.status()),
        isA<GitNotARepository>().having(
          (GitNotARepository failure) => failure.path,
          'path',
          outside,
        ),
      );
    });

    test(
      'pushing with no remote says there is none, not that it was rejected',
      () async {
        expect(failureOf(await repository.push()), isA<GitNoRemote>());
      },
    );
  });

  group('a command the person refuses', () {
    late _Gate gate;
    late GitRepositoryImpl gated;

    /// What [result] failed with, or a failure of the test if it succeeded.
    F failureOf<T, F extends AppFailure>(Result<T, F> result) =>
        switch (result) {
          Success<T, F>() => throw StateError('expected a failure'),
          Failure<T, F>(failure: final F failure) => failure,
        };

    setUp(() {
      write('guide.md', '# Guide\n');
      git(<String>['add', 'guide.md']);
      git(<String>['commit', '--quiet', '--message', 'docs: add the guide']);
      write('guide.md', '# Guide\n\nRewritten.\n');
      gate = _Gate();
      gated = GitRepositoryImpl(
        git: GitDataSource(
          client: DartIoGitClientImpl(
            workingDirectory: repoPath,
            commandGate: gate,
          ),
        ),
      );
    });

    test('is a refusal in the product vocabulary, and git never ran', () async {
      gate.refuses = <String>{'git add -- <files>'};

      final GitFailure refused = failureOf(
        await gated.stage(<RepoRelativePathValueObject>[
          RepoRelativePathValueObject('guide.md'),
        ]),
      );

      expect(refused, isA<GitCommandDenied>());
      expect(refused.isDenial, isTrue);
      expect(
        valueOf(await repository.status()).hasStagedChanges,
        isFalse,
        reason: 'nothing was staged',
      );
    });

    test('a refused read is one too, not a clean tree', () async {
      gate.refuses = <String>{
        'git status --porcelain=v2 --branch --untracked-files=all -z',
      };

      expect(failureOf(await gated.status()), isA<GitCommandDenied>());
    });

    test('discarding everything stops where it was refused', () async {
      git(<String>['add', 'guide.md']);
      gate.refuses = <String>{'git restore --worktree -- :/'};

      expect(failureOf(await gated.discardAll()), isA<GitCommandDenied>());

      final GitStatusValueObject status = valueOf(await repository.status());
      expect(status.hasStagedChanges, isFalse, reason: 'the reset ran');
      expect(status.isClean, isFalse, reason: 'the restore did not');
    });

    test('everything the repository runs names a key the list holds', () async {
      await gated.status();
      await gated.history(limit: 1);
      await gated.branches();
      await gated.standings();
      await gated.mergeState();
      await gated.commitIdentity();
      await gated.head();
      await gated.remoteAddress();
      await gated.defaultBranch();
      await gated.gitDirectory();

      final Set<String> known = GitCommandKeyEnum.values
          .map((GitCommandKeyEnum it) => it.template)
          .toSet();
      expect(gate.asked, isNotEmpty);
      expect(known.containsAll(gate.asked), isTrue);
    });
  });
}

/// A gate that refuses the keys a test names and lets the rest through.
final class _Gate implements CommandGate {
  Set<String> refuses = <String>{};

  /// Every key asked about, in order.
  final List<String> asked = <String>[];

  @override
  CommandPlan plan(List<CommandRequest> commands) => _Plan(this, commands);
}

final class _Plan implements CommandPlan {
  _Plan(this.gate, this.commands);

  final _Gate gate;
  final List<CommandRequest> commands;
  int _next = 0;

  @override
  Future<CommandVerdict> next() async {
    final String key = commands[_next++].key;
    gate.asked.add(key);
    return gate.refuses.contains(key)
        ? const CommandVerdict.denied()
        : const CommandVerdict.run();
  }

  @override
  void close() {}
}
