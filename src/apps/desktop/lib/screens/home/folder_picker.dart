/// Asking the user for a folder, behind something that can be replaced.
library;

import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show WidgetRef;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_presentation/tom_presentation.dart';

part 'folder_picker.g.dart';

/// Asks for a folder, answering null when the user changed their mind.
///
/// A cancelled picker is not a failure and not a state: nothing moves.
typedef FolderPicker = Future<String?> Function();

/// What Home calls when the user wants to open a folder.
///
/// A provider rather than a direct call into `file_selector`, for a reason
/// that is not testing hygiene: **a native dialog is the one thing no test
/// can drive**, and without a seam an end-to-end run would stop exactly
/// where the product starts.
///
/// The seam is the app's own: `tom_e2e` replaces it through a `TomModule`,
/// the same mechanism a third party would use to contribute a panel
/// ([Decision
/// 12](../../../../../../docs/technical/decisions/012-shell-is-extensible-via-compile-time-modules.md)).
@riverpod
FolderPicker folderPicker(Ref ref) => getDirectoryPath;

/// Asks the user for a folder and opens it.
///
/// Beside the seam rather than inside a widget, because two of Home's
/// widgets offer it — the empty state and the refusal — and neither should
/// own the other's copy.
///
/// A cancelled picker is not a failure and not a state: the user changed
/// their mind, and the screen does not move.
Future<void> chooseFolder(WidgetRef ref) async {
  final String? folder = await ref.read(folderPickerProvider)();
  if (folder != null) {
    await ref.read(homeProvider.notifier).open(folder);
  }
}
