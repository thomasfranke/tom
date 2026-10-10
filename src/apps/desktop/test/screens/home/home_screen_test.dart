import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/screens/home/folder_picker.dart';
import 'package:tom_desktop/screens/home/home_screen.dart';
import 'package:tom_desktop/screens/home/widgets/home_clone_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// What the clone field says before anything is pressed.
const String cloneHint =
    'Paste the address. You choose the folder next, and it opens as a space.';

/// No account read: the button has tests of its own, and reading one runs
/// `gh`, git and `ssh`.
final class _NoAccount extends AccountNotifier {
  @override
  AccountState build() => const AccountState();
}

void main() {
  late _Spaces spaces;
  late _Recents recents;
  late _Cloner cloner;
  late List<String?> pickerAnswers;

  final RecentSpaceEntity remembered = RecentSpaceEntity(
    root: '/code/app/docs',
    name: 'docs',
    lastOpened: DateTime.utc(2026, 9, 20),
  );

  setUp(() {
    spaces = _Spaces();
    recents = _Recents();
    cloner = _Cloner();
    pickerAnswers = <String?>['/work'];
  });

  /// Mounts Home with the repositories these tests arranged.
  Future<void> pumpHome(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(1280, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    const _Observability observability = _Observability();
    final OpenSpaceUseCase openSpace = OpenSpaceUseCase(
      spaces: spaces,
      recents: recents,
      observability: observability,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          accountProvider.overrideWith(_NoAccount.new),
          openSpaceProvider.overrideWithValue(openSpace),
          cloneRepositoryProvider.overrideWithValue(
            CloneRepositoryUseCase(
              cloner: cloner,
              openSpace: openSpace,
              observability: observability,
            ),
          ),
          folderPickerProvider.overrideWithValue(
            () async => pickerAnswers.removeAt(0),
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

    testWidgets('cloning is offered, with no milestone beside it', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);

      final OutlinedButton clone = tester.widget<OutlinedButton>(
        find.ancestor(
          of: find.text('Clone from URL'),
          matching: find.byType(OutlinedButton),
        ),
      );
      expect(clone.onPressed, isNotNull);
      expect(find.byType(MilestoneChipWidget), findsNothing);
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

  group('cloning by URL', () {
    const String address = 'https://github.com/acme/handbook.git';

    Finder field() => find.descendant(
      of: find.byType(HomeCloneWidget),
      matching: find.byType(TextField),
    );

    /// The outline the field is drawn with.
    BorderSide outline(WidgetTester tester) =>
        ((tester
                            .widget<DecoratedBox>(
                              find
                                  .descendant(
                                    of: find.byType(HomeCloneWidget),
                                    matching: find.byType(DecoratedBox),
                                  )
                                  .first,
                            )
                            .decoration
                        as BoxDecoration)
                    .border!
                as Border)
            .top;

    Future<void> openTheField(WidgetTester tester) async {
      await tester.tap(find.text('Clone from URL'));
      await tester.pumpAndSettle();
    }

    testWidgets('the button turns into the field, the hint under it', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);

      await openTheField(tester);

      expect(find.text('Clone from URL'), findsNothing);
      expect(field(), findsOneWidget);
      expect(find.text('Clone'), findsOneWidget);
      expect(find.text(cloneHint), findsOneWidget);
      // The keyboard is already in it, so the outline is the accent's.
      expect(outline(tester).color, TomColors.light.accent);
      expect(outline(tester).width, 1.5);
    });

    testWidgets('and Escape puts the button back', (WidgetTester tester) async {
      await pumpHome(tester);
      await openTheField(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.text('Clone from URL'), findsOneWidget);
      expect(field(), findsNothing);
    });

    testWidgets('the recent list does not move when the field opens', (
      WidgetTester tester,
    ) async {
      recents.stored = <RecentSpaceEntity>[remembered];
      await pumpHome(tester);
      final double before = tester.getTopLeft(find.text('RECENT')).dy;

      await openTheField(tester);

      expect(tester.getTopLeft(find.text('RECENT')).dy, before);
    });

    testWidgets('Enter asks for the folder, then clones into it', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);
      await openTheField(tester);

      await tester.enterText(field(), address);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(cloner.asked.single, (
        url: address,
        destination: '/work/handbook',
      ));
    });

    testWidgets('a folder dialog closed without a choice clones nothing', (
      WidgetTester tester,
    ) async {
      pickerAnswers = <String?>[null];
      await pumpHome(tester);
      await openTheField(tester);

      await tester.enterText(field(), address);
      await tester.tap(find.text('Clone'));
      await tester.pumpAndSettle();

      expect(cloner.asked, isEmpty);
      expect(find.text(cloneHint), findsOneWidget);
    });

    testWidgets("while git works the bar and git's phase are under it", (
      WidgetTester tester,
    ) async {
      cloner
        ..gate = Completer<void>()
        ..reports = const <CloneProgressValueObject>[
          CloneProgressValueObject(
            stage: CloneStageEnum.receiving,
            percent: 42,
          ),
        ];
      await pumpHome(tester);
      await openTheField(tester);

      await tester.enterText(field(), address);
      await tester.tap(find.text('Clone'));
      await tester.pumpAndSettle();

      final FilledButton cloning = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('Cloning…'),
          matching: find.byType(FilledButton),
        ),
      );
      expect(cloning.onPressed, isNull);
      expect(field(), findsNothing);
      expect(find.text(address), findsOneWidget);
      expect(
        find.text('Receiving objects · 42%  —  into /work/handbook'),
        findsOneWidget,
      );
      expect(outline(tester).color, TomColors.light.border);
      cloner.gate!.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('a clone that worked opens the space', (
      WidgetTester tester,
    ) async {
      final SpaceEntity handbook = SpaceEntity(
        root: '/work/handbook',
        repositoryRoot: '/work/handbook',
        name: 'handbook',
      );
      spaces.answer = Success<SpaceEntity, AppFailure>(handbook);
      await pumpHome(tester);
      await openTheField(tester);

      await tester.enterText(field(), address);
      await tester.tap(find.text('Clone'));
      // Pumped, not settled: this test mounts Home alone, so nothing takes
      // its place and the bar of a clone with no fraction keeps travelling.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final ProviderContainer container = ProviderScope.containerOf(
        tester.element(find.byType(HomeScreen)),
      );
      expect(container.read(spaceSessionProvider)?.space, handbook);
      expect(spaces.asked, '/work/handbook');
    });

    for (final (GitFailure failure, String sentence) in <(GitFailure, String)>[
      (const GitRemoteNotFound(), 'There is no repository at that address.'),
      (
        const GitAuthenticationFailed(),
        'Git refused the credentials for github.com. Sign in with your own '
            'git, then try again.',
      ),
      (
        const GitNetworkUnavailable(),
        'No network — the address could not be reached.',
      ),
      (
        const GitCloneDestinationTaken('/work/handbook'),
        '/work/handbook already exists — choose another folder.',
      ),
    ]) {
      testWidgets('${failure.runtimeType} says so under the field', (
        WidgetTester tester,
      ) async {
        cloner.answer = Failure<void, GitFailure>(failure);
        await pumpHome(tester);
        await openTheField(tester);

        await tester.enterText(field(), address);
        await tester.tap(find.text('Clone'));
        await tester.pumpAndSettle();

        expect(find.text(sentence), findsOneWidget);
        // The address is kept and `Clone` is live again: one press retries.
        expect(find.text(address), findsOneWidget);
        expect(
          tester
              .widget<FilledButton>(
                find.ancestor(
                  of: find.text('Clone'),
                  matching: find.byType(FilledButton),
                ),
              )
              .onPressed,
          isNotNull,
        );
        expect(outline(tester).color, TomColors.light.removed);
        expect(outline(tester).width, 1.5);
      });
    }
  });

  group('when the folder does not open', () {
    testWidgets('a folder with no repository is not refused: it opens', (
      WidgetTester tester,
    ) async {
      // Through the notifier, since a native file dialog cannot be opened in
      // a widget test (`docs/product/workspace/without-a-repository/doc.md`).
      spaces.answer = Success<SpaceEntity, AppFailure>(
        SpaceEntity(
          root: '/Users/me/notes',
          repositoryRoot: null,
          name: 'notes',
        ),
      );
      await pumpHome(tester);

      final ProviderContainer container = ProviderScope.containerOf(
        tester.element(find.byType(HomeScreen)),
      );
      await container.read(homeProvider.notifier).open('/Users/me/notes');
      await tester.pumpAndSettle();

      expect(
        container.read(spaceSessionProvider)?.space.hasRepository,
        isFalse,
      );
      expect(find.text('Choose another folder…'), findsNothing);
    });

    testWidgets('a folder that is gone is named, with the way on', (
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
      expect(find.text('/gone'), findsOneWidget);
      expect(find.text('Choose another folder…'), findsOneWidget);
    });

    testWidgets('any other refusal is said in words, never as a failure', (
      WidgetTester tester,
    ) async {
      spaces.answer = const Failure<SpaceEntity, AppFailure>(
        GitOperationFailed(),
      );
      await pumpHome(tester);

      final ProviderContainer container = ProviderScope.containerOf(
        tester.element(find.byType(HomeScreen)),
      );
      await container.read(homeProvider.notifier).open('/odd');
      await tester.pumpAndSettle();

      expect(find.text('That folder could not be opened'), findsOneWidget);
      expect(
        find.text(
          'Git or the disk refused it without saying why. Try it again, or '
          'choose another folder.',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('GitFailure'), findsNothing);
    });

    testWidgets('and the recent list is not offered underneath it', (
      WidgetTester tester,
    ) async {
      // A second list of choices under the button would make the button
      // look optional.
      recents.stored = <RecentSpaceEntity>[remembered];
      spaces.answer = const Failure<SpaceEntity, AppFailure>(
        SpaceFolderMissing('/gone'),
      );
      await pumpHome(tester);

      final ProviderContainer container = ProviderScope.containerOf(
        tester.element(find.byType(HomeScreen)),
      );
      await container.read(homeProvider.notifier).open('/gone');
      await tester.pumpAndSettle();

      expect(find.text('RECENT'), findsNothing);
      expect(find.text('docs'), findsNothing);
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
  String? asked;

  @override
  Future<Result<void, SpaceFailure>> createFolder(
    SpaceEntity space,
    SpaceRelativePathValueObject path,
  ) async => throw UnimplementedError();

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
