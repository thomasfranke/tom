/// Why the place releases are published could not be asked.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';

part 'app_updates_failure.freezed.dart';

/// What [AppUpdates](app_updates.dart) can fail with.
@freezed
sealed class AppUpdatesFailure with _$AppUpdatesFailure implements AppFailure {
  /// The host did not answer, answered with an error, or the machine could
  /// not reach it.
  const factory AppUpdatesFailure.unreachable(
    /// What went wrong, for diagnostics — never shown.
    String reason, {
    AppFailure? cause,
  }) = AppUpdatesUnreachable;
}
