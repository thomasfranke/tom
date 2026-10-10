import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  late _Git git;
  late _Desktop desktop;
  _Tree? tree;
  _Editor? editor;
  late ProviderContainer container;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );
  final RepoRelativePathValueObject writing = RepoRelativePathValueObject(
    'docs/guides/writing.md',
  );
  final RepoRelativePathValueObject index = RepoRelativePathValueObject(
    'docs/index.md',
  );

  StatusEntryValueObject entry(
    RepoRelativePathValueObject path, {
    required bool isStaged,
  }) => StatusEntryValueObject(
    path: path,
    state: FileStateEnum.modified,
    isStaged: isStaged,
  );

  GitStatusValueObject statusOf(List<StatusEntryValueObject> entries) =>
      GitStatusValueObject(
        branch: BranchNameValueObject('main'),
        upstream: BranchNameValueObject('origin/main'),
        ahead: 0,
        behind: 0,
        entries: entries,
        isDetached: false,
      );

  setUp(() {
    desktop = _Desktop();
    git = _Git()
      ..reported = statusOf(<StatusEntryValueObject>[
        entry(writing, isStaged: false),
        entry(index, isStaged: false),
      ]);
    container = ProviderContainer(
      overrides: <Override>[
        readGitStatusProvider.overrideWithValue(
          ReadGitStatusUseCase(
            gitFor: (SpaceEntity space) => git,
            observability: const _Silent(),
          ),
        ),
        readMergeStateProvider.overrideWithValue(
          ReadMergeStateUseCase(
            gitFor: (SpaceEntity space) => git,
            observability: const _Silent(),
          ),
        ),
        stageChangesProvider.overrideWithValue(
          StageChangesUseCase(
            gitFor: (SpaceEntity space) => git,
            documentsFor: (SpaceEntity space) => const _NoDocuments(),
            observability: const _Silent(),
          ),
        ),
        commitChangesProvider.overrideWithValue(
          CommitChangesUseCase(
            gitFor: (SpaceEntity space) => git,
            observability: const _Silent(),
          ),
        ),
        discardAllChangesProvider.overrideWithValue(
          DiscardAllChangesUseCase(
            gitFor: (SpaceEntity space) => git,
            observability: const _Silent(),
          ),
        ),
        discardChangeProvider.overrideWithValue(
          DiscardChangeUseCase(
            gitFor: (SpaceEntity space) => git,
            observability: const _Silent(),
          ),
        ),
        openTerminalProvider.overrideWithValue(
          OpenTerminalUseCase(desktop: desktop, observability: const _Silent()),
        ),
        revealFolderProvider.overrideWithValue(
          RevealFolderUseCase(desktop: desktop, observability: const _Silent()),
        ),
        readFileHistoryProvider.overrideWithValue(
          ReadFileHistoryUseCase(
            gitFor: (SpaceEntity space) => git,
            observability: const _Silent(),
          ),
        ),
        fileTreeProvider.overrideWith(() => tree = _Tree()),
        editorProvider.overrideWith(() => editor = _Editor()),
      ],
    );
    addTearDown(container.dispose);
  });

  /// Starts the panel, and answers its first state.
  ChangesState start() {
    container.listen<ChangesState>(changesProvider, (_, _) {});
    return container.read(changesProvider);
  }

  /// Everything scheduled, run.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  /// What the whole window knows about git.
  GitStatusValueObject? observed() => container.read(spaceSessionProvider)?.git;

  ChangesReady ready() => container.read(changesProvider) as ChangesReady;

  group('the git menu', () {
    setUp(() async {
      start();
      container.read(spaceSessionProvider.notifier).open(docs);
      await settle();
    });

    test('Discard all changes asks git, then reads everything again', () async {
      final int before = git.asked;

      await container.read(changesProvider.notifier).discardAll();

      expect(git.discards, 1);
      expect(git.asked, before + 1);
      expect(tree?.refreshes, 1);
      expect(editor?.reloads, 1);
    });

    test('Open in terminal opens at the repository\'s root', () async {
      await container.read(changesProvider.notifier).openTerminalHere();

      expect(desktop.asked, <String>['terminal /code/app']);
    });

    test('the file manager is shown the repository, not the space', () async {
      await container.read(changesProvider.notifier).revealRepository();

      expect(desktop.asked, <String>['reveal /code/app']);
    });
  });

  group('the ↶ at the end of a row', () {
    final SpaceRelativePathValueObject open = SpaceRelativePathValueObject(
      'guides/writing.md',
    );

    setUp(() async {
      start();
      container.read(spaceSessionProvider.notifier)
        ..open(docs)
        ..show(open);
      await settle();
    });

    test('a row in CHANGES goes back as staged, and is read again', () async {
      final int before = git.asked;

      await container
          .read(changesProvider.notifier)
          .discard(entry(writing, isStaged: false));

      expect(git.discarded.single.$1, DiscardKindEnum.toStaged);
      expect(git.discarded.single.$2, <RepoRelativePathValueObject>[writing]);
      expect(git.asked, before + 1);
      expect(editor?.reloads, 1);
      expect(tree?.refreshes, 1);
      expect(container.read(spaceSessionProvider)!.tabs, <DocumentTab>[
        DocumentTab.inSpace(open),
      ]);
    });

    test('a file outside the space, on screen, is read again too', () async {
      final RepoRelativePathValueObject readme = RepoRelativePathValueObject(
        'README.md',
      );
      container.read(spaceSessionProvider.notifier).showOutside(readme);

      await container
          .read(changesProvider.notifier)
          .discard(entry(readme, isStaged: false));

      expect(editor?.reloads, 1);
    });

    test('another document on screen is not read again', () async {
      await container
          .read(changesProvider.notifier)
          .discard(entry(index, isStaged: true));

      expect(git.discarded.single.$1, DiscardKindEnum.toLastCommit);
      expect(editor?.reloads, 0);
    });

    test('a file git never had is deleted, and its tab closes', () async {
      await container
          .read(changesProvider.notifier)
          .discard(
            StatusEntryValueObject(
              path: writing,
              state: FileStateEnum.untracked,
              isStaged: false,
            ),
          );

      expect(git.discarded.single.$1, DiscardKindEnum.delete);
      final SpaceSessionState session = container.read(spaceSessionProvider)!;
      expect(session.tabs, isEmpty);
      expect(session.openDocument, isNull);
    });

    test('a conflicted file offers nothing, and asks git nothing', () async {
      final StatusEntryValueObject conflicted = StatusEntryValueObject(
        path: writing,
        state: FileStateEnum.conflicted,
        isStaged: false,
      );
      final ChangesNotifier changes = container.read(changesProvider.notifier);

      expect(changes.canDiscard(conflicted), isFalse);
      expect(changes.canDiscard(entry(writing, isStaged: true)), isTrue);
      await changes.discard(conflicted);

      expect(git.discarded, isEmpty);
    });

    test('a refusal is said, and the tab stays', () async {
      git.writeFailure = const GitOperationFailed();

      await container
          .read(changesProvider.notifier)
          .discard(
            StatusEntryValueObject(
              path: writing,
              state: FileStateEnum.added,
              isStaged: true,
            ),
          );

      expect(ready().failure, isA<GitOperationFailed>());
      expect(container.read(spaceSessionProvider)!.tabs, <DocumentTab>[
        DocumentTab.inSpace(open),
      ]);
      expect(tree?.refreshes, 0);
    });
  });

  group('pressing a row', () {
    setUp(() async {
      start();
      container.read(spaceSessionProvider.notifier)
        ..open(docs)
        ..decorate(showing: false);
      await settle();
    });

    test('opens its document with the diff on', () async {
      await container
          .read(changesProvider.notifier)
          .open(entry(writing, isStaged: false));

      final SpaceSessionState session = container.read(spaceSessionProvider)!;
      expect(
        session.openDocument,
        SpaceRelativePathValueObject('guides/writing.md'),
      );
      expect(session.showingDiff, isTrue);
    });

    test('a markdown file outside the space opens too, in a tab of its own, '
        'with the diff on', () async {
      final RepoRelativePathValueObject readme = RepoRelativePathValueObject(
        'README.md',
      );
      final ChangesNotifier changes = container.read(changesProvider.notifier);
      expect(changes.canOpen(entry(readme, isStaged: true)), isTrue);

      await changes.open(entry(readme, isStaged: true));

      final SpaceSessionState session = container.read(spaceSessionProvider)!;
      // Not the tree's: no document of the space is open.
      expect(session.openDocument, isNull);
      expect(session.outsideDocument, readme);
      expect(session.tabs, <DocumentTab>[DocumentTab.outside(readme)]);
      expect(session.showingDiff, isTrue);
      expect(session.readingVersion, isNull);
    });

    test('a deleted document opens in preview, and is not a version being '
        'read', () async {
      final RepoRelativePathValueObject gone = RepoRelativePathValueObject(
        'notes/gone.md',
      );
      container
          .read(spaceSessionProvider.notifier)
          .look(DocumentModeEnum.split);

      await container
          .read(changesProvider.notifier)
          .open(
            StatusEntryValueObject(
              path: gone,
              state: FileStateEnum.deleted,
              isStaged: false,
            ),
          );

      final SpaceSessionState session = container.read(spaceSessionProvider)!;
      expect(session.outsideDocument, gone);
      expect(session.readingVersion, isNull);
      expect(session.mode, DocumentModeEnum.preview);
      expect(session.isSourceOnly, isFalse, reason: 'every mode stays');
      expect(git.loggedPath, isNull, reason: 'no history is asked for');
    });

    test('a deleted file that is not markdown leaves the mode alone', () async {
      container
          .read(spaceSessionProvider.notifier)
          .look(DocumentModeEnum.split);

      await container
          .read(changesProvider.notifier)
          .open(
            StatusEntryValueObject(
              path: RepoRelativePathValueObject('docs/old.yaml'),
              state: FileStateEnum.deleted,
              isStaged: true,
            ),
          );

      final SpaceSessionState session = container.read(spaceSessionProvider)!;
      expect(session.mode, DocumentModeEnum.split);
      expect(session.drawnMode, DocumentModeEnum.source);
    });

    test('a file that is not markdown opens too, source only, with the diff '
        'on', () async {
      final ChangesNotifier changes = container.read(changesProvider.notifier);
      final RepoRelativePathValueObject logo = RepoRelativePathValueObject(
        'docs/logo.svg',
      );
      final RepoRelativePathValueObject main = RepoRelativePathValueObject(
        'src/main.dart',
      );
      expect(changes.canOpen(entry(logo, isStaged: false)), isTrue);
      expect(changes.canOpen(entry(main, isStaged: true)), isTrue);

      await changes.open(entry(logo, isStaged: false));
      SpaceSessionState session = container.read(spaceSessionProvider)!;
      expect(session.openDocument, SpaceRelativePathValueObject('logo.svg'));
      expect(session.showingDiff, isTrue);
      expect(session.isSourceOnly, isTrue);

      await changes.open(entry(main, isStaged: true));
      session = container.read(spaceSessionProvider)!;
      expect(session.outsideDocument, main);
      expect(session.drawnMode, DocumentModeEnum.source);
    });

    test('with no repository, no row opens', () async {
      container
          .read(spaceSessionProvider.notifier)
          .open(SpaceEntity(root: '/notes', repositoryRoot: null, name: 'n'));
      final ChangesNotifier changes = container.read(changesProvider.notifier);

      expect(changes.canOpen(entry(index, isStaged: false)), isFalse);
      await changes.open(entry(index, isStaged: false));
      expect(container.read(spaceSessionProvider)!.onScreen, isNull);
    });
  });

  test('with no space open there is nothing to report on', () async {
    expect(start(), isA<ChangesInitial>());
    await settle();

    expect(git.asked, 0);
  });

  test('opening a space asks git, and the session gets the answer', () async {
    start();
    container.read(spaceSessionProvider.notifier).open(docs);

    expect(container.read(changesProvider), isA<ChangesLoading>());
    await settle();

    expect(container.read(changesProvider), isA<ChangesReady>());
    expect(observed()?.branch, BranchNameValueObject('main'));
    expect(observed()?.entries, hasLength(2));
  });

  test('a column opened after the space finds the reading there', () async {
    // The column was shut when the space opened: git was read without it.
    container
      ..listen<GitReadingState>(gitReadingProvider, (_, _) {})
      ..read(spaceSessionProvider.notifier).open(docs);
    await settle();
    final int asked = git.asked;

    expect(start(), isA<ChangesReady>());
    expect(git.asked, asked, reason: 'the column reads no git of its own');
  });

  test('a repository that will not answer clears the session too', () async {
    git.statusFailure = const GitNotARepository('/code/app');
    start();
    container.read(spaceSessionProvider.notifier).open(docs);
    await settle();

    expect(
      (container.read(changesProvider) as ChangesFailed).failure,
      const GitNotARepository('/code/app'),
    );
    expect(observed(), isNull);
  });

  group('a pull that stopped mid-merge', () {
    /// The status a conflicted pull leaves: two documents marked C.
    void conflicted() {
      git
        ..reported = statusOf(<StatusEntryValueObject>[
          StatusEntryValueObject(
            path: writing,
            state: FileStateEnum.conflicted,
            isStaged: false,
          ),
          StatusEntryValueObject(
            path: index,
            state: FileStateEnum.conflicted,
            isStaged: false,
          ),
        ])
        ..merge = const MergeStateValueObject(
          inProgress: true,
          message: "Merge branch 'main' into feat/rendered-diff",
        );
    }

    test('the merge lands on the session beside the status', () async {
      conflicted();
      start();
      container.read(spaceSessionProvider.notifier).open(docs);
      await settle();

      expect(container.read(spaceSessionProvider)?.merge?.inProgress, isTrue);
    });

    test(
      'the documents still to resolve are counted from the status',
      () async {
        conflicted();
        start();
        container.read(spaceSessionProvider.notifier).open(docs);
        await settle();

        final SpaceSessionState session = container.read(spaceSessionProvider)!;
        expect(session.toResolve, hasLength(2));
        expect(session.isResolvingMerge, isTrue);
      },
    );

    test('a reading asked for elsewhere fills an empty box too', () async {
      // A pull ends in the git reading, not in this panel.
      start();
      container.read(spaceSessionProvider.notifier).open(docs);
      await settle();
      conflicted();

      await container.read(gitReadingProvider.notifier).refresh();

      expect(ready().message, "Merge branch 'main' into feat/rendered-diff");
    });

    test('the message box starts from the draft git wrote', () async {
      conflicted();
      start();
      container.read(spaceSessionProvider.notifier).open(docs);
      await settle();

      expect(ready().message, "Merge branch 'main' into feat/rendered-diff");
    });

    // A sentence somebody is typing is theirs: a merge arriving must not
    // replace it, which is the same rule that keeps a reload from emptying
    // the box.
    test('a draft being typed is never replaced by it', () async {
      start();
      container.read(spaceSessionProvider.notifier).open(docs);
      await settle();
      container
          .read(changesProvider.notifier)
          .describe('docs: my own sentence');
      conflicted();

      await container.read(changesProvider.notifier).setAllStaged(staged: true);
      await settle();

      expect(ready().message, 'docs: my own sentence');
    });

    test(
      'a repository at rest leaves the box empty and the session clear',
      () async {
        start();
        container.read(spaceSessionProvider.notifier).open(docs);
        await settle();

        final SpaceSessionState session = container.read(spaceSessionProvider)!;
        expect(session.merge?.inProgress, isFalse);
        expect(session.isResolvingMerge, isFalse);
        expect(session.toResolve, isEmpty);
        expect(ready().message, isEmpty);
      },
    );
  });

  group('staging', () {
    test('a row goes into the index, and git is read again', () async {
      start();
      container.read(spaceSessionProvider.notifier).open(docs);
      await settle();
      git.reported = statusOf(<StatusEntryValueObject>[
        entry(writing, isStaged: true),
        entry(index, isStaged: false),
      ]);

      await container.read(changesProvider.notifier).setStaged(writing, true);

      expect(git.staged, <RepoRelativePathValueObject>[writing]);
      expect(observed()?.entries.first.isStaged, isTrue);
    });

    test('and comes back out again', () async {
      start();
      container.read(spaceSessionProvider.notifier).open(docs);
      await settle();

      await container.read(changesProvider.notifier).setStaged(writing, false);

      expect(git.unstaged, <RepoRelativePathValueObject>[writing]);
    });

    test('all stages only what is not staged yet', () async {
      git.reported = statusOf(<StatusEntryValueObject>[
        entry(writing, isStaged: true),
        entry(index, isStaged: false),
      ]);
      start();
      container.read(spaceSessionProvider.notifier).open(docs);
      await settle();

      await container.read(changesProvider.notifier).setAllStaged(staged: true);

      expect(git.staged, <RepoRelativePathValueObject>[index]);
    });

    test('and none takes back only what is staged', () async {
      git.reported = statusOf(<StatusEntryValueObject>[
        entry(writing, isStaged: true),
        entry(index, isStaged: false),
      ]);
      start();
      container.read(spaceSessionProvider.notifier).open(docs);
      await settle();

      await container
          .read(changesProvider.notifier)
          .setAllStaged(staged: false);

      expect(git.unstaged, <RepoRelativePathValueObject>[writing]);
    });

    test('with no space open it does nothing at all', () async {
      start();

      await container.read(changesProvider.notifier).setAllStaged(staged: true);

      expect(git.staged, isEmpty);
      expect(git.unstaged, isEmpty);
    });

    test('a refusal keeps the panel usable and says what happened', () async {
      start();
      container.read(spaceSessionProvider.notifier).open(docs);
      await settle();
      git.writeFailure = const GitOperationFailed();

      await container.read(changesProvider.notifier).setStaged(writing, true);

      expect(ready().failure, const GitOperationFailed());
      expect(ready().isBusy, isFalse);
    });

    test('the message being typed survives the re-read', () async {
      start();
      container.read(spaceSessionProvider.notifier).open(docs);
      await settle();
      container.read(changesProvider.notifier).describe('docs: rewrite');

      await container.read(changesProvider.notifier).setStaged(writing, true);

      expect(ready().message, 'docs: rewrite');
    });

    test('a message typed while git was busy is not thrown away', () async {
      start();
      container.read(spaceSessionProvider.notifier).open(docs);
      await settle();

      final Future<void> staging = container
          .read(changesProvider.notifier)
          .setStaged(writing, true);
      container.read(changesProvider.notifier).describe('docs: typed during');
      await staging;

      expect(ready().message, 'docs: typed during');
    });
  });

  group('committing', () {
    Future<void> describeAndCommit(String message) async {
      container.read(changesProvider.notifier).describe(message);
      await container.read(changesProvider.notifier).commit();
    }

    test('it records the message and empties the box', () async {
      start();
      container.read(spaceSessionProvider.notifier).open(docs);
      await settle();
      git.reported = statusOf(const <StatusEntryValueObject>[]);

      await describeAndCommit('docs: say what changed');

      expect(git.messages, <String>['docs: say what changed']);
      expect(ready().message, '');
      expect(observed()?.entries, isEmpty);
    });

    test('while it runs the panel knows it is the commit, and after it does '
        'not', () async {
      start();
      container.read(spaceSessionProvider.notifier).open(docs);
      await settle();
      container.read(changesProvider.notifier).describe('docs: say it');

      final Future<void> committing = container
          .read(changesProvider.notifier)
          .commit();

      expect(ready().isBusy, isTrue);
      expect(ready().isCommitting, isTrue);
      await committing;
      expect(ready().isCommitting, isFalse);
    });

    test('a commit that failed is no longer committing', () async {
      start();
      container.read(spaceSessionProvider.notifier).open(docs);
      await settle();
      git.writeFailure = const GitOperationFailed();

      await describeAndCommit('docs: say what changed');

      expect(ready().isCommitting, isFalse);
      expect(ready().isBusy, isFalse);
    });

    test('staging is busy without being the commit', () async {
      start();
      container.read(spaceSessionProvider.notifier).open(docs);
      await settle();

      final Future<void> staging = container
          .read(changesProvider.notifier)
          .setStaged(writing, true);

      expect(ready().isBusy, isTrue);
      expect(ready().isCommitting, isFalse);
      await staging;
    });

    test('a blank message commits nothing', () async {
      start();
      container.read(spaceSessionProvider.notifier).open(docs);
      await settle();

      await describeAndCommit('   ');

      expect(git.messages, isEmpty);
    });

    test('the message is trimmed on its way to git', () async {
      start();
      container.read(spaceSessionProvider.notifier).open(docs);
      await settle();

      await describeAndCommit('  docs: say what changed\n');

      expect(git.messages, <String>['docs: say what changed']);
    });

    test('a commit that failed keeps the sentence somebody wrote', () async {
      start();
      container.read(spaceSessionProvider.notifier).open(docs);
      await settle();
      git.writeFailure = const GitOperationFailed();

      await describeAndCommit('docs: say what changed');

      expect(ready().message, 'docs: say what changed');
      expect(ready().failure, const GitOperationFailed());
    });
  });

  group('a command the person refuses', () {
    setUp(() async {
      start();
      container.read(spaceSessionProvider.notifier).open(docs);
      await settle();
      git.writeFailure = const GitCommandDenied();
    });

    test('is not said: the column is usable, and git is read again', () async {
      final int before = git.asked;

      await container.read(changesProvider.notifier).setStaged(writing, true);

      expect(ready().failure, isNull);
      expect(ready().isBusy, isFalse);
      expect(git.asked, before + 1, reason: 'the window shows what is true');
    });

    test(
      'a refused commit keeps the sentence, and is not committing',
      () async {
        container.read(changesProvider.notifier).describe('docs: rewrite');

        await container.read(changesProvider.notifier).commit();

        expect(ready().message, 'docs: rewrite');
        expect(ready().failure, isNull);
        expect(ready().isCommitting, isFalse);
      },
    );

    test('a refused discard keeps the tab and the buffer over it', () async {
      final DocumentTab tab = DocumentTab.of(docs, writing);
      container.read(spaceSessionProvider.notifier).choose(tab);

      await container
          .read(changesProvider.notifier)
          .discard(entry(writing, isStaged: false));

      expect(ready().failure, isNull);
      expect(editor?.reloads ?? 0, 0);
      expect(tree?.refreshes ?? 0, 0);
      expect(container.read(spaceSessionProvider)?.tabs, contains(tab));
    });

    test('a refused Discard all reads no document again', () async {
      git.discardAllFailure = const GitCommandDenied();

      await container.read(changesProvider.notifier).discardAll();

      expect(ready().failure, isNull);
      expect(editor?.reloads ?? 0, 0, reason: 'its unsaved edits would go');
      expect(tree?.refreshes ?? 0, 0);
    });

    test('each press runs as the action it is', () async {
      git.writeFailure = null;
      final ChangesNotifier changes = container.read(changesProvider.notifier);

      await changes.setStaged(writing, true);
      await changes.setStaged(writing, false);
      changes.describe('docs: rewrite');
      await changes.commit();
      await changes.discard(entry(index, isStaged: false));
      await changes.discardAll();

      expect(git.actions, <CommandActionEnum?>[
        CommandActionEnum.stage,
        CommandActionEnum.unstage,
        CommandActionEnum.commit,
        CommandActionEnum.discard,
        CommandActionEnum.discardAll,
      ]);
    });

    test('a refused reading leaves the column on the last one', () async {
      git
        ..writeFailure = null
        ..statusFailure = const GitCommandDenied();
      container.read(changesProvider.notifier).describe('docs: rewrite');

      await container.read(changesProvider.notifier).setStaged(writing, true);

      expect(container.read(gitReadingProvider), isA<GitReadingStale>());
      expect(ready().isBusy, isFalse);
      expect(ready().message, 'docs: rewrite');
      expect(observed()?.entries, hasLength(2), reason: 'the last reading');
    });
  });
}

/// Git, answering what the test set and remembering what it was asked.
final class _Git implements GitRepository {
  /// What git is taken to say about a merge; no merge unless a test says so.
  MergeStateValueObject merge = MergeStateValueObject.none;

  GitStatusValueObject? reported;
  GitFailure? statusFailure;
  GitFailure? writeFailure;

  int asked = 0;
  final List<RepoRelativePathValueObject> staged =
      <RepoRelativePathValueObject>[];
  final List<RepoRelativePathValueObject> unstaged =
      <RepoRelativePathValueObject>[];
  final List<String> messages = <String>[];

  /// The action each write was asked inside, in order.
  final List<CommandActionEnum?> actions = <CommandActionEnum?>[];

  Result<void, GitFailure> _done() {
    actions.add(CommandScope.current?.action);
    return writeFailure == null
        ? const Success<void, GitFailure>(null)
        : Failure<void, GitFailure>(writeFailure!);
  }

  @override
  Future<Result<GitStatusValueObject, GitFailure>> status() async {
    asked++;
    return statusFailure == null
        ? Success<GitStatusValueObject, GitFailure>(reported!)
        : Failure<GitStatusValueObject, GitFailure>(statusFailure!);
  }

  @override
  Future<Result<void, GitFailure>> stage(
    List<RepoRelativePathValueObject> paths,
  ) async {
    staged.addAll(paths);
    return _done();
  }

  @override
  Future<Result<void, GitFailure>> unstage(
    List<RepoRelativePathValueObject> paths,
  ) async {
    unstaged.addAll(paths);
    return _done();
  }

  @override
  Future<Result<void, GitFailure>> commit(String message) async {
    messages.add(message);
    return _done();
  }

  /// What `log` answers, and the path it was last asked about.
  List<CommitEntity> logged = <CommitEntity>[];
  RepoRelativePathValueObject? loggedPath;

  @override
  Future<Result<List<CommitEntity>, GitFailure>> history({
    RepoRelativePathValueObject? path,
    int? limit,
  }) async {
    loggedPath = path;
    return Success<List<CommitEntity>, GitFailure>(logged);
  }

  @override
  Future<Result<List<BranchEntity>, GitFailure>> branches() async =>
      throw UnimplementedError();

  @override
  Future<Result<String, GitFailure>> contentAt({
    required String revision,
    required RepoRelativePathValueObject path,
  }) async => throw UnimplementedError();

  @override
  Future<Result<void, GitFailure>> createBranch(
    BranchNameValueObject name,
  ) async => throw UnimplementedError();

  @override
  Future<Result<void, GitFailure>> switchBranch(
    BranchNameValueObject name,
  ) async => throw UnimplementedError();

  @override
  Future<Result<void, GitFailure>> fetch() async => throw UnimplementedError();

  @override
  Future<Result<void, GitFailure>> pull() async => throw UnimplementedError();

  @override
  Future<Result<void, GitFailure>> push() async => throw UnimplementedError();

  @override
  Future<Result<MergeStateValueObject, GitFailure>> mergeState() async =>
      Success<MergeStateValueObject, GitFailure>(merge);

  /// How many times everything was put back.
  int discards = 0;

  /// What putting everything back fails with, when a test says so.
  GitFailure? discardAllFailure;

  @override
  Future<Result<void, GitFailure>> discardAll() async {
    discards++;
    actions.add(CommandScope.current?.action);
    return switch (discardAllFailure) {
      final GitFailure failure => Failure<void, GitFailure>(failure),
      null => const Success<void, GitFailure>(null),
    };
  }

  /// Every row put back, as the kind and the paths git was handed.
  final List<(DiscardKindEnum, List<RepoRelativePathValueObject>)> discarded =
      <(DiscardKindEnum, List<RepoRelativePathValueObject>)>[];

  @override
  Future<Result<void, GitFailure>> discard(
    DiscardKindEnum kind,
    List<RepoRelativePathValueObject> paths,
  ) async {
    discarded.add((kind, paths));
    return _done();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Result<void, GitFailure>> abortMerge() async =>
      throw UnimplementedError();
}

/// The machine's desktop, remembering what it was asked.
final class _Desktop implements DesktopRepository {
  final List<String> asked = <String>[];

  @override
  Future<Result<void, AppFailure>> reveal(String folder) async {
    asked.add('reveal $folder');
    return const Success<void, AppFailure>(null);
  }

  @override
  Future<Result<void, AppFailure>> openTerminal(String folder) async {
    asked.add('terminal $folder');
    return const Success<void, AppFailure>(null);
  }

  @override
  Future<Result<void, AppFailure>> openUrl(Uri address) async {
    asked.add('url $address');
    return const Success<void, AppFailure>(null);
  }
}

/// The tree, counting the times it was walked again.
final class _Tree extends FileTreeNotifier {
  int refreshes = 0;

  @override
  FileTreeState build() => const FileTreeState.initial();

  @override
  Future<void> refresh() async => refreshes++;
}

/// The editor, counting the times it read the disk again.
final class _Editor extends EditorNotifier {
  int reloads = 0;

  @override
  EditorState build() => const EditorState.empty();

  @override
  Future<void> reload() async => reloads++;
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

/// Documents nothing can be read from, so the marker check finds nothing to
/// refuse and staging behaves as it did before the check existed.
final class _NoDocuments implements DocumentRepository {
  const _NoDocuments();

  @override
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  ) async =>
      Failure<DocumentEntity, DocumentFailure>(DocumentNotFound(path.value));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Result<void, DocumentFailure>> create(DocumentEntity document) async =>
      throw UnimplementedError();

  @override
  Future<Result<void, DocumentFailure>> write(DocumentEntity document) async =>
      throw UnimplementedError();
}
