import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
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
  final SpaceRelativePathValueObject index = SpaceRelativePathValueObject(
    'index.md',
  );

  CommitEntity commit(String sha, String subject) => CommitEntity(
    sha: CommitShaValueObject(sha.padRight(40, '0')),
    author: const AuthorValueObject(
      name: 'Thomas Franke',
      email: 'thomas@example.invalid',
    ),
    date: CommitDateValueObject(
      utc: DateTime.utc(2026, 9, 20),
      offset: Duration.zero,
    ),
    subject: subject,
    body: '',
  );

  setUp(() {
    git = _Git()
      ..reported = <CommitEntity>[
        commit('abc1234', 'docs: the second pass'),
        commit('def5678', 'docs: the first pass'),
      ];
    container = ProviderContainer(
      overrides: <Override>[
        readFileHistoryProvider.overrideWithValue(
          ReadFileHistoryUseCase(
            gitFor: (SpaceEntity space) => git,
            observability: const _Silent(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  /// Starts the notifier over an open space, and lets the first read land.
  Future<void> open({SpaceRelativePathValueObject? document}) async {
    container
      ..listen<HistoryState>(historyProvider, (_, _) {})
      ..read(spaceSessionProvider.notifier).open(docs);
    if (document != null) {
      container.read(spaceSessionProvider.notifier).show(document);
    }
    await Future<void>.delayed(Duration.zero);
  }

  HistoryNotifier notifier() => container.read(historyProvider.notifier);
  HistoryState state() => container.read(historyProvider);
  CommitEntity? reading() =>
      container.read(spaceSessionProvider)?.readingVersion;

  test('with no document open nothing reaches git', () async {
    await open();

    expect(git.asked, isEmpty);
    expect(state(), isA<HistoryIdle>());
  });

  test('opening a document asks about that document', () async {
    await open(document: writing);

    expect(git.asked, <String>['docs/guides/writing.md']);
    expect(
      (state() as HistoryReady).commits.map((CommitEntity c) => c.subject),
      <String>['docs: the second pass', 'docs: the first pass'],
    );
  });

  test('another document is another history', () async {
    await open(document: writing);

    container.read(spaceSessionProvider.notifier).show(index);
    await Future<void>.delayed(Duration.zero);

    expect(git.asked, <String>['docs/guides/writing.md', 'docs/index.md']);
  });

  test('a file git has never seen is an empty list, not a failure', () async {
    git.reported = <CommitEntity>[];

    await open(document: writing);

    expect((state() as HistoryReady).commits, isEmpty);
  });

  test('a repository that would not answer is a state of its own', () async {
    git.answer = const Failure<List<CommitEntity>, GitFailure>(
      GitOperationFailed(),
    );

    await open(document: writing);

    expect(state(), isA<HistoryFailed>());
  });

  group('opening a version', () {
    test('it is written to the session, not kept here', () async {
      await open(document: writing);
      final CommitEntity second = (state() as HistoryReady).commits.first;

      notifier().open(second);

      expect(reading(), second);
    });

    test('going back to now clears it', () async {
      await open(document: writing);
      notifier().open((state() as HistoryReady).commits.first);

      notifier().closeVersion();

      expect(reading(), isNull);
    });

    test('opening another document goes back to now on its own', () async {
      await open(document: writing);
      notifier().open((state() as HistoryReady).commits.first);

      container.read(spaceSessionProvider.notifier).show(index);
      await Future<void>.delayed(Duration.zero);

      expect(reading(), isNull);
    });
  });

  test('refreshing asks again, for the same document', () async {
    await open(document: writing);

    await notifier().refresh();

    expect(git.asked, <String>[
      'docs/guides/writing.md',
      'docs/guides/writing.md',
    ]);
  });
}

/// Git, answering what the test set and remembering what it was asked.
final class _Git implements GitRepository {
  List<CommitEntity> reported = <CommitEntity>[];
  Result<List<CommitEntity>, GitFailure>? answer;

  final List<String> asked = <String>[];

  @override
  Future<Result<List<CommitEntity>, GitFailure>> history({
    RepoRelativePathValueObject? path,
    int? limit,
  }) async {
    asked.add(path?.value ?? '<the whole repository>');
    return answer ?? Success<List<CommitEntity>, GitFailure>(reported);
  }

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
