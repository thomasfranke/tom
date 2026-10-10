/// Creating a folder inside the space.
library;

import 'package:tom_application/src/spaces/entry_path.dart';
import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// A new, empty folder, named where it was typed
/// (`docs/product/navigation/file-tree/explorer-menu/doc.md`).
///
/// Nothing is reused: a name already taken comes back as `SpaceEntryExists`.
final class CreateFolderUseCase with UseCase {
  /// Creates the use case.
  const CreateFolderUseCase({
    required this.spaces,
    required this.observability,
  });

  /// The folders spaces are made of.
  final SpaceRepository spaces;

  @override
  final Observability observability;

  /// Creates [typed] inside [folder] — the space's root when null — and
  /// answers with the path it was created at.
  Future<Result<SpaceRelativePathValueObject, AppFailure>> create(
    SpaceEntity space,
    SpaceRelativePathValueObject? folder,
    String typed,
  ) => guard(() async {
    final SpaceRelativePathValueObject? path = entryPathFor(folder, typed);
    if (path == null) {
      return Failure<SpaceRelativePathValueObject, AppFailure>(
        SpaceInvalidName(typed),
      );
    }
    final Result<void, SpaceFailure> created = await spaces.createFolder(
      space,
      path,
    );
    return switch (created) {
      Success<void, SpaceFailure>() =>
        Success<SpaceRelativePathValueObject, AppFailure>(path),
      Failure<void, SpaceFailure>(failure: final SpaceFailure why) =>
        Failure<SpaceRelativePathValueObject, AppFailure>(why),
    };
  });
}
