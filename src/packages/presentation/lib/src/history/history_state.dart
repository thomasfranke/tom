/// What the history panel is showing.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

part 'history_state.freezed.dart';

/// The commits that touched the open document, and nothing else.
///
/// Which one is being read is `SpaceSessionState.readingVersion`, because
/// the preview and the bar above the document need it too.
@freezed
sealed class HistoryState with _$HistoryState {
  /// No document is open — its own state, because "never committed" and
  /// "no file open" are different sentences.
  const factory HistoryState.idle() = HistoryIdle;

  /// Git is being asked what touched it.
  const factory HistoryState.loading() = HistoryLoading;

  /// The commits, newest first, as git reported them.
  const factory HistoryState.ready(List<CommitEntity> commits) = HistoryReady;

  /// Git could not be asked.
  const factory HistoryState.failed(AppFailure failure) = HistoryFailed;
}
