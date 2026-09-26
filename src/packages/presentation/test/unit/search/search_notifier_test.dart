import 'dart:async';

import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  late _Search search;
  late _Spaces spaces;
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
    spaces = _Spaces()
      ..held = <SpaceEntryValueObject>[
        SpaceEntryValueObject(
          path: SpaceRelativePathValueObject('guides'),
          type: SpaceEntryTypeEnum.directory,
        ),
        SpaceEntryValueObject(path: writing, type: SpaceEntryTypeEnum.file),
        SpaceEntryValueObject(path: index, type: SpaceEntryTypeEnum.file),
      ];
    container = ProviderContainer(
      overrides: <Override>[
        indexSpaceProvider.overrideWithValue(
          IndexSpaceUseCase(
            spaces: spaces,
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
        // The search follows the editor's document, so opening one is a read.
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

  /// Starts the panel, and answers its first state.
  SearchState start() {
    container.listen<SearchState>(searchProvider, (_, _) {});
    return container.read(searchProvider);
  }

  /// Everything scheduled, run.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  SearchNotifier notifier() => container.read(searchProvider.notifier);

  SearchState state() => container.read(searchProvider);

  test('with no space open there is nothing to search', () async {
    expect(start(), isA<SearchIdle>());
    await settle();

    expect(state(), isA<SearchIdle>());
  });

  test('a space that opens is read into the index, then searchable', () async {
    container.read(spaceSessionProvider.notifier).open(docs);

    expect(start(), isA<SearchIndexing>());
    await settle();

    expect(state(), isA<SearchReady>());
    // The listing is the file tree's, and only its documents are filed.
    expect(search.indexed, <SpaceRelativePathValueObject>[writing, index]);
  });

  test('what was typed while it built is searched for once it is', () async {
    container.read(spaceSessionProvider.notifier).open(docs);
    start();
    search.hits = <SearchHitValueObject>[hit(index, '…the rendered diff…')];

    await notifier().type('rendered');

    expect(state(), isA<SearchIndexing>());
    expect(state().terms, 'rendered');
    await settle();

    expect(search.asked, <String>['rendered']);
    expect((state() as SearchReady).hits, hasLength(1));
  });

  test('typing asks the index, and the hits keep its order', () async {
    container.read(spaceSessionProvider.notifier).open(docs);
    start();
    await settle();
    search.hits = <SearchHitValueObject>[
      hit(index, '…a rendered diff…'),
      hit(writing, '…rendered…'),
    ];

    await notifier().type('rendered');

    expect(
      (state() as SearchReady).hits.map((SearchHitValueObject it) => it.name),
      <String>['index.md', 'writing.md'],
    );
  });

  test('an empty box asks nothing and shows nothing', () async {
    container.read(spaceSessionProvider.notifier).open(docs);
    start();
    await settle();
    search.hits = <SearchHitValueObject>[hit(index, '…rendered…')];
    await notifier().type('rendered');

    await notifier().clear();

    expect(search.asked, <String>['rendered']);
    expect((state() as SearchReady).hits, isEmpty);
    expect(state().terms, isEmpty);
  });

  test('an answer to an older question is dropped', () async {
    // Another keystroke has already asked a better one, and the slower
    // answer must not replace it.
    container.read(spaceSessionProvider.notifier).open(docs);
    start();
    await settle();
    search
      ..echoes = true
      ..holds = true;
    final Future<void> slow = notifier().type('rend');
    search.holds = false;
    await notifier().type('rendered');
    search.release();
    await slow;
    await settle();

    expect(state().terms, 'rendered');
    expect((state() as SearchReady).hits.single.excerpt, '…rendered…');
  });

  test(
    'the document the editor holds is filed again, and the box re-asked',
    () async {
      // The index is a cache over the files, and the one in the editor is the
      // one most likely to be searched for next.
      container.read(spaceSessionProvider.notifier).open(docs);
      start();
      await settle();
      await notifier().type('rendered');
      final int asked = search.asked.length;

      container.read(spaceSessionProvider.notifier).show(index);
      await settle();
      await settle();

      expect(search.refiled, <SpaceRelativePathValueObject>[index]);
      expect(search.asked.length, greaterThan(asked));
    },
  );

  test('clicking a hit opens that document', () async {
    container.read(spaceSessionProvider.notifier).open(docs);
    start();
    await settle();

    notifier().open(hit(writing, '…rendered…'));

    expect(container.read(spaceSessionProvider)?.openDocument, writing);
  });

  test('a space that cannot be indexed says so', () async {
    search.indexFailure = const SearchIndexCorrupted();
    container.read(spaceSessionProvider.notifier).open(docs);

    start();
    await settle();

    expect(state(), isA<SearchFailed>());
  });
}

/// The search of one space, answering what the test set.
final class _Search implements SearchRepository {
  List<SpaceRelativePathValueObject> indexed = <SpaceRelativePathValueObject>[];
  List<SpaceRelativePathValueObject> refiled = <SpaceRelativePathValueObject>[];
  List<String> asked = <String>[];
  List<SearchHitValueObject> hits = <SearchHitValueObject>[];
  SearchFailure? indexFailure;

  /// Whether a search waits to be [release]d, for the stale-answer case.
  bool holds = false;

  /// Whether a hit echoes the terms it answered, so a late answer is telling.
  bool echoes = false;
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
    indexed = paths;
    final SearchFailure? failure = indexFailure;
    return failure == null
        ? const Success<void, SearchFailure>(null)
        : Failure<void, SearchFailure>(failure);
  }

  @override
  Future<Result<void, SearchFailure>> refresh(DocumentEntity document) async {
    refiled.add(document.path);
    return const Success<void, SearchFailure>(null);
  }

  @override
  Future<Result<List<SearchHitValueObject>, SearchFailure>> find(
    String terms, {
    required int limit,
  }) async {
    asked.add(terms);
    if (holds) {
      final Completer<void> held = Completer<void>();
      _waiting.add(held.complete);
      await held.future;
    }
    return Success<List<SearchHitValueObject>, SearchFailure>(
      echoes
          ? <SearchHitValueObject>[
              SearchHitValueObject(
                path: SpaceRelativePathValueObject('index.md'),
                excerpt: '…$terms…',
              ),
            ]
          : hits,
    );
  }
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

/// The folder, answering what the test set.
final class _Spaces implements SpaceRepository {
  List<SpaceEntryValueObject> held = <SpaceEntryValueObject>[];

  @override
  Future<Result<List<SpaceEntryValueObject>, SpaceFailure>> entries(
    SpaceEntity space,
  ) async => Success<List<SpaceEntryValueObject>, SpaceFailure>(held);

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
