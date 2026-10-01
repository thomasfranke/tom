// What this machine has, and what this repository asks of it.
library;

import 'dart:convert';
import 'dart:io';

import '../repo.dart';
import 'process.dart';

/// Where the Flutter version is pinned: the single source of truth, read by
/// the GitHub workflows through `flutter-version-file` and applied locally by
/// `tom fvm`. Inside `src/` because that is the Flutter project root.
const fvmrcPath = 'src/.fvmrc';

/// Where the Dart SDK constraint is declared for the whole workspace.
const workspacePubspecPath = 'src/pubspec.yaml';

/// A semantic version, ordered numerically: `3.9.0` sorts after `3.12.0` as
/// text and before it as a version.
final class Version implements Comparable<Version> {
  const Version(this.major, this.minor, this.patch);

  /// The first `x.y.z` in [text], or `null` when it holds none.
  ///
  /// A scan rather than a parse: every tool spells its version differently
  /// and the three numbers are the only part they agree on. A pre-release
  /// suffix is dropped, because only stable releases are ever compared.
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

  /// Whether this satisfies `^[other]` as pub reads a caret: at least
  /// [other], and below the next version allowed to break — the major,
  /// except below 1.0.0 where the minor carries the breakage.
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

/// The Flutter version `src/.fvmrc` pins, verbatim, or `null` when the file
/// is missing or does not say.
///
/// Parsed by hand: `tool/` depends on nothing but the SDK, which is what lets
/// it be the thing that resolves the workspace.
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
/// Read from the workspace root, the one pubspec that cannot be a copy, and
/// anchored on `environment:` because an app's Flutter dependency spells
/// `sdk:` the same way.
String? declaredDartConstraint() {
  final file = File('${repoRoot().path}/$workspacePubspecPath');
  if (!file.existsSync()) return null;

  final match = RegExp(
    r'''environment:\s*\n\s*sdk:\s*['"]?([^'"\n]+)''',
  ).firstMatch(file.readAsStringSync());
  return match?.group(1)?.trim();
}

/// The Dart SDK this CLI is running on — [Platform.version] rather than the
/// `dart` on `PATH`, since on a machine with two those are not the same.
Version? installedDart() => Version.parse(Platform.version);

/// What the Flutter on `PATH` reports about itself, or `null` when there is
/// none or it answered something this cannot read; `--machine` so the
/// channel and the bundled Dart come back as fields.
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

/// Whether [executable] can be run at all — presence, not health: a tool
/// that answers non-zero is still installed.
Future<bool> isInstalled(
  String executable, {
  List<String> arguments = const ['--version'],
}) async => await capture(executable, arguments) != null;

/// The version [executable] prints, or `null` when it is not on `PATH` or
/// says nothing that looks like one. Both streams are scanned, since enough
/// tools write `--version` to stderr.
Future<Version?> versionOf(
  String executable, {
  List<String> arguments = const ['--version'],
}) async {
  final result = await capture(executable, arguments);
  if (result == null) return null;
  return Version.parse('${result.stdout}\n${result.stderr}');
}

/// Whether the workspace has been resolved on this machine: the file `pub
/// get` writes, since `.dart_tool/` itself is created by other tools too.
bool isWorkspaceResolved() =>
    File('${repoRoot().path}/src/.dart_tool/package_config.json').existsSync();

/// The JSON object inside [text], or `null` if there is none.
///
/// Sliced between the outermost braces: Flutter prepends an upgrade notice
/// to `--machine` output often enough that a strict decode would fail.
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
