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

  final Space opened = Space(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );

  final RecentSpace remembered = RecentSpace(
    root: '/code/app/docs',
    name: 'docs',
    lastOpened: DateTime.utc(2026, 9, 20),
  );

  setUp(() {
    spaces = _Spaces();
    recents = _Recents();
    const _Observability observability = _Observability();
    container = ProviderContainer(
      // Exactly what the composition root does, which is what makes this a
      // test of the notifier rather than of the wiring.
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

  /// Starts Home, and answers its first state.
  ///
  /// Listening is what starts it, and it is done here rather than in
  /// `setUp` so a test can arrange what the repositories hold first: a
  /// provider nobody listens to is disposed as soon as it is read, and the
  /// first thing this notifier does happens in a microtask after that.
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
      // Home *is* the list; a screen offering to load its own content would
      // be asking the user to do the app's work. So the very first state is
      // already "reading it", before anyone has pressed anything.
      expect(start(), isA<HomeLoading>());
    });

    test('and settles on what was remembered', () async {
      recents.stored = <RecentSpace>[remembered];

      expect((await settled() as HomeReady).recents, <RecentSpace>[remembered]);
    });

    test('an empty list is a state, not an error', () async {
      // The first run.
      expect((await settled() as HomeReady).recents, isEmpty);
    });
  });

  group('opening a folder', () {
    test('a space that opened is written to the session', () async {
      // Not to Home's own state: which space is open is what the whole
      // window is built on, so it lives in one place (Decision 9). Home
      // stays on `loading` and goes away with it.
      await settled();
      spaces.answer = Success<Space, AppFailure>(opened);

      await notifier().open('/code/app/docs');

      expect(container.read(spaceSessionProvider)?.space, opened);
      expect(container.read(homeProvider), isA<HomeLoading>());
    });

    test('and no document is showing yet', () async {
      // The file tree is on screen and nothing has been clicked.
      await settled();
      spaces.answer = Success<Space, AppFailure>(opened);

      await notifier().open('/code/app/docs');

      expect(container.read(spaceSessionProvider)?.openDocument, isNull);
    });

    test('a folder outside a repository keeps the failure itself', () async {
      // Not a message: Home shows this one as its own screen with its own
      // explanation, and a string would have thrown away which failure it
      // was (docs/product/home/doc.md).
      await settled();
      spaces.answer = const Failure<Space, AppFailure>(
        GitNotARepository('/loose'),
      );

      await notifier().open('/loose');

      final HomeFailed state = container.read(homeProvider) as HomeFailed;
      expect(state.failure, const GitNotARepository('/loose'));
    });

    test('and the recent list is still offered beside it', () async {
      // Whatever went wrong with one folder, the others are still there to
      // click.
      recents.stored = <RecentSpace>[remembered];
      await settled();
      spaces.answer = const Failure<Space, AppFailure>(
        GitNotARepository('/loose'),
      );

      await notifier().open('/loose');

      expect(
        (container.read(homeProvider) as HomeFailed).recents,
        <RecentSpace>[remembered],
      );
    });

    test('a folder that is gone is a different failure', () async {
      await settled();
      spaces.answer = const Failure<Space, AppFailure>(
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
      recents.stored = <RecentSpace>[remembered];
      await settled();

      await notifier().forget('/code/app/docs');

      expect(recents.forgotten, <String>['/code/app/docs']);
      expect((container.read(homeProvider) as HomeReady).recents, isEmpty);
    });
  });
}

/// A space repository that answers what it was told to.
final class _Spaces implements SpaceRepository {
  Result<Space, AppFailure> answer = const Failure<Space, AppFailure>(
    GitNotARepository('/unset'),
  );

  @override
  Future<Result<Space, AppFailure>> open(String folder) async => answer;

  @override
  Future<Result<List<SpaceEntry>, SpaceFailure>> entries(Space space) async =>
      throw UnimplementedError();
}

/// A recent list held in memory.
final class _Recents implements RecentSpacesRepository {
  List<RecentSpace> stored = <RecentSpace>[];
  final List<String> forgotten = <String>[];

  @override
  Future<Result<List<RecentSpace>, Never>> list() async =>
      Success<List<RecentSpace>, Never>(stored);

  @override
  Future<Result<void, Never>> remember(Space space) async =>
      const Success<void, Never>(null);

  @override
  Future<Result<void, Never>> forget(String root) async {
    forgotten.add(root);
    stored = stored.where((RecentSpace recent) => recent.root != root).toList();
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
