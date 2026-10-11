/// What stands between closing the window and losing an unsaved edit.
library;

import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:window_manager/window_manager.dart';

/// Whether this process has a real desktop window.
///
/// False under a widget test, where `window_manager` has no platform
/// channels and throws.
bool get hasDesktopWindow =>
    !const bool.fromEnvironment('dart.library.js_util') &&
    WidgetsBinding.instance.runtimeType.toString() !=
        'AutomatedTestWidgetsFlutterBinding';

/// Hears the window being closed and the app being quit, and hands both to
/// the leaving question (`docs/product/editor/tabs/doc.md`).
///
/// Two listeners because the platforms have two ways out: the window's own
/// close, which `window_manager` holds back, and the system asking the app
/// to exit — ⌘Q on macOS — which only the binding hears.
class WindowCloseGuardWidget extends ConsumerStatefulWidget {
  /// Guards the window [child] is drawn in.
  const WindowCloseGuardWidget({required this.child, super.key});

  /// The window's contents.
  final Widget child;

  @override
  ConsumerState<WindowCloseGuardWidget> createState() =>
      WindowCloseGuardState();
}

/// The guard's state, public so a test can raise the two requests no test
/// platform sends.
@visibleForTesting
class WindowCloseGuardState extends ConsumerState<WindowCloseGuardWidget>
    with WindowListener, WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (hasDesktopWindow) {
      windowManager.addListener(this);
      unawaited(_holdTheClose());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (hasDesktopWindow) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  /// Has the window ask before it closes, from now on.
  static Future<void> _holdTheClose() async {
    await windowManager.ensureInitialized();
    await windowManager.setPreventClose(true);
  }

  @override
  void onWindowClose() =>
      unawaited(ref.read(spaceMenuProvider.notifier).quit());

  @override
  Future<AppExitResponse> didRequestAppExit() async {
    // Nothing at risk — which is also what the window closing after the
    // question was answered looks like from here.
    if (!ref.read(editorProvider.notifier).hasUnsaved) {
      return AppExitResponse.exit;
    }
    onWindowClose();
    return AppExitResponse.cancel;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
