import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_editor/re_editor.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/screens/editor/editor_panel.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

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
  final SpaceRelativePathValueObject index = SpaceRelativePathValueObject(
    'index.md',
  );

  setUp(() {
    documents = _Documents();
    container = ProviderContainer(
      overrides: <Override>[
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

  /// Mounts the panel, with [document] open when one is given.
  Future<void> pumpEditor(
    WidgetTester tester, {
    SpaceRelativePathValueObject? document,
  }) async {
    tester.view
      ..physicalSize = const Size(1280, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    if (document != null) {
      container.read(spaceSessionProvider.notifier)
        ..open(docs)
        ..show(document);
    }
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(Brightness.light),
          home: const Scaffold(body: EditorPanel()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('it names itself, and says so when nothing is open', (
    WidgetTester tester,
  ) async {
    await pumpEditor(tester);

    expect(find.text('SOURCE'), findsOneWidget);
    expect(find.text('Choose a document in the explorer.'), findsOneWidget);
  });

  testWidgets('an open document is put in an editor, source and all', (
    WidgetTester tester,
  ) async {
    // The file's own markdown, not a rendering of it: there is no WYSIWYG
    // mode, now or later (Decision 3).
    documents.content = '# Title\n\nProse.\n';

    await pumpEditor(tester, document: writing);

    expect(find.byType(CodeEditor), findsOneWidget);
    expect(
      tester.widget<CodeEditor>(find.byType(CodeEditor)).controller!.text,
      '# Title\n\nProse.\n',
    );
  });

  testWidgets('a document that is gone is named as that', (
    WidgetTester tester,
  ) async {
    documents.answer = Failure<DocumentEntity, DocumentFailure>(
      DocumentNotFound(writing.value),
    );

    await pumpEditor(tester, document: writing);

    expect(find.byType(CodeEditor), findsNothing);
    expect(find.text('That document is no longer there.'), findsOneWidget);
  });

  /// Types [source] into the editor on screen.
  ///
  /// The long pump is not padding: showing a cursor schedules a delayed
  /// blink the package never cancels, and a widget test fails on a timer
  /// that outlives the tree.
  Future<void> type(WidgetTester tester, String source) async {
    tester.widget<CodeEditor>(find.byType(CodeEditor)).controller!.text =
        source;
    await tester.pump(const Duration(milliseconds: 200));
  }

  testWidgets('typing in the editor reaches the buffer', (
    WidgetTester tester,
  ) async {
    documents.content = '# Title\n';
    await pumpEditor(tester, document: writing);

    await type(tester, '# Typed\n');

    expect((container.read(editorProvider) as EditorReady).source, '# Typed\n');
    expect(container.read(editorProvider).isDirty, isTrue);
  });

  testWidgets('the save shortcut is answered, not left to do nothing', (
    WidgetTester tester,
  ) async {
    // The binding is the package's — it already maps ⌘S on a Mac and Ctrl+S
    // elsewhere, and dispatches an intent that by default does nothing; the
    // answer to it is what was missing. **The key press itself is not
    // driveable here**: the package installs no shortcuts at all on the
    // platform a widget test reports, and decides that once in a lazy
    // top-level final, so pressing ⌘S in this file would prove nothing. The
    // keystroke is the end-to-end scenario's, on a real runner; this is what
    // it reaches, and `editor_notifier_test.dart` is what saving does.
    documents.content = '# Title\n';
    await pumpEditor(tester, document: writing);

    expect(
      tester
          .widget<CodeEditor>(find.byType(CodeEditor))
          .shortcutOverrideActions,
      contains(CodeShortcutSaveIntent),
    );
  });

  testWidgets('another document gets another editor, not the same one', (
    WidgetTester tester,
  ) async {
    // A controller carried across would carry its undo history with it, and
    // ⌘Z would walk back into a file that is no longer on screen.
    documents.content = '# Title\n';
    await pumpEditor(tester, document: writing);
    final CodeLineEditingController first = tester
        .widget<CodeEditor>(find.byType(CodeEditor))
        .controller!;

    documents.content = '# Other\n';
    container.read(spaceSessionProvider.notifier).show(index);
    await tester.pumpAndSettle();

    final CodeLineEditingController second = tester
        .widget<CodeEditor>(find.byType(CodeEditor))
        .controller!;
    expect(identical(first, second), isFalse);
    expect(second.text, '# Other\n');
  });

  testWidgets('the same document read again reaches the pane', (
    WidgetTester tester,
  ) async {
    // What a branch switch leaves behind, and what discarding an edit is:
    // the path did not change, so the key cannot catch it, and the pane
    // would go on showing text from the branch that was left behind
    // (`docs/product/git-workflow/branch-switch/doc.md`).
    documents.content = '# On main\n';
    await pumpEditor(tester, document: writing);
    container.read(editorProvider.notifier).edit('typed, never saved');
    await tester.pumpAndSettle();

    documents.content = '# On the other branch\n';
    await container.read(editorProvider.notifier).reload();
    await tester.pumpAndSettle();

    expect(
      tester.widget<CodeEditor>(find.byType(CodeEditor)).controller!.text,
      '# On the other branch\n',
    );
  });

  testWidgets('and typing is never overwritten by one', (
    WidgetTester tester,
  ) async {
    // The other side of it: a buffer that differs from the disk is the
    // user's, and nothing may re-seed the controller under their cursor.
    documents.content = '# On main\n';
    await pumpEditor(tester, document: writing);

    container.read(editorProvider.notifier).edit('half a sentence');
    await tester.pumpAndSettle();

    expect(
      tester.widget<CodeEditor>(find.byType(CodeEditor)).controller!.text,
      '# On main\n',
      reason: 'the pane re-seeded itself while the buffer was dirty',
    );
  });
}

/// A repository answering with whatever content the test set.
final class _Documents implements DocumentRepository {
  String content = '';
  Result<DocumentEntity, DocumentFailure>? answer;
  final List<DocumentEntity> written = <DocumentEntity>[];

  @override
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  ) async =>
      answer ??
      Success<DocumentEntity, DocumentFailure>(
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
