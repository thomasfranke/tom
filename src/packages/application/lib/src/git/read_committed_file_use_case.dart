/// A file as git last knew it.
library;

import 'dart:typed_data';

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// What a deleted file opens as: its last committed version, read at `HEAD`
/// — which holds it whether the deletion is staged or not
/// (`docs/product/git-workflow/commit/opening-a-change/doc.md`).
///
/// A file staged and never committed is not in `HEAD`, so it is read from
/// the index instead: the last version git knows.
final class ReadCommittedFileUseCase with UseCase {
  /// Creates the use case.
  const ReadCommittedFileUseCase({
    required this.gitFor,
    required this.observability,
  });

  /// How to reach git for a space.
  final GitRepositoryFor gitFor;

  @override
  final Observability observability;

  /// [path] inside [space] as `HEAD` holds it, or the index when `HEAD`
  /// does not, text or binary.
  Future<Result<FileContentValueObject, AppFailure>> read(
    SpaceEntity space,
    SpaceRelativePathValueObject path,
  ) => guard<FileContentValueObject, GitFailure>(() async {
    final GitRepository git = gitFor(space);
    final RepoRelativePathValueObject file = space.toRepoRelative(path);
    final Result<Uint8List, GitFailure> committed = await git.bytesAt(
      revision: 'HEAD',
      path: file,
    );
    final Result<Uint8List, GitFailure> last = switch (committed) {
      Failure<Uint8List, GitFailure>(failure: GitPathNotInRevision()) =>
        await git.stagedBytes(file),
      _ => committed,
    };
    return last.map(
      (Uint8List bytes) => FileContentValueObject.ofBytes(path, bytes),
    );
  });
}
