/// The domain's space contract, fulfilled by the filesystem and by git.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/src/capabilities/filesystem/filesystem_entry_dto.dart';
import 'package:tom_data/src/capabilities/filesystem/filesystem_entry_type_enum.dart';
import 'package:tom_data/src/spaces/space_data_source.dart';
import 'package:tom_domain/tom_domain.dart';
// For the failure vocabularies only. Naming a failure in order to translate
// it is a repository's job; reaching a capability to obtain data is not, and
// no repository holds one (Decision 25).
import 'package:tom_infra/tom_infra.dart';

/// [SpaceRepository] over [SpaceDataSource].
///
/// Two jobs that look unrelated and are not. Opening a folder asks git where
/// the repository is; listing one asks the disk what is inside. Both are
/// about the *folder* a space is, which is why they are one contract and why
/// the failures they produce send the user to another space rather than to
/// another file.
///
/// What is left here is what a repository owes: the **order** the two
/// questions are asked in, the turn from a DTO into the domain's vocabulary,
/// and the translation of failures. How the entries are gathered — and the
/// `.git/` rule that shapes the walk — belongs to the source
/// ([Decision 25](../../../../../../docs/technical/decisions/025-a-repository-reads-through-a-data-source.md)).
final class SpaceRepositoryImpl implements SpaceRepository {
  /// Creates a repository over [spaces].
  const SpaceRepositoryImpl({required this.spaces});

  /// Where a space's folder is read.
  final SpaceDataSource spaces;

  @override
  Future<Result<SpaceEntity, AppFailure>> open(String folder) async {
    // The disk is asked first, and the order is the whole point: a folder
    // that is not there and a folder that holds no repository send the user
    // somewhere different — forget this space, against open another one —
    // and git reports both as "not a repository".
    final Result<bool, SpaceFailure> exists = await spaces
        .exists(folder)
        .mapFailure(_asSpaceFailure);
    switch (exists) {
      case Failure<bool, SpaceFailure>(failure: final SpaceFailure failure):
        return Failure<SpaceEntity, AppFailure>(failure);
      case Success<bool, SpaceFailure>(value: false):
        return Failure<SpaceEntity, AppFailure>(SpaceFolderMissing(folder));
      case Success<bool, SpaceFailure>():
        break;
    }

    // Links are followed before git is asked, because git follows them on
    // its own: a picker answers `/tmp/x/docs`, `git rev-parse` answers
    // `/private/tmp/x`, and a space built from the two would not enclose
    // itself. The resolved spelling is the space's identity from here on.
    final Result<String, SpaceFailure> resolved = await spaces
        .resolve(folder)
        .mapFailure(_asSpaceFailure);
    if (resolved case Failure<String, SpaceFailure>(
      failure: final SpaceFailure failure,
    )) {
      return Failure<SpaceEntity, AppFailure>(failure);
    }
    final String root = (resolved as Success<String, SpaceFailure>).value;

    final Result<String, GitClientFailure> located = await spaces
        .repositoryRootOf(root);
    switch (located) {
      case Failure<String, GitClientFailure>(
        failure: final GitClientFailure failure,
      ):
        return Failure<SpaceEntity, AppFailure>(_asGitFailure(failure, folder));
      case Success<String, GitClientFailure>(value: final String repositoryRoot)
          when !SpaceEntity.isEnclosedBy(root, repositoryRoot):
        // An answer the invariant refuses, reported rather than asserted:
        // the assertion is stripped from a release build, and a space that
        // does not contain itself would fail on the first path conversion.
        return Failure<SpaceEntity, AppFailure>(SpaceOperationFailed(folder));
      case Success<String, GitClientFailure>(
        value: final String repositoryRoot,
      ):
        return Success<SpaceEntity, AppFailure>(
          SpaceEntity(
            root: root,
            repositoryRoot: repositoryRoot,
            name: SpaceEntity.nameOfFolder(root),
          ),
        );
    }
  }

  @override
  Future<Result<List<SpaceEntryValueObject>, SpaceFailure>> entries(
    SpaceEntity space,
  ) => spaces
      .entries(space.root)
      .map(
        (List<FilesystemEntryDto> gathered) =>
            List<SpaceEntryValueObject>.unmodifiable(<SpaceEntryValueObject>[
              for (final FilesystemEntryDto entry in gathered)
                // A path the space does not contain is dropped rather
                // than spelled: `relativize` answering null is the last
                // guard that nothing outside the folder reaches the tree.
                if (space.relativize(entry.path)
                    case final SpaceRelativePathValueObject path)
                  SpaceEntryValueObject(
                    path: path,
                    type: _asSpaceEntryTypeEnum(entry.type),
                  ),
            ]),
      )
      .mapFailure(_asSpaceFailure);

  /// The same kind, in the product's vocabulary.
  ///
  /// A one-to-one map today, and still written out: the two enums answer to
  /// different owners, and the day the capability learns to report something
  /// the tree has no place for, this is where the compiler will say so.
  static SpaceEntryTypeEnum _asSpaceEntryTypeEnum(
    FilesystemEntryTypeEnum type,
  ) => switch (type) {
    FilesystemEntryTypeEnum.file => SpaceEntryTypeEnum.file,
    FilesystemEntryTypeEnum.directory => SpaceEntryTypeEnum.directory,
    FilesystemEntryTypeEnum.link => SpaceEntryTypeEnum.link,
  };

  /// What the filesystem reported, about the space's folder.
  ///
  /// Exhaustive over [FilesystemFailure] with no default branch. The path is
  /// the capability's own — absolute, and inside a walk rarely the space
  /// root — because a [SpaceFailure] is about a folder on the machine, not
  /// about somewhere inside a space the user can navigate to.
  ///
  /// [FilesystemNotUtf8] cannot come from a listing: it is what reading a
  /// file's bytes answers. It is mapped rather than ignored because leaving
  /// it out would mean a default branch, and a default branch is what stops
  /// the next variant from breaking this.
  static SpaceFailure _asSpaceFailure(FilesystemFailure failure) =>
      switch (failure) {
        FilesystemEntryNotFound(path: final String path) => SpaceFolderMissing(
          path,
          cause: failure,
        ),
        FilesystemAccessDenied(path: final String path) => SpaceAccessDenied(
          path,
          cause: failure,
        ),
        FilesystemNotUtf8(path: final String path) => SpaceOperationFailed(
          path,
          cause: failure,
        ),
        FilesystemOperationFailed(path: final String path) =>
          SpaceOperationFailed(path, cause: failure),
      };

  /// What git reported about [folder], in the product's vocabulary.
  ///
  /// Only the failures `repositoryRoot` can produce are named; anything else
  /// keeps the command and the stderr, which is what the UI's "details"
  /// disclosure shows.
  ///
  /// [GitClientNotARepository] carries the path git was asked about, and
  /// that is the one this hands on — it is the folder the user picked, and
  /// naming anything else would point them at a place they did not choose.
  static GitFailure _asGitFailure(GitClientFailure failure, String folder) =>
      switch (failure) {
        GitClientNotARepository() => GitNotARepository(folder, cause: failure),
        GitClientExecutableNotFound() => GitNotInstalled(cause: failure),
        GitClientTimedOut() => GitTimedOut(cause: failure),
        // The rest cannot come from asking where the repository is: there is
        // nothing to merge, nothing to push and no remote involved. They are
        // still named rather than defaulted, so a capability that learns a
        // new failure mode breaks this switch.
        GitClientCommandFailed() ||
        GitClientMergeConflict() ||
        GitClientAuthenticationFailed() ||
        GitClientPushRejected() ||
        GitClientPathNotInRevision() => GitOperationFailed(cause: failure),
      };
}
