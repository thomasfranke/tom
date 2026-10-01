/// What the compare surface offers, and what is typed into its box.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/tom_domain.dart';

part 'compare_state.freezed.dart';

/// The surface's own state: what can be compared against, and the filter.
///
/// **Which revision is being compared against is not here** — that is
/// `SpaceSessionState.comparingAgainst`, because the preview and the bar
/// above the document read it too. This is the list and the box.
@freezed
sealed class CompareState with _$CompareState {
  /// No document is open, so there is nothing to compare.
  const factory CompareState.idle() = CompareIdle;

  /// What the surface offers, and what has been typed to narrow it.
  const factory CompareState.ready({
    /// Every local branch, as the switcher lists them.
    required List<BranchEntity> branches,

    /// The commits that touched the open document, as history lists them.
    ///
    /// The document's own and not the repository's: a commit that never
    /// touched it holds the same text as the last one that did, so offering
    /// it would be a longer list saying the same things.
    required List<CommitEntity> commits,

    /// What is in the box; empty shows everything.
    @Default('') String draft,
  }) = CompareReady;

  const CompareState._();

  /// The branches that survive the filter, in git's order.
  List<BranchEntity> get visibleBranches => switch (this) {
    CompareReady(:final List<BranchEntity> branches, :final String draft) =>
      branches
          .where((BranchEntity it) => _matches(it.name.value, draft))
          .toList(),
    _ => const <BranchEntity>[],
  };

  /// The commits that survive the filter, newest first.
  ///
  /// Matched on the subject and on the sha, because a sha is how a commit is
  /// named outside the app — in a review, in a terminal.
  List<CommitEntity> get visibleCommits => switch (this) {
    CompareReady(:final List<CommitEntity> commits, :final String draft) =>
      commits
          .where(
            (CommitEntity it) =>
                _matches(it.subject, draft) || _matches(it.sha.value, draft),
          )
          .toList(),
    _ => const <CommitEntity>[],
  };

  /// Whether [text] survives the filter [draft], ignoring case.
  static bool _matches(String text, String draft) =>
      draft.isEmpty || text.toLowerCase().contains(draft.toLowerCase());
}
