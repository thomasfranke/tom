/// What the update check last said.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'updates_state.freezed.dart';

/// The states the About dialog draws, and there are only these.
@freezed
sealed class UpdatesState with _$UpdatesState {
  /// No release has been published: the first state the app ships in, with
  /// the button unavailable.
  const factory UpdatesState.noRelease() = UpdatesNoRelease;

  /// Releases exist and nobody has asked yet.
  const factory UpdatesState.idle() = UpdatesIdle;

  /// The host is being asked.
  const factory UpdatesState.asking() = UpdatesAsking;

  /// The running version is the latest, as of [checkedAt].
  const factory UpdatesState.upToDate(DateTime checkedAt) = UpdatesUpToDate;

  /// A newer [version] exists; [notesUrl] says what is new.
  const factory UpdatesState.newer({
    required String version,
    required String notesUrl,
  }) = UpdatesNewer;

  /// The host did not answer. The old answer is not kept.
  const factory UpdatesState.failed() = UpdatesFailed;
}
