/// A pull request the host already has open.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'opened_pull_request_value_object.freezed.dart';

/// Its number, its page and its title, as the host answered them — what
/// the page shows in place of offering to open another
/// (`docs/product/git-workflow/pull-request/opening-it/doc.md`).
@freezed
abstract class OpenedPullRequestValueObject
    with _$OpenedPullRequestValueObject {
  /// A pull request.
  const factory OpenedPullRequestValueObject({
    /// `#123`, without the `#`.
    required int number,

    /// Its page on the host.
    required Uri address,

    /// Its title on the host, which may have moved on from the draft's.
    required String title,
  }) = _OpenedPullRequestValueObject;
}
