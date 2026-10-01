/// The `dart:io` implementation of [PlatformPaths].
library;

import 'dart:io';

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

/// Derives the folders from each platform's own conventions.
///
/// Not `path_provider`: a Flutter plugin, and this package is pure Dart
/// (see [JsonFileSettingsImpl]).
///
/// | Platform | Folder |
/// |---|---|
/// | macOS | `~/Library/Application Support/tom` |
/// | Windows | `%APPDATA%\tom` |
/// | Linux and the rest | `$XDG_CONFIG_HOME/tom`, else `~/.config/tom` |
final class DartIoPlatformPathsImpl implements PlatformPaths {
  /// Creates the implementation.
  ///
  /// [operatingSystem] and [environment] default to this machine's and are
  /// the seam the other platforms' branches are tested through.
  const DartIoPlatformPathsImpl({
    this.application = 'tom',
    this.operatingSystem,
    this.environment,
  });

  /// The name the folder is given, which is the binary's.
  final String application;

  /// The platform to answer for, or this machine's.
  final String? operatingSystem;

  /// The variables to read, or this process's.
  final Map<String, String>? environment;

  @override
  Result<String, PlatformPathsFailure> applicationData() {
    final String platform = operatingSystem ?? Platform.operatingSystem;
    final Map<String, String> variables = environment ?? Platform.environment;
    if (platform == 'windows') {
      final String? appData = variables['APPDATA'];
      if (appData != null && appData.isNotEmpty) {
        return Success<String, PlatformPathsFailure>('$appData\\$application');
      }
      return _under(
        variables,
        (String home) => '$home\\AppData\\Roaming\\$application',
      );
    }
    if (platform == 'macos') {
      return _under(
        variables,
        (String home) => '$home/Library/Application Support/$application',
      );
    }
    final String? configHome = variables['XDG_CONFIG_HOME'];
    if (configHome != null && configHome.isNotEmpty) {
      return Success<String, PlatformPathsFailure>('$configHome/$application');
    }
    return _under(variables, (String home) => '$home/.config/$application');
  }

  /// [build] applied to the user's home directory, when there is one.
  static Result<String, PlatformPathsFailure> _under(
    Map<String, String> environment,
    String Function(String home) build,
  ) {
    final String? home = environment['HOME'] ?? environment['USERPROFILE'];
    if (home == null || home.isEmpty) {
      return const Failure<String, PlatformPathsFailure>(
        PlatformPathsUnavailable('This machine names no home directory.'),
      );
    }
    return Success<String, PlatformPathsFailure>(build(home));
  }
}
