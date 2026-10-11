/// What the remote actions are doing, and what the last one answered.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_presentation/src/remote/link_state_enum.dart';
import 'package:tom_presentation/src/remote/remote_action_enum.dart';

part 'remote_state.freezed.dart';

/// The states fetch, pull and push can leave behind: whether one is
/// running, and what the last one answered. What git said is
/// `SpaceSessionState.git`, which every one of these re-reads.
@freezed
sealed class RemoteState with _$RemoteState {
  /// Nothing is running, and the last action said nothing worth keeping —
  /// unless it was a pull that worked, whose news is [arrived].
  ///
  /// The news is not a state of its own: nothing runs and nothing is wrong,
  /// and it goes when the next action starts
  /// (`docs/product/git-workflow/push-pull/when-it-works/doc.md`).
  const factory RemoteState.idle({
    /// How many commits the last pull brought in, 0 when the space was
    /// already level; null after anything else, or when git could not count.
    int? arrived,

    /// The message of the commit that was just recorded, null after anything
    /// else (`docs/product/git-workflow/commit/confirming/doc.md`).
    String? committed,

    /// How many commits the last push published, 0 when git could not say;
    /// null after anything else
    /// (`docs/product/git-workflow/push-pull/when-it-works/doc.md`).
    int? published,
  }) = RemoteIdle;

  /// [action] is in flight — which one, so the working button can say so.
  const factory RemoteState.working(RemoteActionEnum action) = RemoteWorking;

  /// The push was refused because the remote moved first.
  ///
  /// Its own state, not a failure among others, because the product answers
  /// it with a screen
  /// (`docs/product/git-workflow/push-pull/when-it-fails/doc.md`).
  const factory RemoteState.rejected() = RemoteRejected;

  /// [action] did not finish, for a reason worth showing.
  const factory RemoteState.failed({
    required RemoteActionEnum action,
    required AppFailure failure,
  }) = RemoteFailed;

  const RemoteState._();

  /// Whether anything is in flight.
  bool get isBusy => this is RemoteWorking;

  /// What the last request said about the link, until another one answers
  /// — derived, so a request that succeeds is what clears it.
  LinkStateEnum? get link => switch (this) {
    RemoteFailed(failure: final AppFailure failure) => LinkStateEnum.of(
      failure,
    ),
    _ => null,
  };
}
