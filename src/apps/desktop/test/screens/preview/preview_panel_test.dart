import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_desktop/screens/preview/preview_design.dart';
import 'package:tom_desktop/screens/preview/preview_panel.dart';
import 'package:tom_desktop/screens/preview/widgets/preview_block_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  late _Documents documents;
  late _Git git;
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
    git = _Git(committed: () => documents.content);
    container = ProviderContainer(
      overrides: <Override>[
        readDocumentProvider.overrideWithValue(
          ReadDocumentUseCase(
            documentsFor: (SpaceEntity space) => documents,
            observability: const _Silent(),
          ),
        ),
        splitDocumentProvider.overrideWithValue(
          const SplitDocumentUseCase(
            blocks: _Blocks(),
            observability: _Silent(),
          ),
        ),
        diffDocumentProvider.overrideWithValue(
          DiffDocumentUseCase(
            // `HEAD` matches the working copy unless a test says otherwise,
            // so a test about rendering draws no diff decoration.
            gitFor: (SpaceEntity space) => git,
            blocks: const _Blocks(),
            differ: const BlockDifferService(
              aligner: TextDifferBlockAlignerImpl(
                differ: TextDifferDataSource(differ: DiffutilTextDifferImpl()),
              ),
            ),
            observability: const _Silent(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  /// Mounts the panel, with [document] open when one is given.
  Future<void> pumpPreview(
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
          home: const Scaffold(body: PreviewPanel()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('it names itself, and says so when nothing is open', (
    WidgetTester tester,
  ) async {
    await pumpPreview(tester);

    expect(find.text('PREVIEW'), findsOneWidget);
    expect(find.text('Choose a document in the explorer.'), findsOneWidget);
  });

  testWidgets('a document is drawn one container per block', (
    WidgetTester tester,
  ) async {
    // The container around each block is what carries the diff decoration.
    documents.content = '# Title\n\nProse.\n\n- one\n- two\n';

    await pumpPreview(tester, document: writing);

    expect(find.byType(MarkdownBody), findsNWidgets(3));
  });

  testWidgets('and the words are on screen', (WidgetTester tester) async {
    documents.content = '# Title\n\nProse.\n';

    await pumpPreview(tester, document: writing);

    expect(find.textContaining('Title', findRichText: true), findsOneWidget);
    expect(find.textContaining('Prose.', findRichText: true), findsOneWidget);
  });

  group('the rendered diff', () {
    /// The letters of every diff mark on screen, in order.
    List<String> marks(WidgetTester tester) => tester
        .widgetList<DiffMarkWidget>(find.byType(DiffMarkWidget))
        .map((DiffMarkWidget mark) => mark.letter)
        .toList();

    testWidgets('a document matching HEAD carries no decoration at all', (
      WidgetTester tester,
    ) async {
      // An unchanged document must add nothing to read past.
      documents.content = '# Title\n\nProse.\n';

      await pumpPreview(tester, document: writing);

      expect(marks(tester), isEmpty);
      expect(find.byType(MarkdownBody), findsNWidgets(2));
    });

    testWidgets('a rewritten paragraph is marked as modified', (
      WidgetTester tester,
    ) async {
      documents.content = '# Title\n\nProse, rewritten.\n';
      git.committed = () => '# Title\n\nProse.\n';

      await pumpPreview(tester, document: writing);

      expect(marks(tester), <String>['M']);
      expect(
        find.textContaining('Prose, rewritten.', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('a new paragraph is marked as added', (
      WidgetTester tester,
    ) async {
      documents.content = '# Title\n\nProse.\n\nAnd more of it.\n';
      git.committed = () => '# Title\n\nProse.\n';

      await pumpPreview(tester, document: writing);

      expect(marks(tester), <String>['A']);
    });

    testWidgets('a deleted paragraph is still rendered, marked as removed', (
      WidgetTester tester,
    ) async {
      // What went is rendered, not shown as `-` lines of raw markdown.
      documents.content = '# Title\n';
      git.committed = () => '# Title\n\nThe paragraph that went.\n';

      await pumpPreview(tester, document: writing);

      expect(marks(tester), <String>['R']);
      expect(
        find.textContaining('The paragraph that went.', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('a deleted code block is struck through like the prose', (
      WidgetTester tester,
    ) async {
      // A fence reads none of the style sheet: with a highlighter set, the
      // strike reaches the code only through the highlighter.
      documents.content = '# Title\n';
      git.committed = () => '# Title\n\n```dart\nfinal int gone = 1;\n```\n';

      await pumpPreview(tester, document: writing);

      expect(marks(tester), <String>['R']);
      expect(
        _decorationsOf(tester, 'final int gone'),
        contains(TextDecoration.lineThrough),
      );
    });

    testWidgets('a code block that stayed is not', (WidgetTester tester) async {
      documents.content = '# Title\n\n```dart\nfinal int kept = 1;\n```\n';

      await pumpPreview(tester, document: writing);

      expect(
        _decorationsOf(tester, 'final int kept'),
        isNot(contains(TextDecoration.lineThrough)),
      );
    });

    testWidgets('what went is drawn before what arrived', (
      WidgetTester tester,
    ) async {
      documents.content = '# Title\n\nSomething else entirely, elsewhere.\n';
      git.committed = () => '# Title\n\nThe old opening, about one thing.\n';

      await pumpPreview(tester, document: writing);

      expect(marks(tester), <String>['R', 'A']);
    });

    testWidgets('a document git has never seen is every block added', (
      WidgetTester tester,
    ) async {
      documents.content = '# Title\n\nProse.\n';
      git.answer = const Failure<String, GitFailure>(
        GitPathNotInRevision('docs/guides/writing.md'),
      );

      await pumpPreview(tester, document: writing);

      expect(marks(tester), <String>['A', 'A']);
    });

    testWidgets('a comparison git could not make leaves the document alone', (
      WidgetTester tester,
    ) async {
      // The document is readable either way, so it is drawn undecorated
      // rather than replaced by an error.
      documents.content = '# Title\n\nProse.\n';
      git.answer = const Failure<String, GitFailure>(GitNotInstalled());

      await pumpPreview(tester, document: writing);

      expect(marks(tester), isEmpty);
      expect(find.byType(MarkdownBody), findsNWidgets(2));
    });
  });

  group('the reading measure', () {
    /// The width of the column the blocks are laid out in.
    double measure(WidgetTester tester) => tester
        .widget<SizedBox>(
          find
              .ancestor(
                of: find.byType(ListView),
                matching: find.byType(SizedBox),
              )
              .first,
        )
        .width!;

    testWidgets('beside the source it is the companion measure', (
      WidgetTester tester,
    ) async {
      documents.content = '# Title\n';

      await pumpPreview(tester, document: writing);

      expect(measure(tester), PreviewDesign.measure + TomMetrics.pad * 2);
    });

    testWidgets('with the pane to itself it is wider, and set larger', (
      WidgetTester tester,
    ) async {
      // Reading is not a lesser mode: nothing competes for the width.
      documents.content = '# Title\n\nProse.\n';
      await pumpPreview(tester, document: writing);

      container
          .read(spaceSessionProvider.notifier)
          .look(DocumentModeEnum.preview);
      await tester.pumpAndSettle();

      expect(
        measure(tester),
        PreviewDesign.readingMeasure + TomMetrics.pad * 2,
      );
      expect(
        tester
            .widgetList<PreviewBlockWidget>(find.byType(PreviewBlockWidget))
            .map((PreviewBlockWidget block) => block.body),
        everyElement(PreviewDesign.readingBody),
      );
    });
  });

  testWidgets('an empty document says so rather than looking broken', (
    WidgetTester tester,
  ) async {
    documents.content = '';

    await pumpPreview(tester, document: writing);

    expect(find.text('This document is empty.'), findsOneWidget);
  });

  testWidgets('a document that is gone is named as that', (
    WidgetTester tester,
  ) async {
    documents.answer = Failure<DocumentEntity, DocumentFailure>(
      DocumentNotFound(writing.value),
    );

    await pumpPreview(tester, document: writing);

    expect(find.text('That document is no longer there.'), findsOneWidget);
  });

  testWidgets('a file TOM cannot read says which problem it is', (
    WidgetTester tester,
  ) async {
    documents.answer = Failure<DocumentEntity, DocumentFailure>(
      DocumentNotUtf8(writing.value),
    );

    await pumpPreview(tester, document: writing);

    expect(
      find.text('That file is not UTF-8 text, so TOM will not open it.'),
      findsOneWidget,
    );
  });

  group('a link in the document', () {
    /// The document the session is showing after whatever was tapped.
    SpaceRelativePathValueObject? shown() =>
        container.read(spaceSessionProvider)?.openDocument;

    testWidgets('is read from the document\'s own folder', (
      WidgetTester tester,
    ) async {
      // Relative to the document, as the author wrote it: `../about.md` from
      // `guides/writing.md` is the one at the root.
      documents.content = '[about](../about.md)\n';

      await pumpPreview(tester, document: writing);
      await tester.tap(find.textContaining('about', findRichText: true));
      await tester.pumpAndSettle();

      expect(shown()?.value, 'about.md');
    });

    testWidgets('that leaves the space is not followed', (
      WidgetTester tester,
    ) async {
      documents.content = '[out](../../secret.md)\n';

      await pumpPreview(tester, document: writing);
      await tester.tap(find.textContaining('out', findRichText: true));
      await tester.pumpAndSettle();

      expect(shown(), writing);
    });
  });

  testWidgets('an image is looked for beside the document', (
    WidgetTester tester,
  ) async {
    documents.content = '![logo](../logo.png)\n';

    await pumpPreview(tester, document: writing);

    // Offstage included: an unloaded image lays out at zero height, which
    // the list reports as not on screen.
    final Image image = tester.widget<Image>(
      find.byType(Image, skipOffstage: false),
    );
    expect((image.image as FileImage).file.path, '/code/app/docs/logo.png');
  });
}

/// Every decoration the rendered spans containing [text] carry.
///
/// Read off the spans rather than the style sheet, because a fence is where
/// the two disagree and the line the reader sees is what matters.
Set<TextDecoration?> _decorationsOf(WidgetTester tester, String text) {
  final Set<TextDecoration?> found = <TextDecoration?>{};
  // The blocks are selectable, so the spans are a `SelectableText.rich`'s.
  for (final SelectableText selectable in tester.widgetList<SelectableText>(
    find.byType(SelectableText),
  )) {
    final InlineSpan? span = selectable.textSpan;
    if (span == null || !span.toPlainText().contains(text)) {
      continue;
    }
    found.add(span.style?.decoration);
    span.visitChildren((InlineSpan child) {
      found.add(child.style?.decoration);
      return true;
    });
  }
  return found;
}

/// A repository answering with whatever content the test set.
final class _Documents implements DocumentRepository {
  String content = '';
  Result<DocumentEntity, DocumentFailure>? answer;

  @override
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  ) async =>
      answer ??
      Success<DocumentEntity, DocumentFailure>(
        DocumentEntity(path: path, content: content),
      );

  @override
  Future<Result<void, DocumentFailure>> write(DocumentEntity document) async =>
      throw UnimplementedError();
}

/// Git, answering with whatever the test says `HEAD` holds.
final class _Git implements GitRepository {
  _Git({required this.committed});

  /// What the committed version of the open document is.
  String Function() committed;

  /// What git answers instead, when the test is about a failure.
  Result<String, GitFailure>? answer;

  @override
  Future<Result<String, GitFailure>> contentAt({
    required String revision,
    required RepoRelativePathValueObject path,
  }) async => answer ?? Success<String, GitFailure>(committed());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// The real reader over the real parser; a fake outline would test the fake.
final class _Blocks implements BlockReaderPort {
  const _Blocks();

  @override
  Future<Result<ParsedDocumentValueObject, DocumentFailure>> read(
    DocumentEntity document,
  ) => _reader.read(document);

  static const MarkdownBlockReaderImpl _reader = MarkdownBlockReaderImpl(
    markdown: MarkdownDataSource(parser: MarkdownPackageParserImpl()),
  );
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
