/// What the remote actions are doing, and what the last one answered.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_presentation/src/remote/remote_action_enum.dart';

part 'remote_state.freezed.dart';

/// The states fetch, pull and push can leave behind.
///
/// **What git said is not here** — that is `SpaceSessionState.git`, which
/// every one of these re-reads. This is only what the buttons need: whether
/// one is running, and what the last one answered.
@freezed
sealed class RemoteState with _$RemoteState {
  /// Nothing is running, and the last action said nothing worth keeping.
  const factory RemoteState.idle() = RemoteIdle;

  /// [action] is in flight.
  ///
  /// Which one, not just *something*: the button that is working says so,
  /// and the other two are disabled rather than all three going grey with
  /// no explanation.
  const factory RemoteState.working(RemoteActionEnum action) = RemoteWorking;

  /// The push was refused because the remote moved first.
  ///
  /// Its own state and not a failure among others, because it is the one
  /// the product answers with a screen: somebody pushed first, nothing
  /// local was lost, and the remedy is a pull
  /// (`docs/product/git-workflow/push-pull/doc.md`).
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
