/// Opening a folder and finding its repository as two separate questions.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/src/spaces/space_entity.dart';

/// What `SpaceRepository.open` does in one go, split in two so the first half
/// asks nothing of git.
///
/// Where git asks the person first (`docs/product/git-workflow/approvals/doc.md`),
/// a folder on this machine must show its files at once: the disk is read
/// now, and the repository is looked for in the background.
abstract interface class SpaceLocationRepository {
  /// [folder] as a space whose repository is not known yet: the disk only —
  /// it is there, and where it really is — so `repositoryRoot` is null.
  ///
  /// `SpaceFolderMissing` when nothing is at [folder].
  Future<Result<SpaceEntity, AppFailure>> openFolder(String folder);

  /// [space] with the repository that encloses it, git asked.
  ///
  /// A folder nothing encloses comes back as it is, never as a failure; an
  /// older git than the product supports is `GitTooOld`, and a command the
  /// person denied is `GitCommandDenied`.
  Future<Result<SpaceEntity, AppFailure>> locate(SpaceEntity space);
}
