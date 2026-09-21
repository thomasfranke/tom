/// Where this machine keeps an application's own files.
library;

import 'dart:io';

import 'package:meta/meta.dart';

/// The folder TOM may write its per-machine files into.
///
/// Derived from the platform's own conventions rather than read from
/// `path_provider`, for the reason `JsonFileSettings` does not use
/// `shared_preferences`: both are Flutter plugins, and this package is pure
/// Dart so that framework independence is asserted by `dart test` on every
/// run rather than claimed in a document.
///
/// | Platform | Folder |
/// |---|---|
/// | macOS | `~/Library/Application Support/tom` |
/// | Windows | `%APPDATA%\tom` |
/// | Linux and the rest | `$XDG_CONFIG_HOME/tom`, else `~/.config/tom` |
///
/// The folder is not created here. Nothing has to: `Filesystem.writeFile`
/// creates the directories its path needs, so the folder appears the first
/// time something is actually stored and a user who never changes a
/// preference never gets a folder.
///
/// [operatingSystem] and [environment] default to this machine's and exist
/// so the three branches above are *tested* rather than asserted — two of
/// them are unreachable on whatever machine the suite happens to run on,
/// which is the most common way a path bug ships.
///
/// Throws [StateError] when the machine names no home directory at all,
/// which is a machine this app cannot run on rather than a state to model.
String applicationSupportDirectory({
  String application = 'tom',
  @visibleForTesting String? operatingSystem,
  @visibleForTesting Map<String, String>? environment,
}) {
  final String platform = operatingSystem ?? Platform.operatingSystem;
  final Map<String, String> variables = environment ?? Platform.environment;
  if (platform == 'windows') {
    final String? appData = variables['APPDATA'];
    if (appData != null && appData.isNotEmpty) {
      return '$appData\\$application';
    }
    return '${_home(variables)}\\AppData\\Roaming\\$application';
  }
  if (platform == 'macos') {
    return '${_home(variables)}/Library/Application Support/$application';
  }
  final String? configHome = variables['XDG_CONFIG_HOME'];
  if (configHome != null && configHome.isNotEmpty) {
    return '$configHome/$application';
  }
  return '${_home(variables)}/.config/$application';
}

/// The user's home directory.
String _home(Map<String, String> environment) {
  final String? home = environment['HOME'] ?? environment['USERPROFILE'];
  if (home == null || home.isEmpty) {
    throw StateError('This machine names no home directory.');
  }
  return home;
}
