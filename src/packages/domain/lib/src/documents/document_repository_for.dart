/// How to get a document repository for a space.
library;

import 'package:tom_domain/src/documents/document_repository.dart';
import 'package:tom_domain/src/spaces/space_entity.dart';

/// Builds the [DocumentRepository] that belongs to [space].
///
/// A [DocumentRepository] is per space — every path on it is relative to
/// that space's root — and a space is picked at runtime, so a use case holds
/// this rather than one repository.
///
/// A typedef rather than a factory class, for the same reason `GitClientFor`
/// is one: a class here would be a name wrapped around a constructor call
/// ([Decision
/// 15](../../../../../../docs/technical/decisions/015-ddd-is-applied-selectively.md)).
typedef DocumentRepositoryFor = DocumentRepository Function(SpaceEntity space);
