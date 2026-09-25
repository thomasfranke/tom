/// Asking the user for a folder, behind something that can be replaced.
library;

import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show WidgetRef;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_presentation/tom_presentation.dart';

part 'folder_picker.g.dart';

/// Asks for a folder, answering null when the user changed their mind.
typedef FolderPicker = Future<String?> Function();

/// What Home calls when the user wants to open a folder.
///
/// A seam because a native dialog is the one thing no test can drive; the
/// e2e suite replaces it through a `TomModule`
/// ([Decision 12](../../../../../../docs/technical/decisions/012-shell-is-extensible-via-compile-time-modules.md)).
@riverpod
FolderPicker folderPicker(Ref ref) => getDirectoryPath;

/// Asks the user for a folder and opens it; a cancelled picker moves
/// nothing.
///
/// Beside the seam because the empty state and the refusal both offer it.
Future<void> chooseFolder(WidgetRef ref) async {
  final String? folder = await ref.read(folderPickerProvider)();
  if (folder != null) {
    await ref.read(homeProvider.notifier).open(folder);
  }
}
