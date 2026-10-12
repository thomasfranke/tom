/// The undo the buttons outside the pane reach.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:re_editor/re_editor.dart';

/// What `re_editor`'s own history can be asked, from outside the editor.
///
/// **The history is not ours.** `CodeEditor` wraps the controller we hand it
/// in a delegate of its own, so `undo()` on our controller says nothing about
/// ⌘Z; what does reach it is the intent the package's own shortcuts
/// dispatch. Invoking that intent needs a `BuildContext` **below** the
/// editor's `Actions`, and the only one handed over is the indicator
/// builder's — so the pane offers it here and the toolbar spends it.
///
/// One history, therefore: the button and the keystroke walk the same stack,
/// which a second stack of our own could not promise.
class EditorHistory extends ChangeNotifier {
  BuildContext? _inside;
  bool _gone = false;

  /// Whether a pane has offered a context to act through.
  bool get isReachable => _inside != null;

  @override
  void dispose() {
    _gone = true;
    super.dispose();
  }

  /// Takes [inside] as the context to invoke through.
  void offer(BuildContext inside) {
    if (identical(_inside, inside)) {
      return;
    }
    _inside = inside;
    notifyListeners();
  }

  /// Gives [inside] back, if it is still the one being used.
  ///
  /// **Only if it is still ours.** Another document disposes one pane and
  /// mounts another, and the order is not promised: a pane that cleared
  /// unconditionally would take away the context its successor had already
  /// offered.
  ///
  /// The pane gives it back a frame late, and the window closing disposes the
  /// shell — which owns this — first, so a history already gone answers
  /// nothing rather than throwing on the way out.
  void withdraw(BuildContext? inside) {
    if (_gone) {
      return;
    }
    if (inside != null && !identical(_inside, inside)) {
      return;
    }
    if (_inside == null) {
      return;
    }
    _inside = null;
    notifyListeners();
  }

  /// Takes the last edit back.
  void undo() => _invoke(const CodeShortcutUndoIntent());

  /// Puts it again.
  void redo() => _invoke(const CodeShortcutRedoIntent());

  void _invoke(Intent intent) {
    final BuildContext? inside = _inside;
    // Deactivated between the offer and the press is ordinary: the pane goes
    // away with its document and the button is still on screen.
    if (inside == null || !inside.mounted) {
      return;
    }
    Actions.maybeInvoke(inside, intent);
  }
}

/// ⌘Z and ⌘⇧Z (Ctrl+Z, Ctrl+Shift+Z, Ctrl+Y off macOS) while the source
/// pane is off screen: the buttons' history, reached by the keyboard.
///
/// Only while [isActive] — with the pane on screen it answers the keys
/// itself — and never from inside a text field, which keeps its own undo:
/// a disabled action lets the key go on up to the field's.
class EditorHistoryKeys extends StatelessWidget {
  /// Hears the keys over [child] while [isActive].
  const EditorHistoryKeys({
    required this.isActive,
    required this.child,
    super.key,
  });

  /// Whether the source pane is off screen, so nothing else answers.
  final bool isActive;

  /// What the keys are heard from.
  final Widget child;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('isActive', isActive));
  }

  static const _HistoryIntent _undo = _HistoryIntent(redo: false);
  static const _HistoryIntent _redo = _HistoryIntent(redo: true);

  @override
  Widget build(BuildContext context) => Shortcuts(
    shortcuts: defaultTargetPlatform == TargetPlatform.macOS
        ? const <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.keyZ, meta: true): _undo,
            SingleActivator(LogicalKeyboardKey.keyZ, meta: true, shift: true):
                _redo,
          }
        : const <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.keyZ, control: true): _undo,
            SingleActivator(
              LogicalKeyboardKey.keyZ,
              control: true,
              shift: true,
            ): _redo,
            SingleActivator(LogicalKeyboardKey.keyY, control: true): _redo,
          },
    child: Actions(
      actions: <Type, Action<Intent>>{
        _HistoryIntent: _HistoryAction(
          isActive: isActive,
          history: EditorHistoryScope.read(context),
        ),
      },
      child: child,
    ),
  );
}

class _HistoryIntent extends Intent {
  const _HistoryIntent({required bool redo}) : _isRedo = redo;

  final bool _isRedo;
}

class _HistoryAction extends Action<_HistoryIntent> {
  _HistoryAction({required this._isActive, required this._history});

  final bool _isActive;
  final EditorHistory? _history;

  @override
  bool isEnabled(_HistoryIntent intent) =>
      _isActive &&
      (_history?.isReachable ?? false) &&
      primaryFocus?.context?.findAncestorWidgetOfExactType<EditableText>() ==
          null;

  @override
  Object? invoke(_HistoryIntent intent) {
    intent._isRedo ? _history?.redo() : _history?.undo();
    return null;
  }
}

/// The history, where both the pane and the bar above it can find it.
class EditorHistoryScope extends InheritedNotifier<EditorHistory> {
  /// Puts [history] over [child].
  const EditorHistoryScope({
    required EditorHistory history,
    required super.child,
    super.key,
  }) : super(notifier: history);

  /// The history above [context], depending on it so a change rebuilds.
  static EditorHistory? of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<EditorHistoryScope>()
      ?.notifier;

  /// The same, without depending: for a widget that only offers to it.
  static EditorHistory? read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<EditorHistoryScope>()?.notifier;
}
