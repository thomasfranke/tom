import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  late _Git git;
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

  BranchEntity branch(String name, {bool isCurrent = false}) =>
      BranchEntity(name: BranchNameValueObject(name), isCurrent: isCurrent);

  setUp(() {
    git = _Git()
      ..reported = <BranchEntity>[
        branch('feat/one'),
        branch('main', isCurrent: true),
        branch('fix/two'),
      ];
    documents = _Documents();
    container = ProviderContainer(
      overrides: <Override>[
        listBranchesProvider.overrideWithValue(
          ListBranchesUseCase(
            gitFor: (SpaceEntity space) => git,
            observability: const _Silent(),
          ),
        ),
        switchBranchProvider.overrideWithValue(
          SwitchBranchUseCase(
            gitFor: (SpaceEntity space) => git,
            observability: const _Silent(),
          ),
        ),
        // A switch re-reads the status, the folder and the buffer, so a test
        // that switches needs all three wired.
        readGitStatusProvider.overrideWithValue(
          ReadGitStatusUseCase(
            gitFor: (SpaceEntity space) => git,
            observability: const _Silent(),
          ),
        ),
        listSpaceEntriesProvider.overrideWithValue(
          const ListSpaceEntriesUseCase(
            spaces: _NothingInIt(),
            observability: _Silent(),
          ),
        ),
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

  /// Starts the notifiers over an open space and lets the first reads land.
  Future<void> open({bool withDocument = false}) async {
    container
      ..listen<BranchesState>(branchesProvider, (_, _) {})
      ..listen<ChangesState>(changesProvider, (_, _) {})
      ..listen<EditorState>(editorProvider, (_, _) {})
      ..read(spaceSessionProvider.notifier).open(docs);
    if (withDocument) {
      container.read(spaceSessionProvider.notifier).show(note);
    }
    await Future<void>.delayed(Duration.zero);
  }

  /// Types into the open document, so the buffer stops matching the disk.
  void typeSomething() =>
      container.read(editorProvider.notifier).edit('changed');

  BranchesNotifier notifier() => container.read(branchesProvider.notifier);
  BranchesState state() => container.read(branchesProvider);
  BranchesReady ready() => state() as BranchesReady;

  /// The names the surface would draw, in the order it would draw them.
  List<String> visible() =>
      state().visible.map((BranchEntity it) => it.name.value).toList();

  test('with no space open nothing reaches git', () async {
    container.listen<BranchesState>(branchesProvider, (_, _) {});

    await notifier().choose(BranchNameValueObject('main'));

    expect(git.listed, 0);
    expect(state(), isA<BranchesInitial>());
  });

  group('the list', () {
    test('it puts the checked-out branch first and keeps the rest', () async {
      await open();

      expect(visible(), <String>['main', 'feat/one', 'fix/two']);
    });

    test('typing narrows it, ignoring case', () async {
      await open();

      notifier().type('FE');

      expect(visible(), <String>['feat/one']);
    });

    test('a failure to list is a state, not an empty list', () async {
      git.branchesAnswer = const Failure<List<BranchEntity>, GitFailure>(
        GitOperationFailed(),
      );

      await open();

      expect(state(), isA<BranchesFailed>());
    });
  });

  group('switching', () {
    test('choosing the branch you are on does nothing', () async {
      await open();

      await notifier().choose(BranchNameValueObject('main'));

      expect(git.switched, isEmpty);
    });

    test('choosing another one checks it out', () async {
      await open();

      await notifier().choose(BranchNameValueObject('feat/one'));

      expect(git.switched, <String>['feat/one']);
      expect(git.created, isEmpty);
    });

    test('and everything the checkout rewrote is read again', () async {
      await open(withDocument: true);
      final int readsBefore = documents.reads;
      final int statusBefore = git.statuses;

      await notifier().choose(BranchNameValueObject('feat/one'));

      expect(git.statuses, greaterThan(statusBefore));
      expect(documents.reads, greaterThan(readsBefore));
    });

    test('a refusal is kept and nothing else is claimed', () async {
      await open();
      git.moveAnswer = const Failure<void, GitFailure>(GitOperationFailed());

      await notifier().choose(BranchNameValueObject('feat/one'));

      expect(ready().failure, isA<GitOperationFailed>());
      expect(ready().isBusy, isFalse);
    });
  });

  group('unsaved work', () {
    test('a switch that would lose the buffer asks instead', () async {
      await open(withDocument: true);
      typeSomething();

      await notifier().choose(BranchNameValueObject('feat/one'));

      expect(ready().pending?.value, 'feat/one');
      expect(git.switched, isEmpty);
    });

    test('saving first writes the buffer, then switches', () async {
      await open(withDocument: true);
      typeSomething();
      await notifier().choose(BranchNameValueObject('feat/one'));

      await notifier().saveAndSwitch();

      expect(documents.written, <String>['changed']);
      expect(git.switched, <String>['feat/one']);
      expect(ready().pending, isNull);
    });

    test('a save that failed leaves the question standing', () async {
      await open(withDocument: true);
      typeSomething();
      await notifier().choose(BranchNameValueObject('feat/one'));
      documents.refuseWrites = true;

      await notifier().saveAndSwitch();

      expect(git.switched, isEmpty);
      expect(ready().pending?.value, 'feat/one');
    });

    test(
      'discarding switches, and the buffer comes back off the disk',
      () async {
        await open(withDocument: true);
        typeSomething();
        await notifier().choose(BranchNameValueObject('feat/one'));

        await notifier().discardAndSwitch();

        expect(documents.written, isEmpty);
        expect(git.switched, <String>['feat/one']);
        expect(container.read(editorProvider).isDirty, isFalse);
      },
    );

    test('staying leaves both the branch and the buffer alone', () async {
      await open(withDocument: true);
      typeSomething();
      await notifier().choose(BranchNameValueObject('feat/one'));

      notifier().cancelSwitch();

      expect(ready().pending, isNull);
      expect(git.switched, isEmpty);
      expect(container.read(editorProvider).isDirty, isTrue);
    });

    test('closing the surface is the same as staying', () async {
      await open(withDocument: true);
      typeSomething();
      await notifier().choose(BranchNameValueObject('feat/one'));

      notifier().dismiss();

      expect(ready().pending, isNull);
      expect(git.switched, isEmpty);
    });
  });

  group('starting a branch', () {
    test('the name carries over from the filter', () async {
      await open();
      notifier().type('feat/three');

      notifier().startCreating();

      expect(ready().draft, 'feat/three');
      expect(state().canCreate, isTrue);
    });

    test('it creates rather than switches, and moves onto it', () async {
      await open();
      notifier()
        ..startCreating()
        ..type('feat/three');

      await notifier().create();

      expect(git.created, <String>['feat/three']);
      expect(git.switched, isEmpty);
    });

    test('a name git would refuse is said while it is typed', () async {
      await open();
      notifier()
        ..startCreating()
        ..type('feat/..three');

      expect(ready().rejected, isNotNull);
      expect(state().canCreate, isFalse);
    });

    test('so is a name that is already taken', () async {
      await open();
      notifier()
        ..startCreating()
        ..type('main');

      expect(ready().rejected, isNotNull);
      expect(state().canCreate, isFalse);
    });

    test('creating it also asks about an unsaved buffer', () async {
      await open(withDocument: true);
      typeSomething();
      notifier()
        ..startCreating()
        ..type('feat/three');

      await notifier().create();

      expect(ready().pending?.value, 'feat/three');
      expect(git.created, isEmpty);
    });

    test('and answering that question still creates it', () async {
      await open(withDocument: true);
      typeSomething();
      notifier()
        ..startCreating()
        ..type('feat/three');
      await notifier().create();

      await notifier().discardAndSwitch();

      expect(git.created, <String>['feat/three']);
      expect(git.switched, isEmpty);
    });
  });

  test('going back to the list keeps the name that was being typed', () async {
    await open();
    notifier()
      ..startCreating()
      ..type('feat/three');

    notifier().stopCreating();

    expect(ready().isCreating, isFalse);
    expect(ready().draft, 'feat/three');
    expect(ready().rejected, isNull);
  });

  test('another space starts with nothing said about the last one', () async {
    await open();
    notifier()
      ..startCreating()
      ..type('feat/three');

    container
        .read(spaceSessionProvider.notifier)
        .open(
          SpaceEntity(
            root: '/code/other',
            repositoryRoot: '/code/other',
            name: 'other',
          ),
        );
    await Future<void>.delayed(Duration.zero);

    expect(ready().isCreating, isFalse);
    expect(ready().draft, isEmpty);
  });
}

/// Git, answering what the test set and remembering what it was asked.
final class _Git implements GitRepository {
  List<BranchEntity> reported = <BranchEntity>[];
  Result<List<BranchEntity>, GitFailure>? branchesAnswer;
  Result<void, GitFailure>? moveAnswer;

  int listed = 0;
  int statuses = 0;
  final List<String> switched = <String>[];
  final List<String> created = <String>[];

  @override
  Future<Result<List<BranchEntity>, GitFailure>> branches() async {
    listed++;
    return branchesAnswer ?? Success<List<BranchEntity>, GitFailure>(reported);
  }

  @override
  Future<Result<void, GitFailure>> switchBranch(
    BranchNameValueObject name,
  ) async {
    if (moveAnswer case final Failure<void, GitFailure> refused) {
      return refused;
    }
    switched.add(name.value);
    return const Success<void, GitFailure>(null);
  }

  @override
  Future<Result<void, GitFailure>> createBranch(
    BranchNameValueObject name,
  ) async {
    if (moveAnswer case final Failure<void, GitFailure> refused) {
      return refused;
    }
    created.add(name.value);
    return const Success<void, GitFailure>(null);
  }

  @override
  Future<Result<GitStatusValueObject, GitFailure>> status() async {
    statuses++;
    return Success<GitStatusValueObject, GitFailure>(
      GitStatusValueObject(
        branch: BranchNameValueObject('main'),
        upstream: null,
        ahead: 0,
        behind: 0,
        entries: const <StatusEntryValueObject>[],
        isDetached: false,
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// One document on disk, which always reads back as what was written.
final class _Documents implements DocumentRepository {
  String content = 'on the disk';
  bool refuseWrites = false;

  int reads = 0;
  final List<String> written = <String>[];

  @override
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  ) async {
    reads++;
    return Success<DocumentEntity, DocumentFailure>(
      DocumentEntity(path: path, content: content),
    );
  }

  @override
  Future<Result<void, DocumentFailure>> write(DocumentEntity document) async {
    if (refuseWrites) {
      return Failure<void, DocumentFailure>(
        DocumentOperationFailed(document.path.value),
      );
    }
    written.add(document.content);
    content = document.content;
    return const Success<void, DocumentFailure>(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A space that holds nothing, so the tree has nothing to draw.
final class _NothingInIt implements SpaceRepository {
  const _NothingInIt();

  @override
  Future<Result<List<SpaceEntryValueObject>, SpaceFailure>> entries(
    SpaceEntity space,
  ) async => const Success<List<SpaceEntryValueObject>, SpaceFailure>(
    <SpaceEntryValueObject>[],
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
