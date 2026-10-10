import 'dart:async';

import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  late _Spaces spaces;
  late _Recents recents;
  late _Cloner cloner;
  late ProviderContainer container;

  final SpaceEntity opened = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );

  final RecentSpaceEntity remembered = RecentSpaceEntity(
    root: '/code/app/docs',
    name: 'docs',
    lastOpened: DateTime.utc(2026, 9, 20),
  );

  setUp(() {
    spaces = _Spaces();
    recents = _Recents();
    cloner = _Cloner();
    const _Observability observability = _Observability();
    final OpenSpaceUseCase openSpace = OpenSpaceUseCase(
      spaces: spaces,
      recents: recents,
      observability: observability,
    );
    container = ProviderContainer(
      overrides: <Override>[
        openSpaceProvider.overrideWithValue(openSpace),
        cloneRepositoryProvider.overrideWithValue(
          CloneRepositoryUseCase(
            cloner: cloner,
            openSpace: openSpace,
            observability: observability,
          ),
        ),
        listRecentSpacesProvider.overrideWithValue(
          ListRecentSpacesUseCase(
            recents: recents,
            observability: observability,
          ),
        ),
        forgetRecentSpaceProvider.overrideWithValue(
          ForgetRecentSpaceUseCase(
            recents: recents,
            observability: observability,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  /// Starts Home, and answers its first state; listening is what starts it,
  /// and it is done here rather than in `setUp` so a test can arrange the
  /// repositories first.
  HomeState start() {
    container.listen<HomeState>(homeProvider, (_, _) {});
    return container.read(homeProvider);
  }

  /// The state after everything scheduled has run.
  Future<HomeState> settled() async {
    start();
    await Future<void>.delayed(Duration.zero);
    return container.read(homeProvider);
  }

  HomeNotifier notifier() => container.read(homeProvider.notifier);

  group('arriving', () {
    test('it starts by reading the list, not by waiting to be asked', () {
      expect(start(), isA<HomeLoading>());
    });

    test('and settles on what was remembered', () async {
      recents.stored = <RecentSpaceEntity>[remembered];

      expect((await settled() as HomeReady).recents, <RecentSpaceEntity>[
        remembered,
      ]);
    });

    test('an empty list is a state, not an error', () async {
      expect((await settled() as HomeReady).recents, isEmpty);
    });
  });

  group('opening a folder', () {
    test('a space that opened is written to the session', () async {
      await settled();
      spaces.answer = Success<SpaceEntity, AppFailure>(opened);

      await notifier().open('/code/app/docs');

      expect(container.read(spaceSessionProvider)?.space, opened);
      expect(container.read(homeProvider), isA<HomeLoading>());
    });

    test('and no document is showing yet', () async {
      await settled();
      spaces.answer = Success<SpaceEntity, AppFailure>(opened);

      await notifier().open('/code/app/docs');

      expect(container.read(spaceSessionProvider)?.openDocument, isNull);
    });

    test('a folder outside a repository keeps the failure itself', () async {
      await settled();
      spaces.answer = const Failure<SpaceEntity, AppFailure>(
        GitNotARepository('/loose'),
      );

      await notifier().open('/loose');

      final HomeFailed state = container.read(homeProvider) as HomeFailed;
      expect(state.failure, const GitNotARepository('/loose'));
    });

    test('and the recent list is still offered beside it', () async {
      recents.stored = <RecentSpaceEntity>[remembered];
      await settled();
      spaces.answer = const Failure<SpaceEntity, AppFailure>(
        GitNotARepository('/loose'),
      );

      await notifier().open('/loose');

      expect(
        (container.read(homeProvider) as HomeFailed).recents,
        <RecentSpaceEntity>[remembered],
      );
    });

    test('a folder that is gone is a different failure', () async {
      await settled();
      spaces.answer = const Failure<SpaceEntity, AppFailure>(
        SpaceFolderMissing('/gone'),
      );

      await notifier().open('/gone');

      expect(
        (container.read(homeProvider) as HomeFailed).failure,
        const SpaceFolderMissing('/gone'),
      );
    });

    test('a folder the person refused to ask git about is not a failure: '
        'Home is the list again', () async {
      recents.stored = <RecentSpaceEntity>[remembered];
      await settled();
      spaces.answer = const Failure<SpaceEntity, AppFailure>(
        GitCommandDenied(),
      );

      await notifier().open('/code/app');

      expect(
        container.read(homeProvider),
        HomeState.ready(<RecentSpaceEntity>[remembered]),
      );
      expect(container.read(spaceSessionProvider), isNull);
    });
  });

  group('cloning by URL', () {
    const String address = 'https://github.com/acme/handbook.git';

    HomeCloneState clone() => (container.read(homeProvider) as HomeReady).clone;

    test('Home starts with the button, not the field', () async {
      await settled();

      expect(clone(), const HomeCloneState.closed());
    });

    test('pressing it shows the field, and Esc puts the button back', () async {
      await settled();

      notifier().showClone();
      expect(clone(), const HomeCloneState.open());

      notifier().closeClone();
      expect(clone(), const HomeCloneState.closed());
    });

    test('the clone goes into a folder named as git clone names it', () async {
      await settled();
      spaces.answer = Success<SpaceEntity, AppFailure>(opened);
      notifier().showClone();

      await notifier().clone(url: '  $address ', parent: '/work');

      expect(cloner.asked.single, (
        url: address,
        destination: '/work/handbook',
      ));
    });

    test(
      'a clone that worked opens the space, as a picked folder does',
      () async {
        await settled();
        spaces.answer = Success<SpaceEntity, AppFailure>(opened);
        notifier().showClone();

        await notifier().clone(url: address, parent: '/work');

        expect(container.read(spaceSessionProvider)?.space, opened);
        expect(recents.remembered, <String>['/code/app/docs']);
      },
    );

    test('while git runs the field says so, and where it is going', () async {
      await settled();
      cloner.gate = Completer<void>();
      notifier().showClone();

      final Future<void> running = notifier().clone(
        url: address,
        parent: '/work',
      );
      await Future<void>.delayed(Duration.zero);

      expect(
        clone(),
        const HomeCloneState.cloning(
          url: address,
          destination: '/work/handbook',
        ),
      );
      cloner.gate!.complete();
      await running;
    });

    test("and git's stages are written onto it as they come", () async {
      await settled();
      cloner
        ..gate = Completer<void>()
        ..reports = const <CloneProgressValueObject>[
          CloneProgressValueObject(stage: CloneStageEnum.preparing),
          CloneProgressValueObject(
            stage: CloneStageEnum.receiving,
            percent: 42,
          ),
        ];
      notifier().showClone();

      final Future<void> running = notifier().clone(
        url: address,
        parent: '/work',
      );
      await Future<void>.delayed(Duration.zero);

      expect(
        (clone() as HomeCloneCloning).progress,
        const CloneProgressValueObject(
          stage: CloneStageEnum.receiving,
          percent: 42,
        ),
      );
      cloner.gate!.complete();
      await running;
    });

    test('a clone in flight cannot be closed or started again', () async {
      await settled();
      cloner.gate = Completer<void>();
      notifier().showClone();
      final Future<void> running = notifier().clone(
        url: address,
        parent: '/work',
      );
      await Future<void>.delayed(Duration.zero);

      notifier().closeClone();
      await notifier().clone(url: address, parent: '/elsewhere');

      expect(clone(), isA<HomeCloneCloning>());
      expect(cloner.asked, hasLength(1));
      cloner.gate!.complete();
      await running;
    });

    for (final GitFailure failure in <GitFailure>[
      const GitRemoteNotFound(),
      const GitAuthenticationFailed(),
      const GitNetworkUnavailable(),
      const GitCloneDestinationTaken('/work/handbook'),
    ]) {
      test(
        '${failure.runtimeType} keeps the address and opens nothing',
        () async {
          await settled();
          cloner.answer = Failure<void, GitFailure>(failure);
          notifier().showClone();

          await notifier().clone(url: address, parent: '/work');

          expect(
            clone(),
            HomeCloneState.failed(url: address, failure: failure),
          );
          expect(container.read(spaceSessionProvider), isNull);
        },
      );
    }

    test('a clone the person refused puts the field back, and says '
        'nothing', () async {
      await settled();
      cloner.answer = const Failure<void, GitFailure>(GitCommandDenied());
      notifier().showClone();

      await notifier().clone(url: address, parent: '/work');

      expect(clone(), const HomeCloneState.open());
      expect(container.read(spaceSessionProvider), isNull);
    });

    test('trying again after a failure is the same press', () async {
      await settled();
      cloner.answer = const Failure<void, GitFailure>(GitNetworkUnavailable());
      notifier().showClone();
      await notifier().clone(url: address, parent: '/work');
      cloner.answer = const Success<void, GitFailure>(null);
      spaces.answer = Success<SpaceEntity, AppFailure>(opened);

      await notifier().clone(url: address, parent: '/work');

      expect(container.read(spaceSessionProvider)?.space, opened);
    });

    test('a blank address asks git nothing', () async {
      await settled();
      notifier().showClone();

      await notifier().clone(url: '   ', parent: '/work');

      expect(cloner.asked, isEmpty);
      expect(clone(), const HomeCloneState.open());
    });

    test('an address that names no folder is refused before git', () async {
      await settled();
      notifier().showClone();

      await notifier().clone(url: '/', parent: '/work');

      expect(cloner.asked, isEmpty);
      expect((clone() as HomeCloneFailed).failure, isA<GitRemoteNotFound>());
    });

    test('forgetting a row leaves the field where it was', () async {
      recents.stored = <RecentSpaceEntity>[remembered];
      await settled();
      notifier().showClone();

      await notifier().forget('/code/app/docs');

      expect(clone(), const HomeCloneState.open());
    });
  });

  group('forgetting', () {
    test('the row goes, and what is left is shown', () async {
      recents.stored = <RecentSpaceEntity>[remembered];
      await settled();

      await notifier().forget('/code/app/docs');

      expect(recents.forgotten, <String>['/code/app/docs']);
      expect((container.read(homeProvider) as HomeReady).recents, isEmpty);
    });
  });
}

/// A clone that reports what it was told to and waits to be let go.
final class _Cloner implements GitCloneRepository {
  Result<void, GitFailure> answer = const Success<void, GitFailure>(null);
  List<CloneProgressValueObject> reports = <CloneProgressValueObject>[];
  Completer<void>? gate;
  final List<({String url, String destination})> asked =
      <({String url, String destination})>[];

  @override
  Future<Result<void, GitFailure>> clone({
    required String url,
    required String destination,
    void Function(CloneProgressValueObject progress)? onProgress,
  }) async {
    asked.add((url: url, destination: destination));
    reports.forEach(onProgress ?? (_) {});
    await gate?.future;
    return answer;
  }
}

/// A space repository that answers what it was told to.
final class _Spaces implements SpaceRepository {
  Result<SpaceEntity, AppFailure> answer =
      const Failure<SpaceEntity, AppFailure>(GitNotARepository('/unset'));

  @override
  Future<Result<void, SpaceFailure>> createFolder(
    SpaceEntity space,
    SpaceRelativePathValueObject path,
  ) async => throw UnimplementedError();

  @override
  Future<Result<SpaceEntity, AppFailure>> open(String folder) async => answer;

  @override
  Future<Result<List<SpaceEntryValueObject>, SpaceFailure>> entries(
    SpaceEntity space,
  ) async => throw UnimplementedError();
}

/// A recent list held in memory.
final class _Recents implements RecentSpacesRepository {
  List<RecentSpaceEntity> stored = <RecentSpaceEntity>[];
  final List<String> forgotten = <String>[];

  @override
  Future<Result<List<RecentSpaceEntity>, Never>> list() async =>
      Success<List<RecentSpaceEntity>, Never>(stored);

  final List<String> remembered = <String>[];

  @override
  Future<Result<void, Never>> remember(SpaceEntity space) async {
    remembered.add(space.root);
    return const Success<void, Never>(null);
  }

  @override
  Future<Result<void, Never>> forget(String root) async {
    forgotten.add(root);
    stored = stored
        .where((RecentSpaceEntity recent) => recent.root != root)
        .toList();
    return const Success<void, Never>(null);
  }
}

/// The no-op observability, which is also the shipping default.
final class _Observability implements Observability {
  const _Observability();

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async {}
}
