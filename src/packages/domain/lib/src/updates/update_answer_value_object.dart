/// What asking for a newer release came back with.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/updates/release_value_object.dart';

part 'update_answer_value_object.freezed.dart';

/// The three things a successful ask can say.
@freezed
sealed class UpdateAnswerValueObject with _$UpdateAnswerValueObject {
  /// Nothing has been published.
  const factory UpdateAnswerValueObject.noRelease() = UpdateNoRelease;

  /// The latest release is no newer than the one running.
  const factory UpdateAnswerValueObject.upToDate() = UpdateUpToDate;

  /// [release] is newer than the one running.
  const factory UpdateAnswerValueObject.newer(ReleaseValueObject release) =
      UpdateNewer;
}
