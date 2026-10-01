/// The two things an end-to-end run has to replace.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:tom_desktop/bootstrap/panel_descriptor.dart';
import 'package:tom_desktop/bootstrap/providers.dart';
import 'package:tom_desktop/bootstrap/tom_module.dart';
import 'package:tom_desktop/screens/home/folder_picker.dart';
import 'package:tom_infra/tom_infra.dart';

/// A module that answers the folder dialog and keeps its own preferences.
///
/// A module like any other ([Decision
/// 12](../../../../../docs/technical/decisions/012-shell-is-extensible-via-compile-time-modules.md)),
/// so every run drives the extension point too. No test can drive a native
/// panel, and the real preferences hold the developer's own recent spaces.
class E2eModuleImpl implements TomModule {
  /// Answers the picker with [folder] — null is the user cancelling — and
  /// stores preferences at [settingsPath].
  const E2eModuleImpl({required this.settingsPath, this.folder});

  /// What the picker answers, or null to cancel.
  final String? folder;

  /// Where this scenario's preferences live — never the real ones.
  final String settingsPath;

  @override
  String get id => 'tom.e2e';

  @override
  List<PanelDescriptor> get panels => const <PanelDescriptor>[];

  @override
  List<Override> get overrides => <Override>[
    folderPickerProvider.overrideWithValue(() async => folder),
    settingsProvider.overrideWith(
      (Ref ref) => JsonFileSettingsImpl(
        filesystem: ref.watch(filesystemProvider),
        path: settingsPath,
      ),
    ),
  ];
}
