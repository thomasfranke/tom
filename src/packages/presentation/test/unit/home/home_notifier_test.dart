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
    const _Observability observability = _Observability();
    container = ProviderContainer(
      overrides: <Override>[
        openSpaceProvider.overrideWithValue(
          OpenSpaceUseCase(
            spaces: spaces,
            recents: recents,
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

/// A space repository that answers what it was told to.
final class _Spaces implements SpaceRepository {
  Result<SpaceEntity, AppFailure> answer =
      const Failure<SpaceEntity, AppFailure>(GitNotARepository('/unset'));

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

  @override
  Future<Result<void, Never>> remember(SpaceEntity space) async =>
      const Success<void, Never>(null);

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
