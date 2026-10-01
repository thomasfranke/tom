/// [SearchRepositoryImpl] against an index and a filesystem that answer on
/// command, because neither a sqlite refusal nor `EIO` can be asked for.
library;

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late _ScriptedIndex index;
  late _ScriptedFilesystem filesystem;
  late SearchRepositoryImpl repository;

  // A folder inside a repository, because that is where a path bug shows.
  final SpaceEntity space = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );

  setUp(() {
    index = _ScriptedIndex();
    filesystem = _ScriptedFilesystem();
    repository = SearchRepositoryImpl(
      search: SearchDataSource(index: index),
      documents: DocumentDataSource(filesystem: filesystem),
      space: space,
    );
  });

  /// What [result] failed with, or a failure of the test if it succeeded.
  F failureOf<T, F extends AppFailure>(Result<T, F> result) => switch (result) {
    Success<T, F>() => throw StateError('expected a failure, got a success'),
    Failure<T, F>(failure: final F failure) => failure,
  };

  group('indexing', () {
    test('reads each document against the space, not the repository', () async {
      await repository.index(<SpaceRelativePathValueObject>[
        SpaceRelativePathValueObject('adr/001.md'),
      ]);

      expect(filesystem.readPaths, <String>['/code/app/docs/adr/001.md']);
    });

    test('files every document under its own path', () async {
      filesystem.contents = <String, String>{
        '/code/app/docs/index.md': '# Index\n',
        '/code/app/docs/adr/001.md': '# Why markdown\n',
      };

      await repository.index(<SpaceRelativePathValueObject>[
        SpaceRelativePathValueObject('index.md'),
        SpaceRelativePathValueObject('adr/001.md'),
      ]);

      expect(
        index.held.map((IndexedDocumentDto it) => (it.key, it.text)),
        <(String, String)>[
          ('index.md', '# Index\n'),
          ('adr/001.md', '# Why markdown\n'),
        ],
      );
    });

    test('a file that cannot be read costs that file, not the index', () async {
      // One document missing from the results is a smaller lie than no
      // search at all.
      filesystem
        ..contents = <String, String>{'/code/app/docs/index.md': '# Index\n'}
        ..missing = <String>{'/code/app/docs/gone.md'};

      final Result<void, SearchFailure> result = await repository
          .index(<SpaceRelativePathValueObject>[
            SpaceRelativePathValueObject('gone.md'),
            SpaceRelativePathValueObject('index.md'),
          ]);

      expect(result, isA<Success<void, SearchFailure>>());
      expect(index.held.single.key, 'index.md');
    });

    test('an index that refuses says the index has to be rebuilt', () async {
      index.failure = const SearchIndexFailed('disk I/O error');

      expect(
        failureOf(await repository.index(<SpaceRelativePathValueObject>[])),
        isA<SearchIndexCorrupted>(),
      );
    });
  });

  group('refreshing one document', () {
    test('files it under its path, with the text it was handed', () async {
      // The document as the editor holds it, not as the disk has it: the
      // index is asked to say what was just written.
      await repository.refresh(
        DocumentEntity(
          path: SpaceRelativePathValueObject('index.md'),
          content: '# Index\n',
        ),
      );

      expect(index.filed?.key, 'index.md');
      expect(index.filed?.text, '# Index\n');
      expect(filesystem.readPaths, isEmpty);
    });
  });

  group('finding', () {
    test('hands the terms and the limit over unchanged', () async {
      await repository.find('rendered diff', limit: 12);

      expect(index.asked, 'rendered diff');
      expect(index.limited, 12);
    });

    test('keeps the order the index ranked them in', () async {
      index.hits = <SearchHitDto>[
        const SearchHitDto(key: 'index.md', excerpt: '…a rendered diff…'),
        const SearchHitDto(key: 'adr/001.md', excerpt: '…rendered…'),
      ];

      final Result<List<SearchHitValueObject>, SearchFailure> result =
          await repository.find('rendered', limit: 50);

      expect(
        (result as Success<List<SearchHitValueObject>, SearchFailure>).value
            .map((SearchHitValueObject it) => it.path.value),
        <String>['index.md', 'adr/001.md'],
      );
    });

    test('a key the space no longer spells as a path is dropped', () async {
      // The index is a cache, and a stale entry is not something to hand to
      // the file tree.
      index.hits = <SearchHitDto>[
        const SearchHitDto(key: '/tmp/elsewhere.md', excerpt: '…rendered…'),
        const SearchHitDto(key: 'index.md', excerpt: '…rendered…'),
      ];

      final Result<List<SearchHitValueObject>, SearchFailure> result =
          await repository.find('rendered', limit: 50);

      expect(
        (result as Success<List<SearchHitValueObject>, SearchFailure>)
            .value
            .single
            .path
            .value,
        'index.md',
      );
    });

    test('an index that refuses says the index has to be rebuilt', () async {
      index.failure = const SearchIndexFailed('database is locked');

      expect(
        failureOf(await repository.find('rendered', limit: 50)),
        isA<SearchIndexCorrupted>(),
      );
    });
  });
}

/// An index that answers what the test set, and keeps what it was given.
final class _ScriptedIndex implements SearchIndex {
  List<IndexedDocumentDto> held = <IndexedDocumentDto>[];
  IndexedDocumentDto? filed;
  List<SearchHitDto> hits = <SearchHitDto>[];
  String? asked;
  int? limited;

  /// What every call fails with, or null to succeed.
  SearchIndexFailure? failure;

  @override
  Future<Result<void, SearchIndexFailure>> replaceAll(
    List<IndexedDocumentDto> documents,
  ) async {
    held = documents;
    return _refusedOr(const Success<void, SearchIndexFailure>(null));
  }

  @override
  Future<Result<void, SearchIndexFailure>> put(
    IndexedDocumentDto document,
  ) async {
    filed = document;
    return _refusedOr(const Success<void, SearchIndexFailure>(null));
  }

  @override
  Future<Result<List<SearchHitDto>, SearchIndexFailure>> find(
    String terms, {
    required int limit,
  }) async {
    asked = terms;
    limited = limit;
    return _refusedOr(Success<List<SearchHitDto>, SearchIndexFailure>(hits));
  }

  @override
  void dispose() {}

  /// [answer], or what the test said every call refuses with.
  Result<T, SearchIndexFailure> _refusedOr<T>(
    Result<T, SearchIndexFailure> answer,
  ) {
    final SearchIndexFailure? refused = failure;
    return refused == null ? answer : Failure<T, SearchIndexFailure>(refused);
  }
}

/// A filesystem that reads what the test wrote into it.
final class _ScriptedFilesystem implements Filesystem {
  Map<String, String> contents = <String, String>{};
  Set<String> missing = <String>{};
  final List<String> readPaths = <String>[];

  @override
  Future<Result<String, FilesystemFailure>> readFile(String path) async {
    readPaths.add(path);
    return missing.contains(path)
        ? Failure<String, FilesystemFailure>(FilesystemEntryNotFound(path))
        : Success<String, FilesystemFailure>(contents[path] ?? '');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
