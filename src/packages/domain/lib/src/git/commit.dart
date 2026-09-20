/// One recorded snapshot of the repository.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/git/author.dart';
import 'package:tom_domain/src/git/commit_sha.dart';

part 'commit.freezed.dart';

/// A commit, as history shows it.
///
/// Without its diff, on purpose: a history panel lists hundreds of these and
/// needs none of them, and the panel that shows one version asks for that
/// version by [sha] (`docs/product/git-workflow/file-history/doc.md`).
@freezed
abstract class Commit with _$Commit {
  /// Creates a commit.
  const factory Commit({
    /// Its object name, which is its identity.
    required CommitSha sha,

    /// Who wrote it.
    required Author author,

    /// When it was written, with the offset git recorded.
    required DateTime date,

    /// The first line of the message.
    required String subject,

    /// Everything after the first line. Empty when there is none.
    required String body,
  }) = _Commit;
}
