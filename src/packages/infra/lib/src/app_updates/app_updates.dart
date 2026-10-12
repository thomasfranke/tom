/// Asking where TOM's releases are published, behind a contract.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/src/app_updates/app_updates_failure.dart';

/// What TOM asks of the place its builds are published: which release is the
/// latest. Asked only when somebody asked for it
/// (`docs/product/about/doc.md`).
abstract interface class AppUpdates {
  /// The latest release as the host answers it, JSON verbatim — carrying
  /// `tag_name` and `html_url` — or null when nothing has been published
  /// yet.
  ///
  /// [AppUpdatesUnreachable] when the host did not answer in time, answered
  /// something else, or the machine is offline.
  Future<Result<String?, AppUpdatesFailure>> latest();
}
