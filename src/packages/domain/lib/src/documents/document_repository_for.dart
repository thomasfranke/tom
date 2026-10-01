/// How to get a document repository for a space.
library;

import 'package:tom_domain/src/documents/document_repository.dart';
import 'package:tom_domain/src/spaces/space_entity.dart';

/// The [DocumentRepository] that belongs to [space].
///
/// A repository is per space and a space is picked at runtime, so a use case
/// holds this; a typedef because a factory class would be a name wrapped
/// around a constructor call ([Decision
/// 15](../../../../../../docs/technical/decisions/015-ddd-is-applied-selectively.md)).
typedef DocumentRepositoryFor = DocumentRepository Function(SpaceEntity space);
