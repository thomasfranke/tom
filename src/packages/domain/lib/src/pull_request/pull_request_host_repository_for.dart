/// How to reach the host's pull requests for a space.
library;

import 'package:tom_domain/src/pull_request/pull_request_host_repository.dart';
import 'package:tom_domain/src/spaces/space_entity.dart';

/// The [PullRequestHostRepository] that belongs to [space]'s repository.
typedef PullRequestHostRepositoryFor =
    PullRequestHostRepository Function(SpaceEntity space);
