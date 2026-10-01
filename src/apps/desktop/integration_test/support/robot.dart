/// Everything a scenario can do to the app, and everything it can see.
library;

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_editor/re_editor.dart';
import 'package:tom_desktop/bootstrap/run_tom.dart';
import 'package:tom_desktop/bootstrap/tom_module.dart';
import 'package:tom_desktop/screens/branches/branches_control_widget.dart';
import 'package:tom_desktop/screens/branches/widgets/branches_popover_widget.dart';
import 'package:tom_desktop/screens/changes/changes_panel.dart';
import 'package:tom_desktop/screens/changes/widgets/changes_remote_widget.dart';
import 'package:tom_desktop/screens/compare/compare_control_widget.dart';
import 'package:tom_desktop/screens/compare/compare_design.dart';
import 'package:tom_desktop/screens/compare/widgets/compare_popover_widget.dart';
import 'package:tom_desktop/screens/editor/editor_panel.dart';
import 'package:tom_desktop/screens/editor/widgets/editor_marks_widget.dart';
import 'package:tom_desktop/screens/file_tree/file_tree_panel.dart';
import 'package:tom_desktop/screens/file_tree/widgets/file_tree_body_widget.dart';
import 'package:tom_desktop/screens/history/history_panel.dart';
import 'package:tom_desktop/screens/preview/preview_panel.dart';
import 'package:tom_desktop/screens/preview/widgets/preview_footnotes_widget.dart';
import 'package:tom_desktop/screens/search/search_boxes.dart';
import 'package:tom_desktop/screens/search/search_field_widget.dart';
import 'package:tom_desktop/screens/search/search_occurrences_panel.dart';
import 'package:tom_desktop/screens/search/search_results_panel.dart';
import 'package:tom_desktop/screens/shell/status_panel.dart';
import 'package:tom_desktop/screens/spaces/space_menu_control_widget.dart';
import 'package:tom_desktop/screens/spaces/widgets/space_menu_popover_widget.dart';
import 'package:tom_desktop/screens/workspace/workspace_grip_widget.dart';
import 'package:tom_ui/tom_ui.dart';
import 'package:window_manager/window_manager.dart';
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

  /// What photographs the window after every action this performs.
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
  /// dialog answering [pickFolder].
  ///
  /// Mounted rather than started, because a scenario relaunches to prove
  /// something survived a restart and `runApp` a second time does not
  /// replace a tree already there. The window's title and size are left out.
  Future<void> launch({String? pickFolder}) async {
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
    await tester.pumpWidget(
      tomApp(
        modules: <TomModule>[
          E2eModuleImpl(folder: pickFolder, settingsPath: settingsPath),
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
  }) async {
    tester.view
      ..physicalSize = boardWindow ?? size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await launch(pickFolder: pickFolder);
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
  /// cannot forget the wrong space and pass.
  Future<void> forgetRecent(String name) async {
    final Finder row = find.ancestor(
      of: find.text(name),
      matching: find.byType(Row),
    );
    await tester.tap(
      find.descendant(of: row.last, matching: find.byTooltip(_forget)),
    );
    await settle();
  }

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

  /// Ticks the changes row that shows [name], staging it.
  ///
  /// Scoped to the row, because the caption's own checkbox — *All* — would
  /// stage everything.
  Future<void> stages(String name) async {
    await _waitUntil(() => _showing(_inTheChanges(name)));
    Finder box() => find.descendant(
      of: find
          .ancestor(of: _inTheChanges(name), matching: find.byType(Row))
          .first,
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

  /// Any of the three saying it is the one in flight.
  Finder get _working => find.descendant(
    of: find.byType(ChangesRemoteWidget),
    matching: find.textContaining('…'),
  );

  /// Ticks *All*, staging everything the panel lists — the caption's own
  /// checkbox, the one [stages] avoids.
  Future<void> stagesEverything() async {
    final Finder all = find.descendant(
      of: find.ancestor(of: find.text('All'), matching: find.byType(Row)).first,
      matching: find.byType(TomCheckWidget),
    );
    await _waitUntil(() => _showing(all));
    await tester.tap(all);
    await _waitUntil(
      () => _showing(all) && tester.widget<TomCheckWidget>(all).isChecked,
    );
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
    await settle();
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

  /// Clicks the row of the file tree that shows [name], scoped to the
  /// explorer because the top bar names the space's folder too.
  Future<void> clickInTheTree(String name) async {
    // Waited for here rather than in each scenario: the shell is on screen
    // before the folder walk has answered.
    await _waitUntil(() => _showing(_inTheTree(name)));
    await tester.tap(_inTheTree(name));
    await settle();
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
    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(find.byType(WorkspaceGripWidget).first),
    );
    await gesture.moveBy(Offset(dx, 0));
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

  /// Opens the breadcrumb's menu of spaces.
  Future<void> opensTheSpaceMenu() async {
    await tester.tap(find.byType(SpaceMenuControlWidget));
    await settle();
  }

  /// Leaves the space, from that menu.
  Future<void> closesTheSpace() async {
    await tester.tap(_saying('Close space'));
    await settle();
  }

  /// Goes straight to the space called [name], from that menu.
  ///
  /// By the row's name exactly, because the path under it holds the name
  /// too and a loose match finds both.
  Future<void> opensFromTheSpaceMenu(String name) async {
    await _waitUntil(() => _showing(_saying(name)));
    await tester.tap(_saying(name));
    await settle();
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

  /// Opens the second box, the one that says what the words become.
  Future<void> opensTheReplacement() async {
    await tester.tap(find.byTooltip('Replace'));
    await tester.pump(const Duration(milliseconds: 300));
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
    await tester.tap(find.byTooltip('Replace this one').first);
    await tester.pump(const Duration(milliseconds: 300));
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

  /// Asserts the preview is showing a document that says [text], as rich
  /// text because the preview renders markdown rather than writing it out.
  Future<void> seesInThePreview(String text) async {
    final Finder shown = find.textContaining(text, findRichText: true);
    await _waitUntil(() => _showing(shown));
    expect(shown, findsWidgets, reason: 'the preview is not showing "$text"');
  }

  /// Asserts the preview is **not** showing [text].
  Future<void> seesNotInThePreview(String text) async {
    final Finder shown = find.textContaining(text, findRichText: true);
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
    // In order: the second citation is below the first.
    for (int at = 1; at < numbers.length; at++) {
      expect(
        tester.getTopLeft(find.text(numbers[at])).dy,
        greaterThan(tester.getTopLeft(find.text(numbers[at - 1])).dy),
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

  /// Asserts the status bar names [path] as the open document, scoped to the
  /// bar because a document at the space's root is spelled the same in the
  /// tree.
  Future<void> seesTheOpenDocument(String path) async {
    final Finder shown = find.descendant(
      of: find.byType(StatusPanel),
      matching: find.text(path),
    );
    await _waitUntil(() => _showing(shown));
    expect(shown, findsOneWidget, reason: 'the status bar does not name $path');
  }

  /// Asserts the source pane is showing [text], through the editor's own
  /// controller (see [typesInTheSource]).
  Future<void> seesInTheSource(String text) async {
    await _waitUntil(() => _showing(find.byType(CodeEditor)));
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

  /// Asserts the formatting bar is drawn.
  Future<void> seesTheFormattingBar() async {
    await _waitUntil(() => _showing(find.byType(TomToolbarButtonWidget)));
    expect(find.byType(TomToolbarButtonWidget), findsWidgets);
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
    final Finder button = find
        .ancestor(
          of: find.byTooltip(word),
          matching: find.byType(TomToolbarButtonWidget),
        )
        .first;
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
    expect(
      painter.marks.isEmpty,
      isFalse,
      reason: 'the source pane marks no line as conflicted',
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

  /// Asserts the buttons say how far the branch has drifted: `Push (2)` and
  /// `Pull (3)`, the verb and the number, and a bare verb where there is
  /// nothing to count.
  Future<void> seesTheDrift({int ahead = 0, int behind = 0}) async {
    final String push = ahead > 0 ? 'Push ($ahead)' : 'Push';
    final String pull = behind > 0 ? 'Pull ($behind)' : 'Pull';
    Finder saying(String label) => find.descendant(
      of: find.byType(ChangesRemoteWidget),
      matching: find.text(label),
    );
    await _waitUntil(
      () =>
          _showing(saying(push)) &&
          _showing(saying(pull)) &&
          !_showing(_working),
    );
    expect(
      saying(push),
      findsOneWidget,
      reason: 'the column does not say $push',
    );
    expect(
      saying(pull),
      findsOneWidget,
      reason: 'the column does not say $pull',
    );
    // The counts are in the buttons and nowhere else: an indicator beside the
    // branch would be the same fact twice
    // (`docs/product/git-workflow/push-pull/the-controls/doc.md`).
    expect(find.textContaining('↑'), findsNothing);
    expect(find.textContaining('↓'), findsNothing);
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
  void seesNoRefusal() {
    expect(find.textContaining('Someone pushed'), findsNothing);
    expect(find.byType(NoticeBandWidget), findsNothing);
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
    // Nothing types into the past, so the three modes give way entirely.
    expect(
      find.text('Split'),
      findsNothing,
      reason: 'the modes are still being offered over a past version',
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

  // ── Comparing against a branch or a commit ───────────────────────────

  /// Opens the surface that chooses what the document is compared against.
  Future<void> opensTheComparison() async {
    // The `Diff` chip is the trigger; the base's name beside it is a label.
    final Finder control = find.descendant(
      of: find.byType(CompareControlWidget),
      matching: find.text('Diff'),
    );
    await _waitUntil(() => _showing(control));
    await tester.tap(control);
    await _waitUntil(() => _showing(_theComparisonField));
  }

  /// Opens it and picks [revision], by the name or subject it is listed under.
  Future<void> comparesAgainst(String revision) async {
    await opensTheComparison();
    // The list's own scrollable, not the filter field's: a `TextField` is a
    // `Scrollable` too, and the surface holds both.
    final Finder list = find.descendant(
      of: find.descendant(
        of: find.byType(ComparePopoverWidget),
        matching: find.byType(ListView),
      ),
      matching: find.byType(Scrollable),
    );
    // The lists are read when the surface opens, so nothing to scroll is
    // there on the first frame.
    await _waitUntil(() => _showing(list));
    // **The surface is as tall as the design fixes it and its list scrolls**,
    // so a commit past the second is a row the viewport has not built:
    // tapping it without this is a silent no-op, the trap the toolbar paid
    // for.
    await tester.scrollUntilVisible(
      _inTheComparison(revision),
      CompareDesign.commitPitch,
      scrollable: list,
    );
    await tester.tap(_inTheComparison(revision));
    await settle();
  }

  /// Opens it and takes the comparison back to the last commit.
  Future<void> stopsComparing() async {
    await opensTheComparison();
    await tapText('Compare against the last commit');
  }

  /// Asserts the bar says the document is compared against [what].
  Future<void> seesTheComparison(String what) async {
    final Finder shown = find.descendant(
      of: find.byType(CompareControlWidget),
      matching: find.textContaining(what),
    );
    await _waitUntil(() => _showing(shown));
    expect(
      shown,
      findsOneWidget,
      reason: 'the bar does not say the document is compared to $what',
    );
  }

  /// Asserts the bar names no base, which is the working tree against `HEAD`.
  ///
  /// The chip stays; what goes is the name beside it.
  Future<void> seesTheDefaultComparison() async {
    await _waitUntil(
      () => !_showing(
        find.descendant(
          of: find.byType(CompareControlWidget),
          matching: find.textContaining('Compared to'),
        ),
      ),
    );
    expect(find.textContaining('Compared to'), findsNothing);
  }

  /// Asserts the open surface is offering each of [names].
  Future<void> seesOnOffer(List<String> names) async {
    await _waitUntil(() => _showing(_inTheComparison(names.first)));
    for (final String name in names) {
      expect(
        _inTheComparison(name),
        findsOneWidget,
        reason: '$name is not among the revisions offered',
      );
    }
  }

  /// Whatever the compare popover shows as [text]; the control above it names
  /// the base the document is already on.
  Finder _inTheComparison(String text) => find.descendant(
    of: find.byType(ComparePopoverWidget),
    matching: find.text(text),
  );

  /// The popover's own box, which is the one field on screen while it is up.
  Finder get _theComparisonField => find.descendant(
    of: find.byType(ComparePopoverWidget),
    matching: find.byType(TextField),
  );

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

  /// Asserts nothing is asking about unsaved work.
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

  /// The commit box, scoped to the panel because the branch popover has a
  /// field of its own.
  Finder get _anyField => find.descendant(
    of: find.byType(ChangesPanel),
    matching: find.byType(TextField),
  );

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
    await _waitUntil(() => _showing(find.text('Unsaved')));
    expect(find.text('Unsaved'), findsOneWidget, reason: 'no mark on the bar');
    await seesTheOpenDocument('$path — unsaved');
    // The explorer's dot is found by being round rather than by a key: the
    // shape is what makes it a mark.
    expect(
      _marksInTheTree(),
      hasLength(1),
      reason: 'the explorer does not mark the file as unsaved',
    );
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

  /// Asserts the refusal screen is showing, for a folder with no repository.
  Future<void> seesNotARepository(String folder) async {
    await _waitUntil(
      () => _showing(find.text('That folder is not inside a Git repository')),
    );
    expect(
      find.text('That folder is not inside a Git repository'),
      findsOneWidget,
    );
    expect(find.text(folder), findsOneWidget);
    expect(
      find.text('Creating a repository is not something TOM does.'),
      findsOneWidget,
      reason: 'the screen must say TOM will not create one',
    );
  }

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

  /// Asserts nothing is offered to go back to, waiting for the list to go
  /// once the preferences file is written.
  Future<void> seesNoRecent() async {
    await _waitUntil(() => !_showing(find.text('RECENT')));
    expect(find.text('RECENT'), findsNothing);
  }

  /// Asserts the app is not showing an unhandled error, which makes every
  /// other assertion fail confusingly.
  void seesNothingBroken() {
    expect(tester.takeException(), isNull);
    expect(find.byType(ErrorWidget), findsNothing);
  }

  static const String _forget = 'Forget this space';
}
