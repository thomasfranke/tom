import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_editor/re_editor.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/bootstrap/panel_descriptor.dart';
import 'package:tom_desktop/bootstrap/panel_placement_enum.dart';
import 'package:tom_desktop/bootstrap/panel_registry.dart';
import 'package:tom_desktop/bootstrap/tom_module.dart';
import 'package:tom_desktop/screens/editor/editor_history.dart';
import 'package:tom_desktop/screens/editor/editor_panel.dart';
import 'package:tom_desktop/screens/editor/editor_toolbar_widget.dart';
import 'package:tom_desktop/screens/preview/preview_panel.dart';
import 'package:tom_desktop/screens/shell/widgets/shell_region_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// macOS for every test: on the platform a widget test reports, `re_editor`
/// installs no `Actions` at all, so the undo intent the history invokes has
/// nothing to land on — decided once, in a lazy final.
final TargetPlatformVariant _mac = TargetPlatformVariant.only(
  TargetPlatform.macOS,
);

void main() {
  late _Documents documents;
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
    final _Preferences preferences = _Preferences();
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
        // The preview's three: git here has no earlier version of anything,
        // so nothing is compared.
        splitDocumentProvider.overrideWithValue(
          SplitDocumentUseCase(
            blocks: _Blocks(),
            observability: const _Silent(),
          ),
        ),
        readVersionProvider.overrideWithValue(
          ReadVersionUseCase(
            gitFor: (SpaceEntity space) => _Git(),
            observability: const _Silent(),
          ),
        ),
        diffDocumentProvider.overrideWithValue(
          DiffDocumentUseCase(
            gitFor: (SpaceEntity space) => _Git(),
            blocks: _Blocks(),
            differ: BlockDifferService(aligner: _Aligner()),
            observability: const _Silent(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  /// What the buffer holds now.
  String source() => (container.read(editorProvider) as EditorReady).source;

  /// Pumps past the preview's own wait, so what it renders is the buffer's.
  Future<void> settle(WidgetTester tester) async {
    await tester.pumpAndSettle();
    await tester.pump(PreviewNotifier.settle);
    await tester.pumpAndSettle();
  }

  /// Mounts the bar over the document region as the shell does: the source
  /// pane kept alive, the preview beside it, both in the session's mode, and
  /// the history's keys heard while the mode is preview.
  Future<void> pumpDocument(WidgetTester tester, EditorHistory history) async {
    tester.view
      ..physicalSize = const Size(1280, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    container.read(spaceSessionProvider.notifier)
      ..open(docs)
      ..show(writing);
    final PanelRegistry registry = PanelRegistry(<TomModule>[_Module()]);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(Brightness.light),
          home: Scaffold(
            body: EditorHistoryScope(
              history: history,
              child: Consumer(
                builder: (BuildContext context, WidgetRef ref, _) {
                  final DocumentModeEnum mode =
                      ref.watch(
                        spaceSessionProvider.select(
                          (SpaceSessionState? it) => it?.drawnMode,
                        ),
                      ) ??
                      DocumentModeEnum.split;
                  return EditorHistoryKeys(
                    isActive: mode == DocumentModeEnum.preview,
                    child: Focus(
                      autofocus: true,
                      child: Column(
                        children: <Widget>[
                          const SizedBox(
                            height: 36,
                            child: EditorToolbarWidget(),
                          ),
                          Expanded(
                            child: ShellRegionWidget(
                              placement: PanelPlacementEnum.document,
                              registry: registry,
                              mode: mode,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    await settle(tester);
  }

  /// An edit made in split, as a keystroke would make it, then preview.
  Future<void> editThenPreview(WidgetTester tester) async {
    tester.widget<CodeEditor>(find.byType(CodeEditor)).controller!.text =
        '# Changed\n';
    await settle(tester);
    expect(source(), '# Changed\n');
    container
        .read(spaceSessionProvider.notifier)
        .look(DocumentModeEnum.preview);
    await settle(tester);
    expect(find.textContaining('Changed', findRichText: true), findsWidgets);
  }

  group('in preview the source pane is kept, unseen', () {
    testWidgets('so undo takes the last edit back and the preview follows', (
      WidgetTester tester,
    ) async {
      documents.content = '# Title\n';
      final EditorHistory history = EditorHistory();
      addTearDown(history.dispose);
      await pumpDocument(tester, history);
      await editThenPreview(tester);
      expect(find.byType(CodeEditor), findsNothing);
      expect(find.byType(CodeEditor, skipOffstage: false), findsOneWidget);

      await tester.tap(
        find
            .ancestor(
              of: find.byTooltip('Undo'),
              matching: find.byType(TomToolbarButtonWidget),
            )
            .first,
      );
      await settle(tester);

      expect(source(), '# Title\n');
      expect(find.textContaining('Changed', findRichText: true), findsNothing);
      expect(find.textContaining('Title', findRichText: true), findsWidgets);
    }, variant: _mac);

    testWidgets('and ⌘Z and ⌘⇧Z walk the same history as the buttons', (
      WidgetTester tester,
    ) async {
      documents.content = '# Title\n';
      final EditorHistory history = EditorHistory();
      addTearDown(history.dispose);
      await pumpDocument(tester, history);
      await editThenPreview(tester);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
      await settle(tester);
      expect(source(), '# Title\n');
      expect(find.textContaining('Changed', findRichText: true), findsNothing);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
      await settle(tester);
      expect(source(), '# Changed\n');
      expect(find.textContaining('Changed', findRichText: true), findsWidgets);
    }, variant: _mac);

    testWidgets('and coming back to split finds the same pane', (
      WidgetTester tester,
    ) async {
      // Another pane would be another controller, and its history empty.
      documents.content = '# Title\n';
      final EditorHistory history = EditorHistory();
      addTearDown(history.dispose);
      await pumpDocument(tester, history);
      final CodeLineEditingController before = tester
          .widget<CodeEditor>(find.byType(CodeEditor))
          .controller!;

      for (final DocumentModeEnum mode in <DocumentModeEnum>[
        DocumentModeEnum.preview,
        DocumentModeEnum.split,
      ]) {
        container.read(spaceSessionProvider.notifier).look(mode);
        await settle(tester);
      }

      expect(
        tester.widget<CodeEditor>(find.byType(CodeEditor)).controller,
        same(before),
      );
      expect(find.byType(PreviewPanel), findsOneWidget);
      expect(find.byType(EditorPanel), findsOneWidget);
    }, variant: _mac);
  });
}

/// The two panes, registered as the core module does.
final class _Module implements TomModule {
  @override
  String get id => 'test.document';

  @override
  List<PanelDescriptor> get panels => <PanelDescriptor>[
    PanelDescriptor(
      id: 'test.source',
      title: (BuildContext context) => 'Source',
      placement: PanelPlacementEnum.document,
      modes: const <DocumentModeEnum>[
        DocumentModeEnum.source,
        DocumentModeEnum.split,
      ],
      isKeptAlive: true,
      builder: (BuildContext context) => const EditorPanel(),
    ),
    PanelDescriptor(
      id: 'test.preview',
      title: (BuildContext context) => 'Preview',
      placement: PanelPlacementEnum.document,
      order: 1,
      modes: const <DocumentModeEnum>[
        DocumentModeEnum.split,
        DocumentModeEnum.preview,
      ],
      builder: (BuildContext context) => const PreviewPanel(),
    ),
  ];

  @override
  List<Override> get overrides => const <Override>[];
}

/// A reader that splits nothing: one heading block, whatever it is given.
final class _Blocks implements BlockReaderPort {
  @override
  Future<Result<ParsedDocumentValueObject, DocumentFailure>> read(
    DocumentEntity document,
  ) async => Success<ParsedDocumentValueObject, DocumentFailure>(
    ParsedDocumentValueObject(
      document: document,
      blocks: <BlockValueObject>[
        BlockValueObject(
          startLine: 0,
          endLine: 0,
          source: document.content.trimRight(),
          kind: BlockKindEnum.heading,
        ),
      ],
      linkDefinitions: '',
    ),
  );
}

/// Git with no earlier version of anything, so no comparison is possible.
final class _Git implements GitRepository {
  @override
  Future<Result<String, GitFailure>> contentAt({
    required String revision,
    required RepoRelativePathValueObject path,
  }) async => Failure<String, GitFailure>(GitPathNotInRevision(path.value));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// An aligner nothing asks, because nothing gets that far here.
final class _Aligner implements BlockAlignerPort {
  @override
  Future<Result<List<SequenceEditValueObject>, DocumentFailure>> align(
    ParsedDocumentValueObject before,
    ParsedDocumentValueObject after, {
    required double threshold,
  }) async => const Success<List<SequenceEditValueObject>, DocumentFailure>(
    <SequenceEditValueObject>[],
  );
}

/// A repository answering with whatever content the test set.
final class _Documents implements DocumentRepository {
  String content = '';

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
  Future<Result<void, DocumentFailure>> write(DocumentEntity document) async =>
      const Success<void, DocumentFailure>(null);
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
