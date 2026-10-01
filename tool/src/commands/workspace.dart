// `tom setup`, `tom clean` and `tom fvm` — the workspace itself, rather than
// the code in it.
library;

import 'dart:io';

import 'process.dart';
import 'toolchain.dart';

/// Resolves every package in the workspace — one `pub get` for all, since
/// they share a single lockfile.
Future<int> runSetup() async {
  announce('Resolve the workspace');
  return flutter(['pub', 'get'], workingDirectory: srcDirectory);
}

/// Clears build artifacts from [targets], then resolves again.
///
/// All eight by default, because a pure Dart layer's `.dart_tool` is the
/// cache `tom codegen hard` does not clear. `flutter clean` rather than a
/// delete, since it leaves the root's `package_config.json` for [runSetup];
/// `coverage/` stays because the gate reuses it; and the resolve is not
/// optional, since without it the workspace cannot build.
Future<int> runClean({List<String> targets = allTargets}) async {
  for (final target in targets) {
    final directory = directoryFor(target);
    if (!directory.existsSync()) continue;

    announce('Clean — $target');
    final code = await flutter(['clean'], workingDirectory: directory);
    if (code != 0) return code;
  }

  return runSetup();
}

/// Pins the Flutter version this workspace is built against, taken from
/// [fvmrcPath] rather than passed in: CI, VS Code, `tom doctor` and `tom
/// updates` all read that file.
Future<int> runFvm() async {
  final version = pinnedFlutterVersion();
  if (version == null) {
    stderr.writeln('tom: could not read the Flutter version from $fvmrcPath');
    return 66; // EX_NOINPUT
  }

  announce('FVM — $version');

  final activated = await dart(['pub', 'global', 'activate', 'fvm']);
  if (activated != 0) return activated;

  return exec('fvm', ['use', version], workingDirectory: srcDirectory);
}
