/// The prepared environment, as the scenarios see it.
library;

import 'dart:convert';
import 'dart:io';

/// Where `tom e2e prepare` puts what the scenarios run against.
///
/// Inside the repository rather than the system temporary folder, so what a
/// failing test was looking at can be opened in the app.
const String e2eDirectory = '.e2e';

/// Where a scenario called [name] keeps its preferences.
///
/// Beside the environment so `tom e2e clean` takes it too, and per scenario
/// so no two of them share a recent list.
String scenarioSettingsPath(String name) {
  final String slug = name
      .toLowerCase()
      .replaceAll(RegExp('[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
  return '${E2eFixtures.directory}/preferences/$slug.json';
}

/// One situation the app can be pointed at.
///
/// Read from the manifest the CLI wrote, because `tool/` has no pubspec and
/// can share no constant with `src/`: the manifest is the seam, and a name
/// changed on one side fails loudly on the other.
final class Fixture {
  const Fixture._(this._values);

  final Map<String, Object?> _values;

  /// The folder the app opens — what the user picks.
  String get root => _values['root']! as String;

  /// The repository that encloses [root], which may be [root] itself.
  String get repositoryRoot =>
      (_values['repositoryRoot'] ?? _values['root'])! as String;

  /// What the space is called once it is open.
  String get name => _values['name']! as String;

  /// The bare repository this one tracks, for a fixture that has a remote.
  ///
  /// A path on disk is a real remote to git, so fetch, push and pull take the
  /// same code path they would against a server, with no network.
  String get remoteRoot => _values['remoteRoot']! as String;

  /// The markdown files the space holds, relative to [root] and sorted.
  List<String> get documents =>
      ((_values['documents'] ?? const <String>[]) as List<Object?>)
          .cast<String>();
}

/// Reads what `tom e2e prepare` built.
///
/// A missing environment is the commonest failure and the fix is one
/// command, so that is what the error says.
final class E2eFixtures {
  E2eFixtures._(this._scenarios);

  final Map<String, Object?> _scenarios;

  /// The prepared environment's absolute path.
  ///
  /// Set by [E2eFixtures.load], read by [scenarioSettingsPath].
  static late String directory;

  /// Loads the manifest, searching upward for the repository root.
  ///
  /// Upward, because the working directory of a test run is the package's,
  /// not the repository's.
  factory E2eFixtures.load() {
    Directory directory_ = Directory.current;
    while (true) {
      final File manifest = File(
        '${directory_.path}/$e2eDirectory/manifest.json',
      );
      if (manifest.existsSync()) {
        directory = '${directory_.path}/$e2eDirectory';
        final Object? decoded = jsonDecode(manifest.readAsStringSync());
        if (decoded is! Map<String, Object?>) {
          throw StateError(_corrupt);
        }
        return E2eFixtures._(decoded['scenarios']! as Map<String, Object?>);
      }
      final Directory parent = directory_.parent;
      if (parent.path == directory_.path) {
        throw StateError(_missing);
      }
      directory_ = parent;
    }
  }

  /// The scenario called [name].
  Fixture operator [](String name) {
    final Object? values = _scenarios[name];
    if (values is! Map<String, Object?>) {
      throw StateError(
        'No e2e scenario called "$name". The environment holds: '
        '${_scenarios.keys.join(', ')}.\n'
        'If you just added one, rebuild with `tom e2e prepare`.',
      );
    }
    return Fixture._(values);
  }

  static const String _missing =
      'The end-to-end environment is not prepared.\n'
      'Run `tom e2e prepare` (or `make e2e-prepare`) and try again.\n'
      'It builds $e2eDirectory/ — real repositories with real markdown in '
      'them — which is what these scenarios drive the app against.';

  static const String _corrupt =
      'The end-to-end manifest is not a JSON object. Rebuild the '
      'environment with `tom e2e prepare`.';
}
