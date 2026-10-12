/// Bringing a repository that lives elsewhere onto the machine.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/src/git/clone_progress_value_object.dart';
import 'package:tom_domain/src/git/git_failure.dart';

/// Cloning by URL (`docs/product/home/cloning/doc.md`).
///
/// Apart from `GitRepository` because that one belongs to a space, and
/// before a clone there is no space; one instance for the app.
abstract interface class GitCloneRepository {
  /// Clones [url] into [destination], an absolute path that does not exist
  /// yet or is an empty folder, reporting each stage to [onProgress].
  ///
  /// `GitRemoteNotFound` for an address that names nothing,
  /// `GitAuthenticationFailed`, `GitNetworkUnavailable` and
  /// `GitCloneDestinationTaken` for a folder already holding something. A
  /// failure leaves nothing the clone made, and touches nothing it did not.
  Future<Result<void, GitFailure>> clone({
    required String url,
    required String destination,
    void Function(CloneProgressValueObject progress)? onProgress,
  });
}
