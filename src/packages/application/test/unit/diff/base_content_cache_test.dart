/// [BaseContentCache]: what is asked of git once, and what is never kept.
library;

import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  late BaseContentCache cache;
  late int asked;
  final RepoRelativePathValueObject path = RepoRelativePathValueObject(
    'docs/a.md',
  );

  setUp(() {
    cache = BaseContentCache();
    asked = 0;
  });

  Future<Result<String, GitFailure>> read(
    Result<String, GitFailure> answer, {
    String revision = 'abc',
    RepoRelativePathValueObject? at,
  }) => cache.read(
    revision: revision,
    path: at ?? path,
    ask: () async {
      asked++;
      return answer;
    },
  );

  test('the second read of a revision and path asks nothing', () async {
    await read(const Success<String, GitFailure>('# A\n'));
    final Result<String, GitFailure> again = await read(
      const Success<String, GitFailure>('changed'),
    );

    expect(asked, 1);
    expect((again as Success<String, GitFailure>).value, '# A\n');
  });

  test('another revision or another path is another entry', () async {
    await read(const Success<String, GitFailure>('one'));
    await read(const Success<String, GitFailure>('two'), revision: 'def');
    await read(
      const Success<String, GitFailure>('three'),
      at: RepoRelativePathValueObject('docs/b.md'),
    );

    expect(asked, 3);
  });

  test('a file the revision does not have is empty, and remembered', () async {
    final Result<String, GitFailure> first = await read(
      const Failure<String, GitFailure>(GitPathNotInRevision('docs/a.md')),
    );
    final Result<String, GitFailure> second = await read(
      const Success<String, GitFailure>('would be ignored'),
    );

    expect((first as Success<String, GitFailure>).value, '');
    expect((second as Success<String, GitFailure>).value, '');
    expect(asked, 1);
  });

  test('any other failure comes back and is not remembered', () async {
    final Result<String, GitFailure> first = await read(
      const Failure<String, GitFailure>(GitCommandDenied()),
    );
    final Result<String, GitFailure> second = await read(
      const Success<String, GitFailure>('now'),
    );

    expect(
      (first as Failure<String, GitFailure>).failure,
      isA<GitCommandDenied>(),
    );
    expect((second as Success<String, GitFailure>).value, 'now');
    expect(asked, 2);
  });

  group('baseOf', () {
    GitStatusValueObject statusOf(FileStateEnum state) => GitStatusValueObject(
      branch: null,
      upstream: null,
      ahead: 0,
      behind: 0,
      isDetached: false,
      entries: <StatusEntryValueObject>[
        StatusEntryValueObject(path: path, state: state, isStaged: false),
      ],
    );

    Future<Result<String, GitFailure>> base(
      GitStatusValueObject? status, {
      String revision = 'HEAD',
      BaseContentCache? kept,
    }) => BaseContentCache.baseOf(
      revision: revision,
      path: path,
      cache: kept,
      status: status,
      ask: () async {
        asked++;
        return const Success<String, GitFailure>('committed');
      },
    );

    test('a path the status calls new is never asked about', () async {
      for (final FileStateEnum state in <FileStateEnum>[
        FileStateEnum.untracked,
        FileStateEnum.added,
        FileStateEnum.renamed,
      ]) {
        final Result<String, GitFailure> result = await base(statusOf(state));
        expect((result as Success<String, GitFailure>).value, '');
      }
      expect(asked, 0);
    });

    test('a modified path, or no status, is asked', () async {
      await base(statusOf(FileStateEnum.modified));
      await base(null);

      expect(asked, 2);
    });

    test('only HEAD is short-cut: a fork point is asked', () async {
      await base(statusOf(FileStateEnum.untracked), revision: 'abc');

      expect(asked, 1);
    });

    test('with a cache, the second read is still one question', () async {
      final BaseContentCache kept = BaseContentCache();
      await base(null, kept: kept);
      await base(null, kept: kept);

      expect(asked, 1);
    });
  });

  test('clearing makes the next read ask again', () async {
    await read(const Success<String, GitFailure>('one'));

    cache.clear();
    await read(const Success<String, GitFailure>('two'));

    expect(asked, 2);
  });
}
