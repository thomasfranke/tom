/// Who wrote a commit.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'author_value_object.freezed.dart';

/// The name and email git recorded for a commit's author.
///
/// One concept rather than two fields on
/// [CommitEntity](commit_entity.dart): they always travel together, and the
/// email is what lets a later feature tell two
/// people with the same name apart.
///
/// A Freezed value object, not an `extension type`: it has two fields
/// ([Decision
/// 16](../../../../../../docs/technical/decisions/016-freezed-is-mandatory-for-immutable-data.md)).
@freezed
abstract class AuthorValueObject with _$AuthorValueObject {
  /// Creates an author.
  const factory AuthorValueObject({
    /// The name, as `user.name` held it when the commit was made.
    required String name,

    /// The email, as `user.email` held it when the commit was made.
    required String email,
  }) = _AuthorValueObject;
}
