/// Drives the pull request page: what it is offered from, what it reads,
/// and the one action that leaves the app.
library;

import 'dart:async';

// `select` lives in the runtime package, not in `riverpod_annotation`.
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/branches/branches_providers.dart';
import 'package:tom_presentation/src/commands/command_action_enum.dart';
import 'package:tom_presentation/src/commands/command_scope.dart';
import 'package:tom_presentation/src/editor/editor_notifier.dart';
import 'package:tom_presentation/src/editor/editor_state.dart';
import 'package:tom_presentation/src/pull_request/pull_request_availability_enum.dart';
import 'package:tom_presentation/src/pull_request/pull_request_providers.dart';
import 'package:tom_presentation/src/pull_request/pull_request_segment_enum.dart';
import 'package:tom_presentation/src/pull_request/pull_request_state.dart';
import 'package:tom_presentation/src/pull_request/pull_request_status.dart';
import 'package:tom_presentation/src/spaces/space_session.dart';
import 'package:tom_presentation/src/spaces/space_session_notifier.dart';

part 'pull_request_notifier.g.dart';

/// What the page follows on the session: which branch, which base, and the
/// git reading that says whether either moved.
typedef _Page = ({
  BranchNameValueObject? page,
  BranchNameValueObject? base,
  GitStatusValueObject? git,
});

/// The page's readings, beside the session's two positions — which branch,
/// onto which base ([Decision
/// 33](../../../../../../docs/technical/decisions/033-a-pull-request-draft-is-a-document-outside-the-space.md)).
///
/// Kept alive because the control lives in the tree and the page in the
/// document area, and the explorer can be shut while the page is up.
@Riverpod(keepAlive: true)
class PullRequestNotifier extends _$PullRequestNotifier {
  /// Reads the remote's project and its own branch.
  ReadPullRequestTargetUseCase get readTarget =>
      ref.read(readPullRequestTargetProvider);

  /// Reads the commits and changes over a base.
  ReadBranchProposalUseCase get readProposal =>
      ref.read(readBranchProposalProvider);

  /// Reads the overview.
  ReadBranchOverviewUseCase get readOverview =>
      ref.read(readBranchOverviewProvider);

  /// Opens the host's page.
  OpenUrlUseCase get openUrl => ref.read(openUrlProvider);

  /// Asks the host for the pull request the branch already has.
  ReadOpenPullRequestUseCase get readOpened =>
      ref.read(readOpenPullRequestProvider);

  /// Opens the pull request through `gh`.
  CreatePullRequestUseCase get createOnHost =>
      ref.read(createPullRequestProvider);

  /// Lists what the base can be — the branch switch's own reading.
  ListBranchesUseCase get listBranches => ref.read(listBranchesProvider);

  /// The draft's title and body.
  static const PullRequestDraftService drafts = PullRequestDraftService();

  /// Which reading is the current one, so a slow answer about the last base
  /// cannot land over the next one's.
  int _generation = 0;

  /// The branch the host was last asked about while the page is up, so a
  /// new reading of git does not ask it again.
  BranchNameValueObject? _askedAbout;

  /// Which question to the host is the current one.
  int _asking = 0;

  @override
  PullRequestState build() {
    final SpaceEntity? space = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.space,
      ),
    );
    if (space == null) {
      return const PullRequestState();
    }
    // What reading the target would answer, without running git to hear it:
    // the row stays, unavailable
    // (`docs/product/workspace/without-a-repository/doc.md`).
    if (!space.hasRepository) {
      return PullRequestState(targetFailure: GitNotARepository(space.root));
    }
    // Listened to, not watched: the target outlives the page, and the
    // segment chosen should not reset because a commit moved `HEAD`.
    ref.listen<_Page>(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => (
          page: session?.pullRequest,
          base: session?.pullRequestBase,
          git: session?.git,
        ),
      ),
      (_Page? _, _Page next) =>
          unawaited(_follow(space, next.page, next.base, next.git)),
    );
    unawaited(Future<void>.microtask(() => _readTarget(space)));
    return const PullRequestState();
  }

  /// Puts the current branch's draft on screen, proposed onto the branch it
  /// came from — the diff's own base — or else the remote's own branch;
  /// nothing when there is nothing to propose.
  void open() {
    final SpaceSessionState? session = ref.read(spaceSessionProvider);
    final BranchNameValueObject? branch = state.branchFrom(session?.git);
    // By its name alone: a remote's copy is proposed onto as the host
    // calls it, which is without the remote.
    final BranchNameValueObject? came = session?.comparingAgainst?.branch.name;
    final BranchNameValueObject? base = came != null && came != branch
        ? came
        : state.target?.defaultBranch;
    if (session == null ||
        state.availability(session.git) !=
            PullRequestAvailabilityEnum.available ||
        branch == null ||
        base == null) {
      return;
    }
    // Already up: the session would not change, so nothing would read the
    // proposal again — and the base somebody chose would be reset.
    if (session.pullRequest == branch) {
      return;
    }
    // Opened afresh, the column starts on the proposal and the host is
    // asked again.
    state = state.copyWith(
      proposal: null,
      overview: null,
      failure: null,
      segment: PullRequestSegmentEnum.proposal,
      throughGh: false,
      opened: null,
      creating: false,
      createFailure: null,
    );
    ref.read(spaceSessionProvider.notifier).proposeBranch(branch, base);
    unawaited(_readBases(session.space, branch, base));
  }

  /// The branches the base can be moved to, read once per opening.
  Future<void> _readBases(
    SpaceEntity space,
    BranchNameValueObject branch,
    BranchNameValueObject base,
  ) async {
    final Result<List<BranchEntity>, AppFailure> read = await CommandScope.run(
      CommandActionEnum.readPullRequest,
      () => listBranches.list(space),
    );
    if (!ref.mounted) {
      return;
    }
    final List<BranchNameValueObject> local = switch (read) {
      Success<List<BranchEntity>, AppFailure>(
        value: final List<BranchEntity> branches,
      ) =>
        branches.map((BranchEntity it) => it.name).toList(),
      Failure<List<BranchEntity>, AppFailure>() =>
        const <BranchNameValueObject>[],
    };
    // The remote's own branch stays on offer when the first base is another,
    // even with no local copy of it.
    final BranchNameValueObject? remotes = state.target?.defaultBranch;
    state = state.copyWith(
      bases: List<BranchNameValueObject>.unmodifiable(<BranchNameValueObject>[
        base,
        if (remotes != null && remotes != base) remotes,
        ...local.where(
          (BranchNameValueObject it) =>
              it != base && it != branch && it != remotes,
        ),
      ]),
    );
  }

  /// Back to the tab that was on screen; the draft is saved on the way.
  void leave() => ref.read(spaceSessionProvider.notifier).leavePullRequest();

  /// Proposes onto [base] instead.
  void chooseBase(BranchNameValueObject base) =>
      ref.read(spaceSessionProvider.notifier).proposeOnto(base);

  /// Shows [segment], reading the overview the first time it is asked for.
  Future<void> show(PullRequestSegmentEnum segment) async {
    state = state.copyWith(segment: segment);
    final SpaceSessionState? session = ref.read(spaceSessionProvider);
    if (segment == PullRequestSegmentEnum.overview &&
        state.overview == null &&
        session?.pullRequestBase != null) {
      await _readOverview(
        session!.space,
        session.pullRequestBase!,
        _generation,
      );
    }
  }

  /// Opens the host's compare page, filled with the draft's title and body
  /// (`docs/product/git-workflow/pull-request/opening-it/doc.md`).
  Future<void> openOnHost() async {
    final SpaceSessionState? session = ref.read(spaceSessionProvider);
    final RemoteProjectValueObject? project = state.target?.project;
    final BranchNameValueObject? head = session?.pullRequest;
    final BranchNameValueObject? base = session?.pullRequestBase;
    if (project == null || head == null || base == null) {
      return;
    }
    final String draft = switch (ref.read(editorProvider)) {
      EditorReady(isDraft: true, source: final String source) => source,
      _ => '',
    };
    final Result<void, AppFailure> opened = await openUrl.open(
      project.compare(
        base: base,
        head: head,
        title: drafts.title(draft) ?? '',
        body: drafts.body(draft),
      ),
    );
    if (!ref.mounted) {
      return;
    }
    state = state.copyWith(
      failure: switch (opened) {
        Success<void, AppFailure>() => null,
        Failure<void, AppFailure>(failure: final AppFailure failure) => failure,
      },
    );
  }

  /// Opens the pull request through `gh`, with the draft's title and body,
  /// and keeps the draft
  /// (`docs/product/git-workflow/pull-request/opening-it/doc.md`).
  Future<void> create() async {
    final SpaceSessionState? session = ref.read(spaceSessionProvider);
    final RemoteProjectValueObject? project = state.target?.project;
    final BranchNameValueObject? head = session?.pullRequest;
    final BranchNameValueObject? base = session?.pullRequestBase;
    final String draft = switch (ref.read(editorProvider)) {
      EditorReady(isDraft: true, source: final String source) => source,
      _ => '',
    };
    final String? title = drafts.title(draft);
    if (session == null ||
        project == null ||
        head == null ||
        base == null ||
        title == null ||
        state.creating) {
      return;
    }
    state = state.copyWith(creating: true, createFailure: null);
    final Result<OpenedPullRequestValueObject, AppFailure> created =
        await CommandScope.run(
          CommandActionEnum.createPullRequest,
          () => createOnHost.create(
            session.space,
            project,
            base: base,
            head: head,
            title: title,
            body: drafts.body(draft),
          ),
        );
    if (!ref.mounted) {
      return;
    }
    state = switch (created) {
      Success<OpenedPullRequestValueObject, AppFailure>(
        value: final OpenedPullRequestValueObject opened,
      ) =>
        state.copyWith(creating: false, opened: opened),
      // Refused, nothing was opened and nothing went wrong: the page is as
      // it was before the press.
      Failure<OpenedPullRequestValueObject, AppFailure>(
        failure: AppFailure(isDenial: true),
      ) =>
        state.copyWith(creating: false),
      Failure<OpenedPullRequestValueObject, AppFailure>(
        failure: final AppFailure failure,
      ) =>
        state.copyWith(creating: false, createFailure: failure),
    };
  }

  /// Opens the pull request the branch already has, in the browser.
  Future<void> viewOnHost() async {
    final OpenedPullRequestValueObject? opened = state.opened;
    if (opened == null) {
      return;
    }
    final Result<void, AppFailure> shown = await openUrl.open(opened.address);
    if (!ref.mounted) {
      return;
    }
    if (shown case Failure<void, AppFailure>(
      failure: final AppFailure failure,
    )) {
      state = state.copyWith(failure: failure);
    }
  }

  /// Asks the host whether [head] already has a pull request — through `gh`,
  /// and only on GitHub. No answer is the host's page as the one action.
  Future<void> _askTheHost(
    SpaceEntity space,
    BranchNameValueObject head,
  ) async {
    final RemoteProjectValueObject? project = state.target?.project;
    if (project == null || project.host != RemoteHostEnum.github) {
      return;
    }
    final int asking = ++_asking;
    final Result<OpenedPullRequestValueObject?, AppFailure> read =
        await CommandScope.run(
          CommandActionEnum.readPullRequest,
          () => readOpened.read(space, project, head),
        );
    if (!ref.mounted ||
        asking != _asking ||
        ref.read(spaceSessionProvider)?.pullRequest != head) {
      return;
    }
    state = switch (read) {
      Success<OpenedPullRequestValueObject?, AppFailure>(
        value: final OpenedPullRequestValueObject? opened,
      ) =>
        state.copyWith(throughGh: true, opened: opened),
      Failure<OpenedPullRequestValueObject?, AppFailure>() => state.copyWith(
        throughGh: false,
        opened: null,
      ),
    };
  }

  /// Reads the target again — the git menu's `Reload`.
  Future<void> reload() async {
    final SpaceEntity? space = ref.read(spaceSessionProvider)?.space;
    if (space != null && space.hasRepository) {
      await _readTarget(space);
    }
  }

  /// What the session moved to: another branch closes the page, and a new
  /// base or a new reading of git reads the proposal again.
  Future<void> _follow(
    SpaceEntity space,
    BranchNameValueObject? page,
    BranchNameValueObject? base,
    GitStatusValueObject? git,
  ) async {
    if (page == null || base == null) {
      _askedAbout = null;
      return;
    }
    // The draft describes *this* branch; a switch is not this branch any
    // more (`docs/product/git-workflow/pull-request/the-draft/doc.md`).
    if (git?.branch != null && git!.branch != page) {
      leave();
      return;
    }
    if (_askedAbout != page) {
      _askedAbout = page;
      unawaited(_askTheHost(space, page));
    }
    final int generation = ++_generation;
    final Result<BranchProposalValueObject, AppFailure> read =
        await CommandScope.run(
          CommandActionEnum.readPullRequest,
          () => readProposal.read(space, base),
        );
    if (!ref.mounted || generation != _generation) {
      return;
    }
    switch (read) {
      // Refused, the proposal on the page stands, out of date and unsaid.
      case Failure<BranchProposalValueObject, AppFailure>(
        failure: AppFailure(isDenial: true),
      ):
        break;
      case Success<BranchProposalValueObject, AppFailure>(
        value: final BranchProposalValueObject proposal,
      ):
        state = state.copyWith(
          proposal: proposal,
          overview: null,
          failure: null,
          createFailure: null,
        );
        if (state.segment == PullRequestSegmentEnum.overview) {
          await _readOverview(space, base, generation);
        }
      case Failure<BranchProposalValueObject, AppFailure>(
        failure: final AppFailure failure,
      ):
        state = state.copyWith(failure: failure);
    }
  }

  Future<void> _readOverview(
    SpaceEntity space,
    BranchNameValueObject base,
    int generation,
  ) async {
    final BranchProposalValueObject? proposal = state.proposal;
    if (proposal == null) {
      return;
    }
    final Result<BranchOverviewValueObject, AppFailure> read =
        await CommandScope.run(
          CommandActionEnum.readPullRequest,
          () => readOverview.read(space, base, proposal),
        );
    if (!ref.mounted || generation != _generation) {
      return;
    }
    state = switch (read) {
      Failure<BranchOverviewValueObject, AppFailure>(
        failure: AppFailure(isDenial: true),
      ) =>
        state,
      Success<BranchOverviewValueObject, AppFailure>(
        value: final BranchOverviewValueObject overview,
      ) =>
        state.copyWith(overview: overview),
      Failure<BranchOverviewValueObject, AppFailure>(
        failure: final AppFailure failure,
      ) =>
        state.copyWith(failure: failure),
    };
  }

  Future<void> _readTarget(SpaceEntity space) async {
    final Result<PullRequestTargetValueObject, AppFailure> read =
        await CommandScope.run(
          CommandActionEnum.readPullRequest,
          () => readTarget.read(space),
        );
    if (!ref.mounted) {
      return;
    }
    // Kept rather than turned into an empty target: a folder with no
    // repository draws no row, and any other failure says so in the row.
    state = switch (read) {
      // Refused, the row keeps the target it had, or none.
      Failure<PullRequestTargetValueObject, AppFailure>(
        failure: AppFailure(isDenial: true),
      ) =>
        state,
      Success<PullRequestTargetValueObject, AppFailure>(
        value: final PullRequestTargetValueObject target,
      ) =>
        state.copyWith(target: target, targetFailure: null),
      Failure<PullRequestTargetValueObject, AppFailure>(
        failure: final AppFailure failure,
      ) =>
        state.copyWith(target: null, targetFailure: failure),
    };
  }
}

/// What the status row says, from git, the proposal and the draft's title.
@riverpod
PullRequestStatus pullRequestStatus(Ref ref) {
  final GitStatusValueObject? git = ref.watch(
    spaceSessionProvider.select((SpaceSessionState? session) => session?.git),
  );
  final BranchProposalValueObject? proposal = ref.watch(
    pullRequestProvider.select((PullRequestState state) => state.proposal),
  );
  final String? title = ref.watch(
    editorProvider.select(
      (EditorState editor) => switch (editor) {
        EditorReady(isDraft: true, source: final String source) =>
          PullRequestNotifier.drafts.title(source),
        _ => null,
      },
    ),
  );
  final bool failed = ref.watch(
    pullRequestProvider.select(
      (PullRequestState state) => state.failure != null,
    ),
  );
  final AppFailure? notCreated = ref.watch(
    pullRequestProvider.select((PullRequestState state) => state.createFailure),
  );
  final int? opened = ref.watch(
    pullRequestProvider.select(
      (PullRequestState state) => state.opened?.number,
    ),
  );
  return PullRequestStatus.of(
    git: git,
    proposal: proposal,
    title: title,
    failed: failed,
    notCreated: notCreated,
    opened: opened,
  );
}
