/// How to get the GitHub accounts for a space.
library;

import 'package:tom_domain/src/account/github_account_repository.dart';
import 'package:tom_domain/src/spaces/space_entity.dart';

/// The [GithubAccountRepository] that belongs to [space].
typedef GithubAccountRepositoryFor =
    GithubAccountRepository Function(SpaceEntity space);
