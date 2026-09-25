/// One recorded snapshot of the repository.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/git/author_value_object.dart';
import 'package:tom_domain/src/git/commit_date_value_object.dart';
import 'package:tom_domain/src/git/commit_sha_value_object.dart';

part 'commit_entity.freezed.dart';

/// A commit, as history shows it.
///
/// Without its diff: a history panel lists hundreds and needs none, and one
/// version is asked for by [sha] (`docs/product/git-workflow/file-history/doc.md`).
@freezed
abstract class CommitEntity with _$CommitEntity {
  /// A commit.
  const factory CommitEntity({
    /// Its object name, which is its identity.
    required CommitShaValueObject sha,

    /// Who wrote it.
    required AuthorValueObject author,

    /// When it was written, and where the author's clock stood.
    required CommitDateValueObject date,

    /// The first line of the message.
    required String subject,

    /// Everything after the first line, empty when there is none.
    ///
    /// **Leading whitespace is content and is never trimmed**: an indented
    /// code block or a nested list means the indentation.
    required String body,
  }) = _CommitEntity;
}
