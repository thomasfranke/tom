import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/screens/home/home_screen.dart';
import 'package:tom_desktop/theme/tom_theme.dart';
import 'package:tom_desktop/widgets/tom_wordmark.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  late _Spaces spaces;
  late _Recents recents;

  final RecentSpace remembered = RecentSpace(
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
            OpenSpace(
              spaces: spaces,
              recents: recents,
              observability: observability,
            ),
          ),
          listRecentSpacesProvider.overrideWithValue(
            ListRecentSpaces(recents: recents, observability: observability),
          ),
          forgetRecentSpaceProvider.overrideWithValue(
            ForgetRecentSpace(recents: recents, observability: observability),
          ),
        ],
        child: MaterialApp(
          theme: tomTheme(Brightness.light),
          home: const HomeScreen(),
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

      // The wordmark, not the name set in type: the O is the commit on the
      // trunk, and a `Text('TOM')` here would pass while the screen showed
      // the wrong mark (`docs/technical/design/brand.md`, rule 1).
      expect(find.byType(TomWordmark), findsOneWidget);
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
      // Shown rather than hidden: the wireframe puts it here, and a button
      // that appears later moves everything under it.
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
    setUp(() => recents.stored = <RecentSpace>[remembered]);

    testWidgets('each one is offered by name and by path', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);

      expect(find.text('RECENT'), findsOneWidget);
      expect(find.text('docs'), findsOneWidget);
      expect(find.text('/code/app/docs'), findsOneWidget);
    });

    testWidgets('clicking one opens it', (WidgetTester tester) async {
      spaces.answer = Success<Space>(
        Space(
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
      // Driven through the notifier rather than the picker: a native file
      // dialog cannot be opened in a widget test, and what is being tested
      // is the screen, not the plugin.
      spaces.answer = const Failure<Space>(
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
      spaces.answer = const Failure<Space>(SpaceFolderMissing('/gone'));
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
      // Both mocks draw this screen with the retry and the one line about
      // repositories, and nothing else
      // (`docs/product/home/mocks/not-a-repository.excalidraw`). It is a
      // state to move on from in one click, and a second list of choices
      // under the button would make the button look optional.
      recents.stored = <RecentSpace>[remembered];
      spaces.answer = const Failure<Space>(GitNotARepository('/loose'));
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
  Result<Space> answer = const Failure<Space>(GitNotARepository('/unset'));
  String? asked;

  @override
  Future<Result<Space>> open(String folder) async {
    asked = folder;
    return answer;
  }

  @override
  Future<Result<List<SpaceEntry>>> entries(Space space) async =>
      throw UnimplementedError();
}

/// A recent list held in memory.
final class _Recents implements RecentSpacesRepository {
  List<RecentSpace> stored = <RecentSpace>[];
  final List<String> forgotten = <String>[];

  @override
  Future<Result<List<RecentSpace>>> list() async =>
      Success<List<RecentSpace>>(stored);

  @override
  Future<Result<void>> remember(Space space) async => const Success<void>(null);

  @override
  Future<Result<void>> forget(String root) async {
    forgotten.add(root);
    stored = stored.where((RecentSpace recent) => recent.root != root).toList();
    return const Success<void>(null);
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
