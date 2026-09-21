/// Asking the user for a folder, behind something that can be replaced.
library;

import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Asks for a folder, answering null when the user changed their mind.
///
/// A cancelled picker is not a failure and not a state: nothing moves.
typedef FolderPicker = Future<String?> Function();

/// What Home calls when the user wants to open a folder.
///
/// A provider rather than a direct call into `file_selector`, for a reason
/// that is not testing hygiene: **a native dialog is the one thing no test
/// can drive**. Without a seam here, an end-to-end run would have to stop
/// exactly where the product starts.
///
/// The seam is the one the app already has. `tom_e2e` replaces it through a
/// `TomModule`, the same mechanism a third party would use to contribute a
/// panel ([Decision
/// 12](../../../../../docs/technical/decisions/012-shell-is-extensible-via-compile-time-modules.md))
/// — so every end-to-end run is also a run of the extension point.
final Provider<FolderPicker> folderPickerProvider = Provider<FolderPicker>(
  (Ref ref) => getDirectoryPath,
);
