import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/screens/home/home_screen.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  late _Spaces spaces;
  late _Recents recents;

  final RecentSpaceEntity remembered = RecentSpaceEntity(
    root: '/code/app/docs',
    name: 'docs',
    lastOpened: DateTime.utc(2026, 9, 20),
  );

  setUp(() {
    spaces = _Spaces();
    recents = _Recents();
  });

  /// Mounts Home with the repositories these tests arranged.
  Future<void> pumpHome(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(1280, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    const _Observability observability = _Observability();
    await tester.pumpWidget(
      ProviderScope(
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
        child: MaterialApp(
          theme: tomTheme(Brightness.light),
          // The trunk never stops moving, so `pumpAndSettle` never would;
          // the motion is `commit_trunk_test.dart`'s.
          home: const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: HomeScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('with nothing open', () {
    testWidgets('it offers the brand and the ways in', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);

      // The wordmark, never the name set in type (brand.md, rule 1).
      expect(find.byType(TomWordmarkWidget), findsOneWidget);
      expect(
        find.text('A Git client built for documentation, not code.'),
        findsOneWidget,
      );
      expect(find.text('Choose folder…'), findsOneWidget);
      expect(find.text('no space open'), findsOneWidget);
    });

    testWidgets('cloning is shown, and disabled until M3', (
      WidgetTester tester,
    ) async {
      // Shown rather than hidden: a button that appears later moves
      // everything under it.
      await pumpHome(tester);

      final OutlinedButton clone = tester.widget<OutlinedButton>(
        find.ancestor(
          of: find.text('Clone from URL'),
          matching: find.byType(OutlinedButton),
        ),
      );
      expect(clone.onPressed, isNull);
    });

    testWidgets('the first run shows no recent list at all', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);

      expect(find.text('RECENT'), findsNothing);
    });
  });

  group('with spaces to go back to', () {
    setUp(() => recents.stored = <RecentSpaceEntity>[remembered]);

    testWidgets('each one is offered by name and by path', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);

      expect(find.text('RECENT'), findsOneWidget);
      expect(find.text('docs'), findsOneWidget);
      expect(find.text('/code/app/docs'), findsOneWidget);
    });

    testWidgets('clicking one opens it', (WidgetTester tester) async {
      spaces.answer = Success<SpaceEntity, AppFailure>(
        SpaceEntity(
          root: '/code/app/docs',
          repositoryRoot: '/code/app',
          name: 'docs',
        ),
      );
      await pumpHome(tester);

      await tester.tap(find.text('docs'));
      await tester.pumpAndSettle();

      expect(spaces.asked, '/code/app/docs');
    });

    testWidgets('and one can be forgotten without touching the folder', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);

      await tester.tap(find.byTooltip('Forget this space'));
      await tester.pumpAndSettle();

      expect(recents.forgotten, <String>['/code/app/docs']);
      expect(find.text('RECENT'), findsNothing);
    });
  });

  group('when the folder is not a repository', () {
    testWidgets('the refusal screen says what it says', (
      WidgetTester tester,
    ) async {
      // Through the notifier, since a native file dialog cannot be opened in
      // a widget test.
      spaces.answer = const Failure<SpaceEntity, AppFailure>(
        GitNotARepository('/Users/me/notes'),
      );
      await pumpHome(tester);

      final ProviderContainer container = ProviderScope.containerOf(
        tester.element(find.byType(HomeScreen)),
      );
      await container.read(homeProvider.notifier).open('/Users/me/notes');
      await tester.pumpAndSettle();

      expect(
        find.text('That folder is not inside a Git repository'),
        findsOneWidget,
      );
      expect(find.text('/Users/me/notes'), findsOneWidget);
      expect(
        find.text('Creating a repository is not something TOM does.'),
        findsOneWidget,
      );
      expect(find.text('Choose another folder…'), findsOneWidget);
    });

    testWidgets('a folder that is gone says something else', (
      WidgetTester tester,
    ) async {
      spaces.answer = const Failure<SpaceEntity, AppFailure>(
        SpaceFolderMissing('/gone'),
      );
      await pumpHome(tester);

      final ProviderContainer container = ProviderScope.containerOf(
        tester.element(find.byType(HomeScreen)),
      );
      await container.read(homeProvider.notifier).open('/gone');
      await tester.pumpAndSettle();

      expect(find.text('That folder is no longer there'), findsOneWidget);
    });

    testWidgets('and the recent list is not offered underneath it', (
      WidgetTester tester,
    ) async {
      // A second list of choices under the button would make the button
      // look optional (`design/screens/desktop/home/not-a-repository-light.svg`).
      recents.stored = <RecentSpaceEntity>[remembered];
      spaces.answer = const Failure<SpaceEntity, AppFailure>(
        GitNotARepository('/loose'),
      );
      await pumpHome(tester);

      final ProviderContainer container = ProviderScope.containerOf(
        tester.element(find.byType(HomeScreen)),
      );
      await container.read(homeProvider.notifier).open('/loose');
      await tester.pumpAndSettle();

      expect(find.text('RECENT'), findsNothing);
      expect(find.text('docs'), findsNothing);
    });
  });
}

/// A space repository that answers what it was told to.
final class _Spaces implements SpaceRepository {
  Result<SpaceEntity, AppFailure> answer =
      const Failure<SpaceEntity, AppFailure>(GitNotARepository('/unset'));
  String? asked;

  @override
  Future<Result<SpaceEntity, AppFailure>> open(String folder) async {
    asked = folder;
    return answer;
  }

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
