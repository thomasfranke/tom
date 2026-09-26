/// What the remote actions are doing, and what the last one answered.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_presentation/src/remote/remote_action_enum.dart';

part 'remote_state.freezed.dart';

/// The states fetch, pull and push can leave behind: whether one is
/// running, and what the last one answered. What git said is
/// `SpaceSessionState.git`, which every one of these re-reads.
@freezed
sealed class RemoteState with _$RemoteState {
  /// Nothing is running, and the last action said nothing worth keeping.
  const factory RemoteState.idle() = RemoteIdle;

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
}
