/// What the changes panel owns: the draft, not the facts.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';

part 'changes_state.freezed.dart';

/// The states the changes panel can be in, and there are only these.
///
/// **What the repository reports is not here** — that is
/// `SpaceSessionState.git`, because the status bar reads it too. This is
/// the half nobody else wants: the message being typed, whether git is busy,
/// and what the last operation refused to do.
@freezed
sealed class ChangesState with _$ChangesState {
  /// No space is open, so there is no repository to report on.
  const factory ChangesState.initial() = ChangesInitial;

  /// Git is being asked where it stands.
  const factory ChangesState.loading() = ChangesLoading;

  /// Git answered, and this is what the panel is holding on top of it.
  const factory ChangesState.ready({
    /// The commit message being written.
    ///
    /// Panel-local on purpose: an unsent message is a draft, and nothing
    /// outside this panel has an opinion about it.
    @Default('') String message,

    /// Whether a stage, an unstage or a commit is in flight.
    ///
    /// One flag for all three: git is serialized per space underneath, so a
    /// second operation would queue behind the first anyway, and a panel
    /// that let one be started twice would just be lying about it.
    @Default(false) bool isBusy,

    /// Why the last operation did not land, or null when it did.
    ///
    /// A commit that failed silently is as bad as a save that did: the work
    /// is still only in the working tree.
    AppFailure? failure,
  }) = ChangesReady;

  /// Git could not be asked at all.
  const factory ChangesState.failed(AppFailure failure) = ChangesFailed;
}
