/// The domain's space contract, fulfilled by the filesystem and by git.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/src/capabilities/filesystem/filesystem_entry_dto.dart';
import 'package:tom_data/src/capabilities/filesystem/filesystem_entry_type_enum.dart';
import 'package:tom_data/src/spaces/space_data_source.dart';
import 'package:tom_domain/tom_domain.dart';
// For the failure vocabularies only (Decision 25).
import 'package:tom_infra/tom_infra.dart';

/// [SpaceRepository] over [SpaceDataSource].
///
/// Opening and listing are one contract because both are about the folder a
/// space is. What is here is the order the questions are asked in and the
/// translations; the walk and its `.git/` rule are the source's
/// ([Decision 25](../../../../../../docs/technical/decisions/025-a-repository-reads-through-a-data-source.md)).
final class SpaceRepositoryImpl implements SpaceRepository {
  /// Creates a repository over [spaces].
  const SpaceRepositoryImpl({required this.spaces});

  /// Where a space's folder is read.
  final SpaceDataSource spaces;

  @override
  Future<Result<SpaceEntity, AppFailure>> open(String folder) async {
    // The disk is asked before git, because git reports a missing folder as
    // "not a repository" and the two send the user somewhere different.
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

    // Links are followed before git is asked, because git follows them on its
    // own and a space built from the two spellings would not enclose itself.
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
        // Reported rather than asserted, because an assertion is stripped
        // from a release build.
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
                // A path the space does not contain is dropped: this is the
                // last guard that nothing outside the folder reaches the tree.
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
  /// Written out although one to one, so a capability reporting something
  /// the tree has no place for breaks here.
  static SpaceEntryTypeEnum _asSpaceEntryTypeEnum(
    FilesystemEntryTypeEnum type,
  ) => switch (type) {
    FilesystemEntryTypeEnum.file => SpaceEntryTypeEnum.file,
    FilesystemEntryTypeEnum.directory => SpaceEntryTypeEnum.directory,
    FilesystemEntryTypeEnum.link => SpaceEntryTypeEnum.link,
  };

  /// What the filesystem reported, about the space's folder.
  ///
  /// Exhaustive with no default branch, which is why [FilesystemNotUtf8] is
  /// mapped although a listing cannot produce it. The path is the
  /// capability's absolute one, because a [SpaceFailure] is about a folder on
  /// the machine.
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
  /// [folder] is the one the user picked, so the failure names a place they
  /// chose; the command and the stderr travel as the cause.
  static GitFailure _asGitFailure(GitClientFailure failure, String folder) =>
      switch (failure) {
        GitClientNotARepository() => GitNotARepository(folder, cause: failure),
        GitClientExecutableNotFound() => GitNotInstalled(cause: failure),
        GitClientTimedOut() => GitTimedOut(cause: failure),
        // The rest cannot come from asking where the repository is, and are
        // named rather than defaulted so a new failure mode breaks this.
        GitClientCommandFailed() ||
        GitClientMergeConflict() ||
        GitClientAuthenticationFailed() ||
        GitClientPushRejected() ||
        GitClientPathNotInRevision() => GitOperationFailed(cause: failure),
      };
}
