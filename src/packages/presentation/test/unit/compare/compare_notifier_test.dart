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
  final SpaceRelativePathValueObject index = SpaceRelativePathValueObject(
    'index.md',
  );

  BranchEntity branch(String name, {bool isCurrent = false}) =>
      BranchEntity(name: BranchNameValueObject(name), isCurrent: isCurrent);

  CommitEntity commit(String sha, String subject) => CommitEntity(
    sha: CommitShaValueObject(sha.padRight(40, '0')),
    author: const AuthorValueObject(name: 'Test', email: 'test@example.com'),
    date: CommitDateValueObject(utc: DateTime.utc(2026), offset: Duration.zero),
    subject: subject,
    body: '',
  );

  setUp(() {
    git = _Git()
      ..reportedBranches = <BranchEntity>[
        branch('main', isCurrent: true),
        branch('feat/rendered-diff'),
      ]
      ..reportedCommits = <CommitEntity>[
        commit('aaa1', 'docs: fix a typo in the index'),
        commit('bbb2', 'docs: expand the index'),
      ];
    container = ProviderContainer(
      overrides: <Override>[
        listBranchesProvider.overrideWithValue(
          ListBranchesUseCase(
            gitFor: (SpaceEntity space) => git,
            observability: const _Silent(),
          ),
        ),
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

  /// Starts the surface, and answers its first state.
  CompareState start() {
    container.listen<CompareState>(compareProvider, (_, _) {});
    return container.read(compareProvider);
  }

  /// Opens the space, and the document when [withDocument].
  void open({bool withDocument = true}) {
    container.read(spaceSessionProvider.notifier).open(docs);
    if (withDocument) {
      container.read(spaceSessionProvider.notifier).show(index);
    }
  }

  /// Everything scheduled, run.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  CompareReady ready() => container.read(compareProvider) as CompareReady;

  CompareNotifier notifier() => container.read(compareProvider.notifier);

  RevisionValueObject? base() =>
      container.read(spaceSessionProvider)?.comparingAgainst;

  test('with no document open there is nothing to compare', () async {
    open(withDocument: false);

    expect(start(), isA<CompareIdle>());
    await settle();

    expect(container.read(compareProvider), isA<CompareIdle>());
  });

  test('it offers the branches and this document\'s commits', () async {
    open();
    start();
    await settle();
    await settle();

    expect(ready().branches.map((BranchEntity it) => it.name.value), <String>[
      'main',
      'feat/rendered-diff',
    ]);
    expect(ready().commits.map((CommitEntity it) => it.subject), <String>[
      'docs: fix a typo in the index',
      'docs: expand the index',
    ]);
  });

  test('it asks git nothing of its own', () async {
    // The branches are the switcher's reading and the commits are the history
    // panel's: a second reading is what would let this list disagree with
    // what is already on screen.
    open();
    start();
    await settle();
    await settle();

    expect(git.branchesAsked, 1);
    expect(git.historyAsked, 1);
  });

  group('the filter', () {
    test('narrows both lists at once', () async {
      open();
      start();
      await settle();
      await settle();

      notifier().type('index');

      expect(ready().visibleBranches, isEmpty);
      expect(ready().visibleCommits, hasLength(2));
    });

    test('matches a branch by name, ignoring case', () async {
      open();
      start();
      await settle();
      await settle();

      notifier().type('FEAT');

      expect(
        ready().visibleBranches.map((BranchEntity it) => it.name.value),
        <String>['feat/rendered-diff'],
      );
    });

    test('matches a commit by its sha, named as elsewhere', () async {
      open();
      start();
      await settle();
      await settle();

      notifier().type('bbb2');

      expect(
        ready().visibleCommits.map((CommitEntity it) => it.subject),
        <String>['docs: expand the index'],
      );
    });

    test('a list arriving does not empty the box being typed into', () async {
      open();
      start();
      await settle();
      await settle();
      notifier().type('feat');

      // What a switch does: the branches are read again underneath, and a
      // different list comes back.
      git.reportedBranches = <BranchEntity>[branch('main', isCurrent: true)];
      container.invalidate(branchesProvider);
      await settle();
      await settle();

      expect(ready().draft, 'feat');
      expect(ready().branches, hasLength(1));
    });
  });

  group('choosing a base', () {
    test('writes it to the session, where the preview reads it', () async {
      open();
      start();
      await settle();
      await settle();

      notifier().choose(RevisionValueObject.branch(ready().branches.last));

      expect(base(), RevisionValueObject.branch(branch('feat/rendered-diff')));
    });

    test('a commit is a base too, and carries the whole commit', () async {
      // The bar names the author and the age, so a sha alone would need a
      // second lookup that could disagree with this list.
      open();
      start();
      await settle();
      await settle();

      notifier().choose(RevisionValueObject.commit(ready().commits.first));

      expect(
        base(),
        RevisionValueObject.commit(
          commit('aaa1', 'docs: fix a typo in the index'),
        ),
      );
    });

    test('and keeps nothing half-typed', () async {
      open();
      start();
      await settle();
      await settle();
      notifier().type('feat');

      notifier().choose(RevisionValueObject.branch(ready().branches.first));

      expect(ready().draft, isEmpty);
    });

    test('stopping goes back to the default, the one way back', () async {
      open();
      start();
      await settle();
      await settle();
      notifier().choose(RevisionValueObject.branch(ready().branches.first));

      notifier().stop();

      expect(base(), isNull);
    });
  });

  test('the base survives opening another document', () async {
    // Comparing a branch is done one file at a time, so a base that reset on
    // every click would make that a chore.
    open();
    start();
    await settle();
    await settle();
    notifier().choose(RevisionValueObject.branch(ready().branches.last));

    container
        .read(spaceSessionProvider.notifier)
        .show(SpaceRelativePathValueObject('guides/writing.md'));
    await settle();

    expect(base(), isNotNull);
  });
}

/// Git, answering with whatever the test said the repository holds.
final class _Git implements GitRepository {
  List<BranchEntity> reportedBranches = <BranchEntity>[];
  List<CommitEntity> reportedCommits = <CommitEntity>[];

  /// How many times each list was read, which is what "no second reading"
  /// is measured in.
  int branchesAsked = 0;
  int historyAsked = 0;

  @override
  Future<Result<List<BranchEntity>, GitFailure>> branches() async {
    branchesAsked++;
    return Success<List<BranchEntity>, GitFailure>(reportedBranches);
  }

  @override
  Future<Result<List<CommitEntity>, GitFailure>> history({
    RepoRelativePathValueObject? path,
    int? limit,
  }) async {
    historyAsked++;
    return Success<List<CommitEntity>, GitFailure>(reportedCommits);
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
