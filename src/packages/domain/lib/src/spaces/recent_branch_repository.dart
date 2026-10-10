/// The branch each space Home offers was left on.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/src/git/branch_name_value_object.dart';
import 'package:tom_domain/src/spaces/recent_space_entity.dart';

/// Reads a recent space's branch, so its row can say it
/// (`docs/product/home/recent-spaces/doc.md`).
///
/// Apart from `RecentSpacesRepository`, which never asks git, and from
/// `GitRepository`, which belongs to an open space. [Never] for the list's
/// reason: a row without its branch is still a row.
abstract interface class RecentBranchRepository {
  /// The branch [recent]'s folder is on, or null when `HEAD` is detached or
  /// the folder is gone or no longer inside a repository.
  Future<Result<BranchNameValueObject?, Never>> branchOf(
    RecentSpaceEntity recent,
  );
}
