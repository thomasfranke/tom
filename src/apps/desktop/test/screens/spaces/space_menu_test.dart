import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/screens/spaces/space_menu_control_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  late _Recents recents;
  late _Spaces spaces;
  late _Documents documents;
  late ProviderContainer container;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );
  final SpaceEntity handbook = SpaceEntity(
    root: '/code/acme/handbook',
    repositoryRoot: '/code/acme',
    name: 'handbook',
  );
  final SpaceRelativePathValueObject note = SpaceRelativePathValueObject(
    'note.md',
  );
  final RecentSpaceEntity here = RecentSpaceEntity(
    root: '/code/app/docs',
    name: 'docs',
    lastOpened: DateTime.utc(2026, 9, 21),
  );
  final RecentSpaceEntity elsewhere = RecentSpaceEntity(
    root: '/code/acme/handbook',
    name: 'handbook',
    lastOpened: DateTime.utc(2026, 9, 20),
  );

  setUp(() {
    recents = _Recents();
    spaces = _Spaces();
    documents = _Documents();
    const _Silent silent = _Silent();
    container = ProviderContainer(
      overrides: <Override>[
        listRecentSpacesProvider.overrideWithValue(
          ListRecentSpacesUseCase(recents: recents, observability: silent),
        ),
        openSpaceProvider.overrideWithValue(
          OpenSpaceUseCase(
            spaces: spaces,
            recents: recents,
            observability: silent,
          ),
        ),
        // Leaving asks about the buffer, so the editor is wired even here.
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

  /// Mounts the breadcrumb with [docs] open, and a document when asked.
  Future<void> pumpControl(
    WidgetTester tester, {
    bool withDocument = false,
  }) async {
    tester.view
      ..physicalSize = const Size(1280, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    container
      ..listen<EditorState>(editorProvider, (_, _) {})
      ..read(spaceSessionProvider.notifier).open(docs);
    if (withDocument) {
      container.read(spaceSessionProvider.notifier).show(note);
    }
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(Brightness.dark),
          home: const Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SpaceMenuControlWidget(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Opens the menu by clicking the breadcrumb.
  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(find.byType(SpaceMenuControlWidget));
    await tester.pumpAndSettle();
  }

  testWidgets('the bar names the repository and the folder, in that order', (
    WidgetTester tester,
  ) async {
    // A space is a folder and three checkouts all have a `docs/`
    // (`docs/product/workspace/leaving-a-space/doc.md`).
    await pumpControl(tester);

    expect(find.text('app'), findsOneWidget);
    expect(find.text('docs'), findsOneWidget);
    expect(
      tester.getCenter(find.text('app')).dx,
      lessThan(tester.getCenter(find.text('docs')).dx),
    );
  });

  testWidgets('nothing of the menu is on screen until it is opened', (
    WidgetTester tester,
  ) async {
    recents.stored = <RecentSpaceEntity>[here, elsewhere];

    await pumpControl(tester);

    expect(find.text('RECENT SPACES'), findsNothing);
    expect(find.text('Close space'), findsNothing);
  });

  testWidgets('opened, it lists the recents with the way out at its foot', (
    WidgetTester tester,
  ) async {
    recents.stored = <RecentSpaceEntity>[here, elsewhere];
    await pumpControl(tester);

    await openMenu(tester);

    expect(find.text('RECENT SPACES'), findsOneWidget);
    expect(find.text('handbook'), findsOneWidget);
    expect(find.text('Close space'), findsOneWidget);
  });

  testWidgets('the space already open is marked and does not answer', (
    WidgetTester tester,
  ) async {
    // A menu whose contents change with what is open moves under the pointer,
    // so it stays in the list and says which one it is.
    recents.stored = <RecentSpaceEntity>[here, elsewhere];
    await pumpControl(tester);
    await openMenu(tester);

    expect(find.text('✓'), findsOneWidget);

    await tester.tap(find.text('✓'));
    await tester.pumpAndSettle();

    expect(container.read(spaceSessionProvider)?.space, docs);
  });

  testWidgets('closing the space puts the window back on the opening screen', (
    WidgetTester tester,
  ) async {
    await pumpControl(tester);
    await openMenu(tester);

    await tester.tap(find.text('Close space'));
    await tester.pumpAndSettle();

    expect(container.read(spaceSessionProvider), isNull);
  });

  testWidgets('choosing another one goes there without a trip through Home', (
    WidgetTester tester,
  ) async {
    recents.stored = <RecentSpaceEntity>[here, elsewhere];
    spaces.answer = Success<SpaceEntity, AppFailure>(handbook);
    await pumpControl(tester);
    await openMenu(tester);

    await tester.tap(find.text('handbook'));
    await tester.pumpAndSettle();

    expect(container.read(spaceSessionProvider)?.space, handbook);
  });

  group('with an unsaved buffer', () {
    testWidgets('leaving asks first, and names the document at stake', (
      WidgetTester tester,
    ) async {
      await pumpControl(tester, withDocument: true);
      container.read(editorProvider.notifier).edit('changed');
      await tester.pumpAndSettle();
      await openMenu(tester);

      await tester.tap(find.text('Close space'));
      await tester.pumpAndSettle();

      expect(find.text('note.md has unsaved changes.'), findsOneWidget);
      expect(find.text('Save and close'), findsOneWidget);
      expect(find.text('Discard and close'), findsOneWidget);
      expect(find.text('Stay in this space'), findsOneWidget);
      expect(container.read(spaceSessionProvider), isNotNull);
    });

    testWidgets('staying is an answer, and the list comes back', (
      WidgetTester tester,
    ) async {
      await pumpControl(tester, withDocument: true);
      container.read(editorProvider.notifier).edit('changed');
      await tester.pumpAndSettle();
      await openMenu(tester);
      await tester.tap(find.text('Close space'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Stay in this space'));
      await tester.pumpAndSettle();

      expect(container.read(spaceSessionProvider), isNotNull);
      expect(find.text('Close space'), findsOneWidget);
    });

    testWidgets('and discarding leaves, with nothing written', (
      WidgetTester tester,
    ) async {
      await pumpControl(tester, withDocument: true);
      container.read(editorProvider.notifier).edit('changed');
      await tester.pumpAndSettle();
      await openMenu(tester);
      await tester.tap(find.text('Close space'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Discard and close'));
      await tester.pumpAndSettle();

      expect(container.read(spaceSessionProvider), isNull);
      expect(documents.written, isEmpty);
    });
  });
}

/// A recent list held in memory.
final class _Recents implements RecentSpacesRepository {
  List<RecentSpaceEntity> stored = <RecentSpaceEntity>[];

  @override
  Future<Result<List<RecentSpaceEntity>, Never>> list() async =>
      Success<List<RecentSpaceEntity>, Never>(stored);

  @override
  Future<Result<void, Never>> remember(SpaceEntity space) async =>
      const Success<void, Never>(null);

  @override
  Future<Result<void, Never>> forget(String root) async =>
      const Success<void, Never>(null);
}

/// The spaces a folder opens into.
final class _Spaces implements SpaceRepository {
  Result<SpaceEntity, AppFailure> answer =
      const Failure<SpaceEntity, AppFailure>(GitNotARepository('/unset'));

  @override
  Future<Result<SpaceEntity, AppFailure>> open(String folder) async => answer;

  @override
  Future<Result<List<SpaceEntryValueObject>, SpaceFailure>> entries(
    SpaceEntity space,
  ) async => const Success<List<SpaceEntryValueObject>, SpaceFailure>(
    <SpaceEntryValueObject>[],
  );
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
