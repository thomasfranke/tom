/// Reading what a branch did, in numbers.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// The `Overview` segment: git's counts, plus the words and blocks the
/// block differ finds in every markdown document the branch changed
/// (`docs/product/git-workflow/pull-request/the-right-column/doc.md`).
///
/// Each document is read twice — at the fork point and at `HEAD` — and
/// diffed by the same differ the rendered diff runs. One that cannot be
/// read is left out of the words rather than failing the overview: the
/// counts git gave are still true.
final class ReadBranchOverviewUseCase with UseCase {
  /// Creates the use case.
  const ReadBranchOverviewUseCase({
    required this.gitFor,
    required this.blocks,
    required this.differ,
    required this.observability,
    this.overview = const BranchOverviewService(),
  });

  /// How to reach git for a space.
  final GitRepositoryFor gitFor;

  /// What splits a version into blocks.
  final BlockReaderPort blocks;

  /// What compares two versions block by block.
  final BlockDifferService differ;

  /// What folds the readings into numbers.
  final BranchOverviewService overview;

  @override
  final Observability observability;

  /// The overview of [proposal], a reading of `HEAD` over [base].
  Future<Result<BranchOverviewValueObject, AppFailure>> read(
    SpaceEntity space,
    BranchNameValueObject base,
    BranchProposalValueObject proposal,
  ) => guard<BranchOverviewValueObject, GitFailure>(() async {
    final GitRepository git = gitFor(space);
    final Result<CommitShaValueObject?, GitFailure> fork = await git.forkPoint(
      base,
    );
    if (fork case Failure<CommitShaValueObject?, GitFailure>(
      failure: final GitFailure failure,
    )) {
      return Failure<BranchOverviewValueObject, GitFailure>(failure);
    }
    final CommitShaValueObject? since =
        (fork as Success<CommitShaValueObject?, GitFailure>).value;
    final List<DocumentDiffValueObject> diffs = <DocumentDiffValueObject>[];
    for (final BranchChangeValueObject change in proposal.changes) {
      if (!change.path.value.toLowerCase().endsWith('.md')) {
        continue;
      }
      final DocumentDiffValueObject? diff = await _diff(
        git,
        change.path,
        since,
      );
      if (diff != null) {
        diffs.add(diff);
      }
    }
    return Success<BranchOverviewValueObject, GitFailure>(
      overview.summarise(
        commits: proposal.commits,
        changes: proposal.changes,
        diffs: diffs,
      ),
    );
  });

  /// [path] at [since] against [path] at `HEAD`, either side empty where
  /// that version does not hold it, or null when anything refused.
  Future<DocumentDiffValueObject?> _diff(
    GitRepository git,
    RepoRelativePathValueObject path,
    CommitShaValueObject? since,
  ) async {
    final String? before = since == null
        ? ''
        : await _contentAt(git, since.value, path);
    final String? after = await _contentAt(git, 'HEAD', path);
    if (before == null || after == null) {
      return null;
    }
    // The label only: a parse never reaches the disk.
    final SpaceRelativePathValueObject named = SpaceRelativePathValueObject(
      path.value,
    );
    final Result<ParsedDocumentValueObject, DocumentFailure> old = await blocks
        .read(DocumentEntity(path: named, content: before));
    final Result<ParsedDocumentValueObject, DocumentFailure> now = await blocks
        .read(DocumentEntity(path: named, content: after));
    if (old case Success<ParsedDocumentValueObject, DocumentFailure>(
      value: final ParsedDocumentValueObject parsedBefore,
    )) {
      if (now case Success<ParsedDocumentValueObject, DocumentFailure>(
        value: final ParsedDocumentValueObject parsedAfter,
      )) {
        final Result<DocumentDiffValueObject, DocumentFailure> diff =
            await differ.diff(before: parsedBefore, after: parsedAfter);
        return switch (diff) {
          Success<DocumentDiffValueObject, DocumentFailure>(
            value: final DocumentDiffValueObject value,
          ) =>
            value,
          Failure<DocumentDiffValueObject, DocumentFailure>() => null,
        };
      }
    }
    return null;
  }

  /// [path] at [revision], empty where the revision does not hold it, null
  /// on any other refusal.
  static Future<String?> _contentAt(
    GitRepository git,
    String revision,
    RepoRelativePathValueObject path,
  ) async => switch (await git.contentAt(revision: revision, path: path)) {
    Success<String, GitFailure>(value: final String content) => content,
    Failure<String, GitFailure>(failure: GitPathNotInRevision()) => '',
    Failure<String, GitFailure>() => null,
  };
}
