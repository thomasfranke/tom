// `tom setup`, `tom clean` and `tom fvm` — the workspace itself, rather than
// the code in it.
library;

import 'dart:io';

import '../repo.dart';
import 'process.dart';

/// Resolves every package in the workspace.
///
/// One `pub get` for all eight: they share a single lockfile, which is what
/// keeps two layers from ending up on different versions of a shared
/// dependency.
Future<int> runSetup() async {
  announce('Resolve the workspace');
  return flutter(['pub', 'get'], workingDirectory: srcDirectory);
}

/// Clears build artifacts from both apps, then resolves again.
///
/// The resolve is not optional: `flutter clean` removes `.dart_tool`, so
/// stopping halfway leaves a workspace that cannot build at all.
Future<int> runClean() async {
  for (final app in apps) {
    final directory = directoryFor(app);
    if (!directory.existsSync()) continue;

    announce('Clean — $app');
    final code = await flutter(['clean'], workingDirectory: directory);
    if (code != 0) return code;
  }

  return runSetup();
}

/// Pins the Flutter version this workspace is built against.
///
/// `src/.fvmrc` is the single source of truth — the GitHub workflows and VS
/// Code read the same file — so the version is taken from there rather than
/// passed in. It lives inside `src/` because that is the actual Flutter
/// project root; FVM pins per project, and the repository root is not one.
Future<int> runFvm() async {
  final version = _pinnedVersion();
  if (version == null) {
    stderr.writeln('tom: could not read the Flutter version from src/.fvmrc');
    return 66; // EX_NOINPUT
  }

  announce('FVM — $version');

  final activated = await dart(['pub', 'global', 'activate', 'fvm']);
  if (activated != 0) return activated;

  return exec('fvm', ['use', version], workingDirectory: srcDirectory);
}

/// The `flutter` entry of `src/.fvmrc`, or `null` if it is not readable.
///
/// Parsed by hand rather than with a YAML or JSON package: `tool/` depends on
/// nothing but the SDK, and one well-known key does not justify losing that.
String? _pinnedVersion() {
  final file = File('${repoRoot().path}/src/.fvmrc');
  if (!file.existsSync()) return null;

  final match = RegExp(
    r'"flutter"\s*:\s*"([^"]+)"',
  ).firstMatch(file.readAsStringSync());
  return match?.group(1);
}
