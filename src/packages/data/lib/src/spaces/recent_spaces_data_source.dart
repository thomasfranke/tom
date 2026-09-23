/// The recent list, kept as JSON in the settings store.
library;

import 'dart:convert';

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/src/spaces/recent_space_dto.dart';
import 'package:tom_infra/tom_infra.dart';

/// Where the recent list is kept, and in what shape.
///
/// [Settings] holds strings and says so — giving structure to the text is
/// this layer's job. So the key, the JSON and the decoding live here, and
/// what the repository above sees is rows ([Decision
/// 25](../../../../../../docs/technical/decisions/025-a-repository-reads-through-a-data-source.md)).
///
/// Failures travel as the store reported them. That the product survives a
/// store it cannot read is a promise `RecentSpacesRepository` makes, and it
/// is kept one layer up — a source that swallowed its own failures would
/// leave the repository unable to keep a promise it did not make.
final class RecentSpacesDataSource {
  /// Creates a source over [settings].
  const RecentSpacesDataSource({required this.settings});

  /// Where the list is kept between runs.
  final Settings settings;

  /// The key the list is stored under.
  ///
  /// Namespaced, because the store is shared with every other preference
  /// and will outlive this class.
  static const String _key = 'spaces.recent';

  /// The stored rows, in the order they were written.
  ///
  /// A store holding something that is not a list of rows answers empty:
  /// there is no version to migrate from, and refusing to start over a
  /// preference file would be worse than forgetting it.
  Future<Result<List<RecentSpaceDto>, SettingsFailure>> read() =>
      settings.read(_key).map(_decode);

  /// Replaces what is stored with [rows].
  Future<Result<void, SettingsFailure>> write(List<RecentSpaceDto> rows) =>
      settings.write(
        _key,
        jsonEncode(<Map<String, Object?>>[
          for (final RecentSpaceDto row in rows) row.toRow(),
        ]),
      );

  /// [text] as rows, skipping anything unreadable.
  static List<RecentSpaceDto> _decode(String? text) {
    if (text == null || text.isEmpty) {
      return <RecentSpaceDto>[];
    }
    final Object? decoded = _tryDecode(text);
    if (decoded is! List<Object?>) {
      return <RecentSpaceDto>[];
    }
    return <RecentSpaceDto>[
      for (final Object? row in decoded)
        if (RecentSpaceDto.fromRow(row) case final RecentSpaceDto dto) dto,
    ];
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
