/// The entrypoint every build of the app goes through.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:tom_desktop/bootstrap/core_module.dart';
import 'package:tom_desktop/bootstrap/panel_registry.dart';
import 'package:tom_desktop/bootstrap/providers.dart';
import 'package:tom_desktop/bootstrap/tom_module.dart';
import 'package:tom_desktop/home/home_screen.dart';
import 'package:tom_desktop/shell/tom_shell.dart';
import 'package:tom_desktop/theme/tom_metrics.dart';
import 'package:tom_desktop/theme/tom_theme.dart';
import 'package:tom_presentation/tom_presentation.dart';
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
  WidgetsFlutterBinding.ensureInitialized();
  await _prepareWindow();
  runApp(tomApp(modules: modules));
}

/// The whole app as a widget, wired from [modules].
///
/// Separate from [runTom] so that something can *mount* the app rather than
/// start the process: an end-to-end scenario restarts it to prove the recent
/// list survived, and `runApp` called a second time does not replace a tree
/// that is already there.
///
/// What it leaves out is the window — a title and a minimum size, which has
/// no screen to assert about — and nothing else. The object graph, the
/// modules and the overrides are the ones the product runs with.
///
/// [CoreModule] is first, so a module's provider override wins over the
/// app's default: `ProviderScope` takes the last override for a provider,
/// and a module that could not replace a default would not be an extension
/// point.
Widget tomApp({List<TomModule> modules = const <TomModule>[]}) {
  final List<TomModule> all = <TomModule>[const CoreModule(), ...modules];
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
/// `runTom` is called more than once in a process by exactly one caller:
/// an end-to-end scenario that restarts the app to prove something survived
/// — the recent list, for instance. Preparing the window a second time
/// leaves the app waiting on a handshake that already happened, and what a
/// scenario sees is the previous screen never going away.
bool _windowPrepared = false;

/// Gives the window a title and a size the layout holds together in.
///
/// Skipped where there is no window — a widget test runs the app with no
/// platform channels, and `window_manager` would throw into a test that is
/// about panels — and skipped the second time, for the reason above.
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
    home: const _WindowContents(),
  );
}

/// Home, or the shell, depending on whether a space is open.
///
/// **Not navigation.** There is no route and no stack: with a space open the
/// window *is* the shell, and without one it is Home ([Decision
/// 6](../../../../../docs/technical/decisions/006-no-navigation-package.md)
/// keeps `Navigator` for dialogs). Which of the two is showing is a fact
/// about the session, so it is read from the state rather than pushed onto
/// anything.
class _WindowContents extends ConsumerWidget {
  const _WindowContents();

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ref.watch(homeProvider) is HomeOpened
      ? const TomShell()
      : const HomeScreen();
}
