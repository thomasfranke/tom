/// Creating a markdown document in a folder of the space.
library;

import 'package:tom_application/src/spaces/entry_path.dart';
import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// A new, empty document, named where it was typed
/// (`docs/product/navigation/file-tree/new-document/doc.md`).
///
/// **Only markdown**: a name that does not end in `.md` gets it, because the
/// `+` creates the one thing the editor opens. Nothing is ever overwritten —
/// a name already taken comes back as `DocumentAlreadyExists`.
final class CreateDocumentUseCase with UseCase {
  /// Creates the use case.
  const CreateDocumentUseCase({
    required this.documentsFor,
    required this.observability,
  });

  /// How to reach the documents of a space.
  final DocumentRepositoryFor documentsFor;

  @override
  final Observability observability;

  /// Creates [typed] inside [folder] — the space's root when null — and
  /// answers with the path it was created at.
  Future<Result<SpaceRelativePathValueObject, AppFailure>> create(
    SpaceEntity space,
    SpaceRelativePathValueObject? folder,
    String typed,
  ) => guard(() async {
    final SpaceRelativePathValueObject? path = pathFor(folder, typed);
    if (path == null) {
      return Failure<SpaceRelativePathValueObject, AppFailure>(
        DocumentInvalidName(typed),
      );
    }
    final Result<void, DocumentFailure> created = await documentsFor(
      space,
    ).create(DocumentEntity(path: path, content: ''));
    return switch (created) {
      Success<void, DocumentFailure>() =>
        Success<SpaceRelativePathValueObject, AppFailure>(path),
      Failure<void, DocumentFailure>(failure: final DocumentFailure why) =>
        Failure<SpaceRelativePathValueObject, AppFailure>(why),
    };
  });

  /// Where [typed] lands inside [folder], `.md` added when it has none, or
  /// null when it is not a name ([entryPathFor]).
  static SpaceRelativePathValueObject? pathFor(
    SpaceRelativePathValueObject? folder,
    String typed,
  ) {
    // Judged as typed, so `.` is refused rather than becoming `..md`.
    if (entryPathFor(folder, typed) == null) {
      return null;
    }
    final String name = typed.trim();
    return entryPathFor(
      folder,
      name.toLowerCase().endsWith('.md') ? name : '$name.md',
    );
  }
}
