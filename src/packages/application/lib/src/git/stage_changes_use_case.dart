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
  /// marker line **while git calls it conflicted**. The policy is this use
  /// case's, the way the detached-HEAD refusal is `CommitChangesUseCase`'s:
  /// git would record the marker, and `<<<<<<<` in committed documentation
  /// is read by everyone who opens the file next.
  ///
  /// Git is asked first because one line is enough to refuse, and outside a
  /// merge one such line is prose: a document *about* conflicts stages.
  Future<Result<void, AppFailure>> stage(
    SpaceEntity space,
    List<RepoRelativePathValueObject> paths,
  ) => guard(() async {
    final GitRepository git = gitFor(space);
    if (paths.isEmpty) {
      return git.stage(paths);
    }
    final Result<GitStatusValueObject, GitFailure> reading = await git.status();
    if (reading case Failure<GitStatusValueObject, GitFailure>(
      failure: final GitFailure failure,
    )) {
      // Not knowing which files are conflicted is not knowing they are safe.
      return Failure<void, GitFailure>(failure);
    }
    final Set<RepoRelativePathValueObject> conflicted =
        <RepoRelativePathValueObject>{
          for (final StatusEntryValueObject entry
              in (reading as Success<GitStatusValueObject, GitFailure>)
                  .value
                  .entries)
            if (entry.state == FileStateEnum.conflicted) entry.path,
        };
    final List<String> holding = await _pathsHoldingMarkers(
      space,
      paths.where(conflicted.contains),
    );
    if (holding.isNotEmpty) {
      return Failure<void, GitFailure>(GitConflictMarkersPresent(holding));
    }
    return git.stage(paths);
  });

  /// [paths] taken back out of the index, the working tree left alone.
  ///
  /// Never refused: unstaging cannot put anything into a commit.
  Future<Result<void, AppFailure>> unstage(
    SpaceEntity space,
    List<RepoRelativePathValueObject> paths,
  ) => guard(() => gitFor(space).unstage(paths));

  /// Which of [paths] — the ones git calls conflicted — still hold a marker
  /// line, in the order given.
  ///
  /// The check is the **text**, never git's `u` record alone: resolving
  /// happens in the buffer and staging is how the resolution is declared, so
  /// refusing everything git still calls conflicted would refuse the way out.
  ///
  /// A path outside the space is read through the repository: the changes
  /// list is the repository's, and one resolved in another editor reads
  /// clean and stages here like any other.
  Future<List<String>> _pathsHoldingMarkers(
    SpaceEntity space,
    Iterable<RepoRelativePathValueObject> paths,
  ) async {
    final List<String> holding = <String>[];
    for (final RepoRelativePathValueObject path in paths) {
      final SpaceRelativePathValueObject? within = space.toSpaceRelative(path);
      final SpaceEntity? repository = space.repositorySpace;
      if (within == null && repository == null) {
        continue;
      }
      final Result<DocumentEntity, DocumentFailure> read = within != null
          ? await documentsFor(space).read(within)
          : await documentsFor(
              repository!,
            ).read(SpaceRelativePathValueObject(path.value));
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
