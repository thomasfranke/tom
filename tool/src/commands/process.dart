// Running other programs, which is most of what the commands do.
library;

import 'dart:io';

import '../repo.dart';
import '../theme/theme.dart';

/// Runs [executable] and returns its exit code.
///
/// stdio is inherited rather than captured: these children are dashboards,
/// compilers and test runners that draw their own output, and piping them
/// would turn a live display into a transcript of every frame. It also means
/// a Ctrl-C reaches the child, which is the only way to stop a long build.
Future<int> exec(
  String executable,
  List<String> arguments, {
  Directory? workingDirectory,
}) async {
  final process = await Process.start(
    executable,
    arguments,
    workingDirectory: (workingDirectory ?? repoRoot()).path,
    mode: ProcessStartMode.inheritStdio,
  );
  return process.exitCode;
}

/// Runs one of this repository's own scripts under the current Dart.
///
/// [Platform.resolvedExecutable] rather than a bare `dart`: the SDK running
/// the CLI is the one that must run its scripts, or a machine with two of
/// them resolves the workspace against the wrong one.
Future<int> dart(List<String> arguments, {Directory? workingDirectory}) => exec(
  Platform.resolvedExecutable,
  arguments,
  workingDirectory: workingDirectory,
);

/// Runs `flutter`, which has to come from `PATH`.
///
/// Unlike `dart`, there is no resolved path to borrow — the Dart binary
/// inside an SDK is not the Flutter wrapper beside it.
Future<int> flutter(List<String> arguments, {Directory? workingDirectory}) =>
    exec('flutter', arguments, workingDirectory: workingDirectory);

/// Announces a step, so a composed command reads as a sequence rather than as
/// output arriving from nowhere.
void announce(String what) {
  stdout
    ..writeln()
    ..writeln('${palette.prompt}• $what${Ansi.reset}');
}

/// The workspace root, `src/`, where the Dart workspace actually lives.
Directory get srcDirectory => Directory('${repoRoot().path}/src');

/// Where [target]'s sources live: `src/packages/x`, or `src/apps/x` for the
/// two Flutter apps.
Directory directoryFor(String target) => Directory(
  '${srcDirectory.path}/${apps.contains(target) ? 'apps' : 'packages'}/'
  '$target',
);

/// The Flutter apps, which differ from the packages in where they live and in
/// which test runner they need.
const apps = {'desktop', 'mobile'};

/// Every package the workspace holds, in dependency order.
const packages = [
  'core',
  'domain',
  'application',
  'infra',
  'data',
  'presentation',
];

/// Packages and apps together — the full set of build and test targets.
const allTargets = [...packages, ...apps];
