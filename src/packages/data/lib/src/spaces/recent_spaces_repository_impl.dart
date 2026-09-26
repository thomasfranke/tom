/// The recent list, as the product's rules shape it.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/src/spaces/recent_space_dto.dart';
import 'package:tom_data/src/spaces/recent_spaces_data_source.dart';
import 'package:tom_domain/tom_domain.dart';
// For the failure vocabulary only (Decision 25).
import 'package:tom_infra/tom_infra.dart';

/// [RecentSpacesRepository] over [RecentSpacesDataSource].
///
/// The product's rules and nothing about storage: newest first, one row per
/// folder, a bounded list. How a row is spelled and where it is kept is the
/// source's ([Decision
/// 25](../../../../../../docs/technical/decisions/025-a-repository-reads-through-a-data-source.md)).
///
/// **A failure never reaches the caller, and is never dropped either.**
/// `Result<T, Never>` is the contract's promise that nothing here is worth
/// interrupting a session for; the failure goes to [Observability] instead,
/// so a preferences folder nobody can write is findable rather than silent.
final class RecentSpacesRepositoryImpl implements RecentSpacesRepository {
  /// Creates a repository over [recents].
  const RecentSpacesRepositoryImpl({
    required this.recents,
    required this.observability,
  });

  /// Where the list is read and written.
  final RecentSpacesDataSource recents;

  /// Where a failure nobody handles is recorded.
  final Observability observability;

  /// How many entries are kept, enforced on write.
  ///
  /// A default, not a product rule: `docs/product/home/recent-spaces/doc.md`
  /// says only that
  /// recent spaces are offered.
  static const int _limit = 10;

  @override
  Future<Result<List<RecentSpaceEntity>, Never>> list() async =>
      Success<List<RecentSpaceEntity>, Never>(await _current());

  @override
  Future<Result<void, Never>> remember(SpaceEntity space) async {
    final List<RecentSpaceEntity> kept = await _current();
    final List<RecentSpaceEntity> updated = <RecentSpaceEntity>[
      RecentSpaceEntity(
        root: space.root,
        name: space.name,
        lastOpened: DateTime.now().toUtc(),
      ),
      // A space already remembered moves to the front rather than repeating.
      ...kept.where((RecentSpaceEntity recent) => recent.root != space.root),
    ];
    return _store(updated.take(_limit).toList());
  }

  @override
  Future<Result<void, Never>> forget(String root) async {
    final List<RecentSpaceEntity> kept = await _current();
    return _store(
      kept.where((RecentSpaceEntity recent) => recent.root != root).toList(),
    );
  }

  /// What is stored now, newest first, or nothing if it cannot be read, with
  /// the reason recorded.
  Future<List<RecentSpaceEntity>> _current() async {
    final Result<List<RecentSpaceDto>, SettingsFailure> stored = await recents
        .read();
    if (stored case Failure<List<RecentSpaceDto>, SettingsFailure>(
      failure: final SettingsFailure failure,
    )) {
      await _record(failure);
      return <RecentSpaceEntity>[];
    }
    return <RecentSpaceEntity>[
      for (final RecentSpaceDto row
          in (stored as Success<List<RecentSpaceDto>, SettingsFailure>).value)
        if (_asEntity(row) case final RecentSpaceEntity recent) recent,
    ]..sort(
      (RecentSpaceEntity a, RecentSpaceEntity b) =>
          b.lastOpened.compareTo(a.lastOpened),
    );
  }

  /// [failure] handed to [Observability], where it ends.
  ///
  /// `StackTrace.current` because nothing threw; the trace names the call
  /// site that gave up on the store.
  Future<void> _record(SettingsFailure failure) =>
      observability.capture(failure, StackTrace.current, layer: 'data');

  /// [row] in the domain's vocabulary, or null when its date is not one.
  ///
  /// Dropped rather than defaulted, because a made-up date would reorder the
  /// user's list.
  static RecentSpaceEntity? _asEntity(RecentSpaceDto row) {
    final DateTime? lastOpened = DateTime.tryParse(row.lastOpened);
    return lastOpened == null
        ? null
        : RecentSpaceEntity(
            root: row.root,
            name: row.name,
            lastOpened: lastOpened.toUtc(),
          );
  }

  /// [entities] written, reporting success whatever the store did and
  /// recording what it did.
  Future<Result<void, Never>> _store(List<RecentSpaceEntity> entities) async {
    final Result<void, SettingsFailure> written = await recents
        .write(<RecentSpaceDto>[
          for (final RecentSpaceEntity recent in entities)
            RecentSpaceDto(
              root: recent.root,
              name: recent.name,
              lastOpened: recent.lastOpened.toIso8601String(),
            ),
        ]);
    if (written case Failure<void, SettingsFailure>(
      failure: final SettingsFailure failure,
    )) {
      await _record(failure);
    }
    return const Success<void, Never>(null);
  }
}
