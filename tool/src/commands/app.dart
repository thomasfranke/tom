// `tom build` and `tom run` — the desktop app itself.
library;

import 'dart:io';

import 'process.dart';

/// The app the desktop build and run target.
Directory get _desktop => directoryFor('desktop');

/// The platform this machine builds natively, or `null` on anything else.
String? get hostPlatform => switch (Platform.operatingSystem) {
  'macos' || 'linux' || 'windows' => Platform.operatingSystem,
  _ => null,
};

/// Compile check for [platform] — the community build, proof that the public
/// repository compiles on its own; the distributed artifact is not produced
/// here.
Future<int> runBuild({String? platform}) async {
  final target = platform ?? hostPlatform;
  if (target == null) {
    stderr.writeln(
      'tom: ${Platform.operatingSystem} builds no desktop target — '
      'pass macos, linux or windows explicitly',
    );
    return 64; // EX_USAGE
  }

  announce('Build — $target');
  return flutter(['build', target, '--release'], workingDirectory: _desktop);
}

/// Opens the desktop app on [device], with any build-time feature [flags] as
/// `NAME=true` pairs turned into `--dart-define` — so a changed flag needs a
/// restart, not a hot reload.
Future<int> runApp({String? device, List<String> flags = const []}) async {
  final target = device ?? hostPlatform;
  if (target == null) {
    stderr.writeln(
      'tom: ${Platform.operatingSystem} runs no desktop target — '
      'pass macos, linux or windows explicitly',
    );
    return 64;
  }

  announce('Run — $target');
  return flutter([
    'run',
    '-d',
    target,
    for (final flag in flags) '--dart-define=$flag',
  ], workingDirectory: _desktop);
}
