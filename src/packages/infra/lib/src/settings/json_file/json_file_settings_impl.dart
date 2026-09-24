/// [Settings] as one JSON file in the user's application-support folder.
library;

import 'dart:convert';

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

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
final class JsonFileSettingsImpl implements Settings {
  /// Creates a store backed by the file at [path].
  const JsonFileSettingsImpl({required this.filesystem, required this.path});

  /// What reads and writes the file.
  final Filesystem filesystem;

  /// The absolute path of the JSON file.
  ///
  /// Given rather than derived, so a test points it at a temporary folder
  /// and the composition root is the only place that knows where a real
  /// user's preferences live — see `application_data_directory.dart`.
  final String path;

  @override
  Future<Result<String?, SettingsFailure>> read(String key) async =>
      (await _load()).map((Map<String, Object?> all) {
        // Anything but a string was not written by this store, and is
        // treated like the rest of a hand-edited file: as nothing stored.
        // A cast would throw out of a contract that promises not to.
        final Object? stored = all[key];
        return stored is String ? stored : null;
      });

  @override
  Future<Result<void, SettingsFailure>> write(String key, String value) =>
      _mutate((Map<String, Object?> all) => all[key] = value);

  @override
  Future<Result<void, SettingsFailure>> remove(String key) =>
      _mutate((Map<String, Object?> all) => all.remove(key));

  /// Applies [change] to the stored object and writes it back.
  Future<Result<void, SettingsFailure>> _mutate(
    void Function(Map<String, Object?>) change,
  ) async {
    final Result<Map<String, Object?>, SettingsFailure> stored = await _load();
    if (stored case Failure<Map<String, Object?>, SettingsFailure>(
      failure: final SettingsFailure failure,
    )) {
      return Failure<void, SettingsFailure>(failure);
    }
    final Map<String, Object?> all =
        (stored as Success<Map<String, Object?>, SettingsFailure>).value;
    change(all);
    return filesystem
        .writeFile(path, const JsonEncoder.withIndent('  ').convert(all))
        .mapFailure(_asSettingsFailure);
  }

  /// The stored object, or an empty one.
  ///
  /// A file that is not there yet is the first run, not a failure. A file
  /// that is there and is not a JSON object is treated the same way: the
  /// alternative is refusing to start over a preferences file someone
  /// hand-edited, and nothing in it is worth that.
  Future<Result<Map<String, Object?>, SettingsFailure>> _load() async {
    final Result<String, FilesystemFailure> text = await filesystem.readFile(
      path,
    );
    switch (text) {
      case Failure<String, FilesystemFailure>(
        failure: FilesystemEntryNotFound(),
      ):
        // Deliberately not const: a const map is unmodifiable, and what
        // comes back from here is about to be written into. The analyzer
        // asks for const and is wrong — this is the first-run path, so the
        // failure would only ever appear on a machine with no preferences
        // file, which is every machine exactly once.
        // ignore: prefer_const_constructors
        return Success<Map<String, Object?>, SettingsFailure>(
          <String, Object?>{},
        );
      case Failure<String, FilesystemFailure>(
        failure: final FilesystemFailure failure,
      ):
        return Failure<Map<String, Object?>, SettingsFailure>(
          _asSettingsFailure(failure),
        );
      case Success<String, FilesystemFailure>(value: final String content):
        return Success<Map<String, Object?>, SettingsFailure>(_decode(content));
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
  /// is the same, and [SettingsFailure] says why it has only one. Exhaustive
  /// rather than an `is` test — one capability fulfilled over another is
  /// still a boundary between two vocabularies, and it gets the same switch
  /// every other boundary gets.
  ///
  /// The filesystem's failure travels as the cause, so flattening loses the
  /// distinction and not the diagnosis.
  static SettingsFailure _asSettingsFailure(FilesystemFailure failure) =>
      switch (failure) {
        FilesystemEntryNotFound() ||
        FilesystemAccessDenied() ||
        FilesystemNotUtf8() ||
        FilesystemOperationFailed() => SettingsUnavailable(
          failure.toString(),
          cause: failure,
        ),
      };
}
