/// Reading any file off the disk, text or not.
library;

import 'dart:typed_data';

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// A file a changed row opens that is not markdown, read as text or found
/// to be binary (`docs/product/git-workflow/commit/opening-a-change/doc.md`).
///
/// Read as bytes, so the test is [FileContentValueObject.ofBytes] — the one
/// a file read out of git gets too.
final class ReadFileUseCase with UseCase {
  /// Creates the use case.
  const ReadFileUseCase({
    required this.documentsFor,
    required this.observability,
  });

  /// How to reach the files of a space.
  final DocumentRepositoryFor documentsFor;

  @override
  final Observability observability;

  /// The file at [path] inside [space], as it is on disk.
  Future<Result<FileContentValueObject, AppFailure>> read(
    SpaceEntity space,
    SpaceRelativePathValueObject path,
  ) => guard<FileContentValueObject, DocumentFailure>(
    () => documentsFor(space)
        .readBytes(path)
        .map((Uint8List bytes) => FileContentValueObject.ofBytes(path, bytes)),
  );
}
