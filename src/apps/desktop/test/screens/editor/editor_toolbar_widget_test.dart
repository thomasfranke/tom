import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/screens/editor/editor_history.dart';
import 'package:tom_desktop/screens/editor/editor_toolbar_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  late _Documents documents;
  late _Preferences preferences;
  late ProviderContainer container;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );
  final SpaceRelativePathValueObject writing = SpaceRelativePathValueObject(
    'guides/writing.md',
  );

  setUp(() {
    documents = _Documents();
    preferences = _Preferences();
    container = ProviderContainer(
      overrides: <Override>[
        readPreferencesProvider.overrideWithValue(
          ReadPreferencesUseCase(preferences: preferences),
        ),
        writePreferencesProvider.overrideWithValue(
          WritePreferencesUseCase(
            preferences: preferences,
            observability: const _Silent(),
          ),
        ),
        readDocumentProvider.overrideWithValue(
          ReadDocumentUseCase(
            documentsFor: (SpaceEntity space) => documents,
            observability: const _Silent(),
          ),
        ),
        saveDocumentProvider.overrideWithValue(
          SaveDocumentUseCase(
            documentsFor: (SpaceEntity space) => documents,
            observability: const _Silent(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  /// Mounts the bar, with a document open when [open].
  Future<void> pumpBar(
    WidgetTester tester, {
    bool open = true,
    EditorHistory? history,
  }) async {
    tester.view
      ..physicalSize = const Size(1600, 200)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    if (open) {
      container.read(spaceSessionProvider.notifier)
        ..open(docs)
        ..show(writing);
    }
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(Brightness.light),
          home: Scaffold(
            body: SizedBox(
              height: 36,
              child: history == null
                  ? const EditorToolbarWidget()
                  : EditorHistoryScope(
                      history: history,
                      child: const EditorToolbarWidget(),
                    ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// What the buffer holds now.
  String source() => (container.read(editorProvider) as EditorReady).source;

  /// Presses the button whose tooltip is [word].
  Future<void> press(WidgetTester tester, String word) async {
    await tester.tap(
      find.ancestor(
        of: find.byTooltip(word),
        matching: find.byType(TomToolbarButtonWidget),
      ).first,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('there is a button for everything the preview renders', (
    WidgetTester tester,
  ) async {
    documents.content = 'a word here\n';

    await pumpBar(tester);

    // Seventeen, because a button for four of the cases teaches that the
    // other cases are not supported
    // (`docs/product/editor/formatting-shortcuts/doc.md`).
    expect(find.byType(TomToolbarButtonWidget), findsNWidgets(17));
    // Five groups, so four rules between them.
    expect(
      EditorToolbarWidget.groups.map((List<ToolbarEntry> g) => g.length),
      <int>[2, 4, 4, 3, 4],
    );
  });

  testWidgets('bold writes the markdown into the source itself', (
    WidgetTester tester,
  ) async {
    documents.content = 'a word here\n';
    await pumpBar(tester);
    // The selection is the pane's; the bar reads it off the buffer.
    container.read(editorProvider.notifier).select(2, 6);

    await press(tester, 'Bold');

    // Literal syntax, never a hidden intermediate format.
    expect(source(), 'a **word** here\n');
  });

  testWidgets('a list marks the line the caret is on', (
    WidgetTester tester,
  ) async {
    documents.content = 'one\ntwo\n';
    await pumpBar(tester);
    container.read(editorProvider.notifier).select(5, 5);

    await press(tester, 'List');

    expect(source(), 'one\n- two\n');
  });

  testWidgets('a formatting press is an edit, so the document goes unsaved', (
    WidgetTester tester,
  ) async {
    documents.content = 'a word here\n';
    await pumpBar(tester);
    expect(container.read(editorProvider).isDirty, isFalse);

    await press(tester, 'Italic');

    // An edit, not a save: the file changes when somebody saves it.
    expect(container.read(editorProvider).isDirty, isTrue);
    expect(documents.written, isEmpty);
  });

  testWidgets('with no document open the buttons are dim, never absent', (
    WidgetTester tester,
  ) async {
    await pumpBar(tester, open: false);

    // A toolbar that reflows is harder to use than a dim button.
    expect(find.byType(TomToolbarButtonWidget), findsNWidgets(17));
    expect(
      tester
          .widgetList<TomToolbarButtonWidget>(
            find.byType(TomToolbarButtonWidget),
          )
          .every((TomToolbarButtonWidget button) => button.onPressed == null),
      isTrue,
    );
  });

  testWidgets('undo and redo answer to the history, not to the document', (
    WidgetTester tester,
  ) async {
    // They are the editor's own, reached through the context the pane leaves
    // in the scope: with no pane in the tree there is nothing to undo, and
    // the buttons say so by being dim rather than absent.
    documents.content = 'a word here\n';

    await pumpBar(tester);

    for (final String word in <String>['Undo', 'Redo']) {
      final TomToolbarButtonWidget button = tester.widget(
        find.ancestor(
          of: find.byTooltip(word),
          matching: find.byType(TomToolbarButtonWidget),
        ).first,
      );
      expect(button.onPressed, isNull);
    }
  });

  testWidgets('a history that is reachable lights them', (
    WidgetTester tester,
  ) async {
    documents.content = 'a word here\n';
    final EditorHistory history = EditorHistory();
    addTearDown(history.dispose);

    await pumpBar(tester, history: history);
    // What a mounted source pane does: hand over a context below the
    // editor's own `Actions`.
    history.offer(tester.element(find.byType(EditorToolbarWidget)));
    await tester.pumpAndSettle();

    for (final String word in <String>['Undo', 'Redo']) {
      final TomToolbarButtonWidget button = tester.widget(
        find.ancestor(
          of: find.byTooltip(word),
          matching: find.byType(TomToolbarButtonWidget),
        ).first,
      );
      expect(button.onPressed, isNotNull);
    }
  });

  testWidgets('bold and italic are letters, because a letter is the icon', (
    WidgetTester tester,
  ) async {
    documents.content = 'a\n';

    await pumpBar(tester);

    expect(find.text('B'), findsOneWidget);
    expect(find.text('I'), findsOneWidget);
  });
}

/// A repository answering with whatever content the test set.
final class _Documents implements DocumentRepository {
  String content = '';
  final List<DocumentEntity> written = <DocumentEntity>[];

  @override
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  ) async => Success<DocumentEntity, DocumentFailure>(
    DocumentEntity(path: path, content: content),
  );

  @override
  Future<Result<void, DocumentFailure>> write(DocumentEntity document) async {
    written.add(document);
    return const Success<void, DocumentFailure>(null);
  }
}

/// The no-op observability, which is also the shipping default.
final class _Silent implements Observability {
  const _Silent();

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async {}
}

/// Preferences in memory, so a widget test needs no disk.
final class _Preferences implements PreferencesRepository {
  PreferencesValueObject held = PreferencesValueObject.defaults;

  @override
  Future<PreferencesValueObject> read() async => held;

  @override
  Future<Result<void, AppFailure>> write(
    PreferencesValueObject preferences,
  ) async {
    held = preferences;
    return const Success<void, AppFailure>(null);
  }
}
