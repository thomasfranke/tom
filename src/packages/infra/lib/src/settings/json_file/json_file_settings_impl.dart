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
  Future<Result<Object?, SettingsFailure>> read(String key) async =>
      (await _load()).map((Map<String, Object?>? all) => all?[key]);

  @override
  Future<Result<void, SettingsFailure>> write(String key, Object? value) =>
      _mutate((Map<String, Object?> all) => all[key] = value);

  @override
  Future<Result<void, SettingsFailure>> remove(String key) =>
      _mutate((Map<String, Object?> all) => all.remove(key));

  /// Applies [change] to the stored object and writes it back.
  ///
  /// **A file that is not a JSON object is never written over**: it can be
  /// opened and saved by hand, so what is in it is somebody's typing, and
  /// the next write of an unrelated key must not delete it. The write fails
  /// instead, which costs a choice between runs and never the text.
  Future<Result<void, SettingsFailure>> _mutate(
    void Function(Map<String, Object?>) change,
  ) async {
    final Result<Map<String, Object?>?, SettingsFailure> stored = await _load();
    final Map<String, Object?>? all;
    switch (stored) {
      case Failure<Map<String, Object?>?, SettingsFailure>(
        failure: final SettingsFailure failure,
      ):
        return Failure<void, SettingsFailure>(failure);
      case Success<Map<String, Object?>?, SettingsFailure>(
        value: final Map<String, Object?>? value,
      ):
        all = value;
    }
    if (all == null) {
      return Failure<void, SettingsFailure>(
        SettingsUnavailable('$path is not a JSON object; it is left as it is'),
      );
    }
    change(all);
    final String text;
    try {
      text = const JsonEncoder.withIndent('  ').convert(all);
    } on JsonUnsupportedObjectError catch (error) {
      return Failure<void, SettingsFailure>(
        SettingsUnavailable('not a JSON value: ${error.unsupportedObject}'),
      );
    }
    return filesystem.writeFile(path, text).mapFailure(_asSettingsFailure);
  }

  /// The stored object — empty on a first run — or null when the file holds
  /// something that is not a JSON object.
  Future<Result<Map<String, Object?>?, SettingsFailure>> _load() async {
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
        return Success<Map<String, Object?>?, SettingsFailure>(
          <String, Object?>{},
        );
      case Failure<String, FilesystemFailure>(
        failure: final FilesystemFailure failure,
      ):
        return Failure<Map<String, Object?>?, SettingsFailure>(
          _asSettingsFailure(failure),
        );
      case Success<String, FilesystemFailure>(value: final String content):
        return Success<Map<String, Object?>?, SettingsFailure>(
          _decode(content),
        );
    }
  }

  /// [content] as a JSON object, an empty one for an empty file, or null.
  static Map<String, Object?>? _decode(String content) {
    if (content.trim().isEmpty) {
      return <String, Object?>{};
    }
    final Object? decoded = _tryDecode(content);
    if (decoded is! Map<String, Object?>) {
      return null;
    }
    return <String, Object?>{
      for (final MapEntry<String, Object?> entry in decoded.entries)
        entry.key: _upgraded(entry.value),
    };
  }

  /// [value], or what it holds when it is a string holding a JSON object or
  /// list — the shape this store wrote before values were JSON, read as what
  /// it holds so the next write puts the whole file in today's shape.
  static Object? _upgraded(Object? value) {
    if (value is String) {
      final Object? held = _tryDecode(value);
      if (held is Map || held is List) {
        return held;
      }
    }
    return value;
  }

  /// [text] as JSON, or null when it is not.
  static Object? _tryDecode(String text) {
    try {
      return jsonDecode(text);
    } on FormatException {
      return null;
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
        FilesystemAlreadyExists() ||
        FilesystemNotUtf8() ||
        FilesystemOperationFailed() => SettingsUnavailable(
          failure.toString(),
          cause: failure,
        ),
      };
}
