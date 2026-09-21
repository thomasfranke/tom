/// [Settings] as one JSON file in the user's application-support folder.
library;

import 'dart:convert';

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/src/filesystem/filesystem.dart';
import 'package:tom_infra/src/filesystem/filesystem_failure.dart';
import 'package:tom_infra/src/settings/settings.dart';
import 'package:tom_infra/src/settings/settings_failure.dart';

/// Preferences kept as a JSON object in a single file.
///
/// **Not `shared_preferences`**, which the dependency table names first and
/// which cannot be used here: it is a Flutter plugin, and `tom_infra` is
/// pure Dart so that six of the seven packages run under `dart test` with no
/// Flutter binding available ([Decision
/// 14](../../../../../../../docs/technical/decisions/014-each-layer-is-its-own-package.md)).
/// Taking it would push settings up into `tom_desktop`, away from the layer
/// that owns capabilities, to store a list of folder paths. The table's own
/// second option — JSON in application support — costs a few lines and keeps
/// the boundary (`docs/technical/dependencies.md`).
///
/// Writing goes through [Filesystem], which already lands a file through a
/// temporary sibling and a rename. So a crash mid-save cannot leave a
/// half-written preferences file, and this class does not have to know that.
///
/// The whole file is read and rewritten on every access. At the size of a
/// preferences file that is the right trade: no cache to invalidate, no
/// state to go stale against a second window, and the cost is one small file
/// read per preference.
final class JsonFileSettings implements Settings {
  /// Creates a store backed by the file at [path].
  const JsonFileSettings({required this.filesystem, required this.path});

  /// What reads and writes the file.
  final Filesystem filesystem;

  /// The absolute path of the JSON file.
  ///
  /// Given rather than derived, so a test points it at a temporary folder
  /// and the composition root is the only place that knows where a real
  /// user's preferences live — see `application_support.dart`.
  final String path;

  @override
  Future<Result<String?>> read(String key) async {
    final Result<Map<String, Object?>> stored = await _load();
    return switch (stored) {
      Success<Map<String, Object?>>(value: final Map<String, Object?> all) =>
        Success<String?>(all[key] as String?),
      Failure<Map<String, Object?>>(failure: final AppFailure failure) =>
        Failure<String?>(failure),
    };
  }

  @override
  Future<Result<void>> write(String key, String value) =>
      _mutate((Map<String, Object?> all) => all[key] = value);

  @override
  Future<Result<void>> remove(String key) =>
      _mutate((Map<String, Object?> all) => all.remove(key));

  /// Applies [change] to the stored object and writes it back.
  Future<Result<void>> _mutate(
    void Function(Map<String, Object?>) change,
  ) async {
    final Result<Map<String, Object?>> stored = await _load();
    if (stored case Failure<Map<String, Object?>>(
      failure: final AppFailure failure,
    )) {
      return Failure<void>(failure);
    }
    final Map<String, Object?> all =
        (stored as Success<Map<String, Object?>>).value;
    change(all);
    final Result<void> written = await filesystem.writeFile(
      path,
      const JsonEncoder.withIndent('  ').convert(all),
    );
    return switch (written) {
      Success<void>() => const Success<void>(null),
      Failure<void>(failure: final AppFailure failure) => Failure<void>(
        _asSettingsFailure(failure),
      ),
    };
  }

  /// The stored object, or an empty one.
  ///
  /// A file that is not there yet is the first run, not a failure. A file
  /// that is there and is not a JSON object is treated the same way: the
  /// alternative is refusing to start over a preferences file someone
  /// hand-edited, and nothing in it is worth that.
  Future<Result<Map<String, Object?>>> _load() async {
    final Result<String> text = await filesystem.readFile(path);
    switch (text) {
      case Failure<String>(failure: FilesystemEntryNotFound()):
        // Deliberately not const: a const map is unmodifiable, and what
        // comes back from here is about to be written into. The analyzer
        // asks for const and is wrong — this is the first-run path, so the
        // failure would only ever appear on a machine with no preferences
        // file, which is every machine exactly once.
        // ignore: prefer_const_constructors
        return Success<Map<String, Object?>>(<String, Object?>{});
      case Failure<String>(failure: final AppFailure failure):
        return Failure<Map<String, Object?>>(_asSettingsFailure(failure));
      case Success<String>(value: final String content):
        return Success<Map<String, Object?>>(_decode(content));
    }
  }

  /// [content] as a JSON object, or an empty one if it is not.
  static Map<String, Object?> _decode(String content) {
    try {
      final Object? decoded = jsonDecode(content);
      return decoded is Map<String, Object?>
          ? Map<String, Object?>.of(decoded)
          : <String, Object?>{};
    } on FormatException {
      return <String, Object?>{};
    }
  }

  /// What the disk reported, as this capability's own failure.
  ///
  /// Flattened to one variant on purpose: the caller's answer to any of them
  /// is the same, and [SettingsFailure] says why it has only one.
  static AppFailure _asSettingsFailure(AppFailure failure) =>
      failure is FilesystemFailure
      ? SettingsUnavailable(failure.toString())
      // Unreachable by the capability's contract.
      : failure;
}
