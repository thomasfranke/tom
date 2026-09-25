/// [Settings] as one JSON file in the user's application-support folder.
library;

import 'dart:convert';

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

/// Preferences kept as a JSON object in a single file.
///
/// **Not `shared_preferences`**, a Flutter plugin in a pure-Dart package
/// ([Decision
/// 14](../../../../../../../docs/technical/decisions/014-each-layer-is-its-own-package.md));
/// JSON in application support is the dependency table's own alternative
/// (`docs/technical/stack/platform.md`). Writing goes through [Filesystem],
/// whose rename makes the save atomic; the whole file is read and rewritten
/// on every access, so no cache goes stale.
final class JsonFileSettingsImpl implements Settings {
  /// Creates a store backed by the file at [path].
  const JsonFileSettingsImpl({required this.filesystem, required this.path});

  /// What reads and writes the file.
  final Filesystem filesystem;

  /// The absolute path of the JSON file.
  ///
  /// Given rather than derived, so a test points it at a temporary folder and
  /// only the composition root knows where a real user's preferences live.
  final String path;

  @override
  Future<Result<String?, SettingsFailure>> read(String key) async =>
      (await _load()).map((Map<String, Object?> all) {
        // Anything but a string was not written by this store and counts as
        // nothing stored; a cast would throw out of a contract that promises
        // not to.
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
  /// A file not there yet is the first run, and a file that is not a JSON
  /// object is treated the same way rather than refusing to start over a
  /// hand-edited preferences file.
  Future<Result<Map<String, Object?>, SettingsFailure>> _load() async {
    final Result<String, FilesystemFailure> text = await filesystem.readFile(
      path,
    );
    switch (text) {
      case Failure<String, FilesystemFailure>(
        failure: FilesystemEntryNotFound(),
      ):
        // Not const: a const map is unmodifiable, and this one is about to be
        // written into.
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
  /// Flattened to one variant, since the caller's answer to any is the same
  /// ([SettingsFailure]); exhaustive rather than an `is` test, because two
  /// capabilities are still two vocabularies. The cause keeps the diagnosis.
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
