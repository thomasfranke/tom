/// What the application may ask about a space's folder.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/src/spaces/space_entity.dart';
import 'package:tom_domain/src/spaces/space_entry_value_object.dart';
import 'package:tom_domain/src/spaces/space_failure.dart';

/// The folders spaces are made of, as the product talks about them.
///
/// One instance for the app: a `SpaceEntity` is data and travels as an
/// argument, which is also why [open] is here rather than on a factory
/// ([Decision
/// 15](../../../../../../docs/technical/decisions/015-ddd-is-applied-selectively.md)).
abstract interface class SpaceRepository {
  /// Opens [folder] as a space, finding the repository that encloses it
  /// (`docs/product/home/doc.md`).
  ///
  /// `SpaceFolderMissing` when nothing is at [folder], which Home offers to
  /// forget; `GitNotARepository` when nothing encloses it, which is explained
  /// and never worked around, since **TOM does not create a repository on
  /// the user's behalf**. [AppFailure] because opening asks the disk *and*
  /// git, and Home switches over both vocabularies.
  Future<Result<SpaceEntity, AppFailure>> open(String folder);

  /// Everything [space] holds, depth first and sorted, so a folder is
  /// immediately followed by what is inside it and a tree is one walk.
  ///
  /// **`.git/` is not in it and is never descended into**, this layer's
  /// policy (`docs/product/navigation/file-tree/doc.md`) and what keeps the
  /// listing affordable; every other dotfolder is included. A folder the
  /// machine will not open costs that folder, not the tree; only the space
  /// root failing fails the call. Files of every kind are reported, since
  /// `SpaceEntryValueObject.isDocument` answers what the editor opens.
  Future<Result<List<SpaceEntryValueObject>, SpaceFailure>> entries(
    SpaceEntity space,
  );
}
