/// Which git a machine has, and whether the product works on it.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'git_version_value_object.freezed.dart';

/// A git release — `2.41.0` — read from what `git --version` prints.
///
/// The oldest one the product works on is [minimum]: `for-each-ref` learned
/// `%(ahead-behind:…)` in 2.41, and that is how the app finds the branch a
/// branch came from (`docs/product/home/opening-a-space/doc.md`).
@freezed
abstract class GitVersionValueObject with _$GitVersionValueObject {
  /// A release.
  const factory GitVersionValueObject({
    required int major,
    required int minor,
    @Default(0) int patch,
  }) = _GitVersionValueObject;

  const GitVersionValueObject._();

  /// The oldest git the product works on.
  static const GitVersionValueObject minimum = GitVersionValueObject(
    major: 2,
    minor: 41,
  );

  /// The release [output] names, or null when it names none.
  ///
  /// Takes the line git prints whole — `git version 2.54.0 (Apple
  /// Git-157)` — and reads the first dotted number in it.
  static GitVersionValueObject? tryParse(String output) {
    final RegExpMatch? match = RegExp(
      r'(\d+)\.(\d+)(?:\.(\d+))?',
    ).firstMatch(output);
    if (match == null) {
      return null;
    }
    return GitVersionValueObject(
      major: int.parse(match.group(1)!),
      minor: int.parse(match.group(2)!),
      patch: int.tryParse(match.group(3) ?? '') ?? 0,
    );
  }

  /// Whether the product works on this release.
  bool get isSupported => !_isBefore(minimum);

  bool _isBefore(GitVersionValueObject other) {
    if (major != other.major) {
      return major < other.major;
    }
    if (minor != other.minor) {
      return minor < other.minor;
    }
    return patch < other.patch;
  }

  /// `2.39.2`, as the sentence under the title says it.
  String get text => '$major.$minor.$patch';
}
