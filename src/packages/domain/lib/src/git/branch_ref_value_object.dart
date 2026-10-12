/// A branch as git can name it: local, or a remote's copy.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/git/branch_name_value_object.dart';

part 'branch_ref_value_object.freezed.dart';

/// A local branch, or a remote-tracking one with the remote it belongs to.
///
/// Two fields rather than `origin/develop` in one name, because the two
/// readers want different halves: git resolves [spec], and a pull request is
/// proposed onto [name] alone, which is what the host calls it.
@freezed
abstract class BranchRefValueObject with _$BranchRefValueObject {
  /// A branch; [remote] is null for a local one.
  const factory BranchRefValueObject({
    /// The branch's own name, without the remote's.
    required BranchNameValueObject name,

    /// The remote whose copy this is, or null for a local branch.
    String? remote,
  }) = _BranchRefValueObject;

  const BranchRefValueObject._();

  /// Whether this is a remote's copy rather than a local branch.
  bool get isRemote => remote != null;

  /// What git resolves it by, and what the bar calls it: `develop`, or
  /// `origin/develop`.
  String get spec => remote == null ? name.value : '$remote/${name.value}';
}
