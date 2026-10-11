/// A published build.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/updates/app_version_value_object.dart';

part 'release_value_object.freezed.dart';

/// A release on the host: which version, and where to read what is new.
@freezed
abstract class ReleaseValueObject with _$ReleaseValueObject {
  /// A release.
  const factory ReleaseValueObject({
    required AppVersionValueObject version,

    /// The release's page, where its notes are.
    required String notesUrl,
  }) = _ReleaseValueObject;
}
