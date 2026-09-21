/// The entrypoint every build of the app goes through.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:tom_desktop/bootstrap/core_module.dart';
import 'package:tom_desktop/bootstrap/panel_registry.dart';
import 'package:tom_desktop/bootstrap/tom_module.dart';
import 'package:tom_desktop/shell/tom_shell.dart';
import 'package:tom_desktop/theme/tom_metrics.dart';
import 'package:tom_desktop/theme/tom_theme.dart';
import 'package:window_manager/window_manager.dart';

/// Starts TOM with [modules] added to the app's own.
///
/// The composition root, and the one place that knows both a contract and
/// what satisfies it. It **only instantiates and wires** — any logic that
/// appears here belongs in a use case
/// ([flows](../../../../../docs/technical/flows.md#wiring-three-lifetimes)).
///
/// `runTom(modules: [])` is the whole public story: clone the repository,
/// build it, it works. A module is added to that list and nothing else
/// changes — the app never imports one
/// ([Decision 12](../../../../../docs/technical/decisions/012-shell-is-extensible-via-compile-time-modules.md)).
///
/// [CoreModule] is first, so a module's provider override wins over the
/// app's default: `ProviderScope` takes the last override for a provider,
/// and a module that could not replace a default would not be an extension
/// point.
Future<void> runTom({List<TomModule> modules = const <TomModule>[]}) async {
  final List<TomModule> all = <TomModule>[const CoreModule(), ...modules];
  WidgetsFlutterBinding.ensureInitialized();
  await _prepareWindow();
  runApp(
    ProviderScope(
      overrides: <Override>[
        panelRegistryProvider.overrideWithValue(PanelRegistry(all)),
        for (final TomModule module in all) ...module.overrides,
      ],
      child: const TomApp(),
    ),
  );
}

/// Gives the window a title and a size the layout holds together in.
///
/// Skipped where there is no window — a widget test runs the app with no
/// platform channels, and `window_manager` would throw into a test that is
/// about panels.
Future<void> _prepareWindow() async {
  if (!_hasWindow) {
    return;
  }
  await windowManager.ensureInitialized();
  await windowManager.waitUntilReadyToShow(
    const WindowOptions(
      title: 'TOM',
      minimumSize: Size(
        TomMetrics.minimumWindowWidth,
        TomMetrics.minimumWindowHeight,
      ),
    ),
    () async {
      await windowManager.show();
      await windowManager.focus();
    },
  );
}

/// Whether this process has a real desktop window.
bool get _hasWindow =>
    !const bool.fromEnvironment('dart.library.js_util') &&
    WidgetsBinding.instance.runtimeType.toString() !=
        'AutomatedTestWidgetsFlutterBinding';

/// The application widget.
///
/// Separate from [runTom] so a test can mount it without starting a window,
/// and so the composition root has exactly one job.
class TomApp extends StatelessWidget {
  /// Creates the application.
  const TomApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'TOM',
    debugShowCheckedModeBanner: false,
    theme: tomTheme(Brightness.light),
    darkTheme: tomTheme(Brightness.dark),
    home: const TomShell(),
  );
}
