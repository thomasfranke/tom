/// Turning a folder the user picked into a space.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// A folder opened as a space (`docs/product/home/doc.md`).
///
/// A folder outside any repository answers `GitNotARepository` and a folder
/// that is gone `SpaceFolderMissing`, because Home sends each somewhere
/// different; TOM never creates a repository on the user's behalf.
final class OpenSpaceUseCase with UseCase {
  /// Creates the use case.
  const OpenSpaceUseCase({
    required this.spaces,
    required this.recents,
    required this.observability,
  });

  /// Where spaces come from.
  final SpaceRepository spaces;

  /// Where the list Home offers to go back to is kept.
  final RecentSpacesRepository recents;

  @override
  final Observability observability;

  /// [folder] opened, and remembered if it opened.
  ///
  /// Remembering is part of opening so no screen can forget it, and it never
  /// fails the open: a preferences file that cannot be written is not a
  /// reason to refuse a session.
  Future<Result<SpaceEntity, AppFailure>> open(String folder) => guard(
    () async {
      final Result<SpaceEntity, AppFailure> opened = await spaces.open(folder);
      if (opened case Success<SpaceEntity, AppFailure>(
        value: final SpaceEntity space,
      )) {
        await recents.remember(space);
      }
      return opened;
    },
  );
}
