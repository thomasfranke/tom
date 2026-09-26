import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/screens/search/search_panel.dart';
import 'package:tom_desktop/screens/search/widgets/search_hit_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  late _Search search;
  late ProviderContainer container;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );
  final SpaceRelativePathValueObject index = SpaceRelativePathValueObject(
    'index.md',
  );
  final SpaceRelativePathValueObject writing = SpaceRelativePathValueObject(
    'guides/writing.md',
  );

  SearchHitValueObject hit(SpaceRelativePathValueObject path, String excerpt) =>
      SearchHitValueObject(path: path, excerpt: excerpt);

  setUp(() {
    search = _Search();
    // One container per test, not per mount: a second container left alive
    // is still scheduling its disposal, a timer the test framework fails on.
    container = ProviderContainer(
      overrides: <Override>[
        indexSpaceProvider.overrideWithValue(
          IndexSpaceUseCase(
            spaces: _Spaces(),
            searchFor: (SpaceEntity space) => search,
            observability: const _Silent(),
          ),
        ),
        indexDocumentProvider.overrideWithValue(
          IndexDocumentUseCase(
            searchFor: (SpaceEntity space) => search,
            observability: const _Silent(),
          ),
        ),
        searchSpaceProvider.overrideWithValue(
          SearchSpaceUseCase(
            searchFor: (SpaceEntity space) => search,
            observability: const _Silent(),
          ),
        ),
        // Opening a hit is opening a document, which the editor reads.
        readDocumentProvider.overrideWithValue(
          const ReadDocumentUseCase(
            documentsFor: _documentsFor,
            observability: _Silent(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  /// Mounts the panel at the width the shell gives it, with [space] open.
  Future<void> pumpPanel(WidgetTester tester, {SpaceEntity? space}) async {
    tester.view
      ..physicalSize = const Size(1280, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    if (space != null) {
      container.read(spaceSessionProvider.notifier).open(space);
    }
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(Brightness.light),
          home: const Scaffold(
            body: Row(
              children: <Widget>[
                Expanded(child: SizedBox.shrink()),
                SizedBox(width: TomMetrics.git, child: SearchPanel()),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Types [terms] into the box the explorer draws, which is this panel's.
  Future<void> type(WidgetTester tester, String terms) async {
    await container.read(searchProvider.notifier).type(terms);
    await tester.pumpAndSettle();
  }

  testWidgets('it names itself, and says so with no space open', (
    WidgetTester tester,
  ) async {
    await pumpPanel(tester);

    expect(find.text('SEARCH'), findsOneWidget);
    expect(find.text('No space is open.'), findsOneWidget);
  });

  testWidgets('a space that has not been read yet says it is reading', (
    WidgetTester tester,
  ) async {
    search.holds = true;

    await pumpPanel(tester, space: docs);

    expect(find.text('Reading the space…'), findsOneWidget);
    search.release();
    await tester.pumpAndSettle();
  });

  testWidgets('with nothing typed it says where the box is', (
    WidgetTester tester,
  ) async {
    await pumpPanel(tester, space: docs);

    expect(
      find.text('Type above the tree to search this space.'),
      findsOneWidget,
    );
  });

  testWidgets('a hit is the file, the folder it is in, and the excerpt', (
    WidgetTester tester,
  ) async {
    search.hits = <SearchHitValueObject>[
      hit(writing, '…a rendered diff of the document…'),
    ];
    await pumpPanel(tester, space: docs);

    await type(tester, 'rendered');

    expect(find.text('writing.md'), findsOneWidget);
    expect(find.text('guides/'), findsOneWidget);
    expect(
      find.textContaining('rendered diff', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('a document at the space root is in the space itself', (
    WidgetTester tester,
  ) async {
    // Never an empty line where every other row has a folder.
    search.hits = <SearchHitValueObject>[hit(index, '…rendered…')];
    await pumpPanel(tester, space: docs);

    await type(tester, 'rendered');

    expect(find.text('docs/'), findsOneWidget);
  });

  testWidgets('the words that were typed are marked in the excerpt', (
    WidgetTester tester,
  ) async {
    search.hits = <SearchHitValueObject>[hit(index, 'the rendered diff')];
    await pumpPanel(tester, space: docs);

    await type(tester, 'render');

    expect(_marked(tester), <String>['rendered']);
  });

  testWidgets('the panel counts what matched, in words', (
    WidgetTester tester,
  ) async {
    search.hits = <SearchHitValueObject>[
      hit(index, '…rendered…'),
      hit(writing, '…rendered…'),
    ];
    await pumpPanel(tester, space: docs);

    await type(tester, 'rendered');

    expect(find.text('2 documents'), findsOneWidget);
  });

  testWidgets('one is one document, not one documents', (
    WidgetTester tester,
  ) async {
    search.hits = <SearchHitValueObject>[hit(index, '…rendered…')];
    await pumpPanel(tester, space: docs);

    await type(tester, 'rendered');

    expect(find.text('1 document'), findsOneWidget);
  });

  testWidgets('words nothing says are said to find nothing', (
    WidgetTester tester,
  ) async {
    await pumpPanel(tester, space: docs);

    await type(tester, 'wikilinks');

    expect(find.text('No document says that.'), findsOneWidget);
    expect(find.textContaining('documents'), findsNothing);
  });

  testWidgets('clicking a hit opens that document', (
    WidgetTester tester,
  ) async {
    search.hits = <SearchHitValueObject>[hit(writing, '…rendered…')];
    await pumpPanel(tester, space: docs);
    await type(tester, 'rendered');

    await tester.tap(find.text('writing.md'));
    await tester.pumpAndSettle();

    expect(container.read(spaceSessionProvider)?.openDocument, writing);
  });

  testWidgets('an index that could not be built says how to get one', (
    WidgetTester tester,
  ) async {
    search.indexFailure = const SearchIndexCorrupted();

    await pumpPanel(tester, space: docs);

    expect(
      find.text(
        'The index could not be built — reopen the space to try again.',
      ),
      findsOneWidget,
    );
  });
}

/// Every stretch of the excerpt the panel drew as a match.
List<String> _marked(WidgetTester tester) {
  final List<String> marked = <String>[];
  for (final RichText text in tester.widgetList<RichText>(
    find.descendant(
      of: find.byType(SearchHitWidget),
      matching: find.byType(RichText),
    ),
  )) {
    text.text.visitChildren((InlineSpan span) {
      if (span case TextSpan(
        text: final String? content,
        style: TextStyle(fontWeight: FontWeight.w600),
      ) when content != null) {
        marked.add(content);
      }
      return true;
    });
  }
  return marked;
}

/// The search of one space, answering what the test set.
final class _Search implements SearchRepository {
  List<SearchHitValueObject> hits = <SearchHitValueObject>[];
  SearchFailure? indexFailure;

  /// Whether indexing waits to be [release]d, for the state before it lands.
  bool holds = false;
  final List<void Function()> _waiting = <void Function()>[];

  void release() {
    for (final void Function() waiting in _waiting) {
      waiting();
    }
    _waiting.clear();
  }

  @override
  Future<Result<void, SearchFailure>> index(
    List<SpaceRelativePathValueObject> paths,
  ) async {
    if (holds) {
      final Completer<void> held = Completer<void>();
      _waiting.add(held.complete);
      await held.future;
    }
    final SearchFailure? failure = indexFailure;
    return failure == null
        ? const Success<void, SearchFailure>(null)
        : Failure<void, SearchFailure>(failure);
  }

  @override
  Future<Result<void, SearchFailure>> refresh(DocumentEntity document) async =>
      const Success<void, SearchFailure>(null);

  @override
  Future<Result<List<SearchHitValueObject>, SearchFailure>> find(
    String terms, {
    required int limit,
  }) async => Success<List<SearchHitValueObject>, SearchFailure>(hits);
}

/// The documents of a space, which the editor reads through.
DocumentRepository _documentsFor(SpaceEntity space) => const _Documents();

/// A repository that reads an empty document and writes nowhere.
final class _Documents implements DocumentRepository {
  const _Documents();

  @override
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  ) async => Success<DocumentEntity, DocumentFailure>(
    DocumentEntity(path: path, content: ''),
  );

  @override
  Future<Result<void, DocumentFailure>> write(DocumentEntity document) async =>
      const Success<void, DocumentFailure>(null);
}

/// A folder holding one document, which is all the index needs to be built.
final class _Spaces implements SpaceRepository {
  @override
  Future<Result<List<SpaceEntryValueObject>, SpaceFailure>> entries(
    SpaceEntity space,
  ) async => Success<List<SpaceEntryValueObject>, SpaceFailure>(
    <SpaceEntryValueObject>[
      SpaceEntryValueObject(
        path: SpaceRelativePathValueObject('index.md'),
        type: SpaceEntryTypeEnum.file,
      ),
    ],
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
