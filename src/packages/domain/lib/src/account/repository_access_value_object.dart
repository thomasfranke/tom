/// What an account may do on one repository.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'repository_access_value_object.freezed.dart';

/// The five columns of the popover's grid — read, open a pull request,
/// push, merge, administer (`docs/product/workspace/the-account/doc.md`).
@freezed
abstract class RepositoryAccessValueObject with _$RepositoryAccessValueObject {
  /// Access, column by column.
  const factory RepositoryAccessValueObject({
    required bool canRead,
    required bool canOpenPullRequests,
    required bool canPush,
    required bool canMerge,
    required bool canAdminister,
  }) = _RepositoryAccessValueObject;

  /// What GitHub's three permissions grant here: opening a pull request and
  /// merging one follow pushing, since both write a branch on the
  /// repository itself.
  factory RepositoryAccessValueObject.granted({
    required bool pull,
    required bool push,
    required bool admin,
  }) => RepositoryAccessValueObject(
    canRead: pull || push || admin,
    canOpenPullRequests: push || admin,
    canPush: push || admin,
    canMerge: push || admin,
    canAdminister: admin,
  );
}
