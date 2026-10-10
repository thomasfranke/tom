/// Which branch the one checked out came from.
library;

import 'package:tom_domain/src/git/branch_name_value_object.dart';
import 'package:tom_domain/src/git/branch_ref_value_object.dart';
import 'package:tom_domain/src/git/branch_standing_value_object.dart';

/// The base the rendered diff is read against, and the one a pull request
/// starts from (`docs/product/diff/branch-diff/doc.md`).
///
/// A domain service with no port: git answers the questions — where each
/// branch stands, what was recorded — and the rule is here, so it is the
/// same rule whichever git answered.
final class BranchBaseService {
  /// Creates the service.
  const BranchBaseService();

  /// The base of [current], or null for "compare against `HEAD`".
  ///
  /// Null when detached, and on the remote's [defaultBranch] itself: there
  /// the base is the branch, so only the uncommitted work is a change.
  /// Otherwise what TOM [recorded] when it started the branch, while that
  /// still exists; otherwise deduced from [standings] — the branch `HEAD`
  /// has come the least way from, ties going to the default branch and then
  /// to a local branch over a remote's copy. Never the branch itself, its
  /// [upstream] or its copy on any remote, nor a branch that already holds
  /// all of `HEAD` and more: that one came *from* here.
  BranchRefValueObject? choose({
    required BranchNameValueObject? current,
    required List<BranchStandingValueObject> standings,
    BranchNameValueObject? upstream,
    BranchNameValueObject? defaultBranch,
    BranchNameValueObject? recorded,
  }) {
    if (current == null || current == defaultBranch) {
      return null;
    }
    final List<BranchRefValueObject> known = <BranchRefValueObject>[
      for (final BranchStandingValueObject it in standings) it.branch,
    ];
    if (recorded != null && recorded != current) {
      final BranchRefValueObject? kept = _localFirst(
        known.where((BranchRefValueObject it) => it.name == recorded),
      );
      if (kept != null) {
        return kept;
      }
    }
    final List<BranchStandingValueObject> candidates =
        standings
            .where(
              (BranchStandingValueObject it) =>
                  it.sharesHistory &&
                  it.branch.name != current &&
                  it.branch.spec != upstream?.value &&
                  !(it.behind == 0 && it.ahead > 0),
            )
            .toList()
          ..sort(
            (BranchStandingValueObject a, BranchStandingValueObject b) =>
                _compare(a, b, defaultBranch),
          );
    return candidates.isEmpty ? null : candidates.first.branch;
  }

  /// A local branch out of [named], or the first remote's copy.
  static BranchRefValueObject? _localFirst(
    Iterable<BranchRefValueObject> named,
  ) =>
      named.where((BranchRefValueObject it) => !it.isRemote).firstOrNull ??
      named.firstOrNull;

  /// Nearest first, then the default branch, then local over remote.
  ///
  /// The name last because `sort` is not stable: two branches equal on the
  /// rule would otherwise come out in whichever order the sort left them.
  static int _compare(
    BranchStandingValueObject a,
    BranchStandingValueObject b,
    BranchNameValueObject? defaultBranch,
  ) {
    int rank(BranchStandingValueObject it) =>
        (it.branch.name == defaultBranch ? 0 : 2) +
        (it.branch.isRemote ? 1 : 0);
    final int byDistance = a.behind.compareTo(b.behind);
    if (byDistance != 0) {
      return byDistance;
    }
    final int byRank = rank(a).compareTo(rank(b));
    return byRank != 0 ? byRank : a.branch.spec.compareTo(b.branch.spec);
  }
}
