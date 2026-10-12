/// Who a commit is made as.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'commit_identity_value_object.freezed.dart';

/// git's `user.name` and `user.email` — shown, never changed
/// (`docs/product/workspace/the-account/doc.md`).
@freezed
abstract class CommitIdentityValueObject with _$CommitIdentityValueObject {
  /// An identity; either half may be unset.
  const factory CommitIdentityValueObject({String? name, String? email}) =
      _CommitIdentityValueObject;

  const CommitIdentityValueObject._();

  /// Whether git would refuse to commit: it asks for both first.
  bool get isIncomplete => name == null || email == null;
}
