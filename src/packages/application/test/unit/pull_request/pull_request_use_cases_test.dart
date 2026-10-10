/// The pull request's four use cases over recorded repositories.
library;

import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );
  final BranchNameValueObject feature = BranchNameValueObject('feat/x');
  final BranchNameValueObject main = BranchNameValueObject('main');
  const Observability silent = _Silent();

  CommitEntity commit(String subject) => CommitEntity(
    sha: CommitShaValueObject('a' * 40),
    author: const AuthorValueObject(name: 'Ana', email: 'ana@example.com'),
    date: CommitDateValueObject(utc: DateTime.utc(2026), offset: Duration.zero),
    subject: subject,
    body: '',
  );

  T valueOf<T>(Result<T, AppFailure> result) => switch (result) {
    Success<T, AppFailure>(:final T value) => value,
    Failure<T, AppFailure>(:final AppFailure failure) => throw StateError(
      'expected a success, got $failure',
    ),
  };

  AppFailure failureOf<T>(Result<T, AppFailure> result) => switch (result) {
    Success<T, AppFailure>() => throw StateError('expected a failure'),
    Failure<T, AppFailure>(:final AppFailure failure) => failure,
  };

  group('opening the draft', () {
    late _Git git;
    late _Folder drafts;
    late OpenPullRequestDraftUseCase open;

    setUp(() {
      git = _Git()..commits = <CommitEntity>[commit('Second'), commit('First')];
      drafts = _Folder();
      open = OpenPullRequestDraftUseCase(
        draftsFor: (SpaceEntity _) => drafts,
        gitFor: (SpaceEntity _) => git,
        observability: silent,
      );
    });

    test(
      'a branch with no draft is seeded from git, at its own path',
      () async {
        final DocumentEntity draft = valueOf(
          await open.open(docs, feature, main),
        );

        expect(draft.path.value, 'feat/x.md');
        expect(draft.content, '# First\n\n- Second\n');
        expect(drafts.created, <String>['feat/x.md']);
      },
    );

    test('opening it twice seeds it once', () async {
      await open.open(docs, feature, main);
      drafts.files['feat/x.md'] = '# Mine\n';

      final DocumentEntity again = valueOf(
        await open.open(docs, feature, main),
      );

      expect(again.content, '# Mine\n');
      expect(drafts.created, hasLength(1));
    });

    test(
      'git refusing the commits is the failure, and nothing is written',
      () async {
        git.failure = const GitOperationFailed();

        expect(
          failureOf(await open.open(docs, feature, main)),
          isA<GitFailure>(),
        );
        expect(drafts.created, isEmpty);
      },
    );

    test('a draft that cannot be read is not overwritten by a seed', () async {
      drafts.readFailure = const DocumentPermissionDenied('feat/x.md');

      expect(
        failureOf(await open.open(docs, feature, main)),
        isA<DocumentPermissionDenied>(),
      );
      expect(drafts.created, isEmpty);
    });
  });

  group('reading the proposal', () {
    test('the commits and the changes, handed over unmodifiable', () async {
      final _Git git = _Git()
        ..commits = <CommitEntity>[commit('One')]
        ..changes = <BranchChangeValueObject>[
          BranchChangeValueObject(
            path: RepoRelativePathValueObject('docs/a.md'),
            state: FileStateEnum.added,
            added: 3,
            removed: 0,
          ),
        ];
      final BranchProposalValueObject proposal = valueOf(
        await ReadBranchProposalUseCase(
          gitFor: (SpaceEntity _) => git,
          observability: silent,
        ).read(docs, main),
      );

      expect(proposal.commits, hasLength(1));
      expect(proposal.linesAdded, 3);
      expect(
        () => proposal.changes.add(proposal.changes.first),
        throwsUnsupportedError,
      );
    });

    test('a failure on the way is the failure', () async {
      final _Git git = _Git()..failure = const GitOperationFailed();

      expect(
        failureOf(
          await ReadBranchProposalUseCase(
            gitFor: (SpaceEntity _) => git,
            observability: silent,
          ).read(docs, main),
        ),
        isA<GitFailure>(),
      );
    });
  });

  group('reading the target', () {
    Future<PullRequestTargetValueObject> target(_Git git) async => valueOf(
      await ReadPullRequestTargetUseCase(
        gitFor: (SpaceEntity _) => git,
        observability: silent,
      ).read(docs),
    );

    test('a GitHub address and the remote’s own branch', () async {
      final PullRequestTargetValueObject read = await target(
        _Git()
          ..address = 'git@github.com:acme/docs.git'
          ..defaultName = main,
      );

      expect(read.project?.host, RemoteHostEnum.github);
      expect(read.defaultBranch, main);
      expect(read.hasRemote, isTrue);
      expect(read.branch, BranchNameValueObject('feat/guide'));
    });

    test('no remote and an unknown host are both no project, told apart by '
        'whether there is a remote', () async {
      final PullRequestTargetValueObject none = await target(_Git());
      final PullRequestTargetValueObject unknown = await target(
        _Git()..address = 'https://git.acme.dev/docs.git',
      );

      expect(none.project, isNull);
      expect(none.hasRemote, isFalse);
      expect(unknown.project, isNull);
      expect(unknown.hasRemote, isTrue);
    });

    test('a detached HEAD is no branch, and says so', () async {
      final PullRequestTargetValueObject read = await target(
        _Git()
          ..address = 'git@github.com:acme/docs.git'
          ..detached = true,
      );

      expect(read.branch, isNull);
      expect(read.isDetached, isTrue);
    });
  });

  group('reading the overview', () {
    ReadBranchOverviewUseCase overviewOf(_Git git) => ReadBranchOverviewUseCase(
      gitFor: (SpaceEntity _) => git,
      blocks: const _Lines(),
      differ: const BlockDifferService(aligner: _Replace()),
      observability: silent,
    );

    BranchProposalValueObject proposal(List<String> paths) =>
        BranchProposalValueObject(
          commits: <CommitEntity>[commit('One')],
          changes: <BranchChangeValueObject>[
            for (final String p in paths)
              BranchChangeValueObject(
                path: RepoRelativePathValueObject(p),
                state: FileStateEnum.modified,
                added: 1,
                removed: 1,
              ),
          ],
        );

    test('words come from markdown documents only', () async {
      final _Git git = _Git()
        ..fork = CommitShaValueObject('b' * 40)
        ..content = <String, String>{'HEAD': 'two new', 'b' * 40: 'old'};

      final BranchOverviewValueObject read = valueOf(
        await overviewOf(
          git,
        ).read(docs, main, proposal(<String>['a.md', 'logo.png'])),
      );

      expect(read.wordsAdded, 2);
      expect(read.wordsRemoved, 1);
      expect(git.shown.where((String it) => it.endsWith('logo.png')), isEmpty);
    });

    test('no shared history reads every word of HEAD as added', () async {
      final _Git git = _Git()..content = <String, String>{'HEAD': 'all of it'};

      final BranchOverviewValueObject read = valueOf(
        await overviewOf(git).read(docs, main, proposal(<String>['a.md'])),
      );

      expect(read.wordsAdded, 3);
      expect(read.wordsRemoved, 0);
    });
  });
}

/// Git, answering what a test set.
final class _Git implements GitRepository {
  List<CommitEntity> commits = <CommitEntity>[];
  List<BranchChangeValueObject> changes = <BranchChangeValueObject>[];
  String? address;
  BranchNameValueObject? defaultName;
  CommitShaValueObject? fork;
  Map<String, String> content = <String, String>{};
  final List<String> shown = <String>[];
  GitFailure? failure;

  Result<T, GitFailure> _answer<T>(T value) => failure == null
      ? Success<T, GitFailure>(value)
      : Failure<T, GitFailure>(failure!);

  @override
  Future<Result<List<CommitEntity>, GitFailure>> commitsSince(
    BranchNameValueObject base,
  ) async => _answer(commits);

  @override
  Future<Result<List<BranchChangeValueObject>, GitFailure>> changesSince(
    BranchNameValueObject base,
  ) async => _answer(changes);

  @override
  Future<Result<String?, GitFailure>> remoteAddress() async => _answer(address);

  /// The branch checked out; null with [detached] is a detached `HEAD`.
  BranchNameValueObject? current = BranchNameValueObject('feat/guide');
  bool detached = false;

  @override
  Future<Result<GitStatusValueObject, GitFailure>> status() async => _answer(
    GitStatusValueObject(
      branch: detached ? null : current,
      upstream: null,
      ahead: 0,
      behind: 0,
      entries: const <StatusEntryValueObject>[],
      isDetached: detached,
    ),
  );

  @override
  Future<Result<BranchNameValueObject?, GitFailure>> defaultBranch() async =>
      _answer(defaultName);

  @override
  Future<Result<CommitShaValueObject?, GitFailure>> forkPoint(
    BranchNameValueObject base,
  ) async => _answer(fork);

  @override
  Future<Result<String, GitFailure>> contentAt({
    required String revision,
    required RepoRelativePathValueObject path,
  }) async {
    shown.add('$revision:${path.value}');
    final String? text = content[revision];
    return text == null
        ? Failure<String, GitFailure>(GitPathNotInRevision(path.value))
        : Success<String, GitFailure>(text);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A folder of drafts kept in a map.
final class _Folder implements DocumentRepository {
  final Map<String, String> files = <String, String>{};
  final List<String> created = <String>[];
  DocumentFailure? readFailure;

  @override
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  ) async {
    if (readFailure case final DocumentFailure failure) {
      return Failure<DocumentEntity, DocumentFailure>(failure);
    }
    final String? text = files[path.value];
    return text == null
        ? Failure<DocumentEntity, DocumentFailure>(DocumentNotFound(path.value))
        : Success<DocumentEntity, DocumentFailure>(
            DocumentEntity(path: path, content: text),
          );
  }

  @override
  Future<Result<void, DocumentFailure>> create(DocumentEntity document) async {
    created.add(document.path.value);
    files[document.path.value] = document.content;
    return const Success<void, DocumentFailure>(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Every non-empty line is a paragraph.
final class _Lines implements BlockReaderPort {
  const _Lines();

  @override
  Future<Result<ParsedDocumentValueObject, DocumentFailure>> read(
    DocumentEntity document,
  ) async => Success<ParsedDocumentValueObject, DocumentFailure>(
    ParsedDocumentValueObject(
      document: document,
      blocks: <BlockValueObject>[
        for (final String line in document.content.split('\n'))
          if (line.isNotEmpty)
            BlockValueObject(
              startLine: 0,
              endLine: 0,
              source: line,
              kind: BlockKindEnum.paragraph,
            ),
      ],
      linkDefinitions: '',
    ),
  );
}

/// Nothing pairs: every old block removed, every new one added.
final class _Replace implements BlockAlignerPort {
  const _Replace();

  @override
  Future<Result<List<SequenceEditValueObject>, DocumentFailure>> align(
    ParsedDocumentValueObject before,
    ParsedDocumentValueObject after, {
    required double threshold,
  }) async => Success<List<SequenceEditValueObject>, DocumentFailure>(<
    SequenceEditValueObject
  >[
    for (int i = 0; i < before.blocks.length; i++)
      SequenceEditValueObject(
        kind: SequenceEditKindEnum.removed,
        beforeIndex: i,
      ),
    for (int i = 0; i < after.blocks.length; i++)
      SequenceEditValueObject(kind: SequenceEditKindEnum.added, afterIndex: i),
  ]);
}

final class _Silent implements Observability {
  const _Silent();

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async {}
}
