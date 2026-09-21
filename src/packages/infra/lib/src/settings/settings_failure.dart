/// What a settings store can fail with.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';

part 'settings_failure.freezed.dart';

/// Reading or writing a preference did not work.
///
/// One variant, and that is the honest shape. Every other capability here
/// names the failures the product reacts to differently — a missing document
/// against a permission problem, a rejected push against a merge conflict.
/// Settings has none: the app's answer to a store it cannot read is the same
/// in every case, which is to carry on without what was in it. A second
/// variant arrives when something reacts to it differently.
@freezed
sealed class SettingsFailure with _$SettingsFailure implements AppFailure {
  /// The store could not be read or written.
  const factory SettingsFailure.unavailable(
    /// What the machine reported, verbatim. For diagnostics — never parsed.
    String description,
  ) = SettingsUnavailable;
}
