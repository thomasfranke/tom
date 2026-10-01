/// Who wrote a commit.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'author_value_object.freezed.dart';

/// The name and email git recorded for a commit's author.
///
/// One concept rather than two fields on `CommitEntity`: they travel
/// together, and the email tells two people with the same name apart.
@freezed
abstract class AuthorValueObject with _$AuthorValueObject {
  /// An author.
  const factory AuthorValueObject({
    /// The name, as `user.name` held it when the commit was made.
    required String name,

    /// The email, as `user.email` held it when the commit was made.
    required String email,
  }) = _AuthorValueObject;
}
