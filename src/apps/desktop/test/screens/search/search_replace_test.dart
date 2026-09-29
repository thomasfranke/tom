import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/screens/file_tree/file_tree_panel.dart';
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
  final SpaceRelativePathValueObject note = SpaceRelativePathValueObject(
    'note.md',
  );

  setUp(() {
    documents = _Documents();
    const _Silent silent = _Silent();
    container = ProviderContainer(
      overrides: <Override>[
        listSpaceEntriesProvider.overrideWithValue(
          const ListSpaceEntriesUseCase(
            spaces: _NothingInIt(),
            observability: silent,
          ),
        ),
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
        indexSpaceProvider.overrideWithValue(
          const IndexSpaceUseCase(
            spaces: _NothingInIt(),
            searchFor: _emptyIndex,
            observability: silent,
          ),
        ),
        indexDocumentProvider.overrideWithValue(
          const IndexDocumentUseCase(
            searchFor: _emptyIndex,
            observability: silent,
          ),
        ),
        searchSpaceProvider.overrideWithValue(
          const SearchSpaceUseCase(
            searchFor: _emptyIndex,
            observability: silent,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  /// Mounts the left column with a document open, asking about this file.
  Future<void> pumpColumn(WidgetTester tester, {String? terms}) async {
    tester.view
      ..physicalSize = const Size(1280, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    container
      ..listen<EditorState>(editorProvider, (_, _) {})
      ..read(spaceSessionProvider.notifier).open(docs)
      ..read(spaceSessionProvider.notifier).show(note);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(Brightness.dark),
          home: const Scaffold(
            body: Row(
              children: <Widget>[
                SizedBox(width: TomMetrics.explorer, child: FileTreePanel()),
                Expanded(child: SizedBox.shrink()),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await container
        .read(searchProvider.notifier)
        .scopeTo(SearchScopeEnum.thisFile);
    if (terms != null) {
      await container.read(searchProvider.notifier).type(terms);
    }
    await tester.pumpAndSettle();
  }

  SearchReady ready() => container.read(searchProvider) as SearchReady;

  testWidgets('the second box is not there until the chevron opens it', (
    WidgetTester tester,
  ) async {
    // Replacing is the rarer half, and a box nobody uses is a box in the way
    // of the results (`docs/product/search/replacing/doc.md`).
    await pumpColumn(tester, terms: 'palette');

    expect(find.text('Replace with'), findsNothing);

    await tester.tap(find.byTooltip('Replace'));
    await tester.pumpAndSettle();

    expect(find.text('Replace with'), findsOneWidget);
  });

  testWidgets('an occurrence is its heading and the line it sits in', (
    WidgetTester tester,
  ) async {
    documents.content = '# Visual language\n\nValues live in palette.py.\n';

    await pumpColumn(tester, terms: 'palette');

    expect(find.text('1 occurrence in note.md'), findsOneWidget);
    expect(find.text('Visual language'), findsOneWidget);
  });

  testWidgets('with nothing to replace with, the count stands alone', (
    WidgetTester tester,
  ) async {
    // `Replace all` belongs beside the count, and only once there is a
    // replacement to make.
    documents.content = 'a palette here\n';

    await pumpColumn(tester, terms: 'palette');

    expect(find.text('Replace all'), findsNothing);

    await tester.tap(find.byTooltip('Replace'));
    await tester.pumpAndSettle();

    expect(find.text('Replace all'), findsOneWidget);
  });

  testWidgets('the row carries the two actions, and only the current one', (
    WidgetTester tester,
  ) async {
    documents.content = 'a palette and a palette\n';
    await pumpColumn(tester, terms: 'palette');

    await tester.tap(find.byTooltip('Replace'));
    await tester.pumpAndSettle();

    expect(ready().occurrences.length, 2);
    expect(find.byTooltip('Replace this one'), findsOneWidget);
    expect(find.byTooltip('Skip this one'), findsOneWidget);
  });

  testWidgets('skipping one takes it off the list without writing', (
    WidgetTester tester,
  ) async {
    documents.content = 'a palette and a palette\n';
    await pumpColumn(tester, terms: 'palette');
    await tester.tap(find.byTooltip('Replace'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Skip this one'));
    await tester.pumpAndSettle();

    expect(ready().occurrences.length, 1);
    expect(documents.written, isEmpty);
  });

  testWidgets('and replacing one writes it into the buffer', (
    WidgetTester tester,
  ) async {
    documents.content = 'a palette here\n';
    await pumpColumn(tester, terms: 'palette');
    await tester.tap(find.byTooltip('Replace'));
    await tester.pumpAndSettle();
    container.read(searchProvider.notifier).replaceWith('swatch');
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Replace this one'));
    await tester.pumpAndSettle();

    expect(
      (container.read(editorProvider) as EditorReady).source,
      'a swatch here\n',
    );
    expect(documents.written, isEmpty, reason: 'the buffer, never the disk');
  });
}

/// A space with nothing in it; these tests are about the column.
final class _NothingInIt implements SpaceRepository {
  const _NothingInIt();

  @override
  Future<Result<SpaceEntity, AppFailure>> open(String folder) async =>
      throw UnimplementedError();

  @override
  Future<Result<List<SpaceEntryValueObject>, SpaceFailure>> entries(
    SpaceEntity space,
  ) async => const Success<List<SpaceEntryValueObject>, SpaceFailure>(
    <SpaceEntryValueObject>[],
  );
}

/// An index that answers nothing; the whole-space half has its own test.
SearchRepository _emptyIndex(SpaceEntity space) => const _NoIndex();

final class _NoIndex implements SearchRepository {
  const _NoIndex();

  @override
  Future<Result<void, SearchFailure>> index(
    List<SpaceRelativePathValueObject> paths,
  ) async => const Success<void, SearchFailure>(null);

  @override
  Future<Result<void, SearchFailure>> refresh(DocumentEntity document) async =>
      const Success<void, SearchFailure>(null);

  @override
  Future<Result<List<SearchHitValueObject>, SearchFailure>> find(
    String terms, {
    required int limit,
  }) async => const Success<List<SearchHitValueObject>, SearchFailure>(
    <SearchHitValueObject>[],
  );
}

/// The one document these tests open, and what was written to it.
final class _Documents implements DocumentRepository {
  String content = 'a palette here\n';
  final List<String> written = <String>[];

  @override
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  ) async => Success<DocumentEntity, DocumentFailure>(
    DocumentEntity(path: path, content: content),
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
