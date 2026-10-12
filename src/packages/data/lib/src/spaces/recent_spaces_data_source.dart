/// The recent list, kept as one list in the settings store.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/src/spaces/recent_space_dto.dart';
import 'package:tom_infra/tom_infra.dart';

/// Where the recent list is kept, and in what shape.
///
/// The key and the rows, since [Settings] keeps JSON values ([Decision
/// 25](../../../../../../docs/technical/decisions/025-a-repository-reads-through-a-data-source.md));
/// failures travel as reported, since surviving them is the repository's.
final class RecentSpacesDataSource {
  /// Creates a source over [settings].
  const RecentSpacesDataSource({required this.settings});

  /// Where the list is kept between runs.
  final Settings settings;

  /// The key the list is stored under, namespaced because the store is
  /// shared.
  static const String _key = 'spaces.recent';

  /// The stored rows, in the order they were written.
  ///
  /// A store holding anything but a list of rows answers empty, since
  /// refusing to start over a preference file would be worse.
  Future<Result<List<RecentSpaceDto>, SettingsFailure>> read() =>
      settings.read(_key).map(_decode);

  /// Replaces what is stored with [rows].
  Future<Result<void, SettingsFailure>> write(List<RecentSpaceDto> rows) =>
      settings.write(_key, <Map<String, Object?>>[
        for (final RecentSpaceDto row in rows) row.toRow(),
      ]);

  /// [stored] as rows, skipping anything unreadable.
  static List<RecentSpaceDto> _decode(Object? stored) => <RecentSpaceDto>[
    if (stored is List<Object?>)
      for (final Object? row in stored)
        if (RecentSpaceDto.fromRow(row) case final RecentSpaceDto dto) dto,
  ];
}
