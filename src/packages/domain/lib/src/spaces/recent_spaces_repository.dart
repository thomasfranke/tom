/// The spaces Home offers to go back to.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/src/spaces/recent_space_entity.dart';
import 'package:tom_domain/src/spaces/space_entity.dart';

/// What the user opened before, so returning is one click
/// (`docs/product/home/recent-spaces/doc.md`).
///
/// **Everything here is a convenience**, so no caller stops on it: [Never]
/// as the failure type is that promise checked, since a `Failure<T, Never>`
/// cannot be constructed.
abstract interface class RecentSpacesRepository {
  /// The remembered spaces, most recently opened first.
  ///
  /// The folders are not checked: a row whose folder is gone is still shown,
  /// because Home offers to forget it rather than hiding it.
  Future<Result<List<RecentSpaceEntity>, Never>> list();

  /// Records that [space] was just opened, moving it to the front.
  ///
  /// A space is identified by its folder, so one already remembered is
  /// updated rather than added again.
  Future<Result<void, Never>> remember(SpaceEntity space);

  /// Drops the entry for [root], if there is one; forgetting one that was
  /// never remembered succeeds.
  Future<Result<void, Never>> forget(String root);
}
