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
import 'package:tom_desktop/screens/compare/compare_control_widget.dart';
import 'package:tom_desktop/screens/compare/widgets/compare_popover_widget.dart';
import 'package:tom_desktop/screens/file_tree/file_tree_panel.dart';
import 'package:tom_desktop/screens/history/history_panel.dart';
import 'package:tom_desktop/screens/preview/preview_panel.dart';
import 'package:tom_desktop/screens/shell/status_panel.dart';
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

  /// Starts the app sized for a desktop window; the default test surface is
  /// narrower than a phone and overflows the shell.
  Future<void> launchWindowed({
    String? pickFolder,
    Size size = const Size(1280, 840),
  }) async {
    tester.view
      ..physicalSize = size
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
      matching: find.byType(Checkbox),
    );
    await tester.tap(box());
    // Waited for, not settled: staging runs git and re-reads it, and nothing
    // animates meanwhile.
    await _waitUntil(
      () => _showing(box()) && tester.widget<Checkbox>(box()).value == true,
    );
    await settle();
  }

  /// Presses *Fetch* and waits for the button to come back, which is git
  /// having answered.
  Future<void> fetches() => _remoteAction('Fetch');

  /// Presses *Push*.
  Future<void> pushes() => _remoteAction('Push');

  /// Presses *Pull*, which lives inside the rejection rather than the bar.
  Future<void> pulls() => _remoteAction('Pull');

  /// Presses the remote action saying [label], and waits for it to finish.
  Future<void> _remoteAction(String label) async {
    await _waitUntil(() => _showing(find.text(label)));
    await tester.tap(find.text(label));
    // The bar's buttons read `Fetch…` while it runs; the label coming back is
    // the action finished and the status re-read.
    await _waitUntil(() => _showing(find.text(label)));
    await settle();
  }

  /// Ticks *All*, staging everything the panel lists — the caption's own
  /// checkbox, the one [stages] avoids.
  Future<void> stagesEverything() async {
    final Finder all = find.descendant(
      of: find.ancestor(of: find.text('All'), matching: find.byType(Row)).first,
      matching: find.byType(Checkbox),
    );
    await _waitUntil(() => _showing(all));
    await tester.tap(all);
    await _waitUntil(
      () => _showing(all) && tester.widget<Checkbox>(all).value == true,
    );
    await settle();
  }

  /// Asserts *Commit* cannot be pressed: unavailable rather than absent, and
  /// refused before the attempt.
  Future<void> seesCommitUnavailable() async {
    final Finder button = find.descendant(
      of: find.byType(ChangesPanel),
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
    final Finder button = find.descendant(
      of: find.byType(ChangesPanel),
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

  /// Clicks the row of the file tree that shows [name], scoped to the
  /// explorer because the top bar names the space's folder too.
  Future<void> clickInTheTree(String name) async {
    // Waited for here rather than in each scenario: the shell is on screen
    // before the folder walk has answered.
    await _waitUntil(() => _showing(_inTheTree(name)));
    await tester.tap(_inTheTree(name));
    await settle();
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

  /// Asserts the preview is showing a document that says [text], as rich
  /// text because the preview renders markdown rather than writing it out.
  Future<void> seesInThePreview(String text) async {
    final Finder shown = find.textContaining(text, findRichText: true);
    await _waitUntil(() => _showing(shown));
    expect(shown, findsWidgets, reason: 'the preview is not showing "$text"');
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

  /// Asserts the top bar says how far the branch has drifted; a zero half is
  /// absent rather than a counter reading nothing.
  Future<void> seesTheDrift({int ahead = 0, int behind = 0}) async {
    final String expected = <String>[
      if (ahead > 0) '↑ $ahead',
      if (behind > 0) '↓ $behind',
    ].join('  ');
    if (expected.isEmpty) {
      await _waitUntil(() => !_showing(find.textContaining('↑')));
      expect(find.textContaining('↑'), findsNothing);
      expect(find.textContaining('↓'), findsNothing);
      return;
    }
    await _waitUntil(() => _showing(find.text(expected)));
    expect(
      find.text(expected),
      findsOneWidget,
      reason: 'the top bar does not say the branch is $expected',
    );
  }

  /// Asserts the push was refused, in all three sentences the product chose
  /// (`docs/product/git-workflow/push-pull/doc.md`).
  Future<void> seesThePushRefused({required int commits}) async {
    final String headline =
        'Someone pushed $commits commit${commits == 1 ? '' : 's'} first.';
    await _waitUntil(() => _showing(find.text(headline)));
    expect(find.text(headline), findsOneWidget, reason: 'no rejection said');
    expect(
      find.text(
        'Pull them, then push again. Nothing you committed has been lost.',
      ),
      findsOneWidget,
      reason: 'the rejection does not say the work is safe',
    );
    expect(find.text('Pull'), findsOneWidget, reason: 'no way out of it');
  }

  /// Asserts nothing on screen is claiming a push was refused.
  void seesNoRefusal() {
    expect(find.textContaining('Someone pushed'), findsNothing);
    expect(find.text('Pull'), findsNothing);
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
    final Finder control = find.descendant(
      of: find.byType(CompareControlWidget),
      matching: find.byType(TextButton),
    );
    await _waitUntil(() => _showing(control));
    await tester.tap(control);
    await _waitUntil(() => _showing(_theComparisonField));
  }

  /// Opens it and picks [revision], by the name or subject it is listed under.
  Future<void> comparesAgainst(String revision) async {
    await opensTheComparison();
    // The lists are read when the surface opens, so the row being reached
    // for is not there on the first frame.
    await _waitUntil(() => _showing(_inTheComparison(revision)));
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

  /// Asserts the bar is back to offering a comparison rather than naming one.
  Future<void> seesTheDefaultComparison() async {
    await _waitUntil(() => _showing(find.text('Compare against…')));
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

  /// Asserts which of the two panes the document area is showing, by each
  /// panel's own caption.
  void seesThePanes({required bool source, required bool preview}) {
    expect(
      find.text('SOURCE'),
      source ? findsOneWidget : findsNothing,
      reason: 'the source pane should ${source ? '' : 'not '}be on screen',
    );
    expect(
      find.text('PREVIEW'),
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

  /// Every round mark the file tree is drawing.
  Iterable<BoxDecoration> _marksInTheTree() => tester
      .widgetList<DecoratedBox>(
        find.descendant(
          of: find.byType(FileTreePanel),
          matching: find.byType(DecoratedBox),
        ),
      )
      .map((DecoratedBox box) => box.decoration)
      .whereType<BoxDecoration>()
      .where((BoxDecoration it) => it.shape == BoxShape.circle);

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
