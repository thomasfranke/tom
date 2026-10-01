/// Reading what a space holds, for the file tree to draw.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// Everything a [SpaceEntity] holds, in the order a tree shows it.
///
/// The whole space in one call, affordable because `.git/` is never descended
/// into; the listing ages until the watcher arrives ([Decision
/// 10](../../../../../../docs/technical/decisions/010-watcher-and-git-cooperate-by-protocol.md)).
final class ListSpaceEntriesUseCase with UseCase {
  /// Creates the use case.
  const ListSpaceEntriesUseCase({
    required this.spaces,
    required this.observability,
  });

  /// Where the folder is read.
  final SpaceRepository spaces;

  @override
  final Observability observability;

  /// What [space] holds.
  Future<Result<List<SpaceEntryValueObject>, AppFailure>> list(
    SpaceEntity space,
  ) => guard(() => spaces.entries(space));
}
