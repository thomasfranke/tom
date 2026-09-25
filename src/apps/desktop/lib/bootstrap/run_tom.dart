/// The entrypoint every build of the app goes through.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:tom_desktop/bootstrap/core_module_impl.dart';
import 'package:tom_desktop/bootstrap/panel_registry.dart';
import 'package:tom_desktop/bootstrap/providers.dart';
import 'package:tom_desktop/bootstrap/tom_module.dart';
import 'package:tom_desktop/screens/home/home_screen.dart';
import 'package:tom_desktop/screens/shell/tom_shell.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';
import 'package:window_manager/window_manager.dart';

/// Starts TOM with [modules] added to the app's own.
///
/// The composition root: it only instantiates and wires, and any logic that
/// appears here belongs in a use case
/// ([composition](../../../../../docs/technical/runtime/composition.md),
/// [Decision 12](../../../../../docs/technical/decisions/012-shell-is-extensible-via-compile-time-modules.md)).
Future<void> runTom({List<TomModule> modules = const <TomModule>[]}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await _prepareWindow();
  runApp(tomApp(modules: modules));
}

/// The whole app as a widget, wired from [modules] and leaving out only the
/// window.
///
/// Separate from [runTom] so an end-to-end scenario can mount the app a
/// second time, which `runApp` would not do into a tree already there.
Widget tomApp({List<TomModule> modules = const <TomModule>[]}) {
  final List<TomModule> all = <TomModule>[const CoreModuleImpl(), ...modules];
  return ProviderScope(
    overrides: <Override>[
      panelRegistryProvider.overrideWithValue(PanelRegistry(all)),
      // The app's own wiring first, so a module's override of the same
      // provider wins: `ProviderScope` takes the last one.
      ...appOverrides,
      for (final TomModule module in all) ...module.overrides,
    ],
    child: const TomApp(),
  );
}

/// Whether the window has already been given its title and its size.
///
/// An end-to-end scenario calls `runTom` twice in one process, and preparing
/// the window again waits on a handshake that already happened.
bool _windowPrepared = false;

/// Gives the window a title and a minimum size.
///
/// Skipped where there is no window, because `window_manager` throws with
/// no platform channels, and skipped the second time ([_windowPrepared]).
Future<void> _prepareWindow() async {
  if (!_hasWindow || _windowPrepared) {
    return;
  }
  _windowPrepared = true;
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

/// The application widget, mountable by a test without a window.
class TomApp extends StatelessWidget {
  /// Creates the application.
  const TomApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'TOM',
    debugShowCheckedModeBanner: false,
    theme: tomTheme(Brightness.light),
    darkTheme: tomTheme(Brightness.dark),
    home: const _WindowContents(),
  );
}

/// Home, or the shell, depending on whether a space is open.
///
/// Not navigation — no route, no stack
/// ([Decision 6](../../../../../docs/technical/decisions/006-no-navigation-package.md));
/// the question goes to the session, not to Home
/// ([Decision 9](../../../../../docs/technical/decisions/009-space-session-is-single-source-of-truth.md)).
class _WindowContents extends ConsumerWidget {
  const _WindowContents();

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      // Whether, not what: the session changes whenever a document opens or
      // the mode moves, and neither swaps the window.
      ref.watch(
        spaceSessionProvider.select(
          (SpaceSessionState? session) => session == null,
        ),
      )
      ? const HomeScreen()
      : const TomShell();
}
