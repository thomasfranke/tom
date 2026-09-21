/// The recent list, kept as JSON in the settings store.
library;

import 'dart:convert';

import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

/// [RecentSpacesRepository] over the [Settings] capability.
///
/// The store holds strings, so the shape of what is stored is decided here —
/// the same split as git's output, where the capability knows the format and
/// this layer knows the meaning.
///
/// **A failure never propagates as one.** Every method answers success even
/// when the store could not be read, because the contract says everything
/// here is a convenience and no caller should be made to handle it
/// ([RecentSpacesRepository]). What a broken store costs is the list, not
/// the session.
final class RecentSpacesRepositoryImpl implements RecentSpacesRepository {
  /// Creates a repository over [settings].
  const RecentSpacesRepositoryImpl({required this.settings});

  /// Where the list is kept between runs.
  final Settings settings;

  /// The key the list is stored under.
  ///
  /// Namespaced, because the store is shared with every other preference and
  /// will outlive this class.
  static const String _key = 'spaces.recent';

  /// How many entries are kept.
  ///
  /// Not a product rule — `docs/product/home/doc.md` says only that recent
  /// spaces are offered — so this is a default, chosen to be more than a
  /// screen shows and far less than a list anyone would scroll. It is
  /// enforced on write, so a file that somehow holds more is trimmed the
  /// next time a space is opened rather than being rejected.
  static const int _limit = 10;

  @override
  Future<Result<List<RecentSpace>>> list() async {
    final Result<String?> stored = await settings.read(_key);
    return switch (stored) {
      Success<String?>(value: final String? text) => Success<List<RecentSpace>>(
        _decode(text),
      ),
      // Deliberately not a failure: a list nobody can read is an empty list,
      // and Home still offers to open a folder.
      Failure<String?>() => const Success<List<RecentSpace>>(<RecentSpace>[]),
    };
  }

  @override
  Future<Result<void>> remember(Space space) async {
    final List<RecentSpace> kept = await _current();
    final List<RecentSpace> updated = <RecentSpace>[
      RecentSpace(
        root: space.root,
        name: space.name,
        lastOpened: DateTime.now().toUtc(),
      ),
      // A space is identified by its folder, so opening one that is already
      // remembered moves it to the front rather than adding a second row.
      ...kept.where((RecentSpace recent) => recent.root != space.root),
    ];
    return _store(updated.take(_limit).toList());
  }

  @override
  Future<Result<void>> forget(String root) async {
    final List<RecentSpace> kept = await _current();
    return _store(
      kept.where((RecentSpace recent) => recent.root != root).toList(),
    );
  }

  /// What is stored now, or nothing if it cannot be read.
  Future<List<RecentSpace>> _current() async {
    final Result<List<RecentSpace>> listed = await list();
    return switch (listed) {
      Success<List<RecentSpace>>(value: final List<RecentSpace> recents) =>
        recents,
      Failure<List<RecentSpace>>() => <RecentSpace>[],
    };
  }

  /// Writes [recents], reporting success whatever the store did.
  Future<Result<void>> _store(List<RecentSpace> recents) async {
    await settings.write(
      _key,
      jsonEncode(<Map<String, Object?>>[
        for (final RecentSpace recent in recents)
          <String, Object?>{
            'root': recent.root,
            'name': recent.name,
            'lastOpened': recent.lastOpened.toIso8601String(),
          },
      ]),
    );
    return const Success<void>(null);
  }

  /// [text] as entries, newest first, skipping anything unreadable.
  ///
  /// Total, like every other parser in this package: one malformed row must
  /// not cost the user the other nine. A row missing a field, carrying a
  /// date nobody can parse, or of the wrong shape entirely is a row to drop.
  static List<RecentSpace> _decode(String? text) {
    if (text == null || text.isEmpty) {
      return <RecentSpace>[];
    }
    final Object? decoded = _tryDecode(text);
    if (decoded is! List<Object?>) {
      return <RecentSpace>[];
    }
    final List<RecentSpace> recents =
        <RecentSpace>[
          for (final Object? row in decoded)
            if (_rowToRecent(row) case final RecentSpace recent) recent,
        ]..sort(
          (RecentSpace a, RecentSpace b) =>
              b.lastOpened.compareTo(a.lastOpened),
        );
    return recents;
  }

  /// One row as an entry, or null when it is not one.
  static RecentSpace? _rowToRecent(Object? row) {
    if (row is! Map<String, Object?>) {
      return null;
    }
    final Object? root = row['root'];
    final Object? name = row['name'];
    final DateTime? lastOpened = DateTime.tryParse(
      row['lastOpened'] as String? ?? '',
    );
    if (root is! String || name is! String || lastOpened == null) {
      return null;
    }
    return RecentSpace(root: root, name: name, lastOpened: lastOpened.toUtc());
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
