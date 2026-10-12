/// The chain a person walks to a first space — clone, open, be remembered,
/// be named by branch on Home — through the composition root over a real
/// bare remote (`docs/product/home/`).
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

import '../support/real_remote_stack.dart';

void main() {
  late RealRemoteStack stack;

  setUp(() => stack = RealRemoteStack.create());

  Future<Result<SpaceEntity, AppFailure>> clone(
    String destination, {
    String? url,
    List<CloneStageEnum>? stages,
  }) => stack.container
      .read(cloneRepositoryProvider)
      .clone(
        url: url ?? stack.remote,
        destination: destination,
        onProgress: stages == null
            ? null
            : (CloneProgressValueObject it) => stages.add(it.stage),
      );

  Future<List<RecentSpaceEntity>> recents() async =>
      (await stack.container.read(listRecentSpacesProvider).list())
          .valueOrNull!;

  Future<BranchNameValueObject?> branchOf(RecentSpaceEntity recent) async =>
      (await stack.container.read(readRecentBranchProvider).read(recent))
          .valueOrNull;

  group('clone, open, remember, name the branch', () {
    test(
      'a clone into a folder with a space in its name opens as a space '
      'at the repository, is remembered, and is named by its branch',
      () async {
        final String destination = '${stack.root}/clones/my docs';
        final List<CloneStageEnum> stages = <CloneStageEnum>[];

        final Result<SpaceEntity, AppFailure> cloned = await clone(
          destination,
          stages: stages,
        );

        final SpaceEntity space = cloned.valueOrNull!;
        expect(space.root, destination);
        expect(space.repositoryRoot, destination);
        expect(space.name, 'my docs');
        expect(stages.first, CloneStageEnum.starting);
        expect(File('$destination/docs/guide.md').existsSync(), isTrue);
        final List<RecentSpaceEntity> remembered = await recents();
        expect(remembered.map((RecentSpaceEntity it) => it.root), <String>[
          destination,
        ]);
        expect((await branchOf(remembered.single))?.value, 'main');
        expect(File('${stack.root}/app/preferences.json').existsSync(), isTrue);
      },
    );

    test('the branch Home names follows the folder when the person switches '
        'it elsewhere', () async {
      final String destination = '${stack.root}/clones/docs';
      await clone(destination);
      final RecentSpaceEntity recent = (await recents()).single;
      stack.git(<String>[
        'checkout',
        '--quiet',
        '-b',
        'feat/elsewhere',
      ], inside: destination);

      expect((await branchOf(recent))?.value, 'feat/elsewhere');
      stack.git(<String>[
        'checkout',
        '--quiet',
        '--detach',
      ], inside: destination);
      expect(await branchOf(recent), isNull);
    });

    test('a clone into an existing empty folder uses it and keeps the '
        'folder', () async {
      final String destination = '${stack.root}/empty';
      Directory(destination).createSync();

      final Result<SpaceEntity, AppFailure> cloned = await clone(destination);

      expect(cloned.valueOrNull?.repositoryRoot, destination);
      expect(File('$destination/README.md').existsSync(), isTrue);
    });

    test('a remote with no commits clones, opens, and names the unborn '
        'branch', () async {
      final String bare = '${stack.root}/empty-remote.git';
      stack
        ..git(<String>['init', '--quiet', '--bare', bare], inside: stack.root)
        ..git(<String>[
          'symbolic-ref',
          'HEAD',
          'refs/heads/main',
        ], inside: bare);

      final Result<SpaceEntity, AppFailure> cloned = await clone(
        '${stack.root}/clones/fresh',
        url: bare,
      );

      expect(cloned.valueOrNull?.hasRepository, isTrue);
      expect((await branchOf((await recents()).single))?.value, 'main');
    });

    test('a destination that holds something is refused, opens nothing and '
        'is left as it was', () async {
      final String destination = '${stack.root}/taken';
      Directory(destination).createSync();
      File('$destination/mine.md').writeAsStringSync('# Mine\n');

      final Result<SpaceEntity, AppFailure> cloned = await clone(destination);

      expect(
        (cloned as Failure<SpaceEntity, AppFailure>).failure,
        isA<GitCloneDestinationTaken>(),
      );
      expect(File('$destination/mine.md').readAsStringSync(), '# Mine\n');
      expect(Directory('$destination/.git').existsSync(), isFalse);
      expect(await recents(), isEmpty);
    });

    test('an address with nothing there is refused, leaves no folder and '
        'remembers nothing', () async {
      final String destination = '${stack.root}/clones/never';

      final Result<SpaceEntity, AppFailure> cloned = await clone(
        destination,
        url: '${stack.root}/nowhere.git',
      );

      expect(
        (cloned as Failure<SpaceEntity, AppFailure>).failure,
        isA<GitRemoteNotFound>(),
      );
      expect(Directory(destination).existsSync(), isFalse);
      expect(await recents(), isEmpty);
    });
  });

  group('opening a folder', () {
    Future<Result<SpaceEntity, AppFailure>> open(String folder) =>
        stack.container.read(openSpaceProvider).open(folder);

    test('below the repository root keeps the two apart, and remembers the '
        'space', () async {
      final SpaceEntity space = (await open(stack.space.root)).valueOrNull!;

      expect(space.root, stack.space.root);
      expect(space.repositoryRoot, stack.clone);
      expect((await recents()).single.root, stack.space.root);
      expect((await branchOf((await recents()).single))?.value, 'main');
    });

    test('a worktree is a space at its own repository root', () async {
      final String worktree = '${stack.root}/work/wt';
      stack.git(<String>[
        'worktree',
        'add',
        '--quiet',
        '-b',
        'feat/wt',
        worktree,
      ]);

      final SpaceEntity space = (await open('$worktree/docs')).valueOrNull!;

      expect(space.repositoryRoot, worktree);
      expect((await branchOf((await recents()).single))?.value, 'feat/wt');
    });

    test('a folder outside any repository opens without one, is '
        'remembered, and names no branch', () async {
      Directory('${stack.root}/loose').createSync();

      final SpaceEntity space = (await open(
        '${stack.root}/loose',
      )).valueOrNull!;

      expect(space.hasRepository, isFalse);
      final RecentSpaceEntity recent = (await recents()).single;
      expect(recent.root, '${stack.root}/loose');
      expect(await branchOf(recent), isNull);
    });

    test('a folder that is gone is refused and is not remembered', () async {
      final Result<SpaceEntity, AppFailure> opened = await open(
        '${stack.root}/gone',
      );

      expect(opened, isA<Failure<SpaceEntity, AppFailure>>());
      expect(await recents(), isEmpty);
    });

    test('opening the same space twice remembers it once', () async {
      await open(stack.space.root);
      await open(stack.space.root);

      expect(await recents(), hasLength(1));
    });
  });
}
