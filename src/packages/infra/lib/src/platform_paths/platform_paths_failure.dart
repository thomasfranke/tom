/// What asking this machine for a folder can fail with.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';

part 'platform_paths_failure.freezed.dart';

/// The machine would not say where an application's files go.
///
/// Close to unreachable on a desktop, where every platform hands a process a
/// home directory; it exists because the alternative is an exception crossing
/// a contract, and a sandboxed mobile app asking over a channel will need it.
@freezed
sealed class PlatformPathsFailure
    with _$PlatformPathsFailure
    implements AppFailure {
  /// The folder could not be derived.
  const factory PlatformPathsFailure.unavailable(
    /// What was missing, verbatim. For diagnostics — never parsed.
    String description, {
    AppFailure? cause,
  }) = PlatformPathsUnavailable;
}
