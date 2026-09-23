/// What asking this machine for a folder can fail with.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';

part 'platform_paths_failure.freezed.dart';

/// The machine would not say where an application's files go.
///
/// One variant, and it is close to unreachable on a desktop: every one of
/// the three platforms hands a process a home directory, and a machine that
/// does not is one that also hides the user's `.gitconfig` and SSH keys,
/// which [Decision
/// 2](../../../../../../docs/technical/decisions/002-git-via-system-binary.md)
/// is built on.
///
/// It exists anyway because the alternative is an exception crossing a
/// capability contract, and because the second implementation will need it
/// for real: a sandboxed mobile app asks the platform for its container over
/// a channel, and a channel answers or does not.
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
