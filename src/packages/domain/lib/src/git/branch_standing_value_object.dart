/// Where a branch stands against the one checked out.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/git/branch_ref_value_object.dart';

part 'branch_standing_value_object.freezed.dart';

/// A branch, and how many commits separate it from `HEAD` either way.
///
/// What the base of a branch is deduced from when nobody recorded it
/// (`BranchBaseService`): [behind] is how far `HEAD` has come since the two
/// last shared a commit.
@freezed
abstract class BranchStandingValueObject with _$BranchStandingValueObject {
  /// A standing.
  const factory BranchStandingValueObject({
    /// The branch standing.
    required BranchRefValueObject branch,

    /// Commits [branch] has that `HEAD` has not.
    required int ahead,

    /// Commits `HEAD` has that [branch] has not.
    required int behind,

    /// Whether the two share any commit at all; a branch with an unrelated
    /// history (`gh-pages`) is no base whatever its numbers say.
    required bool sharesHistory,
  }) = _BranchStandingValueObject;
}
