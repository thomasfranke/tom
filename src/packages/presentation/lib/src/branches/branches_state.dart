/// What the branch switcher is showing, and what it is waiting on.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

part 'branches_state.freezed.dart';

/// The switcher's own state: the branches, the box, and the question.
///
/// **Which branch is checked out is not here** — that is
/// `SpaceSessionState.git`, read the same way the status bar reads it. What
/// lives here is the surface: the list to choose from, the text being typed
/// and whether a switch is waiting on an answer about unsaved work.
@freezed
sealed class BranchesState with _$BranchesState {
  /// No space is open, so there is nothing to list.
  const factory BranchesState.initial() = BranchesInitial;

  /// Git is being asked what branches there are.
  const factory BranchesState.loading() = BranchesLoading;

  /// The branches, and whatever the surface is in the middle of.
  const factory BranchesState.ready({
    /// Every local branch, in the order git reported them.
    required List<BranchEntity> branches,

    /// What is in the one text box, which means two things.
    ///
    /// While listing it filters; while creating it is the name of the
    /// branch about to be started. One box on screen is one string here —
    /// two fields for one control is how they come to disagree, and
    /// carrying the text across is the useful behaviour anyway: filtering
    /// for a branch that turns out not to exist leaves its name typed.
    @Default('') String draft,

    /// Whether the surface is naming a new branch rather than choosing one.
    @Default(false) bool isCreating,

    /// Git is working, so nothing else may be started.
    @Default(false) bool isBusy,

    /// The branch a switch is waiting to move to, or null when none is.
    ///
    /// Set when switching would silently discard an unsaved buffer: the
    /// product asks before, not after
    /// (`docs/product/git-workflow/branch-switch/doc.md`), and this is the
    /// question standing open.
    BranchNameValueObject? pending,

    /// Why the last operation did not happen, or null when it did.
    AppFailure? failure,

    /// What is wrong with the draft as a branch name, or null when nothing is.
    ///
    /// Said while typing rather than after pressing: a name git would refuse
    /// is knowable without asking git.
    String? rejected,
  }) = BranchesReady;

  /// Git could not be asked at all.
  const factory BranchesState.failed(AppFailure failure) = BranchesFailed;

  const BranchesState._();

  /// The branches to draw, the checked-out one first and the filter applied.
  ///
  /// Current first because that is what the mock shows and what the reader
  /// is orienting from; the rest keep git's own order rather than being
  /// sorted into a second opinion about them.
  List<BranchEntity> get visible => switch (this) {
    BranchesReady(:final List<BranchEntity> branches, :final String draft) =>
      <BranchEntity>[
        ...branches.where((BranchEntity it) => it.isCurrent),
        ...branches.where((BranchEntity it) => !it.isCurrent),
      ].where((BranchEntity it) => _matches(it, draft)).toList(),
    _ => const <BranchEntity>[],
  };

  /// Whether a name has been typed that could be created.
  bool get canCreate => switch (this) {
    BranchesReady(
      :final bool isCreating,
      :final String draft,
      :final String? rejected,
      :final bool isBusy,
    ) =>
      isCreating && draft.isNotEmpty && rejected == null && !isBusy,
    _ => false,
  };

  /// Whether [branch] survives the filter [draft], ignoring case.
  static bool _matches(BranchEntity branch, String draft) =>
      draft.isEmpty ||
      branch.name.value.toLowerCase().contains(draft.toLowerCase());
}
