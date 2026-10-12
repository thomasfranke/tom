/// Which TOM a build is.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_version_value_object.freezed.dart';

/// A release number — `1.2.0` — as a tag spells it, with or without a `v`.
@freezed
abstract class AppVersionValueObject with _$AppVersionValueObject {
  /// A release.
  const factory AppVersionValueObject({
    required int major,
    required int minor,
    @Default(0) int patch,
  }) = _AppVersionValueObject;

  const AppVersionValueObject._();

  /// The release [text] names, or null when it names none; a pre-release
  /// suffix (`-rc.1`) is ignored.
  static AppVersionValueObject? tryParse(String text) {
    final RegExpMatch? match = RegExp(
      r'^\s*v?(\d+)\.(\d+)(?:\.(\d+))?',
    ).firstMatch(text);
    if (match == null) {
      return null;
    }
    return AppVersionValueObject(
      major: int.parse(match.group(1)!),
      minor: int.parse(match.group(2)!),
      patch: int.tryParse(match.group(3) ?? '') ?? 0,
    );
  }

  /// Whether this release comes after [other].
  bool isNewerThan(AppVersionValueObject other) {
    if (major != other.major) {
      return major > other.major;
    }
    if (minor != other.minor) {
      return minor > other.minor;
    }
    return patch > other.patch;
  }

  /// `1.2.0`, as the dialog says it.
  String get text => '$major.$minor.$patch';
}
