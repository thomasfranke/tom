/// How a caller gets a client for a folder it did not know about.
library;

import 'package:tom_infra/src/git_client/git_client.dart';

/// Builds a [GitClient] that runs inside [folder].
///
/// A client is per folder and opening a space picks the folder at runtime, so
/// the composition root supplies this
/// ([composition](../../../../../../docs/technical/runtime/composition.md)).
/// A function, since there is one method and no state; it answers a client
/// for any folder, and `GitClient.repositoryRoot` is the check.
typedef GitClientFor = GitClient Function(String folder);
