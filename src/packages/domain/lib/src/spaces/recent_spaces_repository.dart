/// The spaces Home offers to go back to.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/src/spaces/recent_space_entity.dart';
import 'package:tom_domain/src/spaces/space_entity.dart';

/// What the user opened before, so returning is one click
/// (`docs/product/home/doc.md`).
///
/// Separate from `SpaceRepository` because it answers a different question.
/// That one asks the disk and git what a folder *is*; this one remembers
/// what the user did, and is the only thing in the product that survives
/// between runs by design.
///
/// **Everything here is a convenience.** A list that cannot be read is an
/// empty list, and a space that cannot be remembered is a space that opened
/// anyway. Nothing the user can lose here is anything they cannot get back
/// by picking the folder again — which is why no caller is expected to treat
/// a failure from it as a reason to stop.
///
/// **[Never] is the failure type, and it is the contract.** Not prose that an
/// implementation may forget: a `Failure<T, Never>` cannot be constructed,
/// because no value of type [Never] exists. The promise above is checked.
abstract interface class RecentSpacesRepository {
  /// The remembered spaces, most recently opened first.
  ///
  /// The folders are not checked: a row whose folder is gone is still shown,
  /// because Home's answer to that is to offer to forget it rather than to
  /// hide it (`docs/product/home/doc.md`). Checking would also mean touching
  /// the disk once per row of a list the user may not click.
  Future<Result<List<RecentSpaceEntity>, Never>> list();

  /// Records that [space] was just opened, moving it to the front.
  ///
  /// Opening a space that is already remembered updates it rather than
  /// adding a second row: a space is identified by its folder.
  Future<Result<void, Never>> remember(SpaceEntity space);

  /// Drops the entry for [root], if there is one.
  ///
  /// What Home offers for a space whose folder went away. Forgetting one
  /// that was never remembered succeeds — the caller wanted it gone, and it
  /// is.
  Future<Result<void, Never>> forget(String root);
}
