/// Everything a scenario can do to the app, and everything it can see.
library;

import 'dart:io' show Directory, File, Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_editor/re_editor.dart';
import 'package:tom_desktop/bootstrap/run_tom.dart';
import 'package:tom_desktop/bootstrap/tom_module.dart';
import 'package:tom_desktop/screens/about/about_dialog_widget.dart';
import 'package:tom_desktop/screens/account/account_control_widget.dart';
import 'package:tom_desktop/screens/account/widgets/account_access_widget.dart';
import 'package:tom_desktop/screens/account/widgets/account_popover_widget.dart';
import 'package:tom_desktop/screens/account/widgets/account_select_widget.dart';
import 'package:tom_desktop/screens/branches/branches_control_widget.dart';
import 'package:tom_desktop/screens/branches/widgets/branches_popover_widget.dart';
import 'package:tom_desktop/screens/changes/changes_panel.dart';
import 'package:tom_desktop/screens/changes/widgets/changes_count_widget.dart';
import 'package:tom_desktop/screens/changes/widgets/changes_remote_widget.dart';
import 'package:tom_desktop/screens/changes/widgets/changes_row_widget.dart';
import 'package:tom_desktop/screens/commands/commands_panel.dart';
import 'package:tom_desktop/screens/commands/widgets/command_row_widget.dart';
import 'package:tom_desktop/screens/compare/compare_control_widget.dart';
import 'package:tom_desktop/screens/editor/editor_panel.dart';
import 'package:tom_desktop/screens/editor/editor_tabs_widget.dart';
import 'package:tom_desktop/screens/editor/widgets/editor_completion_widget.dart';
import 'package:tom_desktop/screens/editor/widgets/editor_lens_widget.dart';
import 'package:tom_desktop/screens/editor/widgets/editor_marks_widget.dart';
import 'package:tom_desktop/screens/file_tree/file_tree_panel.dart';
import 'package:tom_desktop/screens/file_tree/widgets/file_tree_body_widget.dart';
import 'package:tom_desktop/screens/file_tree/widgets/file_tree_draft_widget.dart';
import 'package:tom_desktop/screens/file_tree/widgets/file_tree_row_widget.dart';
import 'package:tom_desktop/screens/history/history_panel.dart';
import 'package:tom_desktop/screens/home/widgets/home_clone_widget.dart';
import 'package:tom_desktop/screens/preferences/preferences_control_widget.dart';
import 'package:tom_desktop/screens/preferences/widgets/preferences_popover_widget.dart';
import 'package:tom_desktop/screens/preview/preview_panel.dart';
import 'package:tom_desktop/screens/preview/widgets/preview_footnotes_widget.dart';
import 'package:tom_desktop/screens/preview/widgets/preview_wikilink_widget.dart';
import 'package:tom_desktop/screens/pull_request/pull_request_panel.dart';
import 'package:tom_desktop/screens/pull_request/pull_request_row_widget.dart';
import 'package:tom_desktop/screens/pull_request/pull_request_status_row_widget.dart';
import 'package:tom_desktop/screens/pull_request/widgets/pull_request_base_widget.dart';
import 'package:tom_desktop/screens/search/search_boxes.dart';
import 'package:tom_desktop/screens/search/search_design.dart';
import 'package:tom_desktop/screens/search/search_field_widget.dart';
import 'package:tom_desktop/screens/search/search_occurrences_panel.dart';
import 'package:tom_desktop/screens/search/search_results_panel.dart';
import 'package:tom_desktop/screens/shell/document_scroll_link.dart';
import 'package:tom_desktop/screens/shell/status_panel.dart';
import 'package:tom_desktop/screens/shell/widgets/shell_mode_control_widget.dart';
import 'package:tom_desktop/screens/spaces/space_menu_control_widget.dart';
import 'package:tom_desktop/screens/spaces/widgets/space_menu_popover_widget.dart';
import 'package:tom_desktop/screens/spaces/widgets/space_menu_row_widget.dart';
import 'package:tom_desktop/screens/workspace/workspace_bottom_head_widget.dart';
import 'package:tom_desktop/screens/workspace/workspace_grip_widget.dart';
import 'package:tom_desktop/widgets/file_state_mark_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';
import 'package:window_manager/window_manager.dart';
import 'package:xterm/xterm.dart' show Terminal, TerminalView;
import 'e2e_module_impl.dart';
import 'evidence.dart';

/// Drives the assembled app through what is on screen.
///
/// Every tap, wait and assertion lives here so a scenario is only a list of
/// steps. It never reads a provider or a repository: a harness that read the
/// state would go green on a screen that never updated.
final class TomRobot {
  /// Wraps [tester], storing this scenario's preferences at [settingsPath].
  TomRobot(this.tester, {required this.settingsPath, required this.evidence});

  /// The harness driving the widget tree.
  final WidgetTester tester;

  /// What photographs the window: the scenario takes a frame between steps
  /// (`scenario.dart`), never inside one.
  final Evidence evidence;

  /// How long to hold the screen on each thing just done; zero unless
  /// `tom e2e <name> --watch` passed the define, since a run at full speed
  /// is unwatchable.
  ///
  /// Parsed rather than `int.fromEnvironment`: the define is absent in every
  /// ordinary run, and a zero the analyzer can fold sets two lints arguing.
  static Duration get hold => Duration(
    milliseconds:
        int.tryParse(const String.fromEnvironment('TOM_E2E_HOLD_MS')) ?? 0,
  );

  /// Where this scenario's preferences live.
  ///
  /// Cleared before the first step and kept across a relaunch, so a restart
  /// remembers and the next scenario does not.
  final String settingsPath;

  /// Starts the app — the real modules and object graph — with the folder
  /// dialog answering [pickFolder], on a machine with the run's own `gh`
  /// when [withGh].
  ///
  /// Mounted rather than started, because a scenario relaunches to prove
  /// something survived a restart and `runApp` a second time does not
  /// replace a tree already there. The window's title and size are left out.
  Future<void> launch({
    String? pickFolder,
    bool withGh = false,
    Uri? releasesAt,
    String? gitExecutable,
  }) async {
    // Unmounted first: Flutter updates an element in place when the widget's
    // type matches, so a second `ProviderScope` would keep the first one's
    // container and every provider's state with it.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    // Home's trunk animates forever and `pumpAndSettle` would never settle;
    // the platform's own no-animations switch is the product's path to a
    // still screen.
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    // English whatever the machine speaks: every finder here is written in
    // the template's words, and `System` would follow the developer's locale.
    tester.platformDispatcher.localesTestValue = const <Locale>[
      Locale('en', 'US'),
    ];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    // The theme a measurement asks for (`TOM_E2E_THEME`, light or dark);
    // without it the app follows the machine, as before.
    const String theme = String.fromEnvironment('TOM_E2E_THEME');
    if (theme == 'light' || theme == 'dark') {
      tester.platformDispatcher.platformBrightnessTestValue = theme == 'light'
          ? Brightness.light
          : Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    }
    await tester.pumpWidget(
      tomApp(
        modules: <TomModule>[
          E2eModuleImpl(
            folder: pickFolder,
            settingsPath: settingsPath,
            withGh: withGh,
            releasesAt: releasesAt,
            gitExecutable: gitExecutable,
          ),
        ],
      ),
    );
    await settle();
  }

  /// The window a run is given, or the one the boards are drawn in.
  ///
  /// `tom e2e <name> --board` passes the board's own 1440 by 900, so a
  /// screenshot and a board crop to the same rectangle — scaling either to
  /// match the other would make every measurement a measurement of the
  /// scaling.
  static Size? get boardWindow {
    const String given = String.fromEnvironment('TOM_E2E_WINDOW');
    final List<String> parts = given.split('x');
    if (parts.length != 2) {
      return null;
    }
    final double? width = double.tryParse(parts.first);
    final double? height = double.tryParse(parts.last);
    return width == null || height == null ? null : Size(width, height);
  }

  /// Starts the app sized for a desktop window; the default test surface is
  /// narrower than a phone and overflows the shell.
  Future<void> launchWindowed({
    String? pickFolder,
    Size size = const Size(1280, 840),
    bool withGh = false,
    Uri? releasesAt,
    String? gitExecutable,
  }) async {
    tester.view
      ..physicalSize = boardWindow ?? size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await launch(
      pickFolder: pickFolder,
      withGh: withGh,
      releasesAt: releasesAt,
      gitExecutable: gitExecutable,
    );
    await _showTheWindow();
  }

  /// Brings the window forward, only for a run somebody is watching.
  ///
  /// A window not on the active Space is not painted, and mounting the app
  /// rather than calling `runTom()` leaves the window to nobody.
  Future<void> _showTheWindow() async {
    if (hold <= Duration.zero) {
      return;
    }
    await windowManager.ensureInitialized();
    await windowManager.show();
    await windowManager.focus();
    await settle();
  }

  /// Waits until the app stops animating.
  ///
  /// Bounded, because the default is ten minutes and an animation that never
  /// ends would hang the run rather than fail the step.
  Future<void> settle() async {
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 15),
    );
    if (hold > Duration.zero) {
      await tester.binding.delayed(hold);
    }
  }

  /// Pumps until [ready] holds, and gives up quietly when it does not.
  ///
  /// Settling is not waiting: `pumpAndSettle` returns as soon as no frame is
  /// scheduled, and git running in another process is not a frame. Giving
  /// up lets the assertion after it fail with what was on screen rather than
  /// with a timeout.
  Future<void> _waitUntil(
    bool Function() ready, {
    Duration limit = const Duration(seconds: 10),
  }) async {
    final Stopwatch clock = Stopwatch()..start();
    while (!ready() && clock.elapsed < limit) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  /// Whether [finder] currently matches anything.
  bool _showing(Finder finder) => finder.evaluate().isNotEmpty;

  // ── What the user does ────────────────────────────────────────────────

  /// Presses *Choose folder…* on Home; what the dialog answers was decided
  /// at [launch].
  Future<void> chooseFolder() async {
    await tapText('Choose folder…');
  }

  /// Presses *Choose another folder…* on the refusal screen.
  Future<void> chooseAnotherFolder() async {
    await tapText('Choose another folder…');
  }

  /// Opens a space from the recent list, by the name it shows.
  Future<void> openRecent(String name) async {
    await tapText(name);
  }

  /// Drops a space from the recent list, by the name of its row.
  ///
  /// By name and tooltip rather than position, so a list that reordered
  /// cannot forget the wrong space and pass. The pointer goes over the row
  /// first: the ✕ is on the hovered row only.
  Future<void> forgetRecent(String name) async {
    final Finder row = find.ancestor(
      of: find.text(name),
      matching: find.byType(Row),
    );
    final Finder forget = find.descendant(
      of: row.last,
      matching: find.byTooltip(_forget),
    );
    expect(
      _isForgetDrawn(forget),
      isFalse,
      reason: 'the ✕ is drawn on a row the pointer is not over',
    );
    final TestGesture mouse = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
    );
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.text(name)));
    await settle();
    expect(
      _isForgetDrawn(forget),
      isTrue,
      reason: 'the ✕ is not drawn under the pointer',
    );
    await tester.tap(forget);
    await mouse.removePointer();
    await settle();
  }

  /// Whether the ✕ [forget] finds is drawn rather than only keeping its room.
  bool _isForgetDrawn(Finder forget) => tester
      .widget<Visibility>(
        find.ancestor(of: forget, matching: find.byType(Visibility)).first,
      )
      .visible;

  /// Taps whatever shows [label], and lets the app settle.
  Future<void> tapText(String label) async {
    await tester.tap(find.text(label));
    await settle();
  }

  /// Taps [label] inside the dialog on screen, and lets the app settle.
  ///
  /// Scoped rather than found on the whole screen, because a dialog's answer
  /// is often the same words as the control that opened it — `Abort the pull`
  /// is both the band's action and the confirmation's.
  Future<void> tapInTheDialog(String label) async {
    await tester.tap(
      find.descendant(
        of: find.byType(TomDialogWidget),
        matching: find.text(label),
      ),
    );
    await settle();
  }

  /// Chooses a mode on the bar above the document area by its label —
  /// `Source`, `Split`, `Preview`.
  Future<void> looksAt(String mode) async {
    await tapText(mode);
  }

  /// Replaces what the source pane holds with [source].
  ///
  /// The one place this file touches a widget rather than the screen: a code
  /// editor has no `enterText`, so this drives the controller of the editor
  /// on screen.
  Future<void> typesInTheSource(String source) async {
    tester.widget<CodeEditor>(find.byType(CodeEditor)).controller!.text =
        source;
    await settle();
  }

  /// Drags the source pane up by [by] points, as a reader scrolls it.
  Future<void> scrollsTheSourceBy(double by) async {
    await tester.drag(find.byType(CodeEditor).first, Offset(0, -by));
    await settle();
  }

  /// Drags the preview up by [by] points; negative drags it back down.
  Future<void> scrollsThePreviewBy(double by) async {
    await tester.drag(find.byType(PreviewPanel), Offset(0, -by));
    await settle();
  }

  /// The zero-based line at the top of the source pane, which the link
  /// between the two panes reports; -1 while nothing is laid out.
  double theLineAtTheTopOfTheSource() =>
      ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp).first),
      ).read(documentScrollLinkProvider).sourceLine ??
      -1;

  /// Presses the name on the changes row that shows [name], which opens the
  /// document with the diff on.
  Future<void> opensTheChange(String name) async {
    await _waitUntil(() => _showing(_inTheChanges(name)));
    await tester.tap(_inTheChanges(name));
    await settle();
  }

  /// Presses the ↶ at the end of the changes row that shows [name], which
  /// asks before putting the file back.
  Future<void> discardsTheChange(String name) async {
    await _waitUntil(() => _showing(_inTheChanges(name)));
    await tester.tap(
      find.descendant(
        of: find.ancestor(
          of: _inTheChanges(name),
          matching: find.byType(ChangesRowWidget),
        ),
        matching: find.byWidgetPredicate(
          (Widget widget) =>
              widget is TomGlyphWidget && widget.glyph == TomGlyphEnum.discard,
        ),
      ),
    );
    await settle();
  }

  /// Ticks the changes row that shows [name], staging it.
  ///
  /// Scoped to the row, because the caption's own checkbox — *All* — would
  /// stage everything.
  Future<void> stages(String name) async {
    await _waitUntil(() => _showing(_inTheChanges(name)));
    Finder box() => find.descendant(
      of: find.ancestor(
        of: _inTheChanges(name),
        matching: find.byType(ChangesRowWidget),
      ),
      matching: find.byType(TomCheckWidget),
    );
    await tester.tap(box());
    // Waited for, not settled: staging runs git and re-reads it, and nothing
    // animates meanwhile.
    await _waitUntil(
      () => _showing(box()) && tester.widget<TomCheckWidget>(box()).isChecked,
    );
    await settle();
  }

  /// Ticks the changes row that shows [name] and waits for nothing: what a
  /// refused staging needs, since its box never comes back ticked.
  Future<void> triesToStage(String name) async {
    await _waitUntil(() => _showing(_inTheChanges(name)));
    await tester.tap(
      find.descendant(
        of: find.ancestor(
          of: _inTheChanges(name),
          matching: find.byType(ChangesRowWidget),
        ),
        matching: find.byType(TomCheckWidget),
      ),
    );
    await settle();
  }

  /// Asserts the git column is saying [sentence] — why it refused.
  Future<void> seesTheGitColumnSaying(String sentence) async {
    final Finder said = find.descendant(
      of: find.byType(ChangesPanel),
      matching: find.text(sentence),
    );
    await _waitUntil(() => _showing(said));
    expect(said, findsOneWidget, reason: 'the git column does not say it');
  }

  /// Presses *Fetch* and waits for the button to come back, which is git
  /// having answered.
  Future<void> fetches() => _remoteAction('Fetch');

  /// Presses *Push*.
  Future<void> pushes() => _remoteAction('Push');

  /// Presses *Pull*, which is a button of its own at the foot of the column
  /// and not only the way out of a refusal.
  Future<void> pulls() => _remoteAction('Pull');

  /// Presses the remote action whose label starts with [label], and waits for
  /// it to finish.
  ///
  /// Scoped to the three at the foot of the git column, and matched on the
  /// verb rather than the whole label: the counts live *inside* the buttons,
  /// so `Push` reads `Push (2)` whenever there is anything to publish.
  Future<void> _remoteAction(String label) async {
    Finder button() => find.descendant(
      of: find.byType(ChangesRemoteWidget),
      matching: find.textContaining(label),
    );
    await _waitUntil(() => _showing(button()));
    await tester.tap(button());
    // The pressed one reads `Pushing…` while it runs, and `Pushing` contains
    // `Push`: what says the action finished is the ellipsis leaving, not the
    // verb coming back.
    await _waitUntil(() => _showing(button()) && !_showing(_working));
    await settle();
  }

  /// Asserts `Push`, `Fetch` and `Pull` are all unavailable, and that the
  /// commit box is still there — a broken link never takes committing away.
  Future<void> seesTheRemoteActionsUnavailable() async {
    bool isLive(String verb) =>
        tester
            .widget<ButtonStyleButton>(
              find.ancestor(
                of: find.descendant(
                  of: find.byType(ChangesRemoteWidget),
                  matching: find.textContaining(verb),
                ),
                matching: find.byWidgetPredicate(
                  (Widget widget) => widget is ButtonStyleButton,
                ),
              ),
            )
            .onPressed !=
        null;
    await _waitUntil(() => !isLive('Fetch'));
    for (final String verb in <String>['Push', 'Fetch', 'Pull']) {
      expect(isLive(verb), isFalse, reason: '$verb is still available');
    }
    expect(_anyField, findsOneWidget, reason: 'the commit box went away');
  }

  /// Any of the three saying it is the one in flight.
  Finder get _working => find.descendant(
    of: find.byType(ChangesRemoteWidget),
    matching: find.textContaining('…'),
  );

  /// Presses *Stage all* at the head of the unstaged section, and waits for
  /// that section to go.
  Future<void> stagesEverything() async {
    final Finder all = find.text('Stage all');
    await _waitUntil(() => _showing(all));
    await tester.tap(all);
    await _waitUntil(() => !_showing(all));
    await settle();
  }

  /// Asserts *Commit* cannot be pressed: unavailable rather than absent, and
  /// refused before the attempt.
  Future<void> seesCommitUnavailable() async {
    // Anchored on the word rather than on the type: `Push` at the foot of the
    // same column is filled too, and the panel now holds two.
    final Finder button = find.ancestor(
      of: find.textContaining('Commit'),
      matching: find.byType(FilledButton),
    );
    await _waitUntil(() => _showing(button));
    expect(
      tester.widget<FilledButton>(button).onPressed,
      isNull,
      reason: 'Commit is available with nothing staged or nothing written',
    );
  }

  /// Types [message] into the commit box.
  Future<void> describesTheCommit(String message) async {
    await tester.enterText(
      find.descendant(of: find.byType(ChangesPanel), matching: _anyField),
      message,
    );
    // Pumped, not settled: the summary has the keyboard, and its caret
    // blinks for as long as the window is in front.
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Presses *Commit*.
  ///
  /// Checked before it is pressed, because a disabled button swallows a tap
  /// without a word.
  Future<void> commits() async {
    final Finder button = find.ancestor(
      of: find.textContaining('Commit'),
      matching: find.byType(FilledButton),
    );
    expect(
      tester.widget<FilledButton>(button).onPressed,
      isNotNull,
      reason: 'Commit is disabled — is anything staged, and described?',
    );
    await tester.tap(button);
    // The box emptying says the commit landed and the status was re-read;
    // git is another process, so settling says nothing.
    await _waitUntil(
      () => tester.widget<TextField>(_anyField).controller!.text.isEmpty,
    );
    await settle();
  }

  /// Presses the platform's own save shortcut; the tap gives the editor the
  /// focus first.
  Future<void> saves() async {
    await tester.tap(find.byType(CodeEditor));
    await tester.pump(const Duration(milliseconds: 200));
    final LogicalKeyboardKey modifier = Platform.isMacOS
        ? LogicalKeyboardKey.meta
        : LogicalKeyboardKey.control;
    await tester.sendKeyDownEvent(modifier);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
    await tester.sendKeyUpEvent(modifier);
    await settle();
  }

  /// Presses the platform's own undo shortcut, in the editor.
  ///
  /// The editor's own, not a control of ours: a replacement is written into
  /// the buffer the way a keystroke is, so it walks back like any other edit
  /// (`docs/product/search/replacing/doc.md`).
  Future<void> undoes() async {
    await tester.tap(find.byType(CodeEditor));
    await tester.pump(const Duration(milliseconds: 200));
    final LogicalKeyboardKey modifier = Platform.isMacOS
        ? LogicalKeyboardKey.meta
        : LogicalKeyboardKey.control;
    await tester.sendKeyDownEvent(modifier);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
    await tester.sendKeyUpEvent(modifier);
    // Pumped, not settled: the editor blinks a caret once it has had the
    // keyboard, and `pumpAndSettle` waits on an animation that never ends.
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Presses ⌘Z (Ctrl+Z off macOS) where the keyboard already is — in
  /// preview, where no source pane can be clicked into first.
  Future<void> undoesFromTheKeyboard() => _historyKey(redo: false);

  /// Presses ⌘⇧Z (Ctrl+Shift+Z off macOS) the same way.
  Future<void> redoesFromTheKeyboard() => _historyKey(redo: true);

  Future<void> _historyKey({required bool redo}) async {
    final LogicalKeyboardKey modifier = Platform.isMacOS
        ? LogicalKeyboardKey.meta
        : LogicalKeyboardKey.control;
    await tester.sendKeyDownEvent(modifier);
    if (redo) {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
    }
    await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
    if (redo) {
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
    }
    await tester.sendKeyUpEvent(modifier);
    await settle();
  }

  /// Clicks the row of the file tree that shows [name], scoped to the
  /// explorer because the top bar names the space's folder too.
  Future<void> clickInTheTree(String name) async {
    // Waited for here rather than in each scenario: the shell is on screen
    // before the folder walk has answered.
    await _waitUntil(() => _showing(_inTheTree(name)));
    await tester.tap(_inTheTree(name));
    await settle();
  }

  /// Presses the explorer's `+` and names the document [name], pressing
  /// Enter — accepted or refused, which the caller asserts.
  Future<void> createsADocument(String name) async {
    await _waitUntil(() => _showing(find.byTooltip('New document')));
    await tester.tap(find.byTooltip('New document'));
    // Pumped, not settled: the field takes the keyboard, and its caret
    // blinks for as long as it has it.
    await tester.pump(const Duration(milliseconds: 300));
    final Finder field = find.descendant(
      of: find.byType(FileTreeDraftWidget),
      matching: find.byType(TextField),
    );
    await _waitUntil(() => _showing(field));
    await tester.enterText(field, name);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Asserts the tab strip holds [names], left to right.
  Future<void> seesTheTabs(List<String> names) async {
    // The plain text, because a deleted file's tab is one `Text.rich`.
    List<String> shown() => <String>[
      for (final Text text in tester.widgetList<Text>(
        find.descendant(
          of: find.byType(EditorTabsWidget),
          matching: find.byType(Text),
        ),
      ))
        text.data ?? text.textSpan?.toPlainText() ?? '',
    ];
    await _waitUntil(() => listEquals(shown(), names));
    expect(shown(), names, reason: 'the tabs are ${shown()}');
  }

  /// Asserts the tab named [name] is in preview — italic — or kept.
  void seesTheTabInPreview(String name, {bool inPreview = true}) {
    final Text text = tester.widget<Text>(
      find.descendant(
        of: find.byType(EditorTabsWidget),
        matching: find.text(name),
      ),
    );
    expect(
      text.style?.fontStyle == FontStyle.italic,
      inPreview,
      reason: '$name is ${inPreview ? 'not' : ''} in preview',
    );
  }

  /// Chooses the tab named [name].
  Future<void> choosesTheTab(String name) async {
    await tester.tap(
      find.descendant(
        of: find.byType(EditorTabsWidget),
        matching: find.text(name),
      ),
    );
    await settle();
  }

  /// Presses ⌘K (Ctrl+K off macOS), which puts the keyboard in the search.
  Future<void> pressesTheSearchShortcut() async {
    final LogicalKeyboardKey modifier = Platform.isMacOS
        ? LogicalKeyboardKey.metaLeft
        : LogicalKeyboardKey.controlLeft;
    await tester.sendKeyDownEvent(modifier);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(modifier);
    // Pumped, not settled: the box takes the keyboard, and a caret blinks.
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Asserts the search box has the keyboard.
  Future<void> seesTheSearchFocused() async {
    bool focused() =>
        _showing(_theSearchField) &&
        (tester.widget<TextField>(_theSearchField).focusNode?.hasFocus ??
            false);
    await _waitUntil(focused);
    expect(
      focused(),
      isTrue,
      reason: 'the search box does not have the keyboard',
    );
  }

  /// Presses ⌘W (Ctrl+W off macOS), which closes the tab on screen.
  Future<void> closesTheTabFromTheKeyboard() async {
    final LogicalKeyboardKey modifier = Platform.isMacOS
        ? LogicalKeyboardKey.metaLeft
        : LogicalKeyboardKey.controlLeft;
    await tester.sendKeyDownEvent(modifier);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyW);
    await tester.sendKeyUpEvent(modifier);
    await settle();
  }

  /// Presses ⌘J (Ctrl+J off macOS), which opens the panel under the document
  /// or puts it away.
  Future<void> pressesTheCommandsShortcut() async {
    final LogicalKeyboardKey modifier = Platform.isMacOS
        ? LogicalKeyboardKey.metaLeft
        : LogicalKeyboardKey.controlLeft;
    await tester.sendKeyDownEvent(modifier);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyJ);
    await tester.sendKeyUpEvent(modifier);
    await settle();
  }

  /// A row of the commands panel whose command line holds [fragment] — the
  /// last one, since the newest is at the bottom.
  Finder _commandRow(String fragment) => find
      .ancestor(
        of: find.descendant(
          of: find.byType(CommandsPanel),
          matching: find.textContaining(fragment),
        ),
        matching: find.byType(CommandRowWidget),
      )
      .last;

  /// Asserts the commands panel is open and lists a command holding each of
  /// [fragments].
  Future<void> seesTheCommands(List<String> fragments) async {
    await _waitUntil(() => _showing(find.byType(CommandsPanel)));
    expect(
      find.byType(CommandsPanel),
      findsOneWidget,
      reason: 'the commands panel is not open',
    );
    for (final String fragment in fragments) {
      await _waitUntil(
        () => _showing(
          find.descendant(
            of: find.byType(CommandsPanel),
            matching: find.textContaining(fragment),
          ),
        ),
      );
      expect(
        find.descendant(
          of: find.byType(CommandsPanel),
          matching: find.textContaining(fragment),
        ),
        findsWidgets,
        reason: 'no command holding "$fragment" was listed',
      );
    }
  }

  /// How many commands this run has written down whose line holds
  /// [fragment], whether or not the panel is open.
  int commandsRun(String fragment) =>
      ProviderScope.containerOf(tester.element(find.byType(MaterialApp).first))
          .read(commandsProvider)
          .rows
          .where((CommandRow row) => row.record.commandLine.contains(fragment))
          .length;

  /// Asserts that none of the git commands this run has written down
  /// failed — the Commands panel draws no red git row.
  ///
  /// Git only; [seesNoFailedCommand] is every program.
  void seesNoFailedGitCommand() {
    final ProviderContainer container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp).first),
    );
    final List<String> failed = container
        .read(commandsProvider)
        .rows
        .where(
          (CommandRow row) =>
              row.record.failed && row.record.executable == 'git',
        )
        .map((CommandRow row) => row.record.commandLine)
        .toList();
    expect(failed, isEmpty, reason: 'these git commands drew a failed row');
  }

  /// Asserts that none of the commands this run has written down failed,
  /// whichever program — the account probes of a machine with no GitHub
  /// sign-in are answers, so the Commands panel draws no red row at all.
  void seesNoFailedCommand() {
    final ProviderContainer container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp).first),
    );
    final List<String> failed = container
        .read(commandsProvider)
        .rows
        .where((CommandRow row) => row.record.failed)
        .map((CommandRow row) => row.record.commandLine)
        .toList();
    expect(failed, isEmpty, reason: 'these commands drew a failed row');
  }

  /// Presses the last row whose command holds [fragment], which opens it
  /// onto what the command printed.
  Future<void> opensTheCommand(String fragment) async {
    // The list is anchored at its newest row, so an early one can be
    // scrolled out of the panel.
    await tester.ensureVisible(_commandRow(fragment));
    await settle();
    await tester.tap(_commandRow(fragment));
    await settle();
  }

  /// Asserts the last row whose command holds [fragment] is open, showing
  /// what it printed — [printed] among it, when given.
  Future<void> seesTheCommandOpen(String fragment, {String? printed}) async {
    final Finder output = find.descendant(
      of: _commandRow(fragment),
      matching: find.byType(SelectableText),
    );
    await _waitUntil(() => _showing(output));
    expect(output, findsOneWidget, reason: '"$fragment" is not open');
    if (printed != null) {
      final String shown = tester.widget<SelectableText>(output).data ?? '';
      expect(shown, contains(printed), reason: 'it printed "$shown"');
    }
  }

  /// Presses the `×` at the right of the panel's tabs.
  Future<void> closesTheCommands() async {
    await tester.tap(find.byTooltip('Close the panel'));
    await settle();
    seesTheCommandsClosed();
  }

  /// Asserts the panel under the document is not on screen.
  void seesTheCommandsClosed() => expect(
    find.byType(CommandsPanel),
    findsNothing,
    reason: 'the commands panel is still open',
  );

  /// Presses the tab called [title] at the head of the panel under the
  /// document.
  Future<void> choosesTheBottomTab(String title) async {
    await tester.tap(
      find.descendant(
        of: find.byType(WorkspaceBottomHeadWidget),
        matching: find.text(title),
      ),
    );
    await settle();
  }

  /// What the terminal's screen holds, scrollback included, one line each.
  String _terminalText() {
    final Finder view = find.byType(TerminalView);
    if (!_showing(view)) {
      return '';
    }
    final Terminal terminal = tester.widget<TerminalView>(view).terminal;
    return <String>[
      for (int i = 0; i < terminal.buffer.lines.length; i++)
        terminal.buffer.lines[i].toString().trimRight(),
    ].join('\n');
  }

  /// Asserts the terminal is showing and its shell has answered: the head
  /// names it, `<shell> · <folder>`, with [folder] at the folder's end.
  ///
  /// Long, because this is the person's own shell with their own profile,
  /// and a profile can take seconds to read.
  Future<void> seesTheTerminalRunning({required String folder}) async {
    final Finder place = find.descendant(
      of: find.byType(WorkspaceBottomHeadWidget),
      matching: find.textContaining(' · '),
    );
    await _waitUntil(() => _showing(place), limit: const Duration(seconds: 30));
    expect(
      find.textContaining('would not start'),
      findsNothing,
      reason: 'the first drawing is a refusal, not a prompt',
    );
    expect(place, findsOneWidget, reason: 'no shell answered');
    final String said = tester.widget<Text>(place).data ?? '';
    expect(said, endsWith(folder), reason: 'the head says "$said"');
    // The prompt is drawn once the profile is read; typing before it would
    // land in a shell still starting.
    await _waitUntil(
      () => _terminalText().trim().isNotEmpty,
      limit: const Duration(seconds: 30),
    );
  }

  /// Clicks the terminal, types [line] into it, and presses Return.
  Future<void> runsInTheTerminal(String line) async {
    await tester.tap(find.byType(TerminalView));
    // Past the emulator's double-tap window, which is a timer.
    await tester.pump(const Duration(milliseconds: 500));
    tester.testTextInput.enterText(line);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await settle();
  }

  /// Asserts the terminal's screen shows [text], waiting for the shell.
  Future<void> seesInTheTerminal(String text) async {
    await _waitUntil(
      () => _terminalText().contains(text),
      limit: const Duration(seconds: 20),
    );
    expect(
      _terminalText(),
      contains(text),
      reason: 'the terminal shows:\n${_terminalText()}',
    );
  }

  /// Asserts no cell on the terminal's screen is underlined: what a program
  /// negotiates with `CSI > 4 m` is not text decoration.
  void seesNothingUnderlinedInTheTerminal() {
    final Terminal terminal = tester
        .widget<TerminalView>(find.byType(TerminalView))
        .terminal;
    int underlined = 0;
    for (int row = 0; row < terminal.buffer.lines.length; row++) {
      for (int col = 0; col < terminal.viewWidth; col++) {
        if (terminal.buffer.lines[row].getAttributes(col) & 8 != 0) {
          underlined++;
        }
      }
    }
    expect(underlined, 0, reason: 'cells underlined:\n${_terminalText()}');
  }

  /// Asserts the commands panel lists no command reading exactly [line] —
  /// what is typed into the terminal is not what TOM ran.
  void seesNoCommandReading(String line) => expect(
    find.descendant(of: find.byType(CommandsPanel), matching: find.text(line)),
    findsNothing,
    reason: '"$line" was written into the commands',
  );

  /// Presses the pill reading [label] on the band above the document —
  /// `Keep mine` or `Reload` over a file that changed on disk.
  ///
  /// Scoped to the band, because the menus carry a `Reload` of their own.
  Future<void> answersTheBand(String label) async {
    final Finder pill = find.descendant(
      of: find.byType(NoticeBandWidget),
      matching: find.text(label),
    );
    await _waitUntil(() => _showing(pill));
    await tester.tap(pill);
    await settle();
  }

  /// Asserts no band is above the document.
  Future<void> seesNoBand() async {
    await _waitUntil(() => !_showing(find.byType(NoticeBandWidget)));
    expect(find.byType(NoticeBandWidget), findsNothing);
  }

  /// Asserts the band above the document offers each of [labels].
  Future<void> seesInTheBand(List<String> labels) async {
    for (final String label in labels) {
      final Finder pill = find.descendant(
        of: find.byType(NoticeBandWidget),
        matching: find.text(label),
      );
      await _waitUntil(() => _showing(pill));
      expect(pill, findsOneWidget, reason: 'the band does not offer $label');
    }
  }

  /// Asserts the band above the document does not offer [label].
  Future<void> seesNotInTheBand(String label) async {
    expect(
      find.descendant(
        of: find.byType(NoticeBandWidget),
        matching: find.text(label),
      ),
      findsNothing,
      reason: 'the band offers $label',
    );
  }

  /// Whether the band above the document offers [label] right now.
  bool bandOffers(String label) => _showing(
    find.descendant(
      of: find.byType(NoticeBandWidget),
      matching: find.text(label),
    ),
  );

  /// Presses the pill called [label] inside the band above the document, and
  /// waits for whatever it ran to finish.
  Future<void> pressesInTheBand(String label) async {
    final Finder pill = find.descendant(
      of: find.byType(NoticeBandWidget),
      matching: find.text(label),
    );
    await _waitUntil(() => _showing(pill));
    await tester.tap(pill);
    await _waitUntil(() => !_showing(_working));
    await settle();
  }

  /// Presses `Show the command` on the band a failure raised.
  Future<void> showsTheCommandFromTheBand() async {
    final Finder action = find.descendant(
      of: find.byType(NoticeBandWidget),
      matching: find.text('Show the command'),
    );
    await _waitUntil(() => _showing(action));
    await tester.tap(action);
    await settle();
  }

  /// Presses the `Pull request` row at the top of the tree.
  ///
  /// Scoped to the row, because once the page is up the right column has a
  /// tab by the same name.
  ///
  /// Pressed again until the page is up: the row is drawn, muted, while git
  /// is still being read, and a press then opens nothing — which a machine
  /// whose `gh` is also being asked reaches more often than not.
  Future<void> opensThePullRequest() async {
    final Finder row = find.descendant(
      of: find.byType(PullRequestRowWidget),
      matching: find.text('Pull request'),
    );
    await _waitUntil(() => _showing(row));
    for (int attempt = 0; attempt < 20; attempt++) {
      await tester.tap(row);
      await settle();
      if (_showing(find.byType(PullRequestStatusRowWidget))) {
        return;
      }
      await tester.pump(const Duration(milliseconds: 250));
    }
  }

  /// Opens the base control of the pull request column and picks [name].
  Future<void> choosesThePullRequestBase(String name) async {
    final Finder control = find.byType(PullRequestBaseWidget);
    await _waitUntil(() => _showing(control));
    await tester.tap(control);
    await settle();
    final Finder entry = find.descendant(
      of: find.byType(TomMenuWidget),
      matching: find.text(name),
    );
    await _waitUntil(() => _showing(entry));
    await tester.tap(entry);
    await settle();
  }

  /// Asserts the pull request column proposes onto [name].
  Future<void> seesThePullRequestBase(String name) async {
    final Finder shown = find.descendant(
      of: find.byType(PullRequestBaseWidget),
      matching: find.text(name),
    );
    await _waitUntil(() => _showing(shown));
    expect(shown, findsOneWidget, reason: 'the base is not $name');
  }

  /// Presses [label] at the foot of the pull request column — `Create pull
  /// request`, `View #123 on GitHub` — once the host has answered.
  Future<void> pressesThePullRequestAction(String label) async {
    final Finder action = find.descendant(
      of: find.byType(PullRequestPanel),
      matching: find.text(label),
    );
    await _waitUntil(() => _showing(action));
    await tester.tap(action);
    await settle();
  }

  /// Asserts the tree's `Pull request` row is drawn, says [reason] under its
  /// name, and that pressing it opens nothing.
  Future<void> seesThePullRequestUnavailable(String reason) async {
    final Finder said = find.descendant(
      of: find.byType(PullRequestRowWidget),
      matching: find.text(reason),
    );
    await _waitUntil(() => _showing(said));
    expect(said, findsOneWidget, reason: 'the row does not say "$reason"');
    await tester.tap(
      find.descendant(
        of: find.byType(PullRequestRowWidget),
        matching: find.text('Pull request'),
      ),
    );
    await settle();
    expect(
      find.byType(PullRequestStatusRowWidget),
      findsNothing,
      reason: 'an unavailable row opened the page',
    );
  }

  /// Opens the `⋮` named [menu], and leaves it open.
  Future<void> opensTheMenu(String menu) async {
    await _waitUntil(() => _showing(find.byTooltip(menu)));
    await tester.tap(find.byTooltip(menu));
    await settle();
  }

  /// Asserts the open menu offers [labels], in that order.
  Future<void> seesInTheMenu(List<String> labels) async {
    await _waitUntil(() => _showing(find.byType(TomMenuWidget)));
    final List<String> shown = <String>[
      for (final Text text in tester.widgetList<Text>(
        find.descendant(
          of: find.byType(TomMenuWidget),
          matching: find.byType(Text),
        ),
      ))
        text.data ?? '',
    ];
    expect(shown, labels, reason: 'the menu offers $shown');
  }

  /// Presses Escape wherever the keyboard is.
  Future<void> pressesEscape() async {
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await settle();
  }

  /// Puts the open menu away with Escape.
  Future<void> dismissesTheMenu() async {
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await settle();
    expect(find.byType(TomMenuWidget), findsNothing);
  }

  /// Opens the `⋮` named [menu] and chooses [label] from it.
  Future<void> choosesFromTheMenu(String menu, String label) async {
    await _waitUntil(() => _showing(find.byTooltip(menu)));
    await tester.tap(find.byTooltip(menu));
    await settle();
    final Finder row = find.descendant(
      of: find.byType(TomMenuWidget),
      matching: find.text(label),
    );
    await _waitUntil(() => _showing(row));
    await tester.tap(row);
    // Pumped, not settled: a choice can hand the keyboard to a field.
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Right-clicks the tab named [tab] and chooses [label] from its menu.
  Future<void> choosesFromTheTabMenu(String tab, String label) async {
    final Finder name = find.descendant(
      of: find.byType(EditorTabsWidget),
      matching: find.text(tab),
    );
    await _waitUntil(() => _showing(name));
    await tester.tapAt(tester.getCenter(name), buttons: kSecondaryButton);
    await settle();
    final Finder row = find.descendant(
      of: find.byType(TomMenuWidget),
      matching: find.text(label),
    );
    await _waitUntil(() => _showing(row));
    await tester.tap(row);
    await settle();
  }

  /// Asserts the export dialog's answer, [fileName] beside this scenario's
  /// preferences, was written, begins with [starts] and — for a text format
  /// — holds [holding].
  Future<void> seesTheExportWritten(
    String fileName,
    String starts, {
    String? holding,
  }) async {
    final File written = File('${File(settingsPath).parent.path}/$fileName');
    await _waitUntil(written.existsSync);
    expect(written.existsSync(), isTrue, reason: '$fileName was not written');
    final List<int> bytes = written.readAsBytesSync();
    expect(
      String.fromCharCodes(bytes.take(starts.length)),
      starts,
      reason: '$fileName is not what was asked for',
    );
    if (holding != null) {
      expect(
        String.fromCharCodes(bytes),
        contains(holding),
        reason: '$fileName does not hold $holding',
      );
    }
  }

  /// Names the folder the explorer menu's `New folder` asked for, and
  /// presses Enter.
  Future<void> createsAFolder(String name) async {
    await choosesFromTheMenu('Explorer menu', 'New folder');
    final Finder field = find.descendant(
      of: find.byType(FileTreeDraftWidget),
      matching: find.byType(TextField),
    );
    await _waitUntil(() => _showing(field));
    await tester.enterText(field, name);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Asserts the name typed after the `+` was refused where it was typed:
  /// the row is still there, outlined `removed`.
  Future<void> seesTheNameRefused() async {
    Finder box() => find.descendant(
      of: find.byType(FileTreeDraftWidget),
      matching: find.byType(TomFieldBoxWidget),
    );
    await _waitUntil(
      () =>
          _showing(box()) && tester.widget<TomFieldBoxWidget>(box()).isRefused,
    );
    expect(
      tester.widget<TomFieldBoxWidget>(box()).isRefused,
      isTrue,
      reason: 'the new document\'s name was not refused',
    );
  }

  /// Takes the `+`'s row away with Escape.
  Future<void> cancelsTheNewDocument() async {
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await settle();
    expect(find.byType(FileTreeDraftWidget), findsNothing);
  }

  /// Asserts the tree marks [name] with git's [state] letter.
  Future<void> seesTheTreeMark(String name, FileStateEnum state) async {
    Finder mark() => find.descendant(
      of: find.ancestor(
        of: _inTheTree(name),
        matching: find.byType(FileTreeRowWidget),
      ),
      matching: find.byType(FileStateMarkWidget),
    );
    await _waitUntil(
      () =>
          _showing(mark()) &&
          tester.widget<FileStateMarkWidget>(mark()).state == state,
    );
    expect(
      tester.widget<FileStateMarkWidget>(mark()).state,
      state,
      reason: '$name is not marked ${state.name} in the tree',
    );
  }

  /// Asserts the window shows the source pane alone.
  Future<void> seesOnlyTheSource() async {
    await _waitUntil(
      () =>
          _showing(find.byType(CodeEditor)) &&
          !_showing(find.byType(PreviewPanel)),
    );
    expect(find.byType(PreviewPanel), findsNothing);
  }

  /// Types [terms] into the search box above the tree.
  ///
  /// Tapped first, and pumped: `enterText` sends the text to whatever holds
  /// the text input, and once a document is open that is the editor — the
  /// request for the focus needs a frame before the text follows it.
  Future<void> typesInTheSearch(String terms) async {
    await tester.tap(_theSearchField);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(_theSearchField, terms);
    // Pumped, not settled, for the reason [clickInTheResults] gives: a caret
    // blinks for as long as the box has the keyboard.
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Asserts each of [texts] is somewhere on screen.
  ///
  /// Unscoped on purpose, for the window's own chrome: a control in the bar
  /// belongs to no panel, so there is no panel to scope it to.
  Future<void> seesOnScreen(List<String> texts) async {
    await _waitUntil(() => _showing(find.text(texts.first)));
    for (final String text in texts) {
      expect(find.text(text), findsWidgets, reason: '$text is not on screen');
    }
  }

  /// Asserts [text] is not.
  Future<void> seesNotOnScreen(String text) async {
    await _waitUntil(() => !_showing(find.text(text)));
    expect(find.text(text), findsNothing, reason: '$text should not be shown');
  }

  /// Drags the rule beside the left column by [dx], widening it.
  ///
  /// A gesture by hand rather than `drag`, which compensates for the touch
  /// slop on behalf of a widget that starts on recognition; the grip starts
  /// on the pointer going down.
  Future<void> widensTheExplorer(double dx) async {
    // The first of the two gutters: the right column has one of its own, and
    // only the left one is the reader's to drag.
    final Finder column = find.byType(FileTreePanel);
    final double before = tester.getSize(column).width;
    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(find.byType(WorkspaceGripWidget).first),
    );
    await gesture.moveBy(Offset(dx, 0));
    await gesture.up();
    await settle();
    expect(
      tester.getSize(column).width,
      greaterThan(before),
      reason: 'the left column is no wider after the drag',
    );
  }

  /// Drags the gutter of a closed column towards the room it would take:
  /// [left] for the explorer's, otherwise the git column's.
  Future<void> dragsTheClosedGutterOpen({required bool left}) async {
    final Finder grips = find.byType(WorkspaceGripWidget);
    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(left ? grips.first : grips.last),
    );
    await gesture.moveBy(Offset(left ? 40 : -40, 0));
    await gesture.up();
    await settle();
  }

  /// Hides a column, or brings it back, by its control in the top bar.
  Future<void> togglesTheColumn(String tooltip) async {
    await tester.tap(find.byTooltip(tooltip));
    await settle();
  }

  /// Shows the right column's panel called [name].
  Future<void> showsTheGitPanel(String name) async {
    await tester.tap(find.text(name));
    await settle();
  }

  /// Opens the breadcrumb's menu of spaces, by the chevron that says it is one.
  Future<void> opensTheSpaceMenu() async {
    await tester.tap(
      find.descendant(
        of: find.byType(SpaceMenuControlWidget),
        matching: find.byType(TomChevronWidget),
      ),
    );
    await settle();
  }

  /// Leaves the space, from the home button before the breadcrumb.
  Future<void> closesTheSpace() async {
    await tester.tap(find.byTooltip('Close space'));
    await settle();
  }

  /// Asks the window to close, the way its own close button does.
  ///
  /// The real request, through the platform: the app holds it back to ask
  /// about unsaved work, and what it does once that is answered is written
  /// down by the run instead of ending it ([seesTheWindowClosed]).
  Future<void> closesTheWindow() async {
    await windowManager.close();
    await settle();
  }

  /// How many times this scenario's app closed its window for good.
  int get _windowsClosed {
    final File closed = File(E2eModuleImpl.closedPath(settingsPath));
    return closed.existsSync() ? closed.readAsLinesSync().length : 0;
  }

  /// Asserts the app has closed its window for good [times] times — once
  /// per launch that ended that way.
  Future<void> seesTheWindowClosed({int times = 1}) async {
    await _waitUntil(() => _windowsClosed >= times);
    expect(_windowsClosed, times, reason: 'the window was not closed');
  }

  /// Asserts the window was held open: still [times] closings, no more.
  void seesTheWindowStillOpen({int times = 0}) => expect(
    _windowsClosed,
    times,
    reason: 'the window closed over unsaved work',
  );

  /// Goes straight to the space called [name], from that menu.
  ///
  /// By the row's name exactly, because the path under it holds the name
  /// too and a loose match finds both.
  Future<void> opensFromTheSpaceMenu(String name) async {
    await _waitUntil(() => _showing(_saying(name)));
    await tester.tap(_saying(name));
    await settle();
  }

  /// Asserts the menu's row for the open space [name] carries the `✓`, and
  /// that pressing it changes nothing: the row is where the person already
  /// is, and the menu stays as it was.
  Future<void> seesTheOpenSpaceTickedAndInert(String name) async {
    final Finder row = find.byWidgetPredicate(
      (Widget it) =>
          it is SpaceMenuRowWidget && it.isOpen && it.space.name == name,
    );
    await _waitUntil(() => _showing(row));
    expect(row, findsOneWidget, reason: '$name is not the open row');
    expect(
      find.descendant(of: row, matching: find.text('✓')),
      findsOneWidget,
      reason: 'the open row carries no ✓',
    );
    await tester.tap(row);
    await settle();
    expect(row, findsOneWidget, reason: 'pressing the open row moved on');
    expect(find.byType(SpaceMenuPopoverWidget), findsOneWidget);
  }

  /// Answers the question the menu asks about an unsaved buffer.
  Future<void> answersTheUnsavedQuestion(String label) async {
    await _waitUntil(() => _showing(_saying(label)));
    await tester.tap(_saying(label));
    await settle();
  }

  /// Asserts the menu shows each of [texts].
  Future<void> seesInTheSpaceMenu(List<String> texts) async {
    await _waitUntil(() => _showing(_inTheSpaceMenu(texts.first)));
    for (final String text in texts) {
      expect(
        _inTheSpaceMenu(text),
        findsWidgets,
        reason: '$text is not in the space menu',
      );
    }
  }

  /// Asks about the open document rather than the whole space.
  Future<void> searchesTheOpenFile() async {
    await tester.tap(find.text('This file'));
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Opens the second box, the one that says what the words become, with
  /// ⌥⌘F (Ctrl+H off macOS) — the field carries no control for it.
  Future<void> opensTheReplacement() async {
    await _pressesTheReplaceKeys();
    // Two fields, not "a field": the search box alone would satisfy that.
    // Pumped, not settled: the box takes the keyboard, and a caret blinks.
    bool open() =>
        find
            .descendant(
              of: find.byType(SearchBoxes),
              matching: find.byType(TextField),
            )
            .evaluate()
            .length ==
        2;
    await _waitUntil(open);
    expect(open(), isTrue, reason: '⌥⌘F did not open the replace box');
  }

  /// Presses ⌥⌘F again while the second box is open, which puts it away.
  Future<void> closesTheReplacementWithTheKeys() async {
    await _pressesTheReplaceKeys();
    bool shut() =>
        find
            .descendant(
              of: find.byType(SearchBoxes),
              matching: find.byType(TextField),
            )
            .evaluate()
            .length ==
        1;
    await _waitUntil(shut);
    expect(shut(), isTrue, reason: '⌥⌘F did not put the replace box away');
  }

  Future<void> _pressesTheReplaceKeys() async {
    final List<LogicalKeyboardKey> held = Platform.isMacOS
        ? <LogicalKeyboardKey>[
            LogicalKeyboardKey.metaLeft,
            LogicalKeyboardKey.altLeft,
          ]
        : <LogicalKeyboardKey>[LogicalKeyboardKey.controlLeft];
    for (final LogicalKeyboardKey key in held) {
      await tester.sendKeyDownEvent(key);
    }
    await tester.sendKeyEvent(
      Platform.isMacOS ? LogicalKeyboardKey.keyF : LogicalKeyboardKey.keyH,
    );
    for (final LogicalKeyboardKey key in held.reversed) {
      await tester.sendKeyUpEvent(key);
    }
  }

  /// Types [text] into that second box.
  Future<void> typesTheReplacement(String text) async {
    await tester.tap(_theReplacementField);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(_theReplacementField, text);
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Replaces the occurrence the pointer is on.
  Future<void> replacesTheCurrentOne() async {
    // One row carries the pair, the current one — not every occurrence.
    expect(
      find.byTooltip('Replace this one'),
      findsOneWidget,
      reason: 'the action is on more than the current occurrence',
    );
    await tester.tap(find.byTooltip('Replace this one'));
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Presses the occurrence that shows [text], which goes to it.
  Future<void> clicksTheOccurrence(String text) async {
    await _waitUntil(() => _showing(_inTheOccurrences(text)));
    await tester.tap(_inTheOccurrences(text).first);
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Asserts the source pane has exactly [text] selected.
  Future<void> seesTheSourceSelecting(String text) async {
    await _waitUntil(
      () =>
          _showing(find.byType(CodeEditor)) &&
          tester
                  .widget<CodeEditor>(find.byType(CodeEditor))
                  .controller!
                  .selectedText ==
              text,
    );
    expect(
      tester
          .widget<CodeEditor>(find.byType(CodeEditor))
          .controller!
          .selectedText,
      text,
      reason: 'the source pane does not have "$text" selected',
    );
  }

  /// Replaces every occurrence at once.
  Future<void> replacesEveryOne() async {
    await tester.tap(find.text('Replace all'));
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Asserts the occurrence list shows each of [texts].
  Future<void> seesInTheOccurrences(List<String> texts) async {
    await _waitUntil(() => _showing(_inTheOccurrences(texts.first)));
    for (final String text in texts) {
      expect(
        _inTheOccurrences(text),
        findsWidgets,
        reason: '$text is not among the occurrences',
      );
    }
  }

  /// Asserts the occurrence list does not show [text].
  Future<void> seesNotInTheOccurrences(String text) async {
    await _waitUntil(() => !_showing(_inTheOccurrences(text)));
    expect(
      _inTheOccurrences(text),
      findsNothing,
      reason: '$text should not be among the occurrences',
    );
  }

  /// Asserts the search column says [sentence] and nothing is listed — the
  /// note that stands where the occurrences would be.
  Future<void> seesTheSearchColumnSaying(String sentence) async {
    final Finder note = find.descendant(
      of: find.byType(SearchOccurrencesPanel),
      matching: find.text(sentence),
    );
    await _waitUntil(() => _showing(note));
    expect(note, findsOneWidget, reason: 'the column does not say: $sentence');
  }

  /// Asserts the scope control is on screen, both of its halves.
  Future<void> seesTheScopeControl() async {
    await _waitUntil(() => _showing(find.text('This file')));
    expect(find.text('This file'), findsOneWidget);
    expect(find.text('Whole space'), findsOneWidget);
  }

  /// Puts the question back to the whole space, by the control.
  Future<void> searchesTheWholeSpace() async {
    await tester.tap(find.text('Whole space'));
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Presses the `Clear the search` button of the box.
  Future<void> clearsTheSearch() async {
    await tester.tap(find.byTooltip('Clear the search'));
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Asserts the results list [names] top to bottom, best first.
  Future<void> seesTheResultsInOrder(List<String> names) async {
    Finder named(String name) => find.descendant(
      of: find.byType(SearchResultsPanel),
      matching: find.text(name),
    );
    await _waitUntil(() => names.every((String name) => _showing(named(name))));
    double? previous;
    for (final String name in names) {
      final double top = tester.getTopLeft(named(name).first).dy;
      if (previous != null) {
        expect(
          top,
          greaterThan(previous),
          reason: '$name is not below the one before it',
        );
      }
      previous = top;
    }
  }

  /// Asserts the hits show [folder] under their names — one line for each
  /// hit that sits in it.
  Future<void> seesTheFolderOfTheHits(
    String folder, {
    required int hits,
  }) async {
    final Finder lines = find.descendant(
      of: find.byType(SearchResultsPanel),
      matching: find.text(folder),
    );
    await _waitUntil(() => _showing(lines));
    expect(
      lines.evaluate().length,
      hits,
      reason: '$hits hits should show $folder under their names',
    );
  }

  /// The runs of the results' excerpts, marked ones only: a run the hit
  /// widget coloured, which is how a typed word is shown inside the text.
  List<String> _markedInTheResults() {
    final List<String> marked = <String>[];
    final Finder rich = find.descendant(
      of: find.byType(SearchResultsPanel),
      matching: find.byType(RichText),
    );
    for (final Element element in rich.evaluate()) {
      (element.widget as RichText).text.visitChildren((InlineSpan span) {
        if (span is TextSpan && span.style?.color != null) {
          marked.add(span.text ?? '');
        }
        return true;
      });
    }
    return marked;
  }

  /// Asserts [word] is marked inside a result's excerpt, in any case.
  Future<void> seesMarkedInTheResults(String word) async {
    bool marked() => _markedInTheResults().any(
      (String run) => run.toLowerCase().contains(word.toLowerCase()),
    );
    await _waitUntil(marked);
    expect(
      _markedInTheResults(),
      contains(
        predicate<String>(
          (String run) => run.toLowerCase().contains(word.toLowerCase()),
        ),
      ),
      reason: '$word is not marked in any result',
    );
  }

  /// The spans of the occurrences list, below the root of each row.
  List<TextSpan> _occurrenceSpans() {
    final List<TextSpan> spans = <TextSpan>[];
    final Finder rich = find.descendant(
      of: find.byType(SearchOccurrencesPanel),
      matching: find.byType(RichText),
    );
    for (final Element element in rich.evaluate()) {
      (element.widget as RichText).text.visitChildren((InlineSpan span) {
        if (span is TextSpan) {
          spans.add(span);
        }
        return true;
      });
    }
    return spans;
  }

  /// Asserts an occurrence shows [old] struck through and [added] after it:
  /// the change, drawn before it is made.
  ///
  /// With no [added], the replacement is empty and only the strike is read.
  Future<void> seesTheChangeBeforeItIsMade(String old, [String? added]) async {
    bool struck() => _occurrenceSpans().any(
      (TextSpan span) =>
          span.text == old &&
          span.style?.decoration == TextDecoration.lineThrough,
    );
    await _waitUntil(struck);
    expect(struck(), isTrue, reason: '$old is not struck through');
    if (added != null) {
      expect(
        _occurrenceSpans().any((TextSpan span) => span.text == added),
        isTrue,
        reason: '$added does not follow the struck words',
      );
    }
  }

  /// Asserts no occurrence is struck through: nothing is being replaced.
  void seesNoChangeDrawn() {
    expect(
      _occurrenceSpans().any(
        (TextSpan span) => span.style?.decoration == TextDecoration.lineThrough,
      ),
      isFalse,
      reason: 'an occurrence is struck through with no replacement open',
    );
  }

  /// Presses `Skip this one` on the occurrence the actions are on.
  Future<void> skipsTheCurrentOne() async {
    expect(find.byTooltip('Skip this one'), findsOneWidget);
    await tester.tap(find.byTooltip('Skip this one'));
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// The vertical stretch occurrence number [index] takes in the list: rows
  /// are of one fixed extent, so the list's top and the index say where.
  ({double top, double bottom, double left}) _occurrenceRow(int index) {
    final Finder list = find.descendant(
      of: find.byType(SearchOccurrencesPanel),
      matching: find.byType(ListView),
    );
    final Offset origin = tester.getTopLeft(list);
    const double extent = SearchDesign.rowHeight + SearchDesign.rowGap;
    return (
      top: origin.dy + index * extent,
      bottom: origin.dy + (index + 1) * extent,
      left: origin.dx,
    );
  }

  /// Rests the mouse on occurrence number [index] (from 0): the row under
  /// the pointer is the one that carries the actions.
  ///
  /// A pointer of its own, so it never collides with the one the machine's
  /// real mouse owns in the live binding.
  Future<void> pointsAtTheOccurrence(int index) async {
    final ({double bottom, double left, double top}) row = _occurrenceRow(
      index,
    );
    final Offset at = Offset(row.left + 60, (row.top + row.bottom) / 2);
    final TestGesture mouse = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
      pointer: 7,
    );
    await mouse.addPointer(location: at);
    await mouse.moveTo(at);
    await tester.pump(const Duration(milliseconds: 300));
    addTearDown(mouse.removePointer);
  }

  /// Asserts the pair `Replace this one` / `Skip this one` is on occurrence
  /// number [index], and on that one alone.
  Future<void> seesTheActionsOnOccurrence(int index) async {
    await _waitUntil(() => _showing(find.byTooltip('Skip this one')));
    for (final String tooltip in <String>[
      'Replace this one',
      'Skip this one',
    ]) {
      expect(find.byTooltip(tooltip), findsOneWidget, reason: tooltip);
      final double at = tester.getCenter(find.byTooltip(tooltip)).dy;
      final ({double bottom, double left, double top}) row = _occurrenceRow(
        index,
      );
      expect(
        at,
        inInclusiveRange(row.top, row.bottom),
        reason: '$tooltip is not on occurrence $index',
      );
    }
  }

  /// The replace toggle of the box, whichever of its two tooltips it wears.
  Finder get _theReplaceToggle => find.byWidgetPredicate(
    (Widget widget) =>
        widget is Tooltip &&
        (widget.message?.startsWith('Replace (') == true ||
            widget.message?.startsWith('Hide replace (') == true),
  );

  /// Presses the glyph beside the clear, which opens or shuts the second box.
  Future<void> pressesTheReplaceToggle() async {
    await tester.tap(_theReplaceToggle);
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Asserts the toggle says the second box is [open].
  Future<void> seesTheReplaceToggle({required bool open}) async {
    bool says() => find
        .byWidgetPredicate(
          (Widget widget) =>
              widget is Tooltip &&
              widget.message?.startsWith(
                    open ? 'Hide replace (' : 'Replace (',
                  ) ==
                  true,
        )
        .evaluate()
        .isNotEmpty;
    await _waitUntil(says);
    expect(says(), isTrue, reason: 'the toggle does not say open: $open');
  }

  /// Asserts the replacement box is [open] or gone — two fields, or one.
  void seesTheReplacementBox({required bool open}) {
    final int fields = find
        .descendant(
          of: find.byType(SearchBoxes),
          matching: find.byType(TextField),
        )
        .evaluate()
        .length;
    expect(fields, open ? 2 : 1, reason: 'the second box is not as expected');
  }

  /// Writes [text] to [path] without going through the app: a change made
  /// outside, which nothing watches.
  void writesFromOutside(String path, String text) {
    File(path).writeAsStringSync(text);
  }

  /// Clicks the result that shows [name], scoped to the panel because the
  /// tree names the same file.
  ///
  /// Pumped rather than settled: the document it opens arrives in an editor
  /// that blinks a caret forever once the keyboard has been anywhere, and
  /// `pumpAndSettle` waits for an animation that never ends. What the click
  /// did is waited for by the assertion after it.
  Future<void> clickInTheResults(String name) async {
    await _waitUntil(() => _showing(_inTheResults(name)));
    await tester.tap(_inTheResults(name));
    await tester.pump(const Duration(milliseconds: 300));
  }

  // ── What the user sees ────────────────────────────────────────────────

  /// Asserts Home is showing, with nothing open.
  Future<void> seesHome() async {
    await _waitUntil(() => _showing(find.text('Choose folder…')));
    expect(find.text('Choose folder…'), findsOneWidget, reason: 'not on Home');
    expect(find.text('no space open'), findsOneWidget);
  }

  /// Asserts a space is open, by the explorer, which is always on screen
  /// once one is.
  Future<void> seesTheShell() async {
    await _waitUntil(() => _showing(find.text('EXPLORER')));
    expect(
      find.text('EXPLORER'),
      findsOneWidget,
      reason: 'the shell is not showing; is a space actually open?',
    );
    expect(find.text('Choose folder…'), findsNothing);
  }

  /// Asserts the tree shows [names], each exactly once, once the folder walk
  /// has answered.
  Future<void> seesInTheTree(List<String> names) async {
    await _waitUntil(() => _showing(_inTheTree(names.first)));
    for (final String name in names) {
      expect(
        _inTheTree(name),
        findsOneWidget,
        reason: '$name is not in the tree',
      );
    }
  }

  /// Asserts the tree lists [names] from top to bottom in this order.
  Future<void> seesTheTreeInOrder(List<String> names) async {
    await _waitUntil(() => _showing(_inTheTree(names.first)));
    final List<double> ys = <double>[
      for (final String name in names) tester.getTopLeft(_inTheTree(name)).dy,
    ];
    for (int i = 1; i < ys.length; i++) {
      expect(
        ys[i],
        greaterThan(ys[i - 1]),
        reason: '${names[i]} should come after ${names[i - 1]}',
      );
    }
  }

  /// Asserts the tree does not show [name].
  void seesNotInTheTree(String name) {
    expect(
      _inTheTree(name),
      findsNothing,
      reason: '$name should not be in the tree',
    );
  }

  /// Asserts the search panel found [names], each exactly once.
  Future<void> seesInTheResults(List<String> names) async {
    await _waitUntil(() => _showing(_inTheResults(names.first)));
    for (final String name in names) {
      expect(
        _inTheResults(name),
        findsOneWidget,
        reason: '$name is not among the results',
      );
    }
  }

  /// Asserts the search panel does not offer [name], once it has answered.
  Future<void> seesNotInTheResults(String name) async {
    await _waitUntil(() => !_showing(_inTheResults(name)));
    expect(
      _inTheResults(name),
      findsNothing,
      reason: '$name should not be among the results',
    );
  }

  /// Asserts the search found nothing, in the sentence the product chose.
  Future<void> seesNoResults() async {
    const String said = 'No document says that.';
    await _waitUntil(() => _showing(find.text(said)));
    expect(find.text(said), findsOneWidget, reason: 'it found something');
  }

  /// [text] inside the preview panel, as rich text — and nowhere else: a tab
  /// name or a search excerpt on the same window says it too.
  Finder _inThePreview(String text) => find.descendant(
    of: find.byType(PreviewPanel),
    matching: find.textContaining(text, findRichText: true),
  );

  /// Asserts the preview is showing a document that says [text], as rich
  /// text because the preview renders markdown rather than writing it out.
  Future<void> seesInThePreview(String text) async {
    final Finder shown = _inThePreview(text);
    await _waitUntil(() => _showing(shown));
    expect(shown, findsWidgets, reason: 'the preview is not showing "$text"');
  }

  /// Asserts the preview has brought the heading [words] to the top of its
  /// pane, the way a link's `#anchor` leaves it.
  Future<void> seesTheHeadingAtTheTopOfThePreview(String words) async {
    final Finder heading = find.descendant(
      of: find.byType(PreviewPanel),
      matching: find.textContaining(words, findRichText: true),
    );
    bool atTheTop() {
      if (!_showing(heading)) {
        return false;
      }
      final Rect pane = tester.getRect(find.byType(PreviewPanel));
      final double top = tester.getTopLeft(heading.first).dy;
      return top >= pane.top && top < pane.top + pane.height / 4;
    }

    await _waitUntil(atTheTop);
    expect(atTheTop(), isTrue, reason: '"$words" is not at the preview top');
  }

  /// Asserts the preview tints the block an occurrence led to, in the
  /// accent's soft fill, and that the block says [text].
  Future<void> seesTheRevealedBlock(String text) async {
    final Finder tinted = find.descendant(
      of: find.byType(PreviewPanel),
      matching: find.byWidgetPredicate(
        (Widget widget) =>
            widget is DecoratedBox &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color ==
                TomColors.of(
                  tester.element(find.byType(PreviewPanel)),
                ).accentSoft,
      ),
    );
    final Finder block = find.descendant(
      of: tinted,
      matching: find.textContaining(text, findRichText: true),
    );
    await _waitUntil(() => _showing(block));
    expect(block, findsWidgets, reason: 'no tinted block says "$text"');
  }

  /// Asserts the source pane no longer holds [text] anywhere.
  Future<void> seesNotInTheSource(String text) async {
    String held() =>
        tester.widget<CodeEditor>(find.byType(CodeEditor)).controller!.text;
    await _waitUntil(
      () => _showing(find.byType(CodeEditor)) && !held().contains(text),
    );
    expect(held(), isNot(contains(text)), reason: 'the source holds "$text"');
  }

  /// Presses the choice reading [label] under a conflict in the preview —
  /// `Accept Current Change`, `Accept Incoming Change`, `Accept Both Changes`.
  Future<void> acceptsInThePreview(String label) async {
    // The first one: a document with two conflicts offers each choice twice,
    // and the top region is the one resolved first.
    final Finder choice = find
        .descendant(of: find.byType(PreviewPanel), matching: find.text(label))
        .first;
    await _waitUntil(() => _showing(choice));
    await tester.ensureVisible(choice);
    await tester.tap(choice);
    await settle();
  }

  /// Presses the choice reading [label] painted on the line of the
  /// [conflict]th `<<<<<<<` (counting from zero) in the source pane.
  ///
  /// The words are painted, not mounted, so the painter says where the word
  /// is ([EditorLensPainter.wordFor]) and the tap lands there.
  Future<void> acceptsInTheSource(String label, {int conflict = 0}) async {
    final Finder lens = find.descendant(
      of: find.byType(EditorLensWidget),
      matching: find.byType(CustomPaint),
    );
    await _waitUntil(() => _showing(lens));
    final EditorLensPainter painter =
        tester.widget<CustomPaint>(lens.first).painter! as EditorLensPainter;
    final ConflictChoiceEnum choice = switch (label) {
      'Accept Current Change' => ConflictChoiceEnum.current,
      'Accept Incoming Change' => ConflictChoiceEnum.incoming,
      'Accept Both Changes' => ConflictChoiceEnum.both,
      _ => throw ArgumentError('No such choice: $label'),
    };
    final List<int> openings = <int>[
      for (final (int index, String line)
          in tester
              .widget<CodeEditor>(find.byType(CodeEditor))
              .controller!
              .text
              .split('\n')
              .indexed)
        if (line.startsWith('<<<<<<<')) index,
    ];
    expect(openings.length, greaterThan(conflict), reason: 'no such conflict');
    final Rect? word = painter.wordFor(openings[conflict], choice);
    expect(word, isNotNull, reason: '"$label" is not painted on screen');
    await tester.tapAt(tester.getTopLeft(lens.first) + word!.center);
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Asserts the preview is **not** showing [text].
  Future<void> seesNotInThePreview(String text) async {
    final Finder shown = _inThePreview(text);
    await _waitUntil(() => !_showing(shown));
    expect(shown, findsNothing, reason: 'the preview is still showing "$text"');
  }

  /// Asserts the prose carries [numbers] as markers, top to bottom.
  ///
  /// Outside the foot, which draws the same digits with a stop after them.
  Future<void> seesTheFootnoteMarkers(List<String> numbers) async {
    for (final String number in numbers) {
      final Finder marker = find.descendant(
        of: find.byType(PreviewPanel),
        matching: find.text(number),
      );
      await _waitUntil(() => _showing(marker));
      expect(marker, findsOneWidget, reason: 'no marker $number in the prose');
    }
    // In order: the second citation is below the first. Scoped like the
    // search above, because the Git tab's count can be the same digit.
    Finder inThePreview(String number) => find.descendant(
      of: find.byType(PreviewPanel),
      matching: find.text(number),
    );
    for (int at = 1; at < numbers.length; at++) {
      expect(
        tester.getTopLeft(inThePreview(numbers[at])).dy,
        greaterThan(tester.getTopLeft(inThePreview(numbers[at - 1])).dy),
        reason: 'marker ${numbers[at]} is not below ${numbers[at - 1]}',
      );
    }
  }

  /// Asserts the foot of the document carries [numbers], in order.
  ///
  /// The foot is the one container that is not a block, so it is found by
  /// its own widget rather than by what it says
  /// ([PreviewFootnotesWidget]).
  Future<void> seesTheFootnotes(List<String> numbers) async {
    await _waitUntil(() => _showing(find.byType(PreviewFootnotesWidget)));
    for (final String number in numbers) {
      expect(
        find.descendant(
          of: find.byType(PreviewFootnotesWidget),
          matching: find.text(number),
        ),
        findsOneWidget,
        reason: 'the foot does not carry $number',
      );
    }
  }

  /// Asserts the rendered diff is marking [letters], top to bottom.
  ///
  /// Scoped to the preview, because the changes column draws the same mark
  /// about whole files.
  Future<void> seesTheDiffMarks(List<String> letters) async {
    // On the letters, not the count: a block going from added to modified is
    // one mark either way.
    await _waitUntil(() => _diffMarks().join() == letters.join());
    expect(
      _diffMarks(),
      letters,
      reason: 'the rendered diff is not marking $letters',
    );
  }

  /// Asserts the preview is drawing no diff decoration at all.
  Future<void> seesNoDiffMarks() async {
    await settle();
    // Re-marking happens off the frame: the marks a press took away go when
    // git has answered, not when the press settled.
    await _waitUntil(() => _diffMarks().isEmpty);
    expect(
      _diffMarks(),
      isEmpty,
      reason: 'the preview is decorating a document that did not change',
    );
  }

  /// The letter of every diff mark in the preview, in order.
  List<String> _diffMarks() => tester
      .widgetList<DiffMarkWidget>(
        find.descendant(
          of: find.byType(PreviewPanel),
          matching: find.byType(DiffMarkWidget),
        ),
      )
      .map((DiffMarkWidget mark) => mark.letter)
      .toList();

  /// Asserts [path] is the open document: the tree's open row is it, or —
  /// while a search has the column — the session says so.
  ///
  /// Not the status bar, which stopped naming the document when the 1b
  /// restyle gave that job to the tab (`docs/product/editor/tabs/doc.md`);
  /// the session stands in for the tab until tabs are built.
  Future<void> seesTheOpenDocument(String path) async {
    final Finder open = find.byWidgetPredicate(
      (Widget widget) =>
          widget is FileTreeRowWidget &&
          widget.isOpen &&
          widget.row.entry.path.value == path,
    );
    bool sessionSays() =>
        ProviderScope.containerOf(
          tester.element(find.byType(StatusPanel)),
        ).read(spaceSessionProvider)?.openDocument?.value ==
        path;
    await _waitUntil(
      () =>
          _showing(open) ||
          (!_showing(find.byType(FileTreeRowWidget)) && sessionSays()),
    );
    expect(
      _showing(open) || sessionSays(),
      isTrue,
      reason: '$path is not the open document',
    );
    // And the tab says so too, when a strip is up: the session and the tree
    // can agree on a document the strip does not show as chosen.
    if (_showing(find.byType(EditorTabsWidget)) &&
        _showing(
          find.descendant(
            of: find.byType(EditorTabsWidget),
            matching: find.byType(Text),
          ),
        )) {
      await seesTheChosenTab(path.split('/').last);
    }
  }

  /// Asserts the file at the absolute [path] holds [text], waiting for a save
  /// to land, and that the buffer it came from is no longer unsaved.
  Future<void> seesSavedTo(String path, String text) async {
    bool holds() => File(path).readAsStringSync().contains(text);
    await _waitUntil(() => holds() && !_showing(find.text('Unsaved')));
    expect(
      holds(),
      isTrue,
      reason: '$path reads:\n${File(path).readAsStringSync()}',
    );
    expect(find.text('Unsaved'), findsNothing);
  }

  /// Asserts the tree draws no open row: what is on screen is a file it does
  /// not list (`docs/product/git-workflow/commit/opening-a-change/doc.md`).
  void seesNoOpenRowInTheTree() {
    expect(
      find.byWidgetPredicate(
        (Widget widget) => widget is FileTreeRowWidget && widget.isOpen,
      ),
      findsNothing,
      reason: 'the tree marks a row open for a file it does not list',
    );
  }

  /// Asserts the tab named [name] says its file is gone: the name, then
  /// `(deleted)` (`docs/product/git-workflow/commit/opening-a-change/doc.md`).
  Future<void> seesTheTabDeleted(String name) async {
    final Finder tab = find.descendant(
      of: find.byType(EditorTabsWidget),
      matching: find.text('$name (deleted)'),
    );
    await _waitUntil(() => _showing(tab));
    expect(tab, findsOneWidget, reason: 'the tab does not say $name is gone');
  }

  /// Asserts the status bar names the open file's kind as [kind], and says
  /// `Read-only` in place of `Saved` when [readOnly].
  Future<void> seesTheFileKind(String kind, {bool readOnly = false}) async {
    Finder inTheBar(String text) => find.descendant(
      of: find.byType(StatusPanel),
      matching: find.text(text),
    );
    await _waitUntil(
      () =>
          _showing(inTheBar(kind)) &&
          _showing(inTheBar('Read-only')) == readOnly,
    );
    expect(inTheBar(kind), findsOneWidget, reason: 'the kind is not $kind');
    expect(
      inTheBar('Read-only'),
      readOnly ? findsOneWidget : findsNothing,
      reason: readOnly ? 'nothing says read-only' : 'a live file is read-only',
    );
    if (readOnly) {
      expect(inTheBar('Saved'), findsNothing);
    }
  }

  /// The three segments of the mode control, each with whether it is chosen
  /// and whether it can be pressed.
  Map<String, ({bool chosen, bool offered})> _modes() =>
      <String, ({bool chosen, bool offered})>{
        for (final String mode in <String>['Source', 'Split', 'Preview'])
          mode: (
            chosen:
                tester
                    .widget<Text>(
                      find.descendant(
                        of: find.byType(ShellModeControlWidget),
                        matching: find.text(mode),
                      ),
                    )
                    .style
                    ?.fontWeight ==
                FontWeight.w600,
            offered:
                tester
                    .widget<InkWell>(
                      find
                          .ancestor(
                            of: find.descendant(
                              of: find.byType(ShellModeControlWidget),
                              matching: find.text(mode),
                            ),
                            matching: find.byType(InkWell),
                          )
                          .first,
                    )
                    .onTap !=
                null,
          ),
      };

  /// Asserts [chosen] is the mode drawn chosen — none when null — and that
  /// exactly the modes in [offered] can be pressed.
  Future<void> seesTheModes({
    required String? chosen,
    required List<String> offered,
  }) async {
    bool matches() => _modes().entries.every(
      (MapEntry<String, ({bool chosen, bool offered})> mode) =>
          mode.value.chosen == (mode.key == chosen) &&
          mode.value.offered == offered.contains(mode.key),
    );
    await _waitUntil(matches);
    expect(matches(), isTrue, reason: 'the modes read ${_modes()}');
  }

  /// Asserts the source pane's gutter letters [letters], top to bottom, and
  /// that nothing renders the file: no preview, no `Diff` chip.
  Future<void> seesTheLineMarks(List<String> letters) async {
    List<String> lettered() {
      final Finder gutter = find.byType(EditorMarksWidget);
      if (!_showing(gutter)) {
        return const <String>[];
      }
      return <String>[
        for (final EditorMarkSpan span
            in tester.widget<EditorMarksWidget>(gutter).marks.spans)
          if (span.letters) EditorMarksPainter.letterOf(span.mark),
      ];
    }

    await _waitUntil(() => listEquals(lettered(), letters));
    expect(lettered(), letters, reason: 'the gutter letters ${lettered()}');
    expect(find.byType(PreviewPanel), findsNothing);
  }

  /// Asserts there is no `Diff` chip to turn the marks off with.
  void seesNoDiffChip() {
    expect(
      find.descendant(
        of: find.byType(CompareControlWidget),
        matching: find.text('Diff'),
      ),
      findsNothing,
      reason: 'the Diff chip is offered over a file it cannot turn off',
    );
  }

  /// Asserts the preview marks every block it draws removed.
  Future<void> seesEveryBlockRemoved() async {
    bool allRemoved() =>
        _diffMarks().isNotEmpty &&
        _diffMarks().every((String letter) => letter == 'D');
    await _waitUntil(allRemoved);
    expect(allRemoved(), isTrue, reason: 'the preview marks ${_diffMarks()}');
  }

  /// Asserts nothing offers a way back to now: what is on screen is not a
  /// version being read.
  void seesNoWayBackToNow() {
    expect(find.text('Back to now'), findsNothing);
    expect(find.textContaining('Reading '), findsNothing);
  }

  /// Presses the binary tab's `Reveal in Finder` (`Show in Files` off macOS).
  Future<void> revealsTheFile() async {
    await tester.tap(
      find.ancestor(
        of: find.text(Platform.isMacOS ? 'Reveal in Finder' : 'Show in Files'),
        matching: find.byType(OutlinedButton),
      ),
    );
    await settle();
  }

  /// Asserts the tab holds a binary file: its one sentence and the way to the
  /// file, and no source pane.
  Future<void> seesABinaryFile() async {
    final Finder sentence = find.text('A binary file — not shown as text.');
    await _waitUntil(() => _showing(sentence));
    expect(sentence, findsOneWidget);
    expect(
      find.ancestor(
        of: find.text(Platform.isMacOS ? 'Reveal in Finder' : 'Show in Files'),
        matching: find.byType(OutlinedButton),
      ),
      findsOneWidget,
    );
    expect(find.byType(CodeEditor, skipOffstage: false), findsNothing);
  }

  /// Asserts the source pane is showing [text], through the editor's own
  /// controller (see [typesInTheSource]).
  Future<void> seesInTheSource(String text) async {
    // Waited for, not read once: a switch re-reads the buffer after git, the
    // tree and the status, and the pane only shows it once all three answer.
    await _waitUntil(
      () =>
          _showing(find.byType(CodeEditor)) &&
          (tester
                  .widget<CodeEditor>(find.byType(CodeEditor))
                  .controller
                  ?.text
                  .contains(text) ??
              false),
    );
    expect(
      tester.widget<CodeEditor>(find.byType(CodeEditor)).controller!.text,
      contains(text),
      reason: 'the source pane is not showing "$text"',
    );
  }

  /// Opens the preferences popover, or closes it.
  Future<void> opensThePreferences() async {
    await _waitUntil(() => _showing(find.byTooltip('Preferences')));
    await tester.tap(find.byTooltip('Preferences'));
    await settle();
  }

  /// Presses `About TOM` at the foot of the open preferences popover and
  /// waits for the dialog.
  Future<void> opensTheAbout() async {
    final Finder row = find.descendant(
      of: find.byType(PreferencesPopoverWidget),
      matching: find.text('About TOM'),
    );
    await _waitUntil(() => _showing(row));
    await tester.tap(row);
    await settle();
    await _waitUntil(() => _showing(find.byType(AboutDialogWidget)));
  }

  /// Asserts the About dialog says each of [texts].
  Future<void> seesInTheAbout(List<String> texts) async {
    Finder inIt(String text) => find.descendant(
      of: find.byType(AboutDialogWidget),
      matching: find.textContaining(text),
    );
    await _waitUntil(() => _showing(inIt(texts.first)));
    for (final String text in texts) {
      expect(inIt(text), findsWidgets, reason: 'the dialog does not say $text');
    }
  }

  /// Asserts the About dialog does not say [text].
  void seesNotInTheAbout(String text) => expect(
    find.descendant(
      of: find.byType(AboutDialogWidget),
      matching: find.textContaining(text),
    ),
    findsNothing,
    reason: 'the dialog says $text',
  );

  /// Presses the button called [label] in the About dialog, and lets the
  /// answer arrive.
  Future<void> pressesInTheAbout(String label) async {
    final Finder button = find.descendant(
      of: find.byType(AboutDialogWidget),
      matching: find.text(label),
    );
    await _waitUntil(() => _showing(button));
    await tester.tap(button);
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Asserts the button called [label] in the About dialog can be pressed,
  /// or cannot.
  void seesTheAboutButton(String label, {required bool live}) {
    final Finder button = find.ancestor(
      of: find.descendant(
        of: find.byType(AboutDialogWidget),
        matching: find.text(label),
      ),
      matching: find.byWidgetPredicate((Widget w) => w is ButtonStyleButton),
    );
    expect(
      tester.widget<ButtonStyleButton>(button).onPressed != null,
      live,
      reason: '$label should ${live ? 'be live' : 'be unavailable'}',
    );
  }

  /// Presses `Close` and waits for the dialog to go.
  Future<void> closesTheAbout() async {
    await tester.tap(
      find.descendant(
        of: find.byType(AboutDialogWidget),
        matching: find.text('Close'),
      ),
    );
    await settle();
    expect(find.byType(AboutDialogWidget), findsNothing);
  }

  /// Asserts the gear wears the dot an update found at opening leaves.
  Future<void> seesTheGearDot() async {
    final Finder dot = find.byKey(const Key('updateDot'));
    await _waitUntil(() => _showing(dot));
    expect(dot, findsOneWidget, reason: 'the gear has no dot');
  }

  /// Asserts no dialog stands over the window.
  void seesNoDialog() => expect(find.byType(AboutDialogWidget), findsNothing);

  /// Ticks `Check for updates when TOM opens` in the open popover.
  Future<void> ticksCheckingForUpdates() async {
    await tester.tap(find.text('Check for updates when TOM opens'));
    await settle();
  }

  /// Presses the account button while its popover is open, which closes it.
  Future<void> closesTheAccount() async {
    await tester.tap(find.byTooltip('Account'));
    await settle();
  }

  /// Presses the account button while nothing was read yet — the tooltip
  /// says so — which is the ask where git asks first.
  Future<void> opensTheUnreadAccount() async {
    final Finder button = find.byTooltip('Account — not read yet');
    await _waitUntil(() => _showing(button));
    expect(button, findsOneWidget, reason: 'the account was already read');
    await tester.tap(button);
    await settle();
  }

  /// Opens the account popover and waits for what the machine's tools said.
  Future<void> opensTheAccount() async {
    await _waitUntil(() => _showing(find.byTooltip('Account')));
    await tester.tap(find.byTooltip('Account'));
    await settle();
    await _waitUntil(
      () =>
          _showing(find.text('No GitHub credentials on this computer')) ||
          _showing(find.byType(AccountSelectWidget)),
    );
  }

  /// Asserts the popover says the machine holds no GitHub login, and that
  /// what can be done here is unknown — five dashes, no tick.
  Future<void> seesNoGithubCredentials() async {
    await seesOnScreen(<String>[
      'No GitHub credentials on this computer',
      'What you can do here shows once git or gh can reach GitHub.',
    ]);
    final Finder grid = find.byType(AccountAccessWidget);
    expect(
      find.descendant(
        of: grid,
        matching: find.byWidgetPredicate(
          (Widget it) => it is TomGlyphWidget && it.glyph == TomGlyphEnum.rule,
        ),
      ),
      findsNWidgets(5),
    );
    expect(
      find.descendant(
        of: grid,
        matching: find.byWidgetPredicate(
          (Widget it) => it is TomGlyphWidget && it.glyph == TomGlyphEnum.check,
        ),
      ),
      findsNothing,
    );
  }

  /// Presses the repository's name in the account popover.
  Future<void> opensTheRepositoryFromTheAccount(String label) async {
    await tester.tap(
      find.descendant(
        of: find.byType(AccountPopoverWidget),
        matching: find.text(label),
      ),
    );
    await settle();
  }

  /// Asserts the row above the document says the disk refused the save.
  Future<void> seesTheSaveRefused() async {
    await _waitUntil(() => _showing(find.text('Not saved')));
    expect(
      find.text('Not saved'),
      findsOneWidget,
      reason: 'the refused save is not said on screen',
    );
  }

  /// Asserts the commit's summary box already holds [text] — what a merge
  /// in progress writes there.
  Future<void> seesTheSummaryHolding(String text) async {
    String held() => tester
        .widget<TextField>(
          find.descendant(of: find.byType(ChangesPanel), matching: _anyField),
        )
        .controller!
        .text;
    await _waitUntil(() => _showing(_anyField) && held().startsWith(text));
    expect(held(), startsWith(text), reason: 'the summary box holds ${held()}');
  }

  /// Tells the save dialog what to answer from now on: `cancel` for a
  /// dismissed dialog, otherwise the path the person chose.
  void answersTheSaveDialogWith(String answer) {
    File(E2eModuleImpl.saveAnswerPath(settingsPath))
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(answer);
  }

  /// Asserts the open commands panel lists no command holding [fragment].
  Future<void> seesNoCommandHolding(String fragment) async {
    expect(
      find.byType(CommandsPanel),
      findsOneWidget,
      reason: 'the commands panel is not open',
    );
    expect(
      find.descendant(
        of: find.byType(CommandsPanel),
        matching: find.textContaining(fragment),
      ),
      findsNothing,
      reason: 'a command holding "$fragment" was run',
    );
  }

  /// Asserts no GitHub token is painted anywhere in the window — the
  /// commands panel included, where `gh auth token` is listed.
  void seesNoTokenOnScreen() {
    expect(
      find.textContaining('gho_', skipOffstage: false),
      findsNothing,
      reason: 'a token is on screen',
    );
  }

  /// Asserts the run's `gh` was handed the draft: a `pr create` whose
  /// `--title` is [title], a body on its standard input that says [body],
  /// and a token in no argument, no body and nowhere on screen.
  Future<void> seesGhHandedTheDraft({
    required String title,
    required String body,
  }) async {
    final Directory state = Directory(E2eModuleImpl.githubPath(settingsPath));
    final File asked = File('${state.path}/asked.log');
    final File stdin = File('${state.path}/body.md');
    await _waitUntil(stdin.existsSync);
    final List<String> calls = asked.readAsLinesSync();
    final String create = calls.singleWhere(
      (String line) => line.startsWith('pr create'),
    );
    expect(create, contains('--title $title'));
    expect(stdin.readAsStringSync(), contains(body));
    for (final String line in <String>[...calls, stdin.readAsStringSync()]) {
      expect(line, isNot(contains('gho_')), reason: 'a token went to gh');
    }
    expect(
      find.textContaining('gho_'),
      findsNothing,
      reason: 'the token is on screen',
    );
  }

  /// Asserts the app handed [address] to the browser — written down by the
  /// run's desktop instead of opening one.
  Future<void> seesTheBrowserAskedFor(String address) async {
    final File opened = File(E2eModuleImpl.openedPath(settingsPath));
    await _waitUntil(opened.existsSync);
    expect(
      opened.existsSync() ? opened.readAsLinesSync() : const <String>[],
      contains(address),
    );
  }

  /// Asserts the app handed the browser an address that holds every one of
  /// [fragments] — the host and the branch, say, where the whole address is
  /// the host's own business.
  Future<void> seesTheBrowserAskedForAnAddressWith(
    List<String> fragments,
  ) async {
    final File opened = File(E2eModuleImpl.openedPath(settingsPath));
    bool asked() =>
        opened.existsSync() &&
        opened.readAsLinesSync().any(
          (String line) => fragments.every(line.contains),
        );
    await _waitUntil(asked);
    expect(
      opened.existsSync() ? opened.readAsLinesSync() : const <String>[],
      contains(
        predicate<String>((String line) => fragments.every(line.contains)),
      ),
      reason: 'no address with $fragments was handed to the browser',
    );
  }

  /// Presses the `Pull request` row once and says nothing: what a row that
  /// cannot act is asked, where [opensThePullRequest] keeps trying.
  Future<void> triesToOpenThePullRequest() async {
    final Finder row = find.descendant(
      of: find.byType(PullRequestRowWidget),
      matching: find.text('Pull request'),
    );
    await _waitUntil(() => _showing(row));
    await tester.tap(row);
    await settle();
  }

  /// The lines the run's desktop wrote instead of opening Finder or a
  /// terminal, in order: `reveal <folder>` and `terminal <folder>`.
  List<String> _desktopAsked() {
    final File asked = File(E2eModuleImpl.desktopAskedPath(settingsPath));
    return asked.existsSync() ? asked.readAsLinesSync() : const <String>[];
  }

  /// Asserts the app asked the file manager to show [folder] — written down,
  /// never opened on the machine the suite runs on.
  Future<void> seesTheFileManagerAskedFor(String folder) async {
    await _waitUntil(() => _desktopAsked().contains('reveal $folder'));
    expect(_desktopAsked(), contains('reveal $folder'));
  }

  /// Asserts the app asked for a terminal in [folder].
  Future<void> seesATerminalAskedFor(String folder) async {
    await _waitUntil(() => _desktopAsked().contains('terminal $folder'));
    expect(_desktopAsked(), contains('terminal $folder'));
  }

  /// Chooses [language] in the open popover's select, by the language's own
  /// name — which is the one word there that never changes with the choice.
  Future<void> choosesTheLanguage(String language) async {
    await tester.tap(
      find.descendant(
        of: find.byType(PreferencesPopoverWidget),
        matching: find.byType(TomChevronWidget),
      ),
    );
    await settle();
    await tester.tap(
      find.descendant(
        of: find.byType(MenuItemButton),
        matching: find.text(language),
      ),
    );
    await settle();
  }

  /// Presses the popover's `Open preferences.json`, which closes the popover
  /// and opens the file in a tab.
  Future<void> opensThePreferencesFile() async {
    await tester.tap(
      find.descendant(
        of: find.byType(PreferencesPopoverWidget),
        matching: find.text('Open preferences.json'),
      ),
    );
    await settle();
    await _waitUntil(() => _showing(find.byType(CodeEditor)));
  }

  /// Presses `Open git-approvals.json` in the open popover and waits for its
  /// tab to show the file.
  Future<void> opensTheApprovalsFile() async {
    await tester.tap(
      find.descendant(
        of: find.byType(PreferencesPopoverWidget),
        matching: find.text('Open git-approvals.json'),
      ),
    );
    await settle();
    await _waitUntil(() => _showing(find.byType(CodeEditor)));
  }

  /// Presses [mode] — `Automatic`, `Semi` or `Manual` — under `GIT COMMANDS`
  /// in the open popover; it applies at once.
  Future<void> choosesTheGitMode(String mode) async {
    await tester.tap(
      find.descendant(
        of: find.byType(PreferencesPopoverWidget),
        matching: find.text(mode),
      ),
    );
    await settle();
  }

  /// Presses the verb at the foot of the git column and does **not** wait
  /// for it to finish: with a command waiting for a yes it never would.
  Future<void> startsThe(String verb) async {
    final Finder button = find.descendant(
      of: find.byType(ChangesRemoteWidget),
      matching: find.textContaining(verb),
    );
    await _waitUntil(() => _showing(button));
    await tester.tap(button.first);
    await settle();
  }

  /// Presses [answer] — `Run`, `Always allow` or `Deny` — on the command the
  /// panel is waiting on.
  Future<void> answersTheWaitingCommand(String answer) async {
    final Finder button = find.descendant(
      of: find.byType(CommandsPanel),
      matching: find.text(answer),
    );
    await _waitUntil(() => _showing(button));
    await tester.tap(button.first);
    await settle();
  }

  /// Says `Run` to every command that waits, until none does: the reads the
  /// window makes after an action wait like the action did.
  Future<void> runsEverythingThatWaits() async {
    final Finder run = find.descendant(
      of: find.byType(CommandsPanel),
      matching: find.text('Run'),
    );
    for (int answered = 0; answered < 40; answered++) {
      await _waitUntil(() => _showing(run), limit: const Duration(seconds: 2));
      if (!_showing(run)) {
        return;
      }
      await tester.tap(run.first);
      await settle();
    }
  }

  /// Asserts how many commands wait for somebody to say yes.
  void seesCommandsWaiting(int count) => expect(
    ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp).first),
    ).read(commandsProvider).waiting,
    count,
    reason: 'commands waiting for approval',
  );

  /// Asserts `git-approvals.json` — the disk, since that is what a person
  /// edits — holds every one of [lines].
  void seesTheApprovalsFileSaying(List<String> lines) {
    final File file = File(
      '${File(settingsPath).parent.path}/git-approvals.json',
    );
    expect(
      file.existsSync(),
      isTrue,
      reason: 'git-approvals.json is not there',
    );
    final String text = file.readAsStringSync();
    for (final String line in lines) {
      expect(text, contains(line), reason: 'the file reads:\n$text');
    }
  }

  /// Has this scenario's preferences file say `GIT COMMANDS` is [mode] —
  /// `manual` or `semi` — before the app starts, as a person who chose it
  /// last time and relaunched would have it.
  void seedsTheGitMode(String mode) {
    File(settingsPath)
      ..parent.createSync(recursive: true)
      ..writeAsStringSync('{"app.preferences":{"gitApprovals":"$mode"}}');
  }

  /// Asserts Home is still up with a command waiting in its Commands panel,
  /// and its working line says it waits for the person.
  Future<void> seesHomeWaitingForApproval() async {
    await _waitUntil(() => _showing(find.byType(CommandsPanel)));
    expect(find.text('Choose folder…'), findsNothing, reason: 'not working');
    expect(find.text('EXPLORER'), findsNothing, reason: 'a space is open');
    expect(find.text('Waiting for your approval…'), findsOneWidget);
    expect(find.byType(CommandsPanel), findsOneWidget);
    expect(find.text('Run'), findsWidgets);
  }

  /// Asserts the account and preferences controls are live on Home.
  void seesHomesControlsLive() {
    expect(find.byType(PreferencesControlWidget), findsOneWidget);
    expect(find.byType(AccountControlWidget), findsOneWidget);
  }

  /// Writes [to] over the first [from] in what the source pane holds, as
  /// somebody selecting the word and typing would.
  Future<void> rewritesInTheSource(String from, String to) async {
    final String text = tester
        .widget<CodeEditor>(find.byType(CodeEditor))
        .controller!
        .text;
    expect(text, contains(from), reason: 'the source has no "$from"');
    await typesInTheSource(text.replaceFirst(from, to));
  }

  /// Asserts this scenario's preferences file holds every one of [lines] —
  /// the disk, since what a person reads by hand is the file, not the app.
  void seesThePreferencesFileSaying(List<String> lines) {
    final String text = File(settingsPath).readAsStringSync();
    for (final String line in lines) {
      expect(text, contains(line), reason: 'the file reads:\n$text');
    }
  }

  /// Asserts the window is drawn in [brightness] — waited for, because the
  /// app animates a change of theme.
  Future<void> seesTheWindowIn(Brightness brightness) async {
    Brightness drawn() =>
        Theme.of(tester.element(find.byType(StatusPanel))).brightness;
    await _waitUntil(() => drawn() == brightness);
    expect(drawn(), brightness, reason: 'the window is not $brightness');
  }

  /// Asserts the mode control offers `Source` alone: the other two are
  /// drawn and cannot be pressed.
  void seesOnlySourceOffered() {
    for (final String mode in <String>['Split', 'Preview']) {
      final InkWell segment = tester.widget<InkWell>(
        find
            .ancestor(
              of: find.descendant(
                of: find.byType(ShellModeControlWidget),
                matching: find.text(mode),
              ),
              matching: find.byType(InkWell),
            )
            .first,
      );
      expect(segment.onTap, isNull, reason: '$mode can still be chosen');
    }
  }

  /// Asserts the formatting bar is drawn.
  Future<void> seesTheFormattingBar() async {
    await _waitUntil(() => _showing(find.byType(TomToolbarButtonWidget)));
    expect(find.byType(TomToolbarButtonWidget), findsWidgets);
  }

  /// Asserts the toolbar button whose tooltip is [word] is drawn and cannot
  /// be pressed — dim, never absent.
  Future<void> seesTheToolbarButtonDim(String word) async =>
      _seesTheToolbarButton(word, live: false);

  /// Asserts the toolbar button whose tooltip is [word] can be pressed.
  Future<void> seesTheToolbarButtonLive(String word) async =>
      _seesTheToolbarButton(word, live: true);

  Future<void> _seesTheToolbarButton(String word, {required bool live}) async {
    final Finder button = find.ancestor(
      of: find.byTooltip(word),
      matching: find.byType(TomToolbarButtonWidget),
    );
    bool isLive() =>
        tester.widget<TomToolbarButtonWidget>(button.first).onPressed != null;
    await _waitUntil(() => _showing(button) && isLive() == live);
    expect(isLive(), live, reason: '$word is ${live ? 'dim' : 'live'}');
    // What the frame shows: a button that cannot act is fainter than the
    // muted role alone, so it is told from a live one at a glance.
    final Color ink =
        (tester
                    .widget<CustomPaint>(
                      find.descendant(
                        of: button.first,
                        matching: find.byWidgetPredicate(
                          (Widget it) =>
                              it is CustomPaint &&
                              it.painter is TomOutlinePainter,
                        ),
                      ),
                    )
                    .painter!
                as TomOutlinePainter)
            .color;
    final TomColors colors = TomColors.of(tester.element(button.first));
    expect(
      ink,
      live
          ? colors.textSecondary
          : colors.textMuted.withValues(
              alpha: TomToolbarButtonWidget.unavailableInk,
            ),
      reason: '$word is drawn in the wrong ink',
    );
  }

  /// Asserts it is not — the whole set, not half of it.
  Future<void> seesNoFormattingBar() async {
    await _waitUntil(() => !_showing(find.byType(TomToolbarButtonWidget)));
    expect(find.byType(TomToolbarButtonWidget), findsNothing);
  }

  /// Presses the formatting button whose tooltip is [word].
  ///
  /// By its word rather than its glyph: a test that matched the shape would
  /// pass on the wrong button the day two glyphs look alike, which is what
  /// rendering the set at 48 caught twice on the boards.
  Future<void> pressesTheToolbarButton(String word) async {
    Finder buttons() => find.ancestor(
      of: find.byTooltip(word),
      matching: find.byType(TomToolbarButtonWidget),
    );
    await _waitUntil(() => _showing(find.byType(TomToolbarButtonWidget)));
    // A narrow row folds its last groups into `⋯`, and what is folded is not
    // built until the strip opens.
    if (!_showing(buttons())) {
      await tester.tap(find.byTooltip('More formatting'));
      await settle();
    }
    final Finder button = buttons().first;
    await _waitUntil(() => _showing(button));
    // Scrolled to first: the bar never drops a button to fit, so with the git
    // column open the later groups are off the end of the row and a tap at
    // their coordinates would land on the document
    // (`docs/product/editor/formatting-shortcuts/doc.md`).
    await tester.ensureVisible(button);
    await settle();
    await tester.tap(button);
    await settle();
  }

  /// Asserts the source pane marks a conflict in its gutter.
  ///
  /// The painter is what is read, not a widget: the gutter paints rather than
  /// mounts, because the editor writes its layout while it is laying out
  /// ([EditorMarksWidget]).
  Future<void> seesTheConflictMarkedInSource() async {
    final Finder marks = find.descendant(
      of: find.byType(EditorMarksWidget),
      matching: find.byType(CustomPaint),
    );
    await _waitUntil(() => _showing(marks));
    final EditorMarksPainter painter =
        tester.widget<CustomPaint>(marks).painter! as EditorMarksPainter;
    // On the line the region opens on, not on some line: the letter beside
    // anything else would mark a document that is not the conflict.
    final List<String> lines = tester
        .widget<CodeEditor>(find.byType(CodeEditor))
        .controller!
        .text
        .split('\n');
    final int opening = lines.indexWhere(
      (String line) => line.startsWith('<<<<<<<'),
    );
    expect(opening, isNonNegative, reason: 'the source holds no marker');
    expect(
      painter.marks.at(opening),
      EditorMarkEnum.conflicted,
      reason:
          'the gutter does not mark line ${opening + 1} (the opening '
          'marker) as conflicted',
    );
  }

  /// Asserts the source pane's gutter marks no line at all.
  Future<void> seesNoMarksInTheSource() async {
    final Finder gutter = find.byType(EditorMarksWidget);
    bool unmarked() =>
        _showing(gutter) &&
        tester.widget<EditorMarksWidget>(gutter).marks.isEmpty;
    await _waitUntil(unmarked);
    expect(
      unmarked(),
      isTrue,
      reason: 'the source pane marks lines of a file in no repository',
    );
  }

  /// Asserts the changes panel lists [names], each exactly once.
  Future<void> seesInTheChanges(List<String> names) async {
    await _waitUntil(() => _showing(_inTheChanges(names.first)));
    for (final String name in names) {
      expect(
        _inTheChanges(name),
        findsOneWidget,
        reason: '$name is not in the changes panel',
      );
    }
  }

  /// Asserts the changes panel does not list [name], waiting for the row to
  /// go once git has been asked again.
  Future<void> seesNotInTheChanges(String name) async {
    await _waitUntil(() => !_showing(_inTheChanges(name)));
    expect(
      _inTheChanges(name),
      findsNothing,
      reason: '$name should not be in the changes panel',
    );
  }

  /// Asserts nothing differs from the last commit.
  Future<void> seesACleanTree() async {
    const String clean = 'Nothing has changed since the last commit.';
    await _waitUntil(() => _showing(find.text(clean)));
    expect(find.text(clean), findsOneWidget);
  }

  /// Asserts the buttons say how far the branch has drifted: a badge with
  /// the number after `Push` and `Pull`, and no badge where there is nothing
  /// to count.
  Future<void> seesTheDrift({int ahead = 0, int behind = 0}) async {
    Finder button(RemoteActionEnum action) =>
        find.byKey(ValueKey<RemoteActionEnum>(action));
    Finder badge(RemoteActionEnum action) => find.descendant(
      of: button(action),
      matching: find.byType(ChangesCountWidget),
    );
    await _waitUntil(
      () =>
          _showing(button(RemoteActionEnum.push)) &&
          _showing(button(RemoteActionEnum.pull)) &&
          !_showing(_working),
    );
    for (final (RemoteActionEnum action, int count)
        in <(RemoteActionEnum, int)>[
          (RemoteActionEnum.push, ahead),
          (RemoteActionEnum.pull, behind),
        ]) {
      if (count == 0) {
        expect(badge(action), findsNothing, reason: '$action counts nothing');
      } else {
        expect(
          find.descendant(of: badge(action), matching: find.text('$count')),
          findsOneWidget,
          reason: '$action does not say $count',
        );
      }
    }
  }

  /// Asserts the band above the document is saying each of [fragments].
  ///
  /// Fragments rather than the sentence, because the band is one `Text` and
  /// a notice is written as two or three clauses in it — what happened, and
  /// what it cost. A scenario quoting the punctuation between them would
  /// break on a comma.
  Future<void> seesTheBandSaying(List<String> fragments) async {
    await _waitUntil(() => _showing(_bandSaying(fragments.first)));
    for (final String fragment in fragments) {
      expect(
        _bandSaying(fragment),
        findsOneWidget,
        reason: 'the band does not say $fragment',
      );
    }
  }

  /// The band's own sentence, where it holds [fragment].
  Finder _bandSaying(String fragment) => find.descendant(
    of: find.byType(NoticeBandWidget),
    matching: find.textContaining(fragment),
  );

  /// Asserts the push was refused, in all three sentences the product chose
  /// (`docs/product/git-workflow/push-pull/README.md`).
  Future<void> seesThePushRefused({required int commits}) async {
    await seesTheBandSaying(<String>[
      'Someone pushed $commits commit${commits == 1 ? '' : 's'} first.',
      'Pull them, then push again',
      'nothing you committed has been lost',
    ]);
    // Scoped to the band: the git column carries a `Pull` of its own now, so
    // the way *out of a refusal* is the one inside the notice.
    expect(
      find.descendant(
        of: find.byType(NoticeBandWidget),
        matching: find.text('Pull'),
      ),
      findsOneWidget,
      reason: 'no way out of it',
    );
  }

  /// Asserts nothing on screen is claiming a push was refused.
  ///
  /// [allowingBand] when the band is there for good news, which is the one
  /// thing it may then be saying.
  void seesNoRefusal({bool allowingBand = false}) {
    expect(find.textContaining('Someone pushed'), findsNothing);
    if (!allowingBand) {
      expect(find.byType(NoticeBandWidget), findsNothing);
    }
  }

  /// Asserts the status bar names [branch] as the one checked out.
  Future<void> seesTheBranch(String branch) async {
    final Finder shown = find.descendant(
      of: find.byType(StatusPanel),
      matching: find.text(branch),
    );
    await _waitUntil(() => _showing(shown));
    expect(
      shown,
      findsOneWidget,
      reason:
          'the status bar does not say the '
          'branch is $branch',
    );
  }

  // ── Cloning by URL ────────────────────────────────────────────────────

  /// The address field Home shows in place of `Clone from URL`.
  Finder get _theCloneField => find.descendant(
    of: find.byType(HomeCloneWidget),
    matching: find.byType(TextField),
  );

  /// Pastes [address] into Home's clone field — opening it first if the
  /// button is still there — and presses Enter; the folder dialog answers
  /// what [launch] was given.
  Future<void> clonesFromUrl(String address) async {
    if (_showing(find.text('Clone from URL'))) {
      await tester.tap(find.text('Clone from URL'));
    }
    // Pumped, not settled: the field takes the keyboard and its caret
    // blinks, and a clone with no fraction yet draws a bar that travels.
    await tester.pump(const Duration(milliseconds: 300));
    await _waitUntil(() => _showing(_theCloneField));
    await tester.enterText(_theCloneField, address);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Asserts the clone was refused with [sentence], the address still in
  /// the field and `Clone` live again.
  ///
  /// [sentence] may be a fragment (a refusal that names a folder), and
  /// [address] the text the field must still hold.
  Future<void> seesTheCloneRefused(String sentence, {String? address}) async {
    await _waitUntil(() => _showing(find.textContaining(sentence)));
    expect(
      find.textContaining(sentence),
      findsOneWidget,
      reason: 'no refusal shown',
    );
    expect(_theCloneField, findsOneWidget, reason: 'the field went away');
    if (address != null) {
      expect(
        tester.widget<TextField>(_theCloneField).controller?.text,
        address,
        reason: 'the address was not kept in the field',
      );
    }
    final FilledButton clone = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Clone'),
        matching: find.byType(FilledButton),
      ),
    );
    expect(clone.onPressed, isNotNull, reason: '`Clone` is not live again');
  }

  // ── History ───────────────────────────────────────────────────────────

  /// Clicks the history entry whose message is [subject].
  Future<void> opensTheVersion(String subject) async {
    await _waitUntil(() => _showing(_inTheHistory(subject)));
    await tester.tap(_inTheHistory(subject));
    await settle();
  }

  /// Presses *Back to now*, leaving the past version.
  Future<void> goesBackToNow() async {
    await tapText('Back to now');
  }

  /// Asserts the history panel is offering each of [subjects].
  Future<void> seesInTheHistory(List<String> subjects) async {
    await _waitUntil(() => _showing(_inTheHistory(subjects.first)));
    for (final String subject in subjects) {
      expect(
        _inTheHistory(subject),
        findsOneWidget,
        reason: '"$subject" is not in the history',
      );
    }
  }

  /// Asserts the history panel is not offering [subject].
  void seesNotInTheHistory(String subject) {
    expect(
      _inTheHistory(subject),
      findsNothing,
      reason: '"$subject" should not be in this document\'s history',
    );
  }

  /// Asserts the bar above the document says a past version is on screen.
  Future<void> seesReadingAVersion() async {
    await _waitUntil(() => _showing(find.textContaining('Reading ')));
    expect(find.textContaining('Reading '), findsOneWidget);
    expect(find.text('Back to now'), findsOneWidget);
    // The modes stay: `Split` is that version's source beside its rendering.
    expect(
      find.text('Split'),
      findsWidgets,
      reason: 'the modes were taken away over a past version',
    );
  }

  /// Asserts the working copy is what is on screen.
  Future<void> seesTheWorkingCopy() async {
    await _waitUntil(() => _showing(find.text('Split')));
    expect(find.textContaining('Reading '), findsNothing);
    expect(find.text('Back to now'), findsNothing);
  }

  /// Whatever the history panel shows as [text]; a commit message can name a
  /// file the tree shows too.
  Finder _inTheHistory(String text) =>
      find.descendant(of: find.byType(HistoryPanel), matching: find.text(text));

  // ── Branches ──────────────────────────────────────────────────────────

  /// Opens the branch popover from the control in the top bar.
  Future<void> opensTheBranches() async {
    final Finder control = find.descendant(
      of: find.byType(BranchesControlWidget),
      matching: find.byType(OutlinedButton),
    );
    await _waitUntil(() => _showing(control));
    await tester.tap(control);
    await _waitUntil(() => _showing(find.text('Create branch…')));
  }

  /// Closes it the way a keyboard would.
  Future<void> closesTheBranches() async {
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await settle();
    expect(
      find.text('Create branch…'),
      findsNothing,
      reason: 'the branch popover is still up after Escape',
    );
  }

  /// Asserts git refused the switch and the popover says so, with the list
  /// of branches still up under the sentence.
  Future<void> seesTheSwitchRefused() async {
    const String refused = 'Git refused that. Nothing has changed.';
    await _waitUntil(() => _showing(find.text(refused)));
    expect(find.text(refused), findsOneWidget, reason: 'no refusal shown');
    expect(
      find.text('Create branch…'),
      findsOneWidget,
      reason: 'the list went away with the refusal',
    );
  }

  /// Opens the popover and clicks [branch], without waiting for the switch:
  /// what follows may be a checkout or the unsaved question.
  Future<void> switchesTo(String branch) async {
    await opensTheBranches();
    await tester.tap(_inTheBranches(branch));
    await settle();
  }

  /// Opens the popover, names a branch and creates it.
  Future<void> startsABranch(String name) async {
    await opensTheBranches();
    await tapText('Create branch…');
    await tester.enterText(_theBranchField, name);
    await settle();
    await tapText('Create branch');
  }

  /// Opens the popover, names a branch and creates it with Enter in the
  /// field instead of the button.
  Future<void> startsABranchWithEnter(String name) async {
    await opensTheBranches();
    await tapText('Create branch…');
    await tester.enterText(_theBranchField, name);
    await settle();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await settle();
  }

  /// Presses the commit box so it has the keyboard, which an open editor
  /// may otherwise be holding.
  Future<void> focusesTheCommitMessage() async {
    await tester.tap(_anyField);
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Commits from the keyboard: ⌘Enter (Ctrl+Enter off macOS) in the box.
  Future<void> commitsWithTheKeyboard() async {
    expect(
      tester.widget<TextField>(_anyField).controller!.text,
      isNotEmpty,
      reason: 'nothing is written in the message box',
    );
    expect(
      tester
          .widget<FilledButton>(
            find.ancestor(
              of: find.textContaining('Commit'),
              matching: find.byType(FilledButton),
            ),
          )
          .onPressed,
      isNotNull,
      reason: 'Commit is unavailable — is it staged and described?',
    );
    final LogicalKeyboardKey modifier = Platform.isMacOS
        ? LogicalKeyboardKey.metaLeft
        : LogicalKeyboardKey.controlLeft;
    await tester.sendKeyDownEvent(modifier);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyUpEvent(modifier);
    await _waitUntil(
      () => tester.widget<TextField>(_anyField).controller!.text.isEmpty,
    );
    await settle();
  }

  /// Types [name] as a branch to start, asserts the popover refuses it in
  /// words, presses `Create branch` anyway and closes the popover.
  Future<void> triesToStartABranchNamed(String name) async {
    await opensTheBranches();
    await tapText('Create branch…');
    await tester.enterText(_theBranchField, name);
    await settle();
    expect(
      find.text('Not a name git accepts'),
      findsOneWidget,
      reason: '"$name" was not refused',
    );
    // The button is unavailable, so this press must reach nothing.
    await tester.tap(find.text('Create branch'), warnIfMissed: false);
    await settle();
    // Pressing the button took the keyboard off the field, and Escape needs
    // it there: a press outside the popover closes it either way.
    await tester.tapAt(const Offset(2, 2));
    await settle();
  }

  /// Answers the unsaved question by letting the edit go.
  Future<void> discardsTheEdit() async {
    await tapText('Discard and switch');
  }

  /// Answers it by writing the buffer first.
  Future<void> savesAndSwitches() async {
    await tapText('Save and switch');
  }

  /// Answers it by staying put.
  Future<void> staysOnTheBranch() async {
    await tapText('Stay on this branch');
  }

  // ── What the diff is compared against ────────────────────────────────

  /// Presses the `Diff` chip, which only turns the marks off or back on.
  Future<void> pressesTheDiffChip() async {
    // The chip, not the base's name beside it, which is a label.
    final Finder chip = find.descendant(
      of: find.byType(CompareControlWidget),
      matching: find.text('Diff'),
    );
    await _waitUntil(() => _showing(chip));
    await tester.tap(chip);
    await settle();
  }

  /// The base the bar names, beside the chip when the row has room and in
  /// the chip's tooltip always.
  Finder _comparing(String what) => find.descendant(
    of: find.byType(CompareControlWidget),
    matching: find.byWidgetPredicate(
      (Widget widget) =>
          widget is Tooltip && (widget.message?.contains(what) ?? false),
    ),
  );

  /// Asserts the bar says the document is compared against [what].
  ///
  /// Read off the screen: the pointer rests on the chip until its tooltip is
  /// drawn, and the words are looked for in what is painted.
  Future<void> seesTheComparison(String what) async {
    await _waitUntil(() => _showing(_comparing(what)));
    expect(
      _comparing(what),
      findsOneWidget,
      reason: 'the bar does not say the document is compared to $what',
    );
    final int before = find.textContaining(what).evaluate().length;
    await _hoversTheChip();
    expect(
      find.textContaining(what).evaluate().length,
      greaterThan(before),
      reason:
          'the chip, hovered, does not draw a tooltip saying it compares '
          'to $what',
    );
  }

  /// Rests a mouse on the `Diff` chip long enough for its tooltip to open.
  ///
  /// Removed again before returning, not deferred to `addTearDown`: this is
  /// called more than once in a scenario, and a branch switch right after
  /// can rebuild the chip out from under a pointer MouseTracker still thinks
  /// is resting on it — a `mouse_tracker.dart` assertion in a later step,
  /// nowhere near here.
  Future<void> _hoversTheChip() async {
    final TestGesture mouse = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
    );
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(
      tester.getCenter(
        find.descendant(
          of: find.byType(CompareControlWidget),
          matching: find.text('Diff'),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    await mouse.removePointer();
  }

  /// Asserts the working tree is compared against `HEAD`: no branch is
  /// named, and the chip's tooltip says the last commit.
  Future<void> seesTheDefaultComparison() async {
    const String last = 'Compared to the last commit';
    await _waitUntil(() => _showing(_comparing(last)));
    expect(_comparing(last), findsOneWidget);
    expect(
      find.textContaining('Compared to'),
      findsNothing,
      reason: 'a base is named beside the chip',
    );
    await _hoversTheChip();
    expect(
      find.textContaining(last),
      findsOneWidget,
      reason: 'the chip, hovered, does not draw "$last"',
    );
  }

  /// Asserts pressing the chip opened nothing to choose a base from.
  void seesNothingToChooseFrom() {
    for (final String line in <String>[
      'Filter branches and commits',
      'Stop marking what changed',
      'Compare against the last commit',
    ]) {
      expect(
        find.text(line),
        findsNothing,
        reason: 'the chip opened a surface to choose from',
      );
    }
  }

  /// Asserts the control in the top bar names [branch].
  Future<void> seesTheBranchControl(String branch) async {
    final Finder shown = find.descendant(
      of: find.byType(BranchesControlWidget),
      matching: find.text(branch),
    );
    await _waitUntil(() => _showing(shown));
    expect(
      shown,
      findsOneWidget,
      reason: 'the top bar does not say the branch is $branch',
    );
  }

  /// Asserts the open popover is offering each of [names].
  void seesTheBranches(List<String> names) {
    for (final String name in names) {
      expect(
        _inTheBranches(name),
        findsOneWidget,
        reason: '$name is not among the branches offered',
      );
    }
  }

  /// Asserts the switch stopped to ask about [document] rather than
  /// replacing it.
  Future<void> seesTheUnsavedQuestion(String document) async {
    final Finder asked = find.text('$document has unsaved changes.');
    await _waitUntil(() => _showing(asked));
    expect(asked, findsOneWidget, reason: 'it switched without asking');
    expect(find.text('Save and switch'), findsOneWidget);
    expect(find.text('Discard and switch'), findsOneWidget);
  }

  /// Asserts the switch is asking about unsaved work, whatever it names.
  void seesAnUnsavedQuestion() {
    expect(
      find.textContaining('has unsaved changes.'),
      findsOneWidget,
      reason: 'no question about unsaved work was asked',
    );
    expect(find.text('Save and switch'), findsOneWidget);
  }

  /// Asserts no question about unsaved work is up.
  void seesNoQuestion() {
    expect(find.textContaining('has unsaved changes.'), findsNothing);
  }

  /// Whatever the branch popover shows as [name]; the control above it names
  /// the branch being switched *from*.
  Finder _inTheBranches(String name) => find.descendant(
    of: find.byType(BranchesPopoverWidget),
    matching: find.text(name),
  );

  /// The popover's own box, which is the one field on screen while it is up.
  Finder get _theBranchField => find.descendant(
    of: find.byType(BranchesPopoverWidget),
    matching: find.byType(TextField),
  );

  /// Whatever the changes panel shows as [name]; the tree names the same
  /// file too.
  Finder _inTheChanges(String name) =>
      find.descendant(of: find.byType(ChangesPanel), matching: find.text(name));

  /// The commit box's summary, scoped to the panel because the branch
  /// popover has a field of its own; the description is the box's second.
  Finder get _anyField => find
      .descendant(
        of: find.byType(ChangesPanel),
        matching: find.byType(TextField),
      )
      .first;

  /// Asserts which of the two panes the document area is showing.
  ///
  /// By the panel rather than by a caption: neither pane carries one, because
  /// no board draws one (`docs/design/screens/divergences.md`).
  void seesThePanes({required bool source, required bool preview}) {
    expect(
      find.byType(EditorPanel),
      source ? findsOneWidget : findsNothing,
      reason: 'the source pane should ${source ? '' : 'not '}be on screen',
    );
    expect(
      find.byType(PreviewPanel),
      preview ? findsOneWidget : findsNothing,
      reason: 'the preview should ${preview ? '' : 'not '}be on screen',
    );
  }

  /// Asserts the app says [path] is unsaved in every place it says it; a
  /// mark missing in one place is a failure while the other two show it.
  Future<void> seesUnsaved(String path) async {
    final Finder status = find.descendant(
      of: find.byType(StatusPanel),
      matching: find.text('Unsaved'),
    );
    await _waitUntil(() => _showing(status));
    expect(status, findsOneWidget, reason: 'no mark on the status bar');
    // The status bar's is the only word: the row above the document says
    // nothing about an edit that is only unwritten.
    expect(
      find.text('Unsaved'),
      findsOneWidget,
      reason: 'the row above the document says Unsaved too',
    );
    await seesTheOpenDocument(path);
    // The explorer's dot is found by being round rather than by a key: the
    // shape is what makes it a mark.
    expect(
      _marksInTheTree(),
      hasLength(1),
      reason: 'the explorer does not mark the file as unsaved',
    );
    // And the fourth place: the tab's dot, in the close's place.
    expect(
      _dotsInTheTabs(),
      isNotEmpty,
      reason: 'the tab does not carry the unsaved dot',
    );
  }

  /// The round dots the tab strip draws — an unsaved tab's, which takes the
  /// place of its close.
  Iterable<BoxDecoration> _dotsInTheTabs() => tester
      .widgetList<Container>(
        find.descendant(
          of: find.byType(EditorTabsWidget),
          matching: find.byType(Container),
        ),
      )
      .map((Container it) => it.decoration)
      .whereType<BoxDecoration>()
      .where((BoxDecoration it) => it.shape == BoxShape.circle);

  /// Asserts [dirty] tabs carry the unsaved dot where their close would be,
  /// and every other of the [tabs] still offers its `✕` — a tab with edits
  /// cannot be closed by one stray click.
  void seesTheDotInPlaceOfTheClose({required int dirty, required int tabs}) {
    expect(_dotsInTheTabs(), hasLength(dirty), reason: 'unsaved dots');
    expect(
      find.descendant(
        of: find.byType(EditorTabsWidget),
        matching: find.byTooltip('Close'),
      ),
      findsNWidgets(tabs - dirty),
      reason: 'the tabs without edits do not all offer a close',
    );
  }

  /// Asserts no tab in the strip is called [name].
  void seesNoTab(String name) {
    expect(
      find.descendant(
        of: find.byType(EditorTabsWidget),
        matching: find.text(name),
      ),
      findsNothing,
      reason: 'there is still a tab called $name',
    );
  }

  /// Asserts the strip draws the tab called [name] as the chosen one: in
  /// the heavier weight, the others at rest.
  Future<void> seesTheChosenTab(String name) async {
    Iterable<String> chosen() => tester
        .widgetList<Text>(
          find.descendant(
            of: find.byType(EditorTabsWidget),
            matching: find.byType(Text),
          ),
        )
        .where((Text it) => it.style?.fontWeight == FontWeight.w500)
        .map(
          (Text it) => (it.textSpan ?? TextSpan(text: it.data)).toPlainText(),
        );
    await _waitUntil(() => chosen().any((String it) => it.startsWith(name)));
    expect(chosen().toList(), <Matcher>[
      startsWith(name),
    ], reason: 'the chosen tab is not $name');
  }

  /// The unsaved marks the file tree is drawing.
  ///
  /// Round **and** in `modified`: the tree draws a second dot on a folder
  /// that holds a change, in another role, and counting shape alone made an
  /// unsaved document look like two
  /// (`docs/product/navigation/file-tree/change-marks/doc.md`). Scoped to
  /// the body, since the search box above it is round too.
  Iterable<BoxDecoration> _marksInTheTree() => tester
      .widgetList<DecoratedBox>(
        find.descendant(
          of: find.byType(FileTreeBodyWidget),
          matching: find.byType(DecoratedBox),
        ),
      )
      .map((DecoratedBox box) => box.decoration)
      .whereType<BoxDecoration>()
      .where(
        (BoxDecoration it) =>
            it.shape == BoxShape.circle &&
            // Either palette: the app follows the platform's theme and the
            // runner's is not this harness's to decide.
            (it.color == TomColors.dark.modified ||
                it.color == TomColors.light.modified),
      );

  /// Asserts nothing is waiting to be written.
  Future<void> seesNothingUnsaved(String path) async {
    await _waitUntil(() => !_showing(find.text('Unsaved')));
    expect(find.text('Unsaved'), findsNothing);
    expect(
      find.text('Not saved'),
      findsNothing,
      reason: 'the save was refused',
    );
    await seesTheOpenDocument(path);
    expect(
      _marksInTheTree(),
      isEmpty,
      reason: 'the explorer still marks a file that was saved',
    );
    expect(
      _dotsInTheTabs(),
      isEmpty,
      reason: 'a tab still carries the unsaved dot',
    );
  }

  /// Asserts the top bar says which repository the space is a folder of
  /// (rule 12): `app / docs`, not `docs` alone.
  void seesTheSpaceIsIn(String repository) {
    expect(
      find.text(repository),
      findsWidgets,
      reason: 'the top bar does not name the repository the space is in',
    );
    // In the chrome and not in the tree, where a folder of that name would
    // be a different thing.
    seesNotInTheTree(repository);
  }

  /// Whatever the file tree shows as [name]; the chrome names the space's
  /// folder too.
  Finder _inTheTree(String name) => find.descendant(
    of: find.byType(FileTreePanel),
    matching: find.text(name),
  );

  /// Whatever the search panel shows as [text]; the tree lists the same
  /// files, and an excerpt is rich text because the words typed are marked.
  Finder _inTheResults(String text) => find.descendant(
    of: find.byType(SearchResultsPanel),
    matching: find.textContaining(text, findRichText: true),
  );

  /// What the breadcrumb's menu says, scoped to the surface it opens — the
  /// bar behind it names the same space.
  Finder _inTheSpaceMenu(String text) => find.descendant(
    of: find.byType(SpaceMenuPopoverWidget),
    matching: find.textContaining(text, findRichText: true),
  );

  /// One thing the menu says, word for word.
  Finder _saying(String text) => find.descendant(
    of: find.byType(SpaceMenuPopoverWidget),
    matching: find.text(text),
  );

  /// What an occurrence's row says, scoped to the list in the open document.
  Finder _inTheOccurrences(String text) => find.descendant(
    of: find.byType(SearchOccurrencesPanel),
    matching: find.textContaining(text, findRichText: true),
  );

  /// The search box, scoped to its own widget because the changes panel has a
  /// field of its own — and the column itself has a second one once the
  /// replacement is open.
  Finder get _theSearchField => find.descendant(
    of: find.byType(SearchFieldWidget),
    matching: find.byType(TextField),
  );

  /// The replacement box: the second field of the pair, in the order the
  /// column stacks them.
  Finder get _theReplacementField => find
      .descendant(
        of: find.byType(SearchBoxes),
        matching: find.byType(TextField),
      )
      .last;

  /// Asserts the right column of a folder with no repository: the fact and
  /// the two sentences under it, and none of git's controls anywhere
  /// (`docs/product/workspace/without-a-repository/doc.md`).
  Future<void> seesNoRepository() async {
    const String fact = 'This folder is not inside a Git repository.';
    await _waitUntil(() => _showing(find.text(fact)));
    expect(find.text(fact), findsOneWidget, reason: 'the column says nothing');
    expect(find.text('Reading and editing work as usual.'), findsOneWidget);
    expect(find.text('Nothing here is versioned.'), findsOneWidget);
    for (final String control in <String>[
      'History',
      'Fetch',
      'Pull',
      'Diff',
      'Stage all',
    ]) {
      expect(find.text(control), findsNothing, reason: '$control is drawn');
    }
  }

  /// Asserts the commands panel lists no command holding [fragment].
  void seesNoCommand(String fragment) => expect(
    find.descendant(
      of: find.byType(CommandsPanel),
      matching: find.textContaining(fragment),
    ),
    findsNothing,
    reason: '"$fragment" was run',
  );

  /// Asserts the recent list offers [names], in that order.
  Future<void> seesRecent(List<String> names) async {
    await _waitUntil(() => _showing(find.text('RECENT')));
    expect(find.text('RECENT'), findsOneWidget, reason: 'no recent list');
    for (final String name in names) {
      expect(find.text(name), findsOneWidget, reason: '$name is not offered');
    }
    for (int i = 1; i < names.length; i++) {
      expect(
        tester.getCenter(find.text(names[i - 1])).dy,
        lessThan(tester.getCenter(find.text(names[i])).dy),
        reason: '${names[i - 1]} should be above ${names[i]}',
      );
    }
  }

  /// Asserts the recent row [name] says it is on [branch], waiting for git
  /// to answer.
  Future<void> seesRecentOnBranch(String name, String branch) async {
    await _waitUntil(() => _showing(find.text(branch)));
    final Finder row = find.ancestor(
      of: find.text(name),
      matching: find.byType(InkWell),
    );
    expect(
      find.descendant(of: row.first, matching: find.text(branch)),
      findsOneWidget,
      reason: '$name does not say it is on $branch',
    );
  }

  /// Asserts nothing is offered to go back to, waiting for the list to go
  /// once the preferences file is written.
  Future<void> seesNoRecent() async {
    await _waitUntil(() => !_showing(find.text('RECENT')));
    expect(find.text('RECENT'), findsNothing);
  }

  // ── Wikilinks ──────────────────────────────────────────────────────────

  /// The words of the preview's link that reads [shown], count included.
  Finder _theLink(String shown) => find.descendant(
    of: find.byType(PreviewWikilinkWidget),
    matching: find.byWidgetPredicate(
      (Widget widget) =>
          widget is Text &&
          (widget.data ?? widget.textSpan?.toPlainText()) == shown,
    ),
  );

  /// The ink the link reading [shown] is drawn in: its words', never the
  /// count's after them.
  Color? _inkOfTheLink(String shown) {
    final Text text = tester.widget<Text>(_theLink(shown).first);
    if (text.data != null) {
      return text.style?.color;
    }
    final InlineSpan? span = text.textSpan;
    return span is TextSpan && span.children != null
        ? span.children!.first.style?.color
        : span?.style?.color;
  }

  /// Waits for the link reading [shown] to wear the role [role] names, and
  /// asserts it.
  Future<void> _seesTheLinkIn(
    String shown,
    Color Function(TomColors colors) role,
    String what,
  ) async {
    Color? expected() => _showing(_theLink(shown))
        ? role(TomColors.of(tester.element(_theLink(shown).first)))
        : null;
    await _waitUntil(
      () => _showing(_theLink(shown)) && _inkOfTheLink(shown) == expected(),
    );
    expect(_theLink(shown), findsWidgets, reason: 'no link "$shown"');
    expect(
      _inkOfTheLink(shown),
      expected(),
      reason: 'the link "$shown" is not drawn as $what',
    );
  }

  /// Asserts the preview draws [label] as a link that resolves: `accent`.
  Future<void> seesALinkThatResolves(String label) =>
      _seesTheLinkIn(label, (TomColors c) => c.accent, 'resolved');

  /// Asserts the preview draws [label] as a link to nothing: `removed`.
  Future<void> seesALinkThatIsMissing(String label) =>
      _seesTheLinkIn(label, (TomColors c) => c.removed, 'missing');

  /// Asserts the preview draws [label] as a name [count] documents share:
  /// `modified`, the count raised after it.
  Future<void> seesALinkThatIsAmbiguous(String label, int count) =>
      _seesTheLinkIn(
        '$label${PreviewWikilinkWidget.superscript(count)}',
        (TomColors c) => c.modified,
        'ambiguous',
      );

  /// Clicks the preview's link reading [label].
  Future<void> followsTheLink(String label) async {
    await _waitUntil(() => _showing(_theLink(label)));
    await tester.tap(_theLink(label).first);
    await settle();
  }

  /// Rests the mouse on the preview's link reading [label], the way the tip
  /// is asked for.
  Future<void> pointsAtTheLink(String label) async {
    await _waitUntil(() => _showing(_theLink(label)));
    final TestGesture mouse = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
    );
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(_theLink(label).first));
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Asserts the tip under a missing link names [target] and offers to
  /// create it.
  Future<void> seesTheLinkOffersToCreate(String target) async {
    final Finder tip = find.byType(PreviewWikilinkTipWidget);
    await _waitUntil(() => _showing(tip));
    expect(
      find.descendant(
        of: tip,
        matching: find.text('No document called $target.'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: tip, matching: find.text('Create it')),
      findsOneWidget,
    );
  }

  /// Presses the tip's `Create it`.
  Future<void> createsTheLinkedDocument() async {
    await tester.tap(
      find.descendant(
        of: find.byType(PreviewWikilinkTipWidget),
        matching: find.text('Create it'),
      ),
    );
    await settle();
  }

  /// Asserts the menu an ambiguous link opened lists one row per document
  /// sharing [name], each named by its folder in [folders].
  Future<void> seesTheLinkCandidates(String name, List<String> folders) async {
    final Finder menu = find.byType(TomMenuWidget);
    await _waitUntil(() => _showing(menu));
    expect(
      find.descendant(of: menu, matching: find.text(name)),
      findsNWidgets(folders.length),
      reason: 'the menu does not list every "$name"',
    );
    for (final String folder in folders) {
      expect(
        find.descendant(of: menu, matching: find.text(folder)),
        findsOneWidget,
        reason: 'no candidate in "$folder"',
      );
    }
  }

  /// Chooses the candidate in [folder] from an ambiguous link's menu.
  Future<void> choosesTheLinkCandidate(String folder) async {
    await tester.tap(
      find.descendant(
        of: find.byType(TomMenuWidget),
        matching: find.text(folder),
      ),
    );
    await settle();
  }

  /// Types [typed] at the very end of the source, the way a keystroke
  /// does: the editor takes the keyboard first, then the text lands at the
  /// caret.
  ///
  /// The one other place this file drives the editor's controller: a code
  /// editor has no `enterText`, and a whole-text assignment is not typing.
  Future<void> typesAtTheEndOfTheSource(String typed) async {
    await tester.tap(find.byType(CodeEditor));
    await tester.pump(const Duration(milliseconds: 200));
    final CodeLineEditingController editor = tester
        .widget<CodeEditor>(find.byType(CodeEditor))
        .controller!;
    final int last = editor.lineCount - 1;
    editor
      ..selection = CodeLineSelection.collapsed(
        index: last,
        offset: editor.codeLines[last].text.length,
      )
      ..replaceSelection(typed);
    // Pumped, not settled: the caret blinks for as long as it has the
    // keyboard.
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Asserts `[[` is offering exactly [names], best first.
  Future<void> seesTheLinkSuggestions(List<String> names) async {
    final Finder offer = find.byType(EditorCompletionWidget);
    await _waitUntil(() => _showing(offer));
    expect(offer, findsOneWidget, reason: '`[[` offered nothing');
    expect(<String>[
      for (final WikilinkCandidateValueObject candidate
          in tester.widget<EditorCompletionWidget>(offer).candidates)
        candidate.path.value.split('/').last,
    ], names);
  }

  /// Selects the first [word] in the source, the way a drag would: the
  /// editor takes the keyboard first, then its controller holds the range.
  Future<void> selectsInTheSource(String word) async {
    await tester.tap(find.byType(CodeEditor));
    await tester.pump(const Duration(milliseconds: 200));
    final CodeLineEditingController editor = tester
        .widget<CodeEditor>(find.byType(CodeEditor))
        .controller!;
    for (int line = 0; line < editor.lineCount; line++) {
      final int column = editor.codeLines[line].text.indexOf(word);
      if (column >= 0) {
        editor.selection = CodeLineSelection(
          baseIndex: line,
          baseOffset: column,
          extentIndex: line,
          extentOffset: column + word.length,
        );
        await tester.pump(const Duration(milliseconds: 300));
        return;
      }
    }
    fail('"$word" is not in the source');
  }

  /// Presses the platform's modifier with [letter] — and Shift, when asked —
  /// where the keyboard already is: in the source pane.
  Future<void> pressesTheFormattingKey(
    LogicalKeyboardKey letter, {
    bool shift = false,
  }) async {
    final LogicalKeyboardKey modifier = Platform.isMacOS
        ? LogicalKeyboardKey.meta
        : LogicalKeyboardKey.control;
    await tester.sendKeyDownEvent(modifier);
    if (shift) {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
    }
    await tester.sendKeyEvent(letter);
    if (shift) {
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
    }
    await tester.sendKeyUpEvent(modifier);
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Asserts `[[` is offering nothing.
  Future<void> seesNoLinkSuggestion() async {
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.byType(EditorCompletionWidget),
      findsNothing,
      reason: '`[[` offered something it should not',
    );
  }

  /// Presses Enter while `[[` is offering, which writes the chosen row.
  Future<void> acceptsTheLinkSuggestion() async {
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(EditorCompletionWidget), findsNothing);
  }

  /// Asserts the app is not showing an unhandled error, which makes every
  /// other assertion fail confusingly.
  void seesNothingBroken() {
    expect(tester.takeException(), isNull);
    expect(find.byType(ErrorWidget), findsNothing);
  }

  static const String _forget = 'Forget this space';
}
