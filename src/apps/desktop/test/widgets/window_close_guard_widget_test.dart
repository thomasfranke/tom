/// The window being closed, and the app being quit, over unsaved work.
library;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/spaces/space_menu_control_widget.dart';
import 'package:tom_desktop/widgets/window_close_guard_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  late _Documents documents;
  late ProviderContainer container;

  /// How many times the window was closed for good.
  late int windowsClosed;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );
  final SpaceRelativePathValueObject note = SpaceRelativePathValueObject(
    'note.md',
  );

  setUp(() {
    documents = _Documents();
    windowsClosed = 0;
    const _Silent silent = _Silent();
    final _Recents recents = _Recents();
    container = ProviderContainer(
      overrides: <Override>[
        windowCloserProvider.overrideWithValue(() async => windowsClosed++),
        listRecentSpacesProvider.overrideWithValue(
          ListRecentSpacesUseCase(recents: recents, observability: silent),
        ),
        openSpaceProvider.overrideWithValue(
          OpenSpaceUseCase(
            spaces: const _Spaces(),
            recents: recents,
            observability: silent,
          ),
        ),
        readDocumentProvider.overrideWithValue(
          ReadDocumentUseCase(
            documentsFor: (SpaceEntity space) => documents,
            observability: silent,
          ),
        ),
        saveDocumentProvider.overrideWithValue(
          SaveDocumentUseCase(
            documentsFor: (SpaceEntity space) => documents,
            observability: silent,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  /// Mounts the guard around the breadcrumb, with [note] open — and typed
  /// into when [unsaved].
  Future<void> pumpGuarded(
    WidgetTester tester, {
    bool unsaved = false,
    Locale? locale,
  }) async {
    tester.view
      ..physicalSize = const Size(1280, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    container
      ..listen<EditorState>(editorProvider, (_, _) {})
      ..read(spaceSessionProvider.notifier).open(docs)
      ..read(spaceSessionProvider.notifier).show(note);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(Brightness.dark),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const WindowCloseGuardWidget(
            child: Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: SpaceMenuControlWidget(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    if (unsaved) {
      container.read(editorProvider.notifier).edit('changed');
      await tester.pumpAndSettle();
    }
  }

  /// The window's own close, as `window_manager` reports it.
  Future<void> closeTheWindow(WidgetTester tester) async {
    tester
        .state<WindowCloseGuardState>(find.byType(WindowCloseGuardWidget))
        .onWindowClose();
    await tester.pumpAndSettle();
  }

  group('the window is closed', () {
    testWidgets('with nothing unsaved it closes, and asks nothing', (
      WidgetTester tester,
    ) async {
      await pumpGuarded(tester);

      await closeTheWindow(tester);

      expect(windowsClosed, 1);
      expect(find.text('Stay in this space'), findsNothing);
    });

    testWidgets('with an unsaved document it stays open and asks the '
        'leaving question, in the window\'s words', (
      WidgetTester tester,
    ) async {
      await pumpGuarded(tester, unsaved: true);

      await closeTheWindow(tester);

      expect(windowsClosed, 0);
      expect(find.text('note.md has unsaved changes.'), findsOneWidget);
      expect(
        find.text(
          'Closing the window leaves TOM, and the edit that has not reached '
          'the disk goes with it.',
        ),
        findsOneWidget,
      );
      expect(find.text('Save and close'), findsOneWidget);
      expect(find.text('Discard and close'), findsOneWidget);
      expect(find.text('Stay in this space'), findsOneWidget);
    });

    testWidgets('Stay keeps the window, the space and the edit', (
      WidgetTester tester,
    ) async {
      await pumpGuarded(tester, unsaved: true);
      await closeTheWindow(tester);

      await tester.tap(find.text('Stay in this space'));
      await tester.pumpAndSettle();

      expect(windowsClosed, 0);
      expect(container.read(spaceSessionProvider), isNotNull);
      expect(container.read(editorProvider.notifier).hasUnsaved, isTrue);
      expect(find.text('Stay in this space'), findsNothing);
    });

    testWidgets('Save and close writes the edit, then closes', (
      WidgetTester tester,
    ) async {
      await pumpGuarded(tester, unsaved: true);
      await closeTheWindow(tester);

      await tester.tap(find.text('Save and close'));
      await tester.pumpAndSettle();

      expect(documents.written, <String>['changed']);
      expect(windowsClosed, 1);
    });

    testWidgets('Discard and close closes, with nothing written', (
      WidgetTester tester,
    ) async {
      await pumpGuarded(tester, unsaved: true);
      await closeTheWindow(tester);

      await tester.tap(find.text('Discard and close'));
      await tester.pumpAndSettle();

      expect(documents.written, isEmpty);
      expect(windowsClosed, 1);
    });

    testWidgets('it asks in Portuguese too', (WidgetTester tester) async {
      await pumpGuarded(tester, unsaved: true, locale: const Locale('pt'));

      await closeTheWindow(tester);

      expect(
        find.text(
          'Fechar a janela sai do TOM, e a edição que não chegou ao disco '
          'vai junto.',
        ),
        findsOneWidget,
      );
    });
  });

  group('the system asks the app to exit', () {
    testWidgets('with nothing unsaved it may', (WidgetTester tester) async {
      await pumpGuarded(tester);

      expect(await tester.binding.handleRequestAppExit(), AppExitResponse.exit);
      expect(windowsClosed, 0);
    });

    testWidgets('with an unsaved document it may not, and the question is '
        'on screen', (WidgetTester tester) async {
      await pumpGuarded(tester, unsaved: true);

      final AppExitResponse answer = await tester.binding
          .handleRequestAppExit();
      await tester.pumpAndSettle();

      expect(answer, AppExitResponse.cancel);
      expect(find.text('note.md has unsaved changes.'), findsOneWidget);
      expect(find.text('Stay in this space'), findsOneWidget);
    });

    testWidgets('after Discard and close it may: the question is not asked '
        'twice', (WidgetTester tester) async {
      await pumpGuarded(tester, unsaved: true);
      await tester.binding.handleRequestAppExit();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Discard and close'));
      await tester.pumpAndSettle();

      expect(windowsClosed, 1);
      expect(await tester.binding.handleRequestAppExit(), AppExitResponse.exit);
    });
  });
}

/// A recent list that is empty.
final class _Recents implements RecentSpacesRepository {
  @override
  Future<Result<List<RecentSpaceEntity>, Never>> list() async =>
      const Success<List<RecentSpaceEntity>, Never>(<RecentSpaceEntity>[]);

  @override
  Future<Result<void, Never>> remember(SpaceEntity space) async =>
      const Success<void, Never>(null);

  @override
  Future<Result<void, Never>> forget(String root) async =>
      const Success<void, Never>(null);
}

/// Spaces nobody opens here.
final class _Spaces implements SpaceRepository {
  const _Spaces();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// The one document these tests open, and what was written to it.
final class _Documents implements DocumentRepository {
  final List<String> written = <String>[];

  @override
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  ) async => Success<DocumentEntity, DocumentFailure>(
    DocumentEntity(path: path, content: 'on disk'),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Result<void, DocumentFailure>> write(DocumentEntity document) async {
    written.add(document.content);
    return const Success<void, DocumentFailure>(null);
  }
}

/// Observability that records nothing.
final class _Silent implements Observability {
  const _Silent();

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async {}
}
