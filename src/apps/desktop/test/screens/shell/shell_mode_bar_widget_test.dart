import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/screens/shell/widgets/shell_mode_bar_widget.dart';
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

  /// Mounts the bar, with [document] open when one is given.
  Future<void> pumpBar(
    WidgetTester tester, {
    SpaceRelativePathValueObject? document,
  }) async {
    container.read(spaceSessionProvider.notifier).open(docs);
    if (document != null) {
      container.read(spaceSessionProvider.notifier).show(document);
    }
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(Brightness.light),
          home: const Scaffold(body: ShellModeBarWidget()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('it offers the three modes and no fourth', (
    WidgetTester tester,
  ) async {
    // There is no WYSIWYG, now or later (Decision 3).
    await pumpBar(tester);

    expect(find.text('Source'), findsOneWidget);
    expect(find.text('Split'), findsOneWidget);
    expect(find.text('Preview'), findsOneWidget);
  });

  testWidgets('a space opens in split', (WidgetTester tester) async {
    // The product's own claim: source and preview belong side by side.
    await pumpBar(tester);

    expect(container.read(spaceSessionProvider)?.mode, DocumentModeEnum.split);
  });

  testWidgets('choosing a mode writes it to the session', (
    WidgetTester tester,
  ) async {
    // The bar names no panel: what it writes is the mode, and a descriptor
    // is what says which panels that mode includes.
    await pumpBar(tester);

    await tester.tap(find.text('Preview'));
    await tester.pumpAndSettle();

    expect(
      container.read(spaceSessionProvider)?.mode,
      DocumentModeEnum.preview,
    );
  });

  group('the unsaved mark', () {
    testWidgets('is absent while the buffer and the file agree', (
      WidgetTester tester,
    ) async {
      // A mark that is always there is a mark nobody reads.
      await pumpBar(tester, document: writing);

      expect(find.text('Unsaved'), findsNothing);
    });

    testWidgets('appears the moment something is typed', (
      WidgetTester tester,
    ) async {
      await pumpBar(tester, document: writing);

      container.read(editorProvider.notifier).edit('# changed\n');
      await tester.pumpAndSettle();

      expect(find.text('Unsaved'), findsOneWidget);
    });

    testWidgets('goes once the write lands', (WidgetTester tester) async {
      await pumpBar(tester, document: writing);
      container.read(editorProvider.notifier).edit('# changed\n');
      await tester.pumpAndSettle();

      await container.read(editorProvider.notifier).save();
      await tester.pumpAndSettle();

      expect(find.text('Unsaved'), findsNothing);
    });

    testWidgets('a refused save says so in different words', (
      WidgetTester tester,
    ) async {
      // A save that fails silently is the one thing a text editor may never
      // do: the buffer holds work the file does not.
      documents.refusal = Failure<void, DocumentFailure>(
        DocumentPermissionDenied(writing.value),
      );
      await pumpBar(tester, document: writing);
      container.read(editorProvider.notifier).edit('# changed\n');
      await tester.pumpAndSettle();

      await container.read(editorProvider.notifier).save();
      await tester.pumpAndSettle();

      expect(find.text('Not saved'), findsOneWidget);
      expect(find.text('Unsaved'), findsNothing);
    });
  });
}

/// A repository answering with whatever content the test set.
final class _Documents implements DocumentRepository {
  Result<void, DocumentFailure>? refusal;

  @override
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  ) async => Success<DocumentEntity, DocumentFailure>(
    DocumentEntity(path: path, content: '# ${path.name}\n'),
  );

  @override
  Future<Result<void, DocumentFailure>> write(DocumentEntity document) async =>
      refusal ?? const Success<void, DocumentFailure>(null);
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
