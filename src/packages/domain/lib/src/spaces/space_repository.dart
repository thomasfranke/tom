/// What the application may ask about a space's folder.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/src/paths/space_relative_path_value_object.dart';
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
  /// (`docs/product/home/opening-a-space/doc.md`).
  ///
  /// A folder nothing encloses opens with no `repositoryRoot`, never as a
  /// failure (`docs/product/workspace/without-a-repository/doc.md`).
  /// `SpaceFolderMissing` when nothing is at [folder], which Home offers to
  /// forget. [AppFailure] because opening asks the disk *and* git, and Home
  /// switches over both vocabularies.
  Future<Result<SpaceEntity, AppFailure>> open(String folder);

  /// Everything [space] holds, depth first and **folders before files at
  /// every level**, so a tree is one walk
  /// (`docs/product/navigation/file-tree/order-and-shape/doc.md`).
  ///
  /// **`.git/` is not in it and is never descended into**, this layer's
  /// policy (`docs/product/navigation/file-tree/what-is-shown/doc.md`) and
  /// what keeps the listing affordable. A folder the machine will not open
  /// costs that folder, not the tree; only the space root failing fails the
  /// call, and every kind of file is reported since
  /// `SpaceEntryValueObject.isDocument` answers what the editor opens.
  Future<Result<List<SpaceEntryValueObject>, SpaceFailure>> entries(
    SpaceEntity space,
  );

  /// Makes an empty folder at [path] inside [space]
  /// (`docs/product/navigation/file-tree/explorer-menu/doc.md`).
  ///
  /// `SpaceEntryExists` when anything already has that name: a folder is
  /// never reused, and a file is never shadowed.
  Future<Result<void, SpaceFailure>> createFolder(
    SpaceEntity space,
    SpaceRelativePathValueObject path,
  );
}
