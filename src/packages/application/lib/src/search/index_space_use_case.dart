/// Building the index a space is searched through.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// Every markdown file of a space, filed so it can be found by its contents.
///
/// The index is a cache and this is how it is built, so it runs whenever a
/// space opens rather than only when one is missing
/// (`docs/product/search/full-text-search/what-is-searched/doc.md`). The listing is the file
/// tree's — one rule for what a space holds, and `.git/` is outside it.
final class IndexSpaceUseCase with UseCase {
  /// Creates the use case.
  const IndexSpaceUseCase({
    required this.spaces,
    required this.searchFor,
    required this.observability,
  });

  /// Where the folder is read.
  final SpaceRepository spaces;

  /// How to reach the index of the space being built.
  final SearchRepositoryFor searchFor;

  @override
  final Observability observability;

  /// [space] read and filed, ready to be searched.
  Future<Result<void, AppFailure>> index(SpaceEntity space) =>
      guard<void, AppFailure>(() async {
        final Result<List<SpaceEntryValueObject>, SpaceFailure> listed =
            await spaces.entries(space);
        return switch (listed) {
          Success<List<SpaceEntryValueObject>, SpaceFailure>(
            value: final List<SpaceEntryValueObject> entries,
          ) =>
            await searchFor(space)
                .index(<SpaceRelativePathValueObject>[
                  for (final SpaceEntryValueObject entry in entries)
                    if (entry.isDocument) entry.path,
                ])
                .mapFailure<AppFailure>((SearchFailure failure) => failure),
          Failure<List<SpaceEntryValueObject>, SpaceFailure>(
            failure: final SpaceFailure failure,
          ) =>
            Failure<void, AppFailure>(failure),
        };
      });
}
