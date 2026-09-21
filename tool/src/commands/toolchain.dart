// What this machine has, and what this repository asks of it.
//
// The probes live here rather than inside the commands that read them:
// `tom doctor` asks whether the two agree, `tom updates` asks whether both
// have fallen behind what Flutter has released, and those are two readings of
// one set of facts. Every path this repository pins a version in is named
// once, here, so a reader never has to know where a number came from.
library;

import 'dart:convert';
import 'dart:io';

import '../repo.dart';
import 'process.dart';

/// Where the Flutter version is pinned.
///
/// The single source of truth: the GitHub workflows read the same file
/// through `flutter-version-file`, and `tom fvm` applies it locally. It lives
/// inside `src/` because that is the actual Flutter project root.
const fvmrcPath = 'src/.fvmrc';

/// Where the Dart SDK constraint is declared for the whole workspace.
const workspacePubspecPath = 'src/pubspec.yaml';

/// A semantic version, ordered numerically.
///
/// `3.9.0` sorts *after* `3.12.0` as text and before it as a version, which
/// is the whole reason this exists rather than a string comparison on what
/// the tools print.
final class Version implements Comparable<Version> {
  const Version(this.major, this.minor, this.patch);

  /// The first `x.y.z` in [text], or `null` when it holds none.
  ///
  /// A scan rather than a parse: every tool spells its version differently —
  /// `Dart SDK version: 3.12.2 (stable) (Tue Jun 9 …)`, `^3.12.0`,
  /// `3.14.0 (build 3.14.0-95.2.beta)` — and the three numbers are the only
  /// part all of them agree on. A pre-release suffix is dropped with the
  /// rest, because nothing here ever compares anything but stable releases.
  static Version? parse(String text) {
    final match = RegExp(r'(\d+)\.(\d+)\.(\d+)').firstMatch(text);
    if (match == null) return null;
    return Version(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }

  final int major;
  final int minor;
  final int patch;

  /// Whether this satisfies `^[other]`, as pub reads a caret: at least
  /// [other], and below the next version that is allowed to break.
  ///
  /// That boundary is the major, except below 1.0.0 where there is no major
  /// to move yet and the minor carries the breakage instead.
  bool satisfiesCaret(Version other) {
    if (compareTo(other) < 0) return false;
    return other.major > 0
        ? major == other.major
        : major == 0 && minor == other.minor;
  }

  @override
  int compareTo(Version other) => switch (0) {
    _ when major != other.major => major - other.major,
    _ when minor != other.minor => minor - other.minor,
    _ => patch - other.patch,
  };

  bool operator <(Version other) => compareTo(other) < 0;

  bool operator >(Version other) => compareTo(other) > 0;

  @override
  bool operator ==(Object other) => other is Version && compareTo(other) == 0;

  @override
  int get hashCode => Object.hash(major, minor, patch);

  @override
  String toString() => '$major.$minor.$patch';
}

/// A Flutter installation, as it describes itself.
typedef FlutterBuild = ({Version framework, Version dart, String channel});

/// The Flutter version `src/.fvmrc` pins, verbatim, or `null` if the file is
/// missing or does not say.
///
/// Parsed by hand rather than with a YAML or JSON package: `tool/` depends on
/// nothing but the SDK — that is what lets it be the thing that resolves the
/// workspace — and one well-known key does not justify losing it.
String? pinnedFlutterVersion() {
  final file = File('${repoRoot().path}/$fvmrcPath');
  if (!file.existsSync()) return null;

  final match = RegExp(
    r'"flutter"\s*:\s*"([^"]+)"',
  ).firstMatch(file.readAsStringSync());
  return match?.group(1);
}

/// The `sdk:` constraint the workspace declares, verbatim — `^3.12.0`.
///
/// Read from the workspace root rather than from a package: every package
/// declares the same constraint, and the root is the one that cannot be a
/// copy of something else.
///
/// Anchored on `environment:` rather than matching the first `sdk:` in the
/// file, because an app's pubspec spells its Flutter dependency the same way.
String? declaredDartConstraint() {
  final file = File('${repoRoot().path}/$workspacePubspecPath');
  if (!file.existsSync()) return null;

  final match = RegExp(
    r'''environment:\s*\n\s*sdk:\s*['"]?([^'"\n]+)''',
  ).firstMatch(file.readAsStringSync());
  return match?.group(1)?.trim();
}

/// The Dart SDK this CLI is running on.
///
/// [Platform.version] rather than a `dart --version` on `PATH`: the SDK
/// executing the commands is the one that has to satisfy the constraint, and
/// on a machine with two of them those are not the same answer.
Version? installedDart() => Version.parse(Platform.version);

/// What the Flutter on `PATH` reports about itself, or `null` when there is
/// none — or when it answered something this cannot read.
///
/// `--machine` is asked for rather than the human output so the channel and
/// the bundled Dart come back as fields instead of as a paragraph to scrape.
Future<FlutterBuild?> installedFlutter() async {
  final result = await capture('flutter', ['--version', '--machine']);
  if (result == null || result.exitCode != 0) return null;

  final object = _jsonObjectIn(result.stdout as String);
  if (object == null) return null;

  final framework = Version.parse('${object['frameworkVersion']}');
  final dart = Version.parse('${object['dartSdkVersion']}');
  if (framework == null || dart == null) return null;

  return (
    framework: framework,
    dart: dart,
    channel: '${object['channel'] ?? 'unknown'}',
  );
}

/// Whether [executable] can be run at all.
///
/// Presence, not health: a tool that answers with a non-zero code is still
/// installed, and the question every caller has is whether it is there.
Future<bool> isInstalled(
  String executable, {
  List<String> arguments = const ['--version'],
}) async => await capture(executable, arguments) != null;

/// The version [executable] prints, or `null` when it is not on `PATH` or
/// says nothing that looks like one.
///
/// Both streams are scanned: `--version` is written to stdout by most tools
/// and to stderr by enough of them that picking one would be a coin flip.
Future<Version?> versionOf(
  String executable, {
  List<String> arguments = const ['--version'],
}) async {
  final result = await capture(executable, arguments);
  if (result == null) return null;
  return Version.parse('${result.stdout}\n${result.stderr}');
}

/// Whether the workspace has been resolved on this machine.
///
/// The file `pub get` writes, rather than `.dart_tool/` itself: the directory
/// is created by other tools too, and an empty one would report a workspace
/// that cannot build as ready.
bool isWorkspaceResolved() =>
    File('${repoRoot().path}/src/.dart_tool/package_config.json').existsSync();

/// The JSON object inside [text], or `null` if there is none.
///
/// Sliced between the outermost braces rather than decoded whole: Flutter
/// prepends an upgrade notice to `--machine` output often enough that a
/// strict decode would report "no Flutter" on a perfectly good install.
Map<String, dynamic>? _jsonObjectIn(String text) {
  final start = text.indexOf('{');
  final end = text.lastIndexOf('}');
  if (start < 0 || end < start) return null;

  try {
    return jsonDecode(text.substring(start, end + 1)) as Map<String, dynamic>;
  } on FormatException {
    return null;
  }
}
