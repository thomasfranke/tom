/// What asking for a newer release can fail with.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';

part 'update_failure.freezed.dart';

/// The release host could not be asked, or said something unreadable.
@freezed
sealed class UpdateFailure with _$UpdateFailure implements AppFailure {
  /// GitHub did not answer: offline, a silence, or an error status
  /// (`docs/product/about/doc.md`).
  const factory UpdateFailure.unreachable({AppFailure? cause}) =
      UpdateUnreachable;
}
