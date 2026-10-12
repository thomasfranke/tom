/// What the application may ask about the person's GitHub logins.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/src/account/account_failure.dart';
import 'package:tom_domain/src/account/github_account_value_object.dart';
import 'package:tom_domain/src/account/repository_access_value_object.dart';
import 'package:tom_domain/src/pull_request/remote_project_value_object.dart';

/// The GitHub accounts this machine already holds, for one space.
///
/// Per space because git's credential helper may be the repository's own.
/// **Nothing is stored and nothing is asked of the person**: an account no
/// tool holds is not there ([Decision
/// 35](../../../../../../docs/technical/decisions/035-github-is-reached-through-the-gh-cli.md)).
abstract interface class GithubAccountRepository {
  /// Every account `gh`, git's credential helper and `ssh` know — each
  /// login once, in that order — or none.
  Future<Result<List<GithubAccountValueObject>, AccountFailure>> accounts();

  /// What [account] may do on [project], or null when nothing can say: the
  /// account holds no token, or GitHub shows it no such repository.
  Future<Result<RepositoryAccessValueObject?, AccountFailure>> access(
    GithubAccountValueObject account,
    RemoteProjectValueObject project,
  );
}
