import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/preferences/preferences_control_widget.dart';
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

  /// Mounts the breadcrumb with [docs] open, and a document when asked —
  /// with the preferences gear beside it when [withGear], the way the top
  /// bar's two ends sit.
  Future<void> pumpControl(
    WidgetTester tester, {
    bool withDocument = false,
    bool withGear = false,
    Locale? locale,
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
          locale: locale,
          localizationsDelegates: locale == null
              ? null
              : AppLocalizations.localizationsDelegates,
          supportedLocales: locale == null
              ? const <Locale>[Locale('en', 'US')]
              : AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: withGear
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SpaceMenuControlWidget(),
                        PreferencesControlWidget(),
                      ],
                    )
                  : const SpaceMenuControlWidget(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Opens the menu by clicking the breadcrumb — its chevron, which is the
  /// part that says it opens something.
  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(find.byType(TomChevronWidget));
    await tester.pumpAndSettle();
  }

  /// Presses the home button before the breadcrumb.
  Future<void> pressHome(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Close space'));
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
    // The way out is on the bar itself, menu or no menu.
    expect(find.byTooltip('Close space'), findsOneWidget);
  });

  testWidgets('opened, it lists the recents and nothing else', (
    WidgetTester tester,
  ) async {
    recents.stored = <RecentSpaceEntity>[here, elsewhere];
    await pumpControl(tester);

    await openMenu(tester);

    expect(find.text('RECENT SPACES'), findsOneWidget);
    expect(find.text('handbook'), findsOneWidget);
    expect(find.text('Close space'), findsNothing);
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

  testWidgets('the home button puts the window back on the opening screen', (
    WidgetTester tester,
  ) async {
    // One press, no menu: leaving is the thing nobody chooses among spaces
    // for.
    await pumpControl(tester);

    await pressHome(tester);

    expect(container.read(spaceSessionProvider), isNull);
    expect(find.text('RECENT SPACES'), findsNothing);
  });

  testWidgets('the home button is drawn like the gear: outlined, same ink', (
    WidgetTester tester,
  ) async {
    // The bar's two ends read as one set on the 1b boards: the same Solid
    // glyphs stroked, in `text_secondary`, about 16 wide each.
    await pumpControl(tester, withGear: true);

    TomGlyphWidget glyph(TomGlyphEnum which) => tester.widget<TomGlyphWidget>(
      find.byWidgetPredicate(
        (Widget widget) => widget is TomGlyphWidget && widget.glyph == which,
      ),
    );
    final TomGlyphWidget house = glyph(TomGlyphEnum.home);
    final TomGlyphWidget gear = glyph(TomGlyphEnum.preferences);
    final Color secondary = TomColors.dark.textSecondary;

    expect(house.outline, isTrue);
    expect(gear.outline, isTrue);
    expect(house.color, secondary);
    expect(gear.color, secondary);
    // Font Awesome's house is 576 units wide and the gear 512 on a 512 em,
    // so a smaller house is the gear's width.
    expect(house.size * 576 / 512, closeTo(gear.size, 0.5));
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

  testWidgets('one that has moved is named under the rows, in words', (
    WidgetTester tester,
  ) async {
    recents.stored = <RecentSpaceEntity>[here, elsewhere];
    spaces.answer = const Failure<SpaceEntity, AppFailure>(
      SpaceFolderMissing('/code/acme/handbook'),
    );
    await pumpControl(tester);
    await openMenu(tester);

    await tester.tap(find.text('handbook'));
    await tester.pumpAndSettle();

    expect(
      find.text('handbook could not be opened — has it moved?'),
      findsOneWidget,
    );
    expect(container.read(spaceSessionProvider)?.space.name, isNot('handbook'));
  });

  group('with an unsaved buffer', () {
    testWidgets('leaving asks first, and names the document at stake', (
      WidgetTester tester,
    ) async {
      // Pressed with the menu closed: the question is the menu's, so the
      // question opens it.
      await pumpControl(tester, withDocument: true);
      container.read(editorProvider.notifier).edit('changed');
      await tester.pumpAndSettle();

      await pressHome(tester);

      expect(find.text('note.md has unsaved changes.'), findsOneWidget);
      expect(find.text('Save and close'), findsOneWidget);
      expect(find.text('Discard and close'), findsOneWidget);
      expect(find.text('Stay in this space'), findsOneWidget);
      expect(container.read(spaceSessionProvider), isNotNull);
    });

    testWidgets('staying is an answer, and takes the question away', (
      WidgetTester tester,
    ) async {
      // Even with the menu open: the home button is outside it, so the press
      // that asks also puts the list away, and stay leaves nothing on screen.
      recents.stored = <RecentSpaceEntity>[here, elsewhere];
      await pumpControl(tester, withDocument: true);
      container.read(editorProvider.notifier).edit('changed');
      await tester.pumpAndSettle();
      await openMenu(tester);
      await pressHome(tester);
      expect(find.text('Stay in this space'), findsOneWidget);

      await tester.tap(find.text('Stay in this space'));
      await tester.pumpAndSettle();

      expect(container.read(spaceSessionProvider), isNotNull);
      expect(find.text('Stay in this space'), findsNothing);
      expect(find.text('RECENT SPACES'), findsNothing);
    });

    testWidgets('staying on a menu nobody opened closes it again', (
      WidgetTester tester,
    ) async {
      await pumpControl(tester, withDocument: true);
      container.read(editorProvider.notifier).edit('changed');
      await tester.pumpAndSettle();
      await pressHome(tester);

      await tester.tap(find.text('Stay in this space'));
      await tester.pumpAndSettle();

      expect(container.read(spaceSessionProvider), isNotNull);
      expect(find.text('RECENT SPACES'), findsNothing);
      expect(find.text('Stay in this space'), findsNothing);
    });

    testWidgets('and discarding leaves, with nothing written', (
      WidgetTester tester,
    ) async {
      await pumpControl(tester, withDocument: true);
      container.read(editorProvider.notifier).edit('changed');
      await tester.pumpAndSettle();
      await pressHome(tester);

      await tester.tap(find.text('Discard and close'));
      await tester.pumpAndSettle();

      expect(container.read(spaceSessionProvider), isNull);
      expect(documents.written, isEmpty);
    });

    /// Leaves two documents unsaved: [note] held in its tab, `other.md` on
    /// screen.
    Future<void> editTwo(WidgetTester tester) async {
      container.read(editorProvider.notifier).edit('changed');
      await tester.pumpAndSettle();
      container
          .read(spaceSessionProvider.notifier)
          .show(SpaceRelativePathValueObject('other.md'));
      await tester.pumpAndSettle();
      container.read(editorProvider.notifier).edit('changed too');
      await tester.pumpAndSettle();
      expect(container.read(unsavedDocumentsProvider), hasLength(2));
    }

    testWidgets('several unsaved are counted, and the answers say all', (
      WidgetTester tester,
    ) async {
      await pumpControl(tester, withDocument: true);
      await editTwo(tester);

      await pressHome(tester);

      expect(find.text('2 documents have unsaved changes.'), findsOneWidget);
      expect(find.textContaining('note.md'), findsNothing);
      expect(find.text('Save all and close'), findsOneWidget);
      expect(find.text('Discard all and close'), findsOneWidget);
      expect(find.text('Stay in this space'), findsOneWidget);
    });

    testWidgets('going to another space says all too', (
      WidgetTester tester,
    ) async {
      recents.stored = <RecentSpaceEntity>[here, elsewhere];
      await pumpControl(tester, withDocument: true);
      await editTwo(tester);
      await openMenu(tester);

      await tester.tap(find.text('handbook'));
      await tester.pumpAndSettle();

      expect(find.text('2 documents have unsaved changes.'), findsOneWidget);
      expect(find.text('Save all and open'), findsOneWidget);
      expect(find.text('Discard all and open'), findsOneWidget);
    });

    testWidgets('in Portuguese, one is named and several are counted', (
      WidgetTester tester,
    ) async {
      await pumpControl(tester, withDocument: true, locale: const Locale('pt'));
      container.read(editorProvider.notifier).edit('changed');
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Fechar espaço'));
      await tester.pumpAndSettle();

      expect(find.text('note.md tem alterações não salvas.'), findsOneWidget);
      expect(find.text('Salvar e fechar'), findsOneWidget);

      await tester.tap(find.text('Ficar neste espaço'));
      await tester.pumpAndSettle();
      container
          .read(spaceSessionProvider.notifier)
          .show(SpaceRelativePathValueObject('other.md'));
      await tester.pumpAndSettle();
      container.read(editorProvider.notifier).edit('changed too');
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Fechar espaço'));
      await tester.pumpAndSettle();

      expect(
        find.text('2 documentos têm alterações não salvas.'),
        findsOneWidget,
      );
      expect(find.text('Salvar todos e fechar'), findsOneWidget);
      expect(find.text('Descartar todos e fechar'), findsOneWidget);
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
  Future<Result<void, SpaceFailure>> createFolder(
    SpaceEntity space,
    SpaceRelativePathValueObject path,
  ) async => throw UnimplementedError();

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
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Result<void, DocumentFailure>> create(DocumentEntity document) async =>
      throw UnimplementedError();

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
