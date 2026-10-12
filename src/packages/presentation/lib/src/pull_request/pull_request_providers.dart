/// What the pull request page is wired from, declared where it lives.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';

part 'pull_request_providers.g.dart';

/// Reads where a pull request would go.
@riverpod
ReadPullRequestTargetUseCase readPullRequestTarget(Ref ref) => throw StateError(
  'readPullRequestTargetProvider has no default. The composition root '
  'overrides it — see runTom() in tom_desktop.',
);

/// Reads what the branch proposes onto a base.
@riverpod
ReadBranchProposalUseCase readBranchProposal(Ref ref) => throw StateError(
  'readBranchProposalProvider has no default. The composition root '
  'overrides it — see runTom() in tom_desktop.',
);

/// Reads what the branch did, in numbers.
@riverpod
ReadBranchOverviewUseCase readBranchOverview(Ref ref) => throw StateError(
  'readBranchOverviewProvider has no default. The composition root '
  'overrides it — see runTom() in tom_desktop.',
);

/// Asks the host whether the branch already has a pull request.
@riverpod
ReadOpenPullRequestUseCase readOpenPullRequest(Ref ref) => throw StateError(
  'readOpenPullRequestProvider has no default. The composition root '
  'overrides it — see runTom() in tom_desktop.',
);

/// Opens the pull request through `gh`.
@riverpod
CreatePullRequestUseCase createPullRequest(Ref ref) => throw StateError(
  'createPullRequestProvider has no default. The composition root '
  'overrides it — see runTom() in tom_desktop.',
);

/// Opens the host's compare page in the browser.
@riverpod
OpenUrlUseCase openUrl(Ref ref) => throw StateError(
  'openUrlProvider has no default. The composition root overrides it — see '
  'runTom() in tom_desktop.',
);
