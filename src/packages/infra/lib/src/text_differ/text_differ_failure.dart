/// What aligning two sequences can fail with.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';

part 'text_differ_failure.freezed.dart';

/// An alignment that did not complete.
///
/// One variant, and it is the fallback: two texts always line up somehow —
/// nothing here has invalid input. What is left is an algorithm that broke,
/// which is a bug and not a state the product has words for.
@freezed
sealed class TextDifferFailure with _$TextDifferFailure implements AppFailure {
  /// The differ threw.
  const factory TextDifferFailure.failed(
    /// What it reported, verbatim. For diagnostics — never parsed.
    String description, {
    AppFailure? cause,
  }) = TextDifferFailed;
}
