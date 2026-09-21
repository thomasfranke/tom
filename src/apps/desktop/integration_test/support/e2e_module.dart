/// The two things an end-to-end run has to replace.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:tom_desktop/bootstrap/panel_descriptor.dart';
import 'package:tom_desktop/bootstrap/providers.dart';
import 'package:tom_desktop/bootstrap/tom_module.dart';
import 'package:tom_desktop/screens/home/folder_picker.dart';
import 'package:tom_infra/tom_infra.dart';

/// A module that answers the folder dialog, and keeps its own preferences.
///
/// The seam is the app's own. `TomModule` exists so that anything can be
/// added or replaced from outside without forking ([Decision
/// 12](../../../../../docs/technical/decisions/012-shell-is-extensible-via-compile-time-modules.md)),
/// and this is a module like any other — so every end-to-end run is also a
/// run of the extension point. If module overrides ever stopped working,
/// these scenarios would be the first thing to say so.
///
/// It replaces exactly two things, and both for reasons the product cannot
/// solve on its own:
///
/// 1. **The folder dialog.** A native panel is the one thing no test can
///    drive; without this the scenarios would stop where the product starts.
/// 2. **Where preferences are kept.** The app writes to the machine's
///    application-support folder, which on a developer's machine holds
///    *their* recent spaces. A run that wrote there would leave test folders
///    in the list of a person who was using the app five minutes ago — which
///    is exactly what the first run of this harness did.
///
/// It adds no panel. A module that only overrides providers is still a
/// module, and a harness that contributed UI would be testing itself.
class E2eModule implements TomModule {
  /// Creates a module answering the picker with [folder], storing
  /// preferences at [settingsPath].
  ///
  /// A null [folder] is the user cancelling, which is a case the product has
  /// a rule about: nothing moves.
  const E2eModule({required this.settingsPath, this.folder});

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
      (Ref ref) => JsonFileSettings(
        filesystem: ref.watch(filesystemProvider),
        path: settingsPath,
      ),
    ),
  ];
}
