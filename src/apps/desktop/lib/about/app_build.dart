/// What this build knows about itself, decided when it was made.
library;

import 'dart:io';

/// The version, the build and the platform — read at build time, so nothing
/// is asked of the network to say which TOM this is
/// (`docs/product/about/doc.md`).
///
/// Set with `--dart-define=TOM_VERSION=1.2.0 --dart-define=TOM_BUILD=abc123`;
/// the defaults are the pubspec's version and a development build.
abstract final class AppBuild {
  /// The release number, as the pubspec carries it.
  static const String version = String.fromEnvironment(
    'TOM_VERSION',
    defaultValue: '0.1.0',
  );

  /// What it was made from: a commit, or `dev`.
  static const String build = String.fromEnvironment(
    'TOM_BUILD',
    defaultValue: 'dev',
  );

  /// Whether a first release exists on GitHub. False until one is
  /// published, which is why a build ships with the check unavailable.
  static const bool releasesPublished = bool.fromEnvironment('TOM_RELEASES');

  /// Where the source, the licences and the releases are.
  static const String repository = 'https://github.com/thomasfranke/tom';

  /// Where the latest release is answered.
  static const String latestRelease =
      'https://api.github.com/repos/thomasfranke/tom/releases/latest';
}

/// The platform in the words people use.
String platformName() => switch (Platform.operatingSystem) {
  'macos' => 'macOS',
  'windows' => 'Windows',
  'linux' => 'Linux',
  final String other => other,
};
