import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_desktop/screens/preview/preview_panel.dart';
import 'package:tom_desktop/theme/tom_theme.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  late _Documents documents;
  late ProviderContainer container;

  final Space docs = Space(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );
  final SpaceRelativePath writing = SpaceRelativePath('guides/writing.md');

  setUp(() {
    documents = _Documents();
    container = ProviderContainer(
      overrides: <Override>[
        readDocumentProvider.overrideWithValue(
          ReadDocumentUseCase(
            documentsFor: (Space space) => documents,
            blocks: const _Blocks(),
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
    SpaceRelativePath? document,
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
    // Never one widget tree for the whole document: the container around
    // each block is what carries the diff decoration in M2.
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
    documents.answer = Failure<Document, DocumentFailure>(
      DocumentNotFound(writing.value),
    );

    await pumpPreview(tester, document: writing);

    expect(find.text('That document is no longer there.'), findsOneWidget);
  });

  testWidgets('a file TOM cannot read says which problem it is', (
    WidgetTester tester,
  ) async {
    documents.answer = Failure<Document, DocumentFailure>(
      DocumentNotUtf8(writing.value),
    );

    await pumpPreview(tester, document: writing);

    expect(
      find.text('That file is not UTF-8 text, so TOM will not open it.'),
      findsOneWidget,
    );
  });
}

/// A repository answering with whatever content the test set.
final class _Documents implements DocumentRepository {
  String content = '';
  Result<Document, DocumentFailure>? answer;

  @override
  Future<Result<Document, DocumentFailure>> read(
    SpaceRelativePath path,
  ) async =>
      answer ??
      Success<Document, DocumentFailure>(
        Document(path: path, content: content),
      );

  @override
  Future<Result<void, DocumentFailure>> write(Document document) async =>
      throw UnimplementedError();
}

/// The real reader, over the real parser — the panel is what is under test,
/// and a fake outline here would test the fake.
final class _Blocks implements BlockReader {
  const _Blocks();

  @override
  Future<Result<ParsedDocument, DocumentFailure>> read(Document document) =>
      _reader.read(document);

  static const MarkdownBlockReader _reader = MarkdownBlockReader(
    parser: MarkdownPackageParser(),
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
