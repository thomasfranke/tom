/// The undo the buttons outside the pane reach.
library;

import 'package:flutter/material.dart';
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
  /// **Only if it is still ours.** A mode change disposes one pane and mounts
  /// another, and the order is not promised: a pane that cleared
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
    // away with a mode change and the button is still on screen.
    if (inside == null || !inside.mounted) {
      return;
    }
    Actions.maybeInvoke(inside, intent);
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
