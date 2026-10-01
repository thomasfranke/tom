/// Putting changes into the index, and taking them back out.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// Whole files moved in and out of the index; there is no hunk-level staging
/// (`docs/product/git-workflow/commit/the-changes-list/doc.md`).
///
/// Both directions in one use case because a row's checkbox is one control.
final class StageChangesUseCase with UseCase {
  /// Creates the use case.
  const StageChangesUseCase({
    required this.gitFor,
    required this.documentsFor,
    required this.observability,
    this.scanner = const ConflictScannerService(),
  });

  /// How to reach git for a space.
  final GitRepositoryFor gitFor;

  /// How to read a document's text, to check it before staging it.
  final DocumentRepositoryFor documentsFor;

  /// Reads the markers git leaves in a conflicted document.
  final ConflictScannerService scanner;

  @override
  final Observability observability;

  /// [paths] added to [space]'s index; an empty list succeeds and does nothing.
  ///
  /// Refused with `GitConflictMarkersPresent` when any of them still holds a
  /// marker. The policy is this use case's, the way the detached-HEAD refusal
  /// is `CommitChangesUseCase`'s: git would record the marker, and
  /// `<<<<<<<` in committed documentation is read by everyone who opens the
  /// file next.
  Future<Result<void, AppFailure>> stage(
    SpaceEntity space,
    List<RepoRelativePathValueObject> paths,
  ) => guard(() async {
    final List<String> holding = await _pathsHoldingMarkers(space, paths);
    if (holding.isNotEmpty) {
      return Failure<void, GitFailure>(GitConflictMarkersPresent(holding));
    }
    return gitFor(space).stage(paths);
  });

  /// [paths] taken back out of the index, the working tree left alone.
  ///
  /// Never refused: unstaging cannot put anything into a commit.
  Future<Result<void, AppFailure>> unstage(
    SpaceEntity space,
    List<RepoRelativePathValueObject> paths,
  ) => guard(() => gitFor(space).unstage(paths));

  /// Which of [paths] still read as conflicted, in the order given.
  ///
  /// The check is the **text**, never git's `u` record: resolving happens in
  /// the buffer and staging is how the resolution is declared, so refusing
  /// what git still calls conflicted would refuse the way out.
  ///
  /// A path outside the space is not read and not refused. The changes list
  /// is the repository's, so it can name a file this space cannot open — and
  /// somebody who resolved that one in another editor has to be able to
  /// finish here.
  Future<List<String>> _pathsHoldingMarkers(
    SpaceEntity space,
    List<RepoRelativePathValueObject> paths,
  ) async {
    final DocumentRepository documents = documentsFor(space);
    final List<String> holding = <String>[];
    for (final RepoRelativePathValueObject path in paths) {
      final SpaceRelativePathValueObject? within = space.toSpaceRelative(path);
      if (within == null) {
        continue;
      }
      final Result<DocumentEntity, DocumentFailure> read = await documents.read(
        within,
      );
      // A file that cannot be read is not a file with a marker. Whatever is
      // wrong with it, git is about to report it too.
      if (read case Success<DocumentEntity, DocumentFailure>(
        value: final DocumentEntity document,
      )) {
        if (scanner.holdsMarker(document.content)) {
          holding.add(path.value);
        }
      }
    }
    return holding;
  }
}
