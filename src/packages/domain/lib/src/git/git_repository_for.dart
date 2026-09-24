/// How to get a git repository for a space.
library;

import 'package:tom_domain/src/git/git_repository.dart';
import 'package:tom_domain/src/spaces/space_entity.dart';

/// Builds the [GitRepository] that belongs to [space].
///
/// A [GitRepository] is per space — it runs git in that space's repository
/// and serializes its own commands — and a space is picked at runtime, so a
/// use case holds this rather than one repository.
///
/// A typedef rather than a factory class, for the same reason
/// `DocumentRepositoryFor` is one: a class here would be a name wrapped
/// around a constructor call ([Decision
/// 15](../../../../../../docs/technical/decisions/015-ddd-is-applied-selectively.md)).
typedef GitRepositoryFor = GitRepository Function(SpaceEntity space);
