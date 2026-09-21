// `tom setup`, `tom clean` and `tom fvm` — the workspace itself, rather than
// the code in it.
library;

import 'dart:io';

import 'process.dart';
import 'toolchain.dart';

/// Resolves every package in the workspace.
///
/// One `pub get` for all eight: they share a single lockfile, which is what
/// keeps two layers from ending up on different versions of a shared
/// dependency.
Future<int> runSetup() async {
  announce('Resolve the workspace');
  return flutter(['pub', 'get'], workingDirectory: srcDirectory);
}

/// Clears build artifacts from [targets], then resolves again.
///
/// All eight by default, not just the two apps: a pure Dart layer accumulates
/// its own
/// `.dart_tool` — the build_runner cache, the resolvers, the test runner's —
/// and it is the largest thing here by far, tens of megabytes per package.
/// It is also the cache that goes stale in ways nothing else clears: `tom
/// codegen hard` deletes the generated files and regenerates them, but the
/// cache the generator reads is not among them.
///
/// `flutter clean` rather than deleting the directories by hand, in a
/// workspace member too: it removes the `.dart_tool` of the directory it runs
/// in and no other, so the root's `package_config.json` — the one thing the
/// whole workspace resolves through — is left for [runSetup] to rewrite
/// rather than destroyed eight times over.
///
/// What it leaves behind is `coverage/`, and that is the wanted behaviour
/// rather than an oversight to correct later: the coverage gate reuses an
/// `lcov.info` it finds instead of running every package's suite a second
/// time, so clearing it would cost the next `verify` a full extra run.
///
/// The resolve at the end is not optional: `flutter clean` removes
/// `.dart_tool`, so stopping halfway leaves a workspace that cannot build at
/// all. It runs even when [targets] named a single package — resolving the
/// whole workspace is one cached `pub get`, and the alternative is a command
/// that sometimes leaves the tree resolved and sometimes does not.
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

/// Pins the Flutter version this workspace is built against.
///
/// `src/.fvmrc` is the single source of truth — the GitHub workflows and VS
/// Code read the same file, and so do `tom doctor` and `tom updates` — so the
/// version is taken from there rather than passed in. It lives inside `src/`
/// because that is the actual Flutter project root; FVM pins per project, and
/// the repository root is not one.
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
