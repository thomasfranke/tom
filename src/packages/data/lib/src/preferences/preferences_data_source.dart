/// The preferences, kept as JSON in the settings store.
library;

import 'dart:convert';

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/src/preferences/preferences_dto.dart';
import 'package:tom_infra/tom_infra.dart';

/// Where the preferences are kept, and in what shape.
///
/// The key, the JSON and the decoding, since [Settings] holds strings
/// ([Decision
/// 25](../../../../../../docs/technical/decisions/025-a-repository-reads-through-a-data-source.md)).
final class PreferencesDataSource {
  /// Creates a source over [settings].
  const PreferencesDataSource({required this.settings});

  /// Where the object is kept between runs.
  final Settings settings;

  /// The key it is stored under, namespaced because the store is shared.
  static const String key = 'app.preferences';

  /// What is stored, with anything unreadable left for the defaults.
  Future<Result<PreferencesDto, SettingsFailure>> read() =>
      settings.read(key).map(_decode);

  /// Replaces what is stored with [row].
  Future<Result<void, SettingsFailure>> write(PreferencesDto row) =>
      settings.write(key, jsonEncode(row.toRow()));

  /// [text] as a row, or an empty one.
  ///
  /// A store holding anything but an object answers empty: **editing the
  /// file by hand is supported, not protected**, and a value the app cannot
  /// use falls back rather than refusing to open.
  static PreferencesDto _decode(String? text) {
    if (text == null || text.isEmpty) {
      return const PreferencesDto(
        theme: null,
        language: null,
        showingFormattingBar: null,
      );
    }
    final Object? decoded = _tryDecode(text);
    return decoded is Map<String, Object?>
        ? PreferencesDto.fromRow(decoded)
        : const PreferencesDto(
            theme: null,
            language: null,
            showingFormattingBar: null,
          );
  }

  /// [text] as JSON, or null when it is not.
  static Object? _tryDecode(String text) {
    try {
      return jsonDecode(text);
    } on FormatException {
      return null;
    }
  }
}
