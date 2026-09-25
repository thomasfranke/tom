/// One row of the recent list, as it is stored.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'recent_space_dto.freezed.dart';

/// A remembered space in the shape the settings store holds it.
///
/// A real DTO by [Decision
/// 21](../../../../../../docs/technical/decisions/021-dtos-and-daos-when-they-are-real.md)'s
/// test: JSON has no `DateTime`, so `lastOpened` is text here.
@freezed
abstract class RecentSpaceDto with _$RecentSpaceDto {
  /// Creates a row.
  const factory RecentSpaceDto({
    /// The absolute path of the space's folder.
    required String root,

    /// What the folder is called.
    required String name,

    /// When it was last opened, ISO 8601 in UTC.
    required String lastOpened,
  }) = _RecentSpaceDto;

  const RecentSpaceDto._();

  /// [row] as a DTO, or null when it is not one.
  ///
  /// Total, so one malformed row does not cost the user the other nine.
  static RecentSpaceDto? fromRow(Object? row) {
    if (row is! Map<String, Object?>) {
      return null;
    }
    final Object? root = row['root'];
    final Object? name = row['name'];
    final Object? lastOpened = row['lastOpened'];
    if (root is! String || name is! String || lastOpened is! String) {
      return null;
    }
    return RecentSpaceDto(root: root, name: name, lastOpened: lastOpened);
  }

  /// This row as the map that is encoded.
  Map<String, Object?> toRow() => <String, Object?>{
    'root': root,
    'name': name,
    'lastOpened': lastOpened,
  };
}
