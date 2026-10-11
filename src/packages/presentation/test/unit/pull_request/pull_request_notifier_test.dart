/// The pull request page over real use cases and recorded repositories:
/// the draft is a document from another folder (Decision 33).
library;

import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  late _Git git;
  late _Folder space;
  late _Folder drafts;
  late _Desktop desktop;
  late _Accounts accounts;
  late _Host host;
  late ProviderContainer container;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );
  final SpaceRelativePathValueObject guide = SpaceRelativePathValueObject(
    'guide.md',
  );
  final BranchNameValueObject feature = BranchNameValueObject('feat/x');
  final BranchNameValueObject main = BranchNameValueObject('main');

  GitStatusValueObject status({
    BranchNameValueObject? branch,
    int ahead = 0,
    bool tracked = true,
    List<StatusEntryValueObject> entries = const <StatusEntryValueObject>[],
  }) => GitStatusValueObject(
    branch: branch ?? feature,
    upstream: tracked ? BranchNameValueObject('origin/feat/x') : null,
    ahead: ahead,
    behind: 0,
    entries: entries,
    isDetached: false,
  );

  setUp(() {
    git = _Git();
    space = _Folder(<String, String>{'guide.md': '# Guide\n'});
    drafts = _Folder(<String, String>{});
    desktop = _Desktop();
    accounts = _Accounts();
    host = _Host();
    const Observability silent = _Silent();
    container = ProviderContainer(
      overrides: <Override>[
        readDocumentProvider.overrideWithValue(
          ReadDocumentUseCase(
            documentsFor: (SpaceEntity _) => space,
            observability: silent,
          ),
        ),
        saveDocumentProvider.overrideWithValue(
          SaveDocumentUseCase(
            documentsFor: (SpaceEntity _) => space,
            observability: silent,
          ),
        ),
        openPullRequestDraftProvider.overrideWithValue(
          OpenPullRequestDraftUseCase(
            draftsFor: (SpaceEntity _) => drafts,
            gitFor: (SpaceEntity _) => git,
            observability: silent,
          ),
        ),
        saveDraftProvider.overrideWithValue(
          SaveDocumentUseCase(
            documentsFor: (SpaceEntity _) => drafts,
            observability: silent,
          ),
        ),
        readPullRequestTargetProvider.overrideWithValue(
          ReadPullRequestTargetUseCase(
            gitFor: (SpaceEntity _) => git,
            observability: silent,
          ),
        ),
        readBranchProposalProvider.overrideWithValue(
          ReadBranchProposalUseCase(
            gitFor: (SpaceEntity _) => git,
            observability: silent,
          ),
        ),
        readBranchOverviewProvider.overrideWithValue(
          ReadBranchOverviewUseCase(
            gitFor: (SpaceEntity _) => git,
            blocks: const _Lines(),
            differ: const BlockDifferService(aligner: _Replace()),
            observability: silent,
          ),
        ),
        openUrlProvider.overrideWithValue(
          OpenUrlUseCase(desktop: desktop, observability: silent),
        ),
        readOpenPullRequestProvider.overrideWithValue(
          ReadOpenPullRequestUseCase(
            gitFor: (SpaceEntity _) => git,
            accountsFor: (SpaceEntity _) => accounts,
            hostFor: (SpaceEntity _) => host,
            observability: silent,
          ),
        ),
        createPullRequestProvider.overrideWithValue(
          CreatePullRequestUseCase(
            gitFor: (SpaceEntity _) => git,
            accountsFor: (SpaceEntity _) => accounts,
            hostFor: (SpaceEntity _) => host,
            observability: silent,
          ),
        ),
        listBranchesProvider.overrideWithValue(
          ListBranchesUseCase(
            gitFor: (SpaceEntity _) => git,
            observability: silent,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  /// Everything scheduled, run.
  Future<void> settle() async {
    for (int i = 0; i < 5; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  /// A space open on [guide], on `feat/x`, with the page's notifiers alive.
  Future<void> openSpace({GitStatusValueObject? git}) async {
    container
      ..listen<EditorState>(editorProvider, (_, _) {})
      ..listen<PullRequestState>(pullRequestProvider, (_, _) {})
      ..listen<PullRequestStatus>(pullRequestStatusProvider, (_, _) {});
    container.read(spaceSessionProvider.notifier)
      ..open(docs)
      ..observe(git ?? status())
      ..show(guide);
    await settle();
  }

  PullRequestState page() => container.read(pullRequestProvider);
  EditorState editor() => container.read(editorProvider);
  SpaceSessionState session() => container.read(spaceSessionProvider)!;

  group('where it is offered', () {
    test(
      'from a branch that is not the remote’s own, on a known host',
      () async {
        await openSpace();

        expect(page().target?.project?.host, RemoteHostEnum.github);
        expect(page().target?.defaultBranch, main);
        expect(
          page().availability(session().git),
          PullRequestAvailabilityEnum.available,
        );
      },
    );

    test(
      'not on the remote’s own branch, which has nothing to propose',
      () async {
        await openSpace(git: status(branch: main));

        expect(
          page().availability(session().git),
          PullRequestAvailabilityEnum.onBase,
        );
      },
    );

    test('not on a host the app does not know', () async {
      git.address = 'https://git.acme.dev/docs.git';
      await openSpace();

      expect(
        page().availability(session().git),
        PullRequestAvailabilityEnum.unknownHost,
      );
    });

    test('not without a remote, and that is a reason of its own', () async {
      git.address = null;
      await openSpace();

      expect(
        page().availability(session().git),
        PullRequestAvailabilityEnum.noRemote,
      );
    });

    test('with the git column shut, the branch is the target’s own', () async {
      container
        ..listen<EditorState>(editorProvider, (_, _) {})
        ..listen<PullRequestState>(pullRequestProvider, (_, _) {});
      // Opened without a git reading on the session.
      container.read(spaceSessionProvider.notifier).open(docs);
      await settle();

      expect(page().availability(null), PullRequestAvailabilityEnum.available);
      container.read(pullRequestProvider.notifier).open();
      await settle();

      expect(session().pullRequest, feature);
    });

    test('a folder with no repository is unavailable, git unasked', () async {
      // The row stays, muted with no reason
      // (`docs/product/workspace/without-a-repository/doc.md`).
      container.listen<PullRequestState>(pullRequestProvider, (_, _) {});
      container
          .read(spaceSessionProvider.notifier)
          .open(
            SpaceEntity(root: '/notes', repositoryRoot: null, name: 'notes'),
          );
      await settle();

      expect(page().target, isNull, reason: 'the target was read from git');
      expect(
        page().availability(null),
        PullRequestAvailabilityEnum.noRepository,
      );
      container.read(pullRequestProvider.notifier).open();
      await container.read(pullRequestProvider.notifier).reload();
      await settle();

      expect(session().pullRequest, isNull);
      expect(page().target, isNull);
    });

    test('nothing can be opened from where it cannot', () async {
      await openSpace(git: status(branch: main));

      container.read(pullRequestProvider.notifier).open();
      await settle();

      expect(session().pullRequest, isNull);
    });
  });

  group('the draft', () {
    test('opening it seeds it from git, and the editor holds it', () async {
      await openSpace();

      container.read(pullRequestProvider.notifier).open();
      await settle();

      expect(session().pullRequest, feature);
      expect(session().pullRequestBase, main);
      expect(drafts.files['feat/x.md'], '# First\n\n- Second\n');
      // The remote's own first, and never the branch being proposed.
      expect(page().bases, <BranchNameValueObject>[
        main,
        BranchNameValueObject('release'),
      ]);
      final EditorReady draft = editor() as EditorReady;
      expect(draft.isDraft, isTrue);
      expect(draft.source, '# First\n\n- Second\n');
      expect(git.since, main);
    });

    test('it is proposed onto the branch the diff is read against', () async {
      // The base is the same answer in both places: the branch this one
      // came from (`docs/product/diff/branch-diff/doc.md`).
      await openSpace();
      container
          .read(spaceSessionProvider.notifier)
          .compare(
            DiffBaseValueObject(
              branch: BranchRefValueObject(
                name: BranchNameValueObject('release'),
                remote: 'origin',
              ),
              forkPoint: CommitShaValueObject(
                'abc1234def5678901234567890abcdef12345678',
              ),
            ),
          );

      container.read(pullRequestProvider.notifier).open();
      await settle();

      expect(session().pullRequestBase, BranchNameValueObject('release'));
      expect(page().bases, <BranchNameValueObject>[
        BranchNameValueObject('release'),
        main,
      ]);
    });

    test('a draft already on disk is read, not seeded again', () async {
      drafts.files['feat/x.md'] = '# Mine\n';
      await openSpace();

      container.read(pullRequestProvider.notifier).open();
      await settle();

      expect((editor() as EditorReady).source, '# Mine\n');
      expect(drafts.created, isEmpty);
    });

    test('leaving saves its edits and puts the tab back', () async {
      await openSpace();
      container.read(pullRequestProvider.notifier).open();
      await settle();
      container.read(editorProvider.notifier).edit('# Better title\n');

      container.read(pullRequestProvider.notifier).leave();
      await settle();

      expect(drafts.files['feat/x.md'], '# Better title\n');
      expect((editor() as EditorReady).saved.path, guide);
      expect((editor() as EditorReady).isDraft, isFalse);
    });

    test('its folder is asked of git, so reading and writing it are the '
        'pull request\'s action', () async {
      await openSpace();
      container.read(pullRequestProvider.notifier).open();
      await settle();
      container.read(editorProvider.notifier).edit('# Better title\n');
      await container.read(editorProvider.notifier).save();

      expect(drafts.actions, isNotEmpty);
      expect(drafts.actions, everyElement(CommandActionEnum.readPullRequest));
    });

    test('a tab with edits waits behind the page and comes back', () async {
      await openSpace();
      container.read(editorProvider.notifier).edit('# Guide, edited\n');

      container.read(pullRequestProvider.notifier).open();
      await settle();
      container.read(pullRequestProvider.notifier).leave();
      await settle();

      expect((editor() as EditorReady).source, '# Guide, edited\n');
      expect(space.files['guide.md'], '# Guide\n');
    });

    test('saving it writes the drafts folder, never the space', () async {
      await openSpace();
      container.read(pullRequestProvider.notifier).open();
      await settle();
      container.read(editorProvider.notifier).edit('# Saved\n');

      await container.read(editorProvider.notifier).save();

      expect(drafts.files['feat/x.md'], '# Saved\n');
      expect(space.files.keys, <String>['guide.md']);
    });

    test('a branch switch closes the page', () async {
      await openSpace();
      container.read(pullRequestProvider.notifier).open();
      await settle();

      container
          .read(spaceSessionProvider.notifier)
          .observe(status(branch: BranchNameValueObject('other')));
      await settle();

      expect(session().pullRequest, isNull);
    });
  });

  group('the status row', () {
    Future<PullRequestStatus> statusWith(GitStatusValueObject git) async {
      await openSpace(git: git);
      container.read(pullRequestProvider.notifier).open();
      await settle();
      return container.read(pullRequestStatusProvider);
    }

    test('ready when everything is committed and pushed', () async {
      expect(
        await statusWith(status()),
        const PullRequestStatus.ready(commits: 2),
      );
    });

    test('uncommitted work comes first, and stops both actions', () async {
      final PullRequestStatus row = await statusWith(
        status(
          ahead: 1,
          entries: <StatusEntryValueObject>[
            StatusEntryValueObject(
              path: RepoRelativePathValueObject('docs/guide.md'),
              state: FileStateEnum.modified,
              isStaged: false,
            ),
          ],
        ),
      );

      expect(row, const PullRequestStatus.uncommitted(documents: 1));
      expect(row.canOpen, isFalse);
    });

    test('commits the remote lacks are unpublished', () async {
      expect(
        await statusWith(status(ahead: 1)),
        const PullRequestStatus.unpublished(commits: 1, hasUpstream: true),
      );
      expect(
        await statusWith(status(tracked: false)),
        const PullRequestStatus.unpublished(commits: 2, hasUpstream: false),
      );
    });

    test('a draft whose heading went has no title to open with', () async {
      await statusWith(status());

      container.read(editorProvider.notifier).edit('No heading here.\n');

      expect(
        container.read(pullRequestStatusProvider),
        const PullRequestStatus.untitled(),
      );
    });
  });

  test('opening on the host hands the browser the draft', () async {
    await openSpace();
    container.read(pullRequestProvider.notifier).open();
    await settle();
    container.read(editorProvider.notifier).edit('# Close it\n\nWhy.\n');

    await container.read(pullRequestProvider.notifier).openOnHost();

    final Uri opened = desktop.opened.single;
    expect(opened.path, '/acme/docs/compare/main...feat/x');
    expect(opened.queryParameters['title'], 'Close it');
    expect(opened.queryParameters['body'], 'Why.');
  });

  test(
    'pressing the row again keeps the proposal and the base chosen',
    () async {
      await openSpace();
      container.read(pullRequestProvider.notifier).open();
      await settle();
      container
          .read(pullRequestProvider.notifier)
          .chooseBase(BranchNameValueObject('release'));
      await settle();

      container.read(pullRequestProvider.notifier).open();
      await settle();

      expect(page().proposal, isNotNull);
      expect(session().pullRequestBase, BranchNameValueObject('release'));
    },
  );

  test('a reading git refuses is said, and nothing can be opened', () async {
    git.changesFail = true;
    await openSpace();
    container.read(pullRequestProvider.notifier).open();
    await settle();

    final PullRequestStatus row = container.read(pullRequestStatusProvider);
    expect(row, const PullRequestStatus.failed());
    expect(row.canOpen, isFalse);
  });

  test('a draft the person refused to have seeded closes the page, back '
      'onto the tabs, with no failure in the editor', () async {
    git.commitsRefused = true;
    await openSpace();

    container.read(pullRequestProvider.notifier).open();
    await settle();

    expect(container.read(spaceSessionProvider)?.pullRequest, isNull);
    expect(editor(), isNot(isA<EditorFailed>()));
    expect(drafts.files, isEmpty);
  });

  test('a reading the person refused is not said as a failure', () async {
    git.changesRefused = true;
    await openSpace();
    container.read(pullRequestProvider.notifier).open();
    await settle();

    expect(page().failure, isNull);
    expect(page().proposal, isNull);
    expect(
      container.read(pullRequestStatusProvider),
      isNot(const PullRequestStatus.failed()),
    );
  });

  test('until git answers the row is reading, and nothing can be opened', () {
    final PullRequestStatus row = PullRequestStatus.of(
      git: status(),
      proposal: null,
      title: 'Close it',
    );

    expect(row, const PullRequestStatus.reading());
    expect(row.canOpen, isFalse);
  });

  test('leaving for another space does not write the draft there', () async {
    await openSpace();
    container.read(pullRequestProvider.notifier).open();
    await settle();
    container.read(editorProvider.notifier).edit('# Unsaved here\n');

    container
        .read(spaceSessionProvider.notifier)
        .open(
          SpaceEntity(
            root: '/elsewhere',
            repositoryRoot: '/elsewhere',
            name: 'x',
          ),
        );
    await settle();

    expect(drafts.files['feat/x.md'], '# First\n\n- Second\n');
  });

  test('the overview is read when its segment is chosen', () async {
    await openSpace();
    container.read(pullRequestProvider.notifier).open();
    await settle();

    await container
        .read(pullRequestProvider.notifier)
        .show(PullRequestSegmentEnum.overview);
    await settle();

    final BranchOverviewValueObject? overview = page().overview;
    expect(overview?.commits, 2);
    expect(overview?.wordsAdded, 2);
    expect(overview?.wordsRemoved, 1);
  });

  group('when something beside the page goes wrong', () {
    Future<void> openThePage() async {
      await openSpace();
      container.read(pullRequestProvider.notifier).open();
      await settle();
    }

    test(
      'a remote git cannot read is said in the row, with no target',
      () async {
        git.addressFailure = const GitFailure.operationFailed();

        await openSpace();

        expect(page().target, isNull);
        expect(page().targetFailure, isA<GitOperationFailed>());
      },
    );

    test('a remote the person refused to have read is not said', () async {
      git.addressFailure = const GitFailure.commandDenied();

      await openSpace();

      expect(page().target, isNull);
      expect(page().targetFailure, isNull);
    });

    test('reloading reads the target again, from the repository', () async {
      git.address = null;
      await openSpace();
      expect(
        page().availability(session().git),
        PullRequestAvailabilityEnum.noRemote,
      );

      git.address = 'git@github.com:acme/docs.git';
      await container.read(pullRequestProvider.notifier).reload();

      expect(
        page().availability(session().git),
        PullRequestAvailabilityEnum.available,
      );
    });

    test('reloading with no space open asks nothing', () async {
      container.listen<PullRequestState>(pullRequestProvider, (_, _) {});

      await container.read(pullRequestProvider.notifier).reload();

      expect(page().target, isNull);
    });

    test('branches git cannot list leave the base alone on offer', () async {
      git.branchesFail = true;

      await openThePage();

      expect(page().bases, <BranchNameValueObject>[main]);
    });

    test('a browser that cannot open the host is said', () async {
      await openThePage();
      desktop.refusal = const UnexpectedFailure('no browser');

      await container.read(pullRequestProvider.notifier).openOnHost();

      expect(page().failure, isA<UnexpectedFailure>());
    });

    test(
      'the overview asked for before the proposal has nothing to read',
      () async {
        await openSpace();
        final PullRequestNotifier notifier = container.read(
          pullRequestProvider.notifier,
        )..open();

        await notifier.show(PullRequestSegmentEnum.overview);
        await settle();

        expect(page().failure, isNull);
        expect(page().segment, PullRequestSegmentEnum.overview);
      },
    );

    test('an overview git cannot read is said', () async {
      git.forkFailure = const GitFailure.operationFailed();
      await openThePage();

      await container
          .read(pullRequestProvider.notifier)
          .show(PullRequestSegmentEnum.overview);

      expect(page().overview, isNull);
      expect(page().failure, isA<GitOperationFailed>());
    });

    test('an overview the person refused to have read is not said', () async {
      git.forkFailure = const GitFailure.commandDenied();
      await openThePage();

      await container
          .read(pullRequestProvider.notifier)
          .show(PullRequestSegmentEnum.overview);

      expect(page().overview, isNull);
      expect(page().failure, isNull);
    });
  });

  group('through gh', () {
    const GithubAccountValueObject ada = GithubAccountValueObject(
      login: 'ada',
      source: AccountSourceEnum.gh,
    );
    final OpenedPullRequestValueObject numbered = OpenedPullRequestValueObject(
      number: 123,
      address: Uri.parse('https://github.com/acme/docs/pull/123'),
      title: 'First',
    );

    Future<void> openThePage() async {
      await openSpace();
      container.read(pullRequestProvider.notifier).open();
      await settle();
    }

    test(
      'without an account nothing changes: the host page is the action',
      () async {
        await openThePage();

        expect(page().throughGh, isFalse);
        expect(host.asked, isEmpty);
      },
    );

    test('without gh nothing changes either', () async {
      accounts.held = <GithubAccountValueObject>[ada];
      host.failure = const PullRequestHostUnavailable();

      await openThePage();

      expect(page().throughGh, isFalse);
      expect(page().opened, isNull);
    });

    test('with gh and none open, it offers to create one', () async {
      accounts.held = <GithubAccountValueObject>[ada];

      await openThePage();

      expect(page().throughGh, isTrue);
      expect(page().opened, isNull);
      expect(host.asked, <String>['open ada feat/x']);
      expect(
        container.read(pullRequestStatusProvider),
        const PullRequestStatus.ready(commits: 2),
      );
    });

    test('one already open is shown instead, by its number', () async {
      accounts.held = <GithubAccountValueObject>[ada];
      host.open = numbered;

      await openThePage();

      expect(page().opened, numbered);
      expect(
        container.read(pullRequestStatusProvider),
        const PullRequestStatus.alreadyOpen(number: 123),
      );
    });

    test('a new reading of git does not ask the host again', () async {
      accounts.held = <GithubAccountValueObject>[ada];
      await openThePage();

      container.read(spaceSessionProvider.notifier).observe(status(ahead: 1));
      await settle();

      expect(page().proposal, isNotNull);
      expect(host.asked, hasLength(1));
    });

    test('creating opens it with the draft, and keeps the draft', () async {
      accounts.held = <GithubAccountValueObject>[ada];
      await openThePage();
      container
          .read(editorProvider.notifier)
          .edit('# Release notes\n\nWhy it exists.\n');
      host.created = numbered;

      await container.read(pullRequestProvider.notifier).create();

      // Created, then asked again so the page shows what the host holds.
      expect(host.asked.skip(1), <String>[
        'create main feat/x Release notes|Why it exists.',
        'open ada feat/x',
      ]);
      expect(page().opened, numbered);
      expect(page().creating, isFalse);
      expect(drafts.files['feat/x.md'], isNotNull);
      expect(editor(), isA<EditorReady>());
      expect(
        container.read(pullRequestStatusProvider),
        const PullRequestStatus.alreadyOpen(number: 123),
      );
    });

    test('one the host refuses is said, and nothing is open', () async {
      accounts.held = <GithubAccountValueObject>[ada];
      await openThePage();
      host.createFailure = const PullRequestHostUnreachable();

      await container.read(pullRequestProvider.notifier).create();

      expect(page().opened, isNull);
      final PullRequestStatus row = container.read(pullRequestStatusProvider);
      expect(
        row,
        const PullRequestStatus.notCreated(
          failure: PullRequestHostUnreachable(),
        ),
      );
      expect(row.canOpen, isFalse);
    });

    test('one the person refused to send is not said: the page is as it '
        'was', () async {
      accounts.held = <GithubAccountValueObject>[ada];
      await openThePage();
      container
          .read(editorProvider.notifier)
          .edit('# Release notes\n\nWhy it exists.\n');
      final PullRequestStatus before = container.read(
        pullRequestStatusProvider,
      );
      host.createFailure = const PullRequestHostDenied();

      await container.read(pullRequestProvider.notifier).create();

      expect(page().creating, isFalse);
      expect(page().createFailure, isNull);
      expect(page().opened, isNull);
      expect(container.read(pullRequestStatusProvider), before);
    });

    test('the one open is viewed on the host', () async {
      accounts.held = <GithubAccountValueObject>[ada];
      host.open = numbered;
      await openThePage();

      await container.read(pullRequestProvider.notifier).viewOnHost();

      expect(desktop.opened.single, numbered.address);
    });

    test('viewing one that is not open does nothing', () async {
      accounts.held = <GithubAccountValueObject>[ada];
      await openThePage();

      await container.read(pullRequestProvider.notifier).viewOnHost();

      expect(desktop.opened, isEmpty);
      expect(page().failure, isNull);
    });

    test('a browser that cannot show the one open is said', () async {
      accounts.held = <GithubAccountValueObject>[ada];
      host.open = numbered;
      await openThePage();
      desktop.refusal = const UnexpectedFailure('no browser');

      await container.read(pullRequestProvider.notifier).viewOnHost();

      expect(page().failure, isA<UnexpectedFailure>());
    });

    test('leaving and coming back asks the host again', () async {
      accounts.held = <GithubAccountValueObject>[ada];
      await openThePage();

      container.read(pullRequestProvider.notifier).leave();
      await settle();
      container.read(pullRequestProvider.notifier).open();
      await settle();

      expect(host.asked, <String>['open ada feat/x', 'open ada feat/x']);
    });
  });

  test('one already open comes after the branch’s own news', () {
    final BranchProposalValueObject proposal = BranchProposalValueObject(
      commits: <CommitEntity>[
        CommitEntity(
          sha: CommitShaValueObject('a' * 40),
          author: const AuthorValueObject(name: 'Ana', email: 'a@x.org'),
          date: CommitDateValueObject(
            utc: DateTime.utc(2026),
            offset: Duration.zero,
          ),
          subject: 'One',
          body: '',
        ),
      ],
      changes: const <BranchChangeValueObject>[],
    );

    expect(
      PullRequestStatus.of(
        git: status(ahead: 1),
        proposal: proposal,
        title: null,
        opened: 7,
      ),
      const PullRequestStatus.unpublished(commits: 1, hasUpstream: true),
    );
    expect(
      PullRequestStatus.of(
        git: status(),
        proposal: proposal,
        title: null,
        opened: 7,
      ),
      const PullRequestStatus.alreadyOpen(number: 7),
    );
  });
}

/// The machine's GitHub accounts; none may push, so the first is used.
final class _Accounts implements GithubAccountRepository {
  List<GithubAccountValueObject> held = <GithubAccountValueObject>[];

  @override
  Future<Result<List<GithubAccountValueObject>, AccountFailure>>
  accounts() async =>
      Success<List<GithubAccountValueObject>, AccountFailure>(held);

  @override
  Future<Result<RepositoryAccessValueObject?, AccountFailure>> access(
    GithubAccountValueObject account,
    RemoteProjectValueObject project,
  ) async => const Success<RepositoryAccessValueObject?, AccountFailure>(null);
}

/// GitHub through `gh`, writing down each question.
final class _Host implements PullRequestHostRepository {
  OpenedPullRequestValueObject? open;
  OpenedPullRequestValueObject? created;
  PullRequestHostFailure? failure;
  PullRequestHostFailure? createFailure;
  final List<String> asked = <String>[];

  @override
  Future<Result<OpenedPullRequestValueObject?, PullRequestHostFailure>>
  openFrom(
    GithubAccountValueObject account,
    RemoteProjectValueObject project,
    BranchNameValueObject head,
  ) async {
    asked.add('open ${account.login} ${head.value}');
    return failure == null
        ? Success<OpenedPullRequestValueObject?, PullRequestHostFailure>(
            open ?? created,
          )
        : Failure<OpenedPullRequestValueObject?, PullRequestHostFailure>(
            failure!,
          );
  }

  @override
  Future<Result<OpenedPullRequestValueObject, PullRequestHostFailure>> create(
    GithubAccountValueObject account,
    RemoteProjectValueObject project, {
    required BranchNameValueObject base,
    required BranchNameValueObject head,
    required String title,
    required String body,
  }) async {
    asked.add('create ${base.value} ${head.value} $title|$body');
    return createFailure == null
        ? Success<OpenedPullRequestValueObject, PullRequestHostFailure>(
            created!,
          )
        : Failure<OpenedPullRequestValueObject, PullRequestHostFailure>(
            createFailure!,
          );
  }
}

/// Git for a branch with two commits over `main`, on GitHub.
final class _Git implements GitRepository {
  String? address = 'git@github.com:acme/docs.git';
  BranchNameValueObject? since;

  CommitEntity _commit(String subject) => CommitEntity(
    sha: CommitShaValueObject('a' * 40),
    author: const AuthorValueObject(name: 'Ana', email: 'ana@example.com'),
    date: CommitDateValueObject(utc: DateTime.utc(2026), offset: Duration.zero),
    subject: subject,
    body: '',
  );

  /// What the remote's address is answered with instead of [address].
  GitFailure? addressFailure;

  /// Whether listing the branches fails.
  bool branchesFail = false;

  /// What the fork point is answered with, when it fails.
  GitFailure? forkFailure;

  @override
  Future<Result<String?, GitFailure>> remoteAddress() async {
    final GitFailure? failure = addressFailure;
    return failure == null
        ? Success<String?, GitFailure>(address)
        : Failure<String?, GitFailure>(failure);
  }

  @override
  Future<Result<String?, GitFailure>> chosenAccount() async =>
      const Success<String?, GitFailure>(null);

  /// The branch checked out, as the target reads it for itself.
  BranchNameValueObject checkedOut = BranchNameValueObject('feat/x');

  @override
  Future<Result<GitStatusValueObject, GitFailure>> status() async =>
      Success<GitStatusValueObject, GitFailure>(
        GitStatusValueObject(
          branch: checkedOut,
          upstream: null,
          ahead: 0,
          behind: 0,
          entries: const <StatusEntryValueObject>[],
          isDetached: false,
        ),
      );

  @override
  Future<Result<BranchNameValueObject?, GitFailure>> defaultBranch() async =>
      Success<BranchNameValueObject?, GitFailure>(
        BranchNameValueObject('main'),
      );

  /// Whether the person says no to reading the branch's commits.
  bool commitsRefused = false;

  @override
  Future<Result<List<CommitEntity>, GitFailure>> commitsSince(
    BranchNameValueObject base,
  ) async {
    since = base;
    if (commitsRefused) {
      return const Failure<List<CommitEntity>, GitFailure>(GitCommandDenied());
    }
    return Success<List<CommitEntity>, GitFailure>(<CommitEntity>[
      _commit('Second'),
      _commit('First'),
    ]);
  }

  /// Whether reading the changes fails, as with no shared history.
  bool changesFail = false;

  /// Whether the person says no to reading the changes.
  bool changesRefused = false;

  @override
  Future<Result<List<BranchChangeValueObject>, GitFailure>> changesSince(
    BranchNameValueObject base,
  ) async => changesFail || changesRefused
      ? Failure<List<BranchChangeValueObject>, GitFailure>(
          changesRefused
              ? const GitFailure.commandDenied()
              : const GitFailure.operationFailed(),
        )
      : Success<List<BranchChangeValueObject>, GitFailure>(
          <BranchChangeValueObject>[
            BranchChangeValueObject(
              path: RepoRelativePathValueObject('docs/guide.md'),
              state: FileStateEnum.modified,
              added: 1,
              removed: 1,
            ),
          ],
        );

  @override
  Future<Result<List<BranchEntity>, GitFailure>> branches() async =>
      branchesFail
      ? const Failure<List<BranchEntity>, GitFailure>(
          GitFailure.operationFailed(),
        )
      : Success<List<BranchEntity>, GitFailure>(<BranchEntity>[
          BranchEntity(name: BranchNameValueObject('main'), isCurrent: false),
          BranchEntity(name: BranchNameValueObject('feat/x'), isCurrent: true),
          BranchEntity(
            name: BranchNameValueObject('release'),
            isCurrent: false,
          ),
        ]);

  @override
  Future<Result<CommitShaValueObject?, GitFailure>> forkPoint(
    BranchNameValueObject base,
  ) async {
    final GitFailure? failure = forkFailure;
    return failure == null
        ? Success<CommitShaValueObject?, GitFailure>(
            CommitShaValueObject('b' * 40),
          )
        : Failure<CommitShaValueObject?, GitFailure>(failure);
  }

  @override
  Future<Result<String, GitFailure>> contentAt({
    required String revision,
    required RepoRelativePathValueObject path,
  }) async =>
      Success<String, GitFailure>(revision == 'HEAD' ? 'New words' : 'Old');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A folder of documents kept in a map, by path.
final class _Folder implements DocumentRepository {
  _Folder(this.files);

  final Map<String, String> files;
  final List<String> created = <String>[];

  /// The action each read and write was asked inside, in order.
  final List<CommandActionEnum?> actions = <CommandActionEnum?>[];

  @override
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  ) async {
    actions.add(CommandScope.current?.action);
    final String? content = files[path.value];
    return content == null
        ? Failure<DocumentEntity, DocumentFailure>(DocumentNotFound(path.value))
        : Success<DocumentEntity, DocumentFailure>(
            DocumentEntity(path: path, content: content),
          );
  }

  @override
  Future<Result<void, DocumentFailure>> create(DocumentEntity document) async {
    created.add(document.path.value);
    files[document.path.value] = document.content;
    return const Success<void, DocumentFailure>(null);
  }

  @override
  Future<Result<void, DocumentFailure>> write(DocumentEntity document) async {
    actions.add(CommandScope.current?.action);
    files[document.path.value] = document.content;
    return const Success<void, DocumentFailure>(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A desktop that remembers the addresses it was handed.
final class _Desktop implements DesktopRepository {
  final List<Uri> opened = <Uri>[];

  /// What every request is refused with, or null to succeed.
  AppFailure? refusal;

  @override
  Future<Result<void, AppFailure>> openUrl(Uri address) async {
    opened.add(address);
    final AppFailure? refused = refusal;
    return refused == null
        ? const Success<void, AppFailure>(null)
        : Failure<void, AppFailure>(refused);
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
