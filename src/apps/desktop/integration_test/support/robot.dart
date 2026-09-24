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
import 'package:tom_desktop/screens/file_tree/file_tree_panel.dart';
import 'package:tom_desktop/screens/history/history_panel.dart';
import 'package:tom_desktop/screens/preview/preview_panel.dart';
import 'package:tom_desktop/screens/shell/status_panel.dart';
import 'package:tom_ui/tom_ui.dart';
import 'e2e_module_impl.dart';

/// Drives the assembled app.
///
/// **This file is the reuse.** A scenario is a list of named steps and
/// nothing else; every tap, every wait and every assertion lives here, so
/// the tenth scenario costs a list and not another copy of "find the button,
/// tap it, settle". When the Home layout changes, one file changes.
///
/// It talks to the app the way a person does — through what is on screen —
/// and never reaches into a provider or a repository. A harness that read
/// the state directly would go green on an app whose screen never updated.
final class TomRobot {
  /// Wraps [tester], storing this scenario's preferences at [settingsPath].
  TomRobot(this.tester, {required this.settingsPath});

  /// The harness driving the widget tree.
  final WidgetTester tester;

  /// Where this scenario's preferences live.
  ///
  /// One file per scenario, cleared before the first step. Within a
  /// scenario it survives a relaunch — which is what "remembers a space"
  /// needs — and between scenarios nothing leaks, so the order they run in
  /// cannot change what they assert.
  final String settingsPath;

  /// Starts the app, with the folder dialog answering [pickFolder].
  ///
  /// The real modules and the real object graph — `tomApp` is what `main()`
  /// runs — plus one module that answers the native dialog no test can
  /// open. Mounted rather than started, because a scenario calls this more
  /// than once to prove something survived a restart, and `runApp` a second
  /// time does not replace a tree that is already there.
  ///
  /// The one thing it leaves out is the window: a title and a minimum size,
  /// which has no screen to assert about.
  Future<void> launch({String? pickFolder}) async {
    // Unmounted first, and this is not ceremony. Flutter updates an element
    // in place when the widget at that position is of the same type, so
    // pumping a second `ProviderScope` keeps the *first* one's container —
    // and with it every provider's state. A scenario that restarted the app
    // would find it exactly where it left it, which is the opposite of what
    // it is asserting.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    // Home's trunk animates forever, and `pumpAndSettle` waits for a frame
    // that never comes. The platform's own "no animations" switch is what
    // the widget honours, so the run asks for the still screen the way an
    // accessibility setting would — the product's own path, not a test hook.
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

  /// Starts the app sized for a desktop window.
  ///
  /// The shell is three regions side by side and has a minimum width it
  /// holds together in; a default test surface is narrower than a phone and
  /// would report overflows that no user can produce.
  Future<void> launchWindowed({
    String? pickFolder,
    Size size = const Size(1280, 840),
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await launch(pickFolder: pickFolder);
  }

  /// Waits until the app stops animating.
  ///
  /// With a timeout, because the default is ten minutes: an animation that
  /// never ends — a spinner on a screen with nothing coming, which this app
  /// has already had once — otherwise hangs the whole run rather than
  /// failing the step that caused it.
  Future<void> settle() async {
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 15),
    );
  }

  /// Pumps until [ready] holds, and gives up quietly when it does not.
  ///
  /// **Settling is not waiting.** `pumpAndSettle` returns as soon as no
  /// frame is scheduled, and the app's work is not a frame: opening a space
  /// runs `git` in another process, and a screen with nothing animating on
  /// it settles in a millisecond while that is still in flight. A scenario
  /// that asserted right there was reading the screen before the answer had
  /// arrived — which passed on a warm machine and failed on a busy one, at
  /// whichever step happened to lose the race.
  ///
  /// It gives up rather than throwing, so the assertion that follows fails
  /// with what was actually on screen instead of with a timeout.
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

  /// Presses *Choose folder…* on Home.
  ///
  /// What the dialog answers was decided at [launch]: the module overriding
  /// it is installed before the app starts, because the app reads it once.
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
  /// The row is found by its name and the button by its tooltip, rather than
  /// by position: a list that reordered would otherwise forget the wrong
  /// space and still pass.
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

  /// Chooses one of the modes on the bar above the document area.
  ///
  /// By its label — `Source`, `Split`, `Preview` — which is what a person
  /// clicks.
  Future<void> looksAt(String mode) async {
    await tapText(mode);
  }

  /// Replaces what the source pane holds with [source].
  ///
  /// **The one place this file touches a widget rather than the screen.** A
  /// code editor is not a `TextField` and has no `enterText`; what it does
  /// have is the controller the editor on screen is actually driving, so
  /// this is still the real editor being edited and not a provider being
  /// written to behind it.
  Future<void> typesInTheSource(String source) async {
    tester.widget<CodeEditor>(find.byType(CodeEditor)).controller!.text =
        source;
    await settle();
  }

  /// Ticks the changes row that shows [name], staging it.
  ///
  /// Scoped to the row rather than to the panel: the caption carries a
  /// checkbox of its own — *All* — and a tap that found that one would
  /// stage everything while the step said one file.
  Future<void> stages(String name) async {
    await _waitUntil(() => _showing(_inTheChanges(name)));
    Finder box() => find.descendant(
      of: find
          .ancestor(of: _inTheChanges(name), matching: find.byType(Row))
          .first,
      matching: find.byType(Checkbox),
    );
    await tester.tap(box());
    // Waited for, not settled: staging runs git in another process and then
    // reads it again, and a screen with nothing animating settles in a
    // millisecond while both are still in flight.
    await _waitUntil(
      () => _showing(box()) && tester.widget<Checkbox>(box()).value == true,
    );
    await settle();
  }

  /// Presses *Fetch* and waits for git to answer.
  ///
  /// The wait is for the button to come back: all three remote actions are
  /// disabled while one runs, and settling only says no frame is scheduled
  /// while git is still in another process.
  Future<void> fetches() => _remoteAction('Fetch');

  /// Presses *Push*.
  Future<void> pushes() => _remoteAction('Push');

  /// Presses *Pull*, which lives inside the rejection rather than the bar.
  Future<void> pulls() => _remoteAction('Pull');

  /// Presses the remote action saying [label], and waits for it to finish.
  Future<void> _remoteAction(String label) async {
    await _waitUntil(() => _showing(find.text(label)));
    await tester.tap(find.text(label));
    // While it runs the bar's own buttons read `Fetch…` and are disabled;
    // the label coming back is the action having finished *and* the status
    // having been read again.
    await _waitUntil(() => _showing(find.text(label)));
    await settle();
  }

  /// Ticks *All*, staging everything the panel is listing.
  ///
  /// The caption's own checkbox, which is the other half of "everything at
  /// once, or one file at a time" — and the reason [stages] is careful to
  /// find a *row's* box rather than this one.
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

  /// Asserts *Commit* cannot be pressed.
  ///
  /// Unavailable rather than absent, and refused before the attempt rather
  /// than reported after it.
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
  /// without a word: the step would go green and the assertion after it
  /// would fail somewhere else entirely.
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
    // The box emptying is what says the commit landed *and* the status has
    // been read again — settling only says no frame is scheduled, and git
    // is another process.
    await _waitUntil(
      () => tester.widget<TextField>(_anyField).controller!.text.isEmpty,
    );
    await settle();
  }

  /// Presses the save shortcut, the way a person does.
  ///
  /// The platform's own — a Mac user presses ⌘S — and the editor has to have
  /// the focus, which is what the tap is for.
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

  /// Clicks the row of the file tree that shows [name].
  ///
  /// Scoped to the explorer rather than to the window: the space's own folder
  /// is named in the top bar too, and a tap that found the chrome instead of
  /// the tree would pass while doing nothing.
  Future<void> clickInTheTree(String name) async {
    // Waited for, not assumed: opening a space walks a real folder, and the
    // shell is on screen before that answer has arrived. Here rather than in
    // each scenario, so the race is paid for once.
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

  /// Asserts the shell has taken over — a space is open.
  ///
  /// By the explorer, which the product says is always on screen once a
  /// space is open and never hidden by anything.
  Future<void> seesTheShell() async {
    await _waitUntil(() => _showing(find.text('EXPLORER')));
    expect(
      find.text('EXPLORER'),
      findsOneWidget,
      reason: 'the shell is not showing; is a space actually open?',
    );
    expect(find.text('Choose folder…'), findsNothing);
  }

  /// Asserts the tree shows [names], each exactly once.
  ///
  /// The wait is the same race as everywhere else, read forwards: opening a
  /// space walks the folder, and the shell is on screen before that answer
  /// has arrived.
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

  /// Asserts the preview is showing a document that says [text].
  ///
  /// Rich text, because the preview renders markdown rather than writing it
  /// out: `find.text` would match nothing at all here.
  Future<void> seesInThePreview(String text) async {
    final Finder shown = find.textContaining(text, findRichText: true);
    await _waitUntil(() => _showing(shown));
    expect(shown, findsWidgets, reason: 'the preview is not showing "$text"');
  }

  /// Asserts the rendered diff is marking [letters], top to bottom.
  ///
  /// Scoped to the preview, because the changes column draws the same mark
  /// about whole files — a finder that matched either would pass while the
  /// document carried no decoration at all.
  Future<void> seesTheDiffMarks(List<String> letters) async {
    // On the letters and not on how many there are: a block going from
    // added to modified is one mark either way, and a wait that counted
    // them would come back happy with the decoration from before the edit.
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

  /// Asserts the status bar names [path] as the document that is open.
  ///
  /// Scoped to the bar, because a document at the space's root has the same
  /// spelling in the tree — and a finder that matched either would pass
  /// while the bar said nothing.
  Future<void> seesTheOpenDocument(String path) async {
    final Finder shown = find.descendant(
      of: find.byType(StatusPanel),
      matching: find.text(path),
    );
    await _waitUntil(() => _showing(shown));
    expect(shown, findsOneWidget, reason: 'the status bar does not name $path');
  }

  /// Asserts the source pane is showing [text].
  ///
  /// Through the editor's own controller, for the reason [typesInTheSource]
  /// gives: what a code editor paints is not a `Text` widget.
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

  /// Asserts the changes panel does not list [name].
  ///
  /// Waits for the row to *go*, which is the same race read backwards: a
  /// file stops differing because git was asked again, and the row is still
  /// on screen until that answer arrives.
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

  /// Asserts the top bar says how far the branch has drifted.
  ///
  /// [ahead] and [behind] are what the two arrows should read; zero means
  /// that half should be absent, because a counter with nothing to count is
  /// chrome read twice and ignored.
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

  /// Asserts the push was refused, in the words the product chose.
  ///
  /// All three sentences, because the wording *is* the product here: who
  /// got there first, what to do, and that nothing committed was lost
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

  /// Whatever the history panel shows as [text].
  ///
  /// Scoped to the panel, because a commit's message can name a file the
  /// tree is showing too.
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

  /// Opens the popover and clicks [branch].
  ///
  /// Does not wait for the switch: what happens next is the step's to
  /// assert — it may be a checkout, or it may be the question about an
  /// unsaved buffer.
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

  /// Whatever the branch popover shows as [name].
  ///
  /// Scoped to the popover, because the control above it names a branch too
  /// — and it is the one the popover would be switching *from*.
  Finder _inTheBranches(String name) => find.descendant(
    of: find.byType(BranchesPopoverWidget),
    matching: find.text(name),
  );

  /// The popover's own box, which is the one field on screen while it is up.
  Finder get _theBranchField => find.descendant(
    of: find.byType(BranchesPopoverWidget),
    matching: find.byType(TextField),
  );

  /// Whatever the changes panel shows as [name].
  ///
  /// Scoped to the panel, because the same file is named in the tree too.
  Finder _inTheChanges(String name) =>
      find.descendant(of: find.byType(ChangesPanel), matching: find.text(name));

  /// The commit box.
  ///
  /// Scoped to the panel now that the branch popover has a field of its own;
  /// the search above the tree is still not a field.
  Finder get _anyField => find.descendant(
    of: find.byType(ChangesPanel),
    matching: find.byType(TextField),
  );

  /// Asserts which of the two panes the document area is showing.
  ///
  /// By each panel's own caption, which is what a person reads — and what a
  /// panel the shell had hardcoded would keep showing whatever the mode bar
  /// said.
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

  /// Asserts the app says, in each place it says it, that [path] is unsaved.
  ///
  /// All three at once on purpose: the one thing a text editor may never do
  /// is lose work quietly, so a mark that went missing in one place is a
  /// failure even while the other two still show it.
  Future<void> seesUnsaved(String path) async {
    await _waitUntil(() => _showing(find.text('Unsaved')));
    expect(find.text('Unsaved'), findsOneWidget, reason: 'no mark on the bar');
    await seesTheOpenDocument('$path — unsaved');
    // And the third place: a dot against the file in the explorer, found by
    // being round rather than by a key — what makes it a mark is its shape,
    // and a key would let a square pass.
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

  /// Asserts the top bar says which repository the space is a folder of.
  ///
  /// A space is a folder, not a repository (rule 12), and the bar is where
  /// the difference is visible: `app / docs`, not `docs` alone.
  void seesTheSpaceIsIn(String repository) {
    expect(
      find.text(repository),
      findsWidgets,
      reason: 'the top bar does not name the repository the space is in',
    );
    // In the chrome and not in the tree: the repository is *above* the space,
    // so a folder of that name inside it would be a different thing.
    seesNotInTheTree(repository);
  }

  /// Whatever the file tree shows as [name].
  ///
  /// Scoped to the panel, because the space's folder is named in the chrome
  /// as well and a finder that matched either would assert nothing.
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

  /// Asserts nothing is offered to go back to.
  ///
  /// Waits for the list to *go*, which is the same race read backwards:
  /// forgetting writes the preferences file, and the row is still on screen
  /// until that comes back.
  Future<void> seesNoRecent() async {
    await _waitUntil(() => !_showing(find.text('RECENT')));
    expect(find.text('RECENT'), findsNothing);
  }

  /// Asserts the app is not showing an unhandled error.
  ///
  /// Cheap, and worth doing at the end of every scenario: a red screen makes
  /// most assertions fail in confusing ways, and this names it directly.
  void seesNothingBroken() {
    expect(tester.takeException(), isNull);
    expect(find.byType(ErrorWidget), findsNothing);
  }

  static const String _forget = 'Forget this space';
}
