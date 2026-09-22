/// How a caller gets a client for a folder it did not know about.
library;

import 'package:tom_data/src/capabilities/git_client/git_client.dart';

/// Builds a [GitClient] that runs inside [folder].
///
/// A `GitClient` is per folder by construction — it holds the working
/// directory its commands run in, and the queue that serializes them. Most
/// callers are handed one and never make one. Opening a space is the
/// exception: the folder arrives from a picker at runtime, so *something*
/// has to construct a client for it.
///
/// A function rather than an interface, because there is exactly one method
/// and no state to hold: a factory class here would be a name wrapped around
/// a constructor call. The composition root supplies it, which keeps the
/// choice of implementation in the one place allowed to make it
/// ([flows](../../../../../../docs/technical/flows.md#wiring-three-lifetimes)).
///
/// It answers a client for any folder, including one that holds no
/// repository and one that does not exist. Finding that out is what
/// `GitClient.repositoryRoot` is for — a constructor that validated would
/// have to do I/O, and a factory that can fail would put the failure in the
/// wrong place.
typedef GitClientFor = GitClient Function(String folder);
