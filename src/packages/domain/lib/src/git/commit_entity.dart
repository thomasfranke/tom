/// One recorded snapshot of the repository.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/git/author_value_object.dart';
import 'package:tom_domain/src/git/commit_date_value_object.dart';
import 'package:tom_domain/src/git/commit_sha_value_object.dart';

part 'commit_entity.freezed.dart';

/// A commit, as history shows it.
///
/// Without its diff, on purpose: a history panel lists hundreds of these and
/// needs none of them, and the panel that shows one version asks for that
/// version by [sha] (`docs/product/git-workflow/file-history/doc.md`).
@freezed
abstract class CommitEntity with _$CommitEntity {
  /// Creates a commit.
  const factory CommitEntity({
    /// Its object name, which is its identity.
    required CommitShaValueObject sha,

    /// Who wrote it.
    required AuthorValueObject author,

    /// When it was written, and where the author's clock stood.
    required CommitDateValueObject date,

    /// The first line of the message.
    required String subject,

    /// Everything after the first line. Empty when there is none.
    required String body,
  }) = _CommitEntity;
}
