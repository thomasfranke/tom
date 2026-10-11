/// The domain's clone contract, fulfilled by running the system binary.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/src/capabilities/filesystem/filesystem_entry_dto.dart';
import 'package:tom_data/src/capabilities/filesystem/filesystem_entry_type_enum.dart';
import 'package:tom_data/src/git/git_clone_data_source.dart';
import 'package:tom_data/src/git/git_clone_progress_parser.dart';
import 'package:tom_domain/tom_domain.dart';
// For the failure vocabulary only (Decision 25).
import 'package:tom_infra/tom_infra.dart';

/// [GitCloneRepository] over [GitCloneDataSource].
///
/// Translates git's lines into progress and its failures into [GitFailure];
/// a line that names no stage is not passed on.
final class GitCloneRepositoryImpl implements GitCloneRepository {
  /// Creates a repository over [git].
  const GitCloneRepositoryImpl({
    required this.git,
    this.progressParser = const GitCloneProgressParser(),
  });

  /// Where the clone runs.
  final GitCloneDataSource git;

  /// Reads `--progress` lines.
  final GitCloneProgressParser progressParser;

  @override
  Future<Result<void, GitFailure>> clone({
    required String url,
    required String destination,
    void Function(CloneProgressValueObject progress)? onProgress,
  }) async {
    final _Leftover leftover = await _leftoverAt(destination);
    final Result<void, GitFailure> cloned = await git
        .clone(
          url,
          destination,
          onLine: onProgress == null
              ? null
              : (String line) {
                  if (progressParser.parse(line)
                      case final CloneProgressValueObject progress) {
                    onProgress(progress);
                  }
                },
        )
        .mapFailure(_asGitFailure);
    if (cloned is Failure<void, GitFailure>) {
      await _remove(leftover, destination);
    }
    return cloned;
  }

  /// What a failed clone into [destination] will have made, read before git
  /// runs (`docs/product/home/cloning/doc.md`).
  ///
  /// Git cleans up after itself unless it is killed, and a timeout kills it;
  /// a folder already holding something, or one the machine will not
  /// describe, is never the clone's.
  Future<_Leftover> _leftoverAt(String destination) async {
    switch (await git.entryTypeOf(destination)) {
      case Success<FilesystemEntryTypeEnum?, FilesystemFailure>(value: null):
        return _Leftover.folder;
      case Success<FilesystemEntryTypeEnum?, FilesystemFailure>(
        value: FilesystemEntryTypeEnum.directory,
      ):
        return switch (await git.entriesOf(destination)) {
          Success<List<FilesystemEntryDto>, FilesystemFailure>(
            value: <FilesystemEntryDto>[],
          ) =>
            _Leftover.contents,
          _ => _Leftover.nothing,
        };
      case _:
        return _Leftover.nothing;
    }
  }

  /// Removes what [leftover] says the clone made at [destination].
  ///
  /// What the removal answers is dropped: the clone's own failure is what
  /// the user needs, and a folder left over can still go by hand.
  Future<void> _remove(_Leftover leftover, String destination) async {
    switch (leftover) {
      case _Leftover.nothing:
        return;
      case _Leftover.folder:
        await git.remove(destination);
      case _Leftover.contents:
        if (await git.entriesOf(destination)
            case Success<List<FilesystemEntryDto>, FilesystemFailure>(
              value: final List<FilesystemEntryDto> entries,
            )) {
          for (final FilesystemEntryDto entry in entries) {
            await git.remove(entry.path);
          }
        }
    }
  }

  /// What infrastructure reported, in the product's vocabulary.
  ///
  /// Exhaustive with no default branch, so a new failure mode breaks this.
  /// What a clone cannot produce — a conflict, a rejected push, a path not
  /// in a revision — is git refusing something nobody asked for here.
  static GitFailure _asGitFailure(GitClientFailure failure) =>
      switch (failure) {
        GitClientExecutableNotFound() => GitNotInstalled(cause: failure),
        GitClientRemoteNotFound() => GitRemoteNotFound(cause: failure),
        GitClientDestinationTaken(path: final String path) =>
          GitCloneDestinationTaken(path, cause: failure),
        GitClientAuthenticationFailed() => GitAuthenticationFailed(
          cause: failure,
        ),
        GitClientNetworkUnavailable() => GitNetworkUnavailable(cause: failure),
        GitClientTimedOut() => GitTimedOut(cause: failure),
        GitClientCommandDenied() => GitCommandDenied(cause: failure),
        GitClientNoRemote() => GitRemoteNotFound(cause: failure),
        GitClientNotARepository() ||
        GitClientMergeConflict() ||
        GitClientPushRejected() ||
        GitClientBranchProtected() ||
        GitClientLocalChangesOverwritten() ||
        GitClientPathNotInRevision() ||
        GitClientPathCommitted() ||
        GitClientCommandFailed() => GitOperationFailed(cause: failure),
      };
}

/// What a clone that fails leaves to remove.
enum _Leftover {
  /// The destination itself, which the clone created.
  folder,

  /// What is inside the destination, an empty folder before the clone.
  contents,

  /// Nothing: whatever is there was there before.
  nothing,
}
