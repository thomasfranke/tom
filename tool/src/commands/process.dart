// Running other programs, which is most of what the commands do.
library;

import 'dart:io';

import '../repo.dart';
import '../theme/theme.dart';

/// Runs [executable] and returns its exit code.
///
/// stdio is inherited: these children draw their own output, and piping them
/// would turn a live display into a transcript of every frame. It also lets a
/// Ctrl-C reach the child.
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

/// Runs [executable] and answers what it printed, or `null` when there is no
/// such program: the caller wants the output as a value, and "is this
/// installed" is a question with an answer, not an error.
Future<ProcessResult?> capture(
  String executable,
  List<String> arguments, {
  Directory? workingDirectory,
}) async {
  try {
    return await Process.run(
      executable,
      arguments,
      workingDirectory: (workingDirectory ?? repoRoot()).path,
    );
  } on ProcessException {
    return null;
  }
}

/// The Dart to spawn, wherever this CLI spawns one.
///
/// [Platform.resolvedExecutable] rather than a bare `dart`: the SDK running
/// this process must run its children, or a machine with two resolves the
/// workspace against the wrong one, silently, since the wrong SDK still
/// builds. `flutter` has no equivalent to borrow ([flutter]).
String get dartExecutable => Platform.resolvedExecutable;

/// Runs one of this repository's own scripts under the current Dart.
Future<int> dart(List<String> arguments, {Directory? workingDirectory}) =>
    exec(dartExecutable, arguments, workingDirectory: workingDirectory);

/// Runs `flutter`, which has to come from `PATH`: the Dart binary inside an
/// SDK is not the Flutter wrapper beside it.
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

/// The Flutter apps, which differ from the packages in where they live.
const apps = {'desktop', 'mobile'};

/// Every package the workspace holds, in dependency order.
const packages = [
  'core',
  'domain',
  'application',
  'infra',
  'data',
  'presentation',
  'ui',
];

/// What needs `flutter test` rather than `dart test`: the applications, and
/// `ui`, which lives with the packages but draws
/// ([Decision 26](../../../docs/technical/decisions/026-the-look-is-a-package.md)).
const drawn = {...apps, 'ui'};

/// Packages and apps together — the full set of build and test targets.
const allTargets = [...packages, ...apps];
