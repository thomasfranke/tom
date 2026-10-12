/// Turning a folder the user picked into a space.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// A folder opened as a space (`docs/product/home/opening-a-space/doc.md`).
///
/// A folder outside any repository opens with no repository, and one that
/// is gone answers `SpaceFolderMissing`; TOM never creates a repository on
/// the user's behalf.
final class OpenSpaceUseCase with UseCase {
  /// Creates the use case.
  const OpenSpaceUseCase({
    required this.spaces,
    required this.recents,
    required this.observability,
    this.locator,
  });

  /// Where spaces come from.
  final SpaceRepository spaces;

  /// Where a folder is opened without git and its repository found apart,
  /// for [openFolder] and [locate]; null where nothing defers git.
  final SpaceLocationRepository? locator;

  /// Where the list Home offers to go back to is kept.
  final RecentSpacesRepository recents;

  @override
  final Observability observability;

  /// [folder] opened, and remembered if it opened.
  ///
  /// Remembering is part of opening so no screen can forget it, and it never
  /// fails the open: a preferences file that cannot be written is not a
  /// reason to refuse a session.
  ///
  /// [openFolder] and [locate] are the same opening in two halves.
  Future<Result<SpaceEntity, AppFailure>> openFolder(String folder) =>
      guard(() async {
        final SpaceLocationRepository? where = locator;
        if (where == null) {
          return spaces.open(folder);
        }
        final Result<SpaceEntity, AppFailure> opened = await where.openFolder(
          folder,
        );
        if (opened case Success<SpaceEntity, AppFailure>(
          value: final SpaceEntity space,
        )) {
          await recents.remember(space);
        }
        return opened;
      });

  /// [space] with its repository found — the half of opening that asks git.
  Future<Result<SpaceEntity, AppFailure>> locate(SpaceEntity space) =>
      guard(() async {
        final SpaceLocationRepository? where = locator;
        if (where == null) {
          return Success<SpaceEntity, AppFailure>(space);
        }
        return where.locate(space);
      });

  /// [folder] opened whole, git asked first.
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
