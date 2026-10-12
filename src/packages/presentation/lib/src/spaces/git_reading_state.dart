/// Whether the open space's git reading landed, and why it did not.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';

part 'git_reading_state.freezed.dart';

/// The states a git reading can be in, and there are only these.
///
/// What git said is `SpaceSessionState.git` and `merge`, because the whole
/// window reads it; this is only how the asking went.
@freezed
sealed class GitReadingState with _$GitReadingState {
  /// No space is open, or the open one has no repository: nothing to read.
  const factory GitReadingState.initial() = GitReadingInitial;

  /// The first reading of this space has not answered yet.
  const factory GitReadingState.loading() = GitReadingLoading;

  /// The last reading landed on the session.
  const factory GitReadingState.ready() = GitReadingReady;

  /// The person refused the last reading: what the session holds is the one
  /// before it — nothing at all, when there was none — and it is out of
  /// date until a `Reload` asks again
  /// (`docs/product/git-workflow/approvals/doc.md`).
  const factory GitReadingState.stale() = GitReadingStale;

  /// Git could not be asked at all.
  const factory GitReadingState.failed(AppFailure failure) = GitReadingFailed;
}
