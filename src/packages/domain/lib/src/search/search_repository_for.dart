/// How to get a search repository for a space.
library;

import 'package:tom_domain/src/search/search_repository.dart';
import 'package:tom_domain/src/spaces/space_entity.dart';

/// The [SearchRepository] that belongs to [space].
///
/// Per space like the documents are, and for one reason more: the index is
/// the space's, so two spaces open at once could never share one.
typedef SearchRepositoryFor = SearchRepository Function(SpaceEntity space);
