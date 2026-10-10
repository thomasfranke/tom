/// Everything the account popover says about one space.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/account/commit_identity_value_object.dart';
import 'package:tom_domain/src/account/github_account_value_object.dart';
import 'package:tom_domain/src/account/repository_access_value_object.dart';
import 'package:tom_domain/src/pull_request/remote_project_value_object.dart';

part 'account_summary_value_object.freezed.dart';

/// Who commits, which GitHub account is used here, and what it may do
/// (`docs/product/workspace/the-account/doc.md`).
@freezed
abstract class AccountSummaryValueObject with _$AccountSummaryValueObject {
  /// A summary; everything past [identity] may be unknown.
  const factory AccountSummaryValueObject({
    required CommitIdentityValueObject identity,

    /// Every account the machine holds, the chosen one among them.
    ///
    /// Handed over, not copied: the producer passes `List.unmodifiable`.
    @Default(<GithubAccountValueObject>[])
    List<GithubAccountValueObject> accounts,

    /// The account used in this repository, or null when there is none.
    GithubAccountValueObject? chosen,

    /// The repository on GitHub, or null when `origin` is not there.
    RemoteProjectValueObject? project,

    /// What [chosen] may do on [project], or null when nothing says.
    RepositoryAccessValueObject? access,
  }) = _AccountSummaryValueObject;
}
