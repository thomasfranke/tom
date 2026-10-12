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

// What happens under the bar in preview — the source pane kept unseen, undo
// through it — is `test/screens/shell/shell_region_widget_test.dart`'s.
void main() {
  test(
    'the cell is the board’s 28 with its ink, on the same pitch as ever',
    () {
      // The cells touch, so the centres sit where the 24-cell, 4-gap bar put
      // them: the x every board draws the buttons at.
      expect(TomToolbarButtonWidget.size, 28);
      expect(TomToolbarButtonWidget.glyphBox, 22);
      expect(EditorToolbarWidget.between, 0);
      final List<ToolbarEntry> first = EditorToolbarWidget.groups.first;
      expect(EditorToolbarWidget.widthOfGroup(first), first.length * 28);
      // First centre: inset 8 + 14 = 22, as 10 + 12 was.
      expect(EditorToolbarWidget.inset + TomToolbarButtonWidget.size / 2, 22);
      // Every group boundary moved by nothing: 6 + 1 + 3 = 10 = 8 + 1 + 5 - 4.
      expect(EditorToolbarWidget.betweenGroups, 10);
    },
  );

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
        readPreferencesFileProvider.overrideWithValue(
          ReadDocumentUseCase(
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
      find
          .ancestor(
            of: find.byTooltip(word),
            matching: find.byType(TomToolbarButtonWidget),
          )
          .first,
    );
    await tester.pumpAndSettle();
  }

  /// The button whose tooltip is [word].
  TomToolbarButtonWidget buttonFor(WidgetTester tester, String word) =>
      tester.widget(
        find
            .ancestor(
              of: find.byTooltip(word),
              matching: find.byType(TomToolbarButtonWidget),
            )
            .first,
      );

  /// The fifteen formatting buttons, past undo and redo.
  Iterable<TomToolbarButtonWidget> formatting(WidgetTester tester) => tester
      .widgetList<TomToolbarButtonWidget>(find.byType(TomToolbarButtonWidget))
      .skip(2);

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

  testWidgets('the preferences file dims the fifteen formatting buttons', (
    WidgetTester tester,
  ) async {
    // JSON takes no markdown (`preferences/where-it-is-stored/doc.md`).
    documents.content = '{}\n';
    await pumpBar(tester);
    container
        .read(spaceSessionProvider.notifier)
        .openPreferencesFile(SpaceRelativePathValueObject('preferences.json'));
    await tester.pumpAndSettle();
    expect(container.read(editorProvider), isA<EditorReady>());

    final Iterable<TomToolbarButtonWidget> buttons = tester
        .widgetList<TomToolbarButtonWidget>(
          find.byType(TomToolbarButtonWidget),
        );
    expect(buttons, hasLength(17));
    for (final TomToolbarButtonWidget button in buttons.skip(2)) {
      expect(button.onPressed, isNull, reason: button.tooltip);
    }
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
        find
            .ancestor(
              of: find.byTooltip(word),
              matching: find.byType(TomToolbarButtonWidget),
            )
            .first,
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
        find
            .ancestor(
              of: find.byTooltip(word),
              matching: find.byType(TomToolbarButtonWidget),
            )
            .first,
      );
      expect(button.onPressed, isNotNull);
    }
  });

  group('a change that is not a document', () {
    /// Mounts the bar with a reachable history over [state].
    Future<void> pumpHolding(WidgetTester tester, EditorState state) async {
      documents.content = 'a word here\n';
      final EditorHistory history = EditorHistory();
      addTearDown(history.dispose);
      await pumpBar(tester, history: history);
      history.offer(tester.element(find.byType(EditorToolbarWidget)));
      container.read(editorProvider.notifier).state = state;
      await tester.pumpAndSettle();
    }

    testWidgets('a text file dims formatting and keeps undo and redo', (
      WidgetTester tester,
    ) async {
      // Typed into and saved like any tab, but it takes no markdown.
      await pumpHolding(
        tester,
        EditorState.ready(
          saved: DocumentEntity(
            path: SpaceRelativePathValueObject('mkdocs.yml'),
            content: 'site_name: docs\n',
          ),
          source: 'site_name: docs\n',
        ),
      );

      for (final TomToolbarButtonWidget button in formatting(tester)) {
        expect(button.onPressed, isNull, reason: button.tooltip);
      }
      expect(buttonFor(tester, 'Undo').onPressed, isNotNull);
      expect(buttonFor(tester, 'Redo').onPressed, isNotNull);
    });

    testWidgets('a deleted document dims all seventeen', (
      WidgetTester tester,
    ) async {
      // Its last version is read-only: nothing to format, nothing to undo.
      await pumpHolding(
        tester,
        EditorState.ready(
          saved: DocumentEntity(path: writing, content: '# Writing\n'),
          source: '# Writing\n',
          isDeleted: true,
        ),
      );

      for (final TomToolbarButtonWidget button
          in tester.widgetList<TomToolbarButtonWidget>(
            find.byType(TomToolbarButtonWidget),
          )) {
        expect(button.onPressed, isNull, reason: button.tooltip);
      }
    });
  });

  group('the mode decides whether there is a caret to format at', () {
    for (final DocumentModeEnum mode in <DocumentModeEnum>[
      DocumentModeEnum.source,
      DocumentModeEnum.split,
    ]) {
      testWidgets('in ${mode.name} the formatting buttons act', (
        WidgetTester tester,
      ) async {
        documents.content = 'a word here\n';
        await pumpBar(tester);
        container.read(spaceSessionProvider.notifier).look(mode);
        await tester.pumpAndSettle();

        for (final TomToolbarButtonWidget button in formatting(tester)) {
          expect(button.onPressed, isNotNull, reason: button.tooltip);
        }
      });
    }

    testWidgets('in preview the fifteen are dim, and undo and redo are not', (
      WidgetTester tester,
    ) async {
      // No caret, so formatting has nothing to act on; the history acts on
      // the buffer (`editor/formatting-shortcuts/doc.md`, last rule).
      documents.content = 'a word here\n';
      final EditorHistory history = EditorHistory();
      addTearDown(history.dispose);
      await pumpBar(tester, history: history);
      history.offer(tester.element(find.byType(EditorToolbarWidget)));
      container
          .read(spaceSessionProvider.notifier)
          .look(DocumentModeEnum.preview);
      await tester.pumpAndSettle();

      expect(find.byType(TomToolbarButtonWidget), findsNWidgets(17));
      for (final TomToolbarButtonWidget button in formatting(tester)) {
        expect(button.onPressed, isNull, reason: button.tooltip);
      }
      expect(buttonFor(tester, 'Undo').onPressed, isNotNull);
      expect(buttonFor(tester, 'Redo').onPressed, isNotNull);
    });

    testWidgets('a version being read dims them too', (
      WidgetTester tester,
    ) async {
      // The past is drawn as preview whatever the chosen mode.
      documents.content = 'a word here\n';
      await pumpBar(tester);
      container
          .read(spaceSessionProvider.notifier)
          .read(
            CommitEntity(
              sha: CommitShaValueObject('a' * 40),
              author: const AuthorValueObject(
                name: 'Ana',
                email: 'ana@example.com',
              ),
              date: CommitDateValueObject(
                utc: DateTime.utc(2026, 10),
                offset: Duration.zero,
              ),
              subject: 'Write the guide',
              body: '',
            ),
          );
      await tester.pumpAndSettle();

      for (final TomToolbarButtonWidget button in formatting(tester)) {
        expect(button.onPressed, isNull, reason: button.tooltip);
      }
    });
  });

  testWidgets(
    'bold and italic are outlines of the same set as their neighbours',
    (WidgetTester tester) async {
      documents.content = 'a\n';

      await pumpBar(tester);

      final Iterable<TomGlyphEnum> drawn = tester
          .widgetList<TomToolbarButtonWidget>(
            find.byType(TomToolbarButtonWidget),
          )
          .map((TomToolbarButtonWidget it) => it.glyph);
      expect(
        drawn,
        containsAll(<TomGlyphEnum>[TomGlyphEnum.bold, TomGlyphEnum.italic]),
      );
    },
  );
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
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Result<void, DocumentFailure>> create(DocumentEntity document) async =>
      throw UnimplementedError();

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
