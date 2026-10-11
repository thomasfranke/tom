/// What a pull request proposes, read through [GitRepositoryImpl] from real
/// history: the commits, the changed files and the fork point, against the
/// remote's copy of the base when it has one and the local copy when not.
@TestOn('!windows')
library;

// Arranging a repository is a run of statements on one world.
// ignore_for_file: cascade_invocations

import 'dart:io';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';

import '../../support/git_world.dart';

void main() {
  late GitWorld world;
  late String remote;
  late String work;
  late String colleague;

  final BranchNameValueObject main_ = branch('main');

  setUp(() {
    world = GitWorld();
    final String seed = world.init('${world.base}/seed');
    world.write(seed, 'docs/a.md', '# A\n');
    world.write(seed, 'docs/b.md', '# B\n');
    world.write(seed, 'docs/old.md', '# Old\nsome text\nmore text\n');
    world.write(seed, 'docs/shared.md', '# Shared\n');
    world.commitAll(seed, 'Start');
    remote = '${world.base}/remote.git';
    world.git(<String>[
      'clone',
      '--quiet',
      '--bare',
      seed,
      remote,
    ], inside: world.base);
    work = world.clone(remote, '${world.base}/work');
    colleague = world.colleague(remote);
  });

  tearDown(() => world.dispose());

  /// The feature branch's own work, in every shape a diff has.
  void featureWork() {
    world.git(<String>['switch', '--quiet', '-c', 'feat/x'], inside: work);
    world.commitFile(
      work,
      'docs/new notes.md',
      '# New\nline\n',
      message: 'Add',
    );
    world.commitFile(work, 'docs/a.md', '# A\nmore\n', message: 'Edit A');
    File('$work/docs/b.md').deleteSync();
    world.git(<String>['rm', '--quiet', '--cached', 'docs/b.md'], inside: work);
    world.git(<String>['commit', '--quiet', '-m', 'Drop B'], inside: work);
    world.git(<String>['mv', 'docs/old.md', 'docs/renamed.md'], inside: work);
    world.git(<String>['commit', '--quiet', '-m', 'Rename'], inside: work);
    File(
      '$work/docs/pic.png',
    ).writeAsBytesSync(Uint8List.fromList(<int>[0, 1, 2, 3, 255, 0, 254]));
    world.git(<String>['add', 'docs/pic.png'], inside: work);
    world.git(<String>['commit', '--quiet', '-m', 'Picture'], inside: work);
  }

  /// The remote's main moves on while the local one stays where it was, and
  /// the feature branch takes that work in.
  void remoteMovesOn() {
    world.commitFile(
      colleague,
      'docs/shared.md',
      '# Shared\nby them\n',
      message: 'Theirs',
    );
    world.git(<String>['push', '--quiet', 'origin', 'main'], inside: colleague);
    world.git(<String>['fetch', '--quiet'], inside: work);
    world.git(<String>[
      'merge',
      '--quiet',
      '--no-edit',
      'origin/main',
    ], inside: work);
  }

  for (final String below in const <String>['', 'docs']) {
    group('a branch proposed against main, the client in ${_where(below)}', () {
      late GitRepositoryImpl repository;

      setUp(() {
        featureWork();
        repository = world.repository(below.isEmpty ? work : '$work/$below');
      });

      test(
        'lists its commits, the newest first, and none of main\'s',
        () async {
          final List<String> subjects = valueOf(
            await repository.commitsSince(main_),
          ).map((CommitEntity c) => c.subject).toList();

          expect(subjects, <String>[
            'Picture',
            'Rename',
            'Drop B',
            'Edit A',
            'Add',
          ]);
        },
      );

      test('lists the files changed, in repository paths, with their '
          'counts', () async {
        final Map<String, BranchChangeValueObject> changes =
            <String, BranchChangeValueObject>{
              for (final BranchChangeValueObject c in valueOf(
                await repository.changesSince(main_),
              ))
                c.path.value: c,
            };

        expect(changes.keys.toSet(), <String>{
          'docs/new notes.md',
          'docs/a.md',
          'docs/b.md',
          'docs/old.md',
          'docs/renamed.md',
          'docs/pic.png',
        });
        expect(changes['docs/new notes.md']!.state, FileStateEnum.added);
        expect(changes['docs/new notes.md']!.added, 2);
        expect(changes['docs/a.md']!.state, FileStateEnum.modified);
        expect(changes['docs/a.md']!.added, 1);
        expect(changes['docs/a.md']!.removed, 0);
        expect(changes['docs/b.md']!.state, FileStateEnum.deleted);
        expect(changes['docs/b.md']!.removed, 1);
      });

      test('a rename is a deletion and an addition, as the diff reads '
          'it', () async {
        final List<BranchChangeValueObject> changes = valueOf(
          await repository.changesSince(main_),
        );

        expect(
          changes
              .singleWhere(
                (BranchChangeValueObject c) => c.path.value == 'docs/old.md',
              )
              .state,
          FileStateEnum.deleted,
        );
        expect(
          changes
              .singleWhere(
                (BranchChangeValueObject c) =>
                    c.path.value == 'docs/renamed.md',
              )
              .state,
          FileStateEnum.added,
        );
      });

      test('a binary file has no line counts', () async {
        final BranchChangeValueObject picture =
            valueOf(await repository.changesSince(main_)).singleWhere(
              (BranchChangeValueObject c) => c.path.value == 'docs/pic.png',
            );

        expect(picture.state, FileStateEnum.added);
        expect(picture.added, isNull);
        expect(picture.removed, isNull);
      });

      test('forks from where main was when the branch left it', () async {
        expect(
          valueOf(await repository.forkPoint(main_)),
          CommitShaValueObject.tryParse(
            world.git(<String>['rev-parse', 'main'], inside: work),
          ),
        );
      });

      test('seeds a draft from the real commits, the oldest as its '
          'title', () async {
        final String draft = const PullRequestDraftService().seed(
          valueOf(await repository.commitsSince(main_)),
        );

        expect(draft, '# Add\n\n- Edit A\n- Drop B\n- Rename\n- Picture\n');
        expect(const PullRequestDraftService().title(draft), 'Add');
      });
    });

    group(
      'against a main that moved on the remote, the client in ${_where(below)}',
      () {
        late GitRepositoryImpl repository;

        setUp(() {
          featureWork();
          remoteMovesOn();
          repository = world.repository(below.isEmpty ? work : '$work/$below');
        });

        test('reads origin\'s copy, so work the branch took in is not '
            'proposed', () async {
          // The local main is stale: against it the colleague's commit
          // would be listed as the branch's own.
          expect(
            world.git(<String>[
              'log',
              '--format=%s',
              'main..HEAD',
            ], inside: work),
            contains('Theirs'),
          );

          final List<String> subjects = valueOf(
            await repository.commitsSince(main_),
          ).map((CommitEntity c) => c.subject).toList();

          expect(subjects, isNot(contains('Theirs')));
          expect(subjects, contains('Picture'));
        });

        test('leaves the colleague\'s file out of the changes', () async {
          final List<String> paths = valueOf(
            await repository.changesSince(main_),
          ).map((BranchChangeValueObject c) => c.path.value).toList();

          expect(paths, isNot(contains('docs/shared.md')));
          expect(paths, contains('docs/a.md'));
        });

        test('forks from origin\'s main, not the stale local one', () async {
          expect(
            valueOf(await repository.forkPoint(main_)),
            CommitShaValueObject.tryParse(
              world.git(<String>['rev-parse', 'origin/main'], inside: work),
            ),
          );
        });
      },
    );
  }

  group('with no remote copy of the base', () {
    late GitRepositoryImpl repository;

    setUp(() {
      featureWork();
      world.git(<String>['remote', 'remove', 'origin'], inside: work);
      repository = world.repository('$work/docs');
    });

    test('the local branch is the base', () async {
      expect(valueOf(await repository.commitsSince(main_)), hasLength(5));
      expect(valueOf(await repository.changesSince(main_)), hasLength(6));
      expect(valueOf(await repository.forkPoint(main_)), isNotNull);
    });

    test(
      'a base that is nowhere is a failure, not an empty proposal',
      () async {
        expect(
          await repository.commitsSince(branch('nowhere')),
          isA<Failure<List<CommitEntity>, GitFailure>>(),
        );
        expect(
          await repository.changesSince(branch('nowhere')),
          isA<Failure<List<BranchChangeValueObject>, GitFailure>>(),
        );
      },
    );
  });

  group('a branch with a history of its own', () {
    late GitRepositoryImpl repository;

    setUp(() {
      world.git(<String>[
        'switch',
        '--quiet',
        '--orphan',
        'island',
      ], inside: work);
      world.commitFile(work, 'island.md', '# Island\n', message: 'Alone');
      repository = world.repository(work);
    });

    test('shares no fork point with main', () async {
      expect(valueOf(await repository.forkPoint(main_)), isNull);
    });

    test('has no changes to compare, and says so as a failure', () async {
      expect(
        await repository.changesSince(main_),
        isA<Failure<List<BranchChangeValueObject>, GitFailure>>(),
      );
    });
  });
}

/// Where the client runs, for a group's name.
String _where(String below) => below.isEmpty ? 'the root' : '$below/';
