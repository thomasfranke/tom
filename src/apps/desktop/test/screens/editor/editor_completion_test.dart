import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/re_highlight.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/screens/editor/editor_highlight.dart';
import 'package:tom_desktop/screens/editor/editor_panel.dart';
import 'package:tom_desktop/screens/editor/widgets/editor_completion_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// macOS for every test: `re_editor` decides once, in a lazy top-level
/// final, whether to install its shortcuts, and the platform a widget test
/// reports otherwise gets none — the arrows and Enter would prove nothing.
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
  final SpaceRelativePathValueObject roadmap = SpaceRelativePathValueObject(
    'tasks/roadmap.md',
  );

  SpaceEntryValueObject file(String path) => SpaceEntryValueObject(
    path: SpaceRelativePathValueObject(path),
    type: SpaceEntryTypeEnum.file,
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
        // The board's three, and one that matches nothing typed below.
        fileTreeProvider.overrideWith(
          () => _Tree(<SpaceEntryValueObject>[
            file('tasks/roadmap.md'),
            file('docs/guides/setup.md'),
            file('docs/reference/settings.md'),
            file('docs/ops/setting-up-ci.md'),
            file('about.md'),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  Future<void> pumpEditor(WidgetTester tester, String content) async {
    tester.view
      ..physicalSize = const Size(1280, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    documents.content = content;
    container.read(spaceSessionProvider.notifier)
      ..open(docs)
      ..show(roadmap);
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
    // The keyboard goes where a click puts it.
    await tester.tap(find.byType(CodeEditor));
    await tester.pump(const Duration(milliseconds: 200));
  }

  CodeLineEditingController controller(WidgetTester tester) =>
      tester.widget<CodeEditor>(find.byType(CodeEditor)).controller!;

  /// Types [typed] at the end of the last line, as a keystroke does.
  Future<void> typeAtTheEnd(WidgetTester tester, String typed) async {
    final CodeLineEditingController editor = controller(tester);
    final int last = editor.lineCount - 1;
    editor
      ..selection = CodeLineSelection.collapsed(
        index: last,
        offset: editor.codeLines[last].text.length,
      )
      ..replaceSelection(typed);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
  }

  /// The preview debounces and the gutter is its diff, so an edit starts a
  /// timer that has to be pumped past before the tree goes.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump(PreviewNotifier.settle * 2);
  }

  /// The names the offer shows, top to bottom.
  List<String> offered(WidgetTester tester) => <String>[
    for (final WikilinkCandidateValueObject candidate
        in tester
            .widget<EditorCompletionWidget>(find.byType(EditorCompletionWidget))
            .candidates)
      candidate.path.value,
  ];

  int chosen(WidgetTester tester) => tester
      .widget<EditorCompletionWidget>(find.byType(EditorCompletionWidget))
      .chosen;

  String buffer() => (container.read(editorProvider) as EditorReady).source;

  testWidgets('typing [[ offers the space\'s documents, best first', (
    WidgetTester tester,
  ) async {
    await pumpEditor(tester, 'See ');

    await typeAtTheEnd(tester, '[[set');

    expect(offered(tester), <String>[
      'docs/guides/setup.md',
      'docs/reference/settings.md',
      'docs/ops/setting-up-ci.md',
    ]);
    // Each row names the document and the folder it is in.
    expect(find.text('setup.md'), findsOneWidget);
    expect(find.text('docs/guides'), findsOneWidget);
    expect(
      find.text('↑↓ to choose · Enter to insert · Esc to close'),
      findsOneWidget,
    );
    await settle(tester);
  }, variant: _mac);

  testWidgets('the chosen row is tinted, its name in accent', (
    WidgetTester tester,
  ) async {
    await pumpEditor(tester, 'See ');
    await typeAtTheEnd(tester, '[[set');

    final Text name = tester.widget<Text>(find.text('setup.md'));
    expect(name.style?.color, TomColors.light.accent);
    expect(name.style?.fontWeight, FontWeight.w600);
    final Text other = tester.widget<Text>(find.text('settings.md'));
    expect(other.style?.color, TomColors.light.textPrimary);
    expect(other.style?.fontWeight, FontWeight.w500);
    await settle(tester);
  }, variant: _mac);

  testWidgets('it hangs under the [[, the board\'s width and step', (
    WidgetTester tester,
  ) async {
    await pumpEditor(tester, 'See ');
    await typeAtTheEnd(tester, '[[set');

    final Rect list = tester.getRect(
      find
          .descendant(
            of: find.byType(EditorCompletionWidget),
            matching: find.byType(Container),
          )
          .first,
    );
    expect(list.width, EditorCompletionWidget.width);
    // Three rows of thirty between the two insets.
    expect(list.height, 3 * TomMenuWidget.rowHeight + 2 * 6 + 2);
    await settle(tester);
  }, variant: _mac);

  testWidgets('down and up move the choice, round the ends', (
    WidgetTester tester,
  ) async {
    await pumpEditor(tester, 'See ');
    await typeAtTheEnd(tester, '[[set');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(chosen(tester), 1);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(chosen(tester), 2);
    // The caret stayed where it was typed.
    expect(buffer(), 'See [[set');
    await settle(tester);
  }, variant: _mac);

  testWidgets('Enter writes the chosen document and closes the link', (
    WidgetTester tester,
  ) async {
    await pumpEditor(tester, 'See ');
    await typeAtTheEnd(tester, '[[set');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(buffer(), 'See [[settings]]');
    expect(find.byType(EditorCompletionWidget), findsNothing);
    // The caret after the brackets, not a newline inserted.
    final EditorReady ready = container.read(editorProvider) as EditorReady;
    expect(ready.selectionEnd, 'See [[settings]]'.length);
    await settle(tester);
  }, variant: _mac);

  testWidgets('a click on a row writes it too', (WidgetTester tester) async {
    await pumpEditor(tester, 'See ');
    await typeAtTheEnd(tester, '[[set');

    await tester.tap(find.text('setting-up-ci.md'));
    await tester.pump();

    expect(buffer(), 'See [[setting-up-ci]]');
    expect(find.byType(EditorCompletionWidget), findsNothing);
    await settle(tester);
  }, variant: _mac);

  testWidgets('brackets the editor already closed are not doubled', (
    WidgetTester tester,
  ) async {
    // `re_editor` closes a bracket as it is typed, so `[[` arrives as
    // `[[]]` with the caret between them.
    await pumpEditor(tester, 'See [[]]');
    controller(tester).selection = const CodeLineSelection.collapsed(
      index: 0,
      offset: 6,
    );
    await tester.pump();
    controller(tester).replaceSelection('se');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(buffer(), 'See [[setup]]');
    await settle(tester);
  }, variant: _mac);

  testWidgets('Escape closes it and leaves what was typed', (
    WidgetTester tester,
  ) async {
    await pumpEditor(tester, 'See ');
    await typeAtTheEnd(tester, '[[set');

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();

    expect(find.byType(EditorCompletionWidget), findsNothing);
    expect(buffer(), 'See [[set');
    await settle(tester);
  }, variant: _mac);

  testWidgets('moving the caret away closes it', (WidgetTester tester) async {
    await pumpEditor(tester, 'See ');
    await typeAtTheEnd(tester, '[[set');

    controller(tester).selection = const CodeLineSelection.collapsed(
      index: 0,
      offset: 1,
    );
    await tester.pump();

    expect(find.byType(EditorCompletionWidget), findsNothing);
    await settle(tester);
  }, variant: _mac);

  testWidgets('a finished link, or one matching nothing, offers nothing', (
    WidgetTester tester,
  ) async {
    await pumpEditor(tester, 'See ');

    await typeAtTheEnd(tester, '[[setup]] and [[zzz');

    expect(find.byType(EditorCompletionWidget), findsNothing);
    await settle(tester);
  }, variant: _mac);

  testWidgets('inside a fenced block, [[ offers nothing', (
    WidgetTester tester,
  ) async {
    await pumpEditor(tester, '# Setup\n\n```markdown\n');

    await typeAtTheEnd(tester, '[[set');

    expect(buffer(), endsWith('```markdown\n[[set'));
    expect(find.byType(EditorCompletionWidget), findsNothing);
    await settle(tester);
  }, variant: _mac);

  testWidgets('inside an inline code span, [[ offers nothing', (
    WidgetTester tester,
  ) async {
    await pumpEditor(tester, 'Write `');

    await typeAtTheEnd(tester, '[[set');

    expect(find.byType(EditorCompletionWidget), findsNothing);
    await settle(tester);
  }, variant: _mac);

  testWidgets('past a closed fence, [[ offers again', (
    WidgetTester tester,
  ) async {
    await pumpEditor(tester, '```\n[[a]]\n```\n\nSee ');

    await typeAtTheEnd(tester, '[[set');

    expect(offered(tester), contains('docs/guides/setup.md'));
    await settle(tester);
  }, variant: _mac);

  test('the source colours a wikilink, closed or still being typed', () {
    final Highlight highlight = Highlight()
      ..registerLanguage('markdown', editorMarkdown);
    final CodeHighlightTheme theme = editorHighlightOf(
      TomColors.light,
      Brightness.light,
    );
    for (final String typed in <String>['See [[setup]] now', 'See [[set']) {
      final TextSpanRenderer renderer = TextSpanRenderer(
        const TextStyle(),
        theme.theme,
      );
      highlight.highlight(code: typed, language: 'markdown').render(renderer);
      final List<String> accented = <String>[];
      renderer.span!.visitChildren((InlineSpan span) {
        if (span is TextSpan &&
            span.style?.color == TomColors.light.accent &&
            span.text != null) {
          accented.add(span.text!);
        }
        return true;
      });
      expect(
        accented.join(),
        typed.substring(4, typed.contains(']]') ? 13 : null),
      );
    }
  });
}

/// The tree, answering with a listing.
final class _Tree extends FileTreeNotifier {
  _Tree(this.entries);

  final List<SpaceEntryValueObject> entries;

  @override
  FileTreeState build() => FileTreeState.ready(
    entries: entries,
    collapsed: const <SpaceRelativePathValueObject>{},
  );
}

/// A reader that splits nothing: one paragraph, whatever it is given.
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
          kind: BlockKindEnum.paragraph,
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
