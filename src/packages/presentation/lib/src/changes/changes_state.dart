/// What the changes panel owns: the draft, not the facts.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';

part 'changes_state.freezed.dart';

/// The states the changes panel can be in, and there are only these.
///
/// What the repository reports is `SpaceSessionState.git`, because the
/// status bar reads it too; this is the half nobody else wants.
@freezed
sealed class ChangesState with _$ChangesState {
  /// No space is open, so there is no repository to report on.
  const factory ChangesState.initial() = ChangesInitial;

  /// Git is being asked where it stands.
  const factory ChangesState.loading() = ChangesLoading;

  /// Git answered, and this is what the panel is holding on top of it.
  const factory ChangesState.ready({
    /// The commit message being written — a draft, so panel-local.
    @Default('') String message,

    /// The body under the summary, optional; a commit joins the two with a
    /// blank line, which is how git tells them apart.
    @Default('') String description,

    /// Whether a stage, an unstage or a commit is in flight.
    ///
    /// One flag for all three: git is serialized per space underneath, so a
    /// second operation would only queue behind the first.
    @Default(false) bool isBusy,

    /// Whether the operation in flight is the commit: the one that dims the
    /// staged rows and says `Committing…`
    /// (`docs/product/git-workflow/commit/confirming/doc.md`).
    @Default(false) bool isCommitting,

    /// Why the last operation did not land, or null when it did.
    AppFailure? failure,
  }) = ChangesReady;

  /// Git could not be asked at all.
  const factory ChangesState.failed(AppFailure failure) = ChangesFailed;
}
