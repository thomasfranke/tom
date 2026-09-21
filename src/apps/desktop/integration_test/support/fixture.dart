/// The prepared environment, as the scenarios see it.
library;

import 'dart:convert';
import 'dart:io';

/// Where `tom e2e prepare` puts what the scenarios run against.
///
/// Inside the repository and gitignored, rather than under the system
/// temporary directory, for one reason: **you can open it in the app**. An
/// end-to-end failure is read by looking at what the test was looking at,
/// and a path under `/var/folders/…` that vanishes on reboot is not
/// something anyone inspects.
const String e2eDirectory = '.e2e';

/// Where a scenario called [name] keeps its preferences.
///
/// Beside the prepared environment, so `tom e2e clean` takes it with
/// everything else, and named after the scenario so two of them cannot see
/// each other's recent list.
String scenarioSettingsPath(String name) {
  final String slug = name
      .toLowerCase()
      .replaceAll(RegExp('[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
  return '${E2eFixtures.directory}/preferences/$slug.json';
}

/// One situation the app can be pointed at.
///
/// Read from the manifest the CLI wrote rather than declared here, because
/// the CLI builds the folders and these scenarios assert against them, and
/// the two live in different worlds — `tool/` has no pubspec and can share
/// no constant with `src/`. The manifest is the seam: one side writes it,
/// the other reads it, and a scenario renamed on one side fails loudly on
/// the other instead of quietly testing nothing.
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

  /// The markdown files the space holds, relative to [root] and sorted.
  List<String> get documents =>
      ((_values['documents'] ?? const <String>[]) as List<Object?>)
          .cast<String>();
}

/// Reads what `tom e2e prepare` built.
///
/// Fails with an explanation rather than an assertion nobody can act on: a
/// missing environment is the most common reason these scenarios fail, and
/// the fix is one command.
final class E2eFixtures {
  E2eFixtures._(this._scenarios);

  final Map<String, Object?> _scenarios;

  /// The prepared environment's absolute path, once it has been found.
  ///
  /// Set by [E2eFixtures.load] and read by [scenarioSettingsPath], which
  /// needs it before any fixture is asked for.
  static late String directory;

  /// Loads the manifest, searching upward for the repository root.
  ///
  /// Upward, because the working directory of a test run is the package's,
  /// not the repository's, and a relative path that only works from one of
  /// them is a trap for whoever runs a single file.
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
