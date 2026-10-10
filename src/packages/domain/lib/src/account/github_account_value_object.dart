/// A GitHub login this machine holds.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/account/account_source_enum.dart';

part 'github_account_value_object.freezed.dart';

/// Who the person is on GitHub, as one of the machine's tools knows them.
///
/// Never a token: what TOM shows is the login, and the token stays below the
/// repository that read it ([Decision
/// 35](../../../../../../docs/technical/decisions/035-github-is-reached-through-the-gh-cli.md)).
@freezed
abstract class GithubAccountValueObject with _$GithubAccountValueObject {
  /// An account.
  const factory GithubAccountValueObject({
    /// The login, without the `@`.
    required String login,

    /// The tool it was read from.
    required AccountSourceEnum source,
  }) = _GithubAccountValueObject;
}
