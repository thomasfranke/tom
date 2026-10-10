/// The preferences, applied as they are chosen.
library;

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/commands/commands_providers.dart';
import 'package:tom_presentation/src/editor/editor_notifier.dart';
import 'package:tom_presentation/src/editor/editor_state.dart';
import 'package:tom_presentation/src/editor/held_buffers_notifier.dart';
import 'package:tom_presentation/src/preferences/preferences_providers.dart';
import 'package:tom_presentation/src/spaces/document_tab.dart';
import 'package:tom_presentation/src/spaces/space_session.dart';
import 'package:tom_presentation/src/spaces/space_session_notifier.dart';

part 'preferences_notifier.g.dart';

/// What the machine remembers, and the one place it is changed.
///
/// **A preference applies when it is chosen** — there is no OK and no Cancel,
/// so every setter writes the state first and the store after: the window
/// changes behind the popover, and a store that refused loses the choice
/// between runs rather than on screen
/// (`docs/product/preferences/the-popover/doc.md`).
///
/// Kept alive because the theme is read above the shell, by the window
/// itself: a provider nobody in the shell listened to would be disposed
/// between screens and the choice would go with it.
@Riverpod(keepAlive: true)
class PreferencesNotifier extends _$PreferencesNotifier {
  /// Reads what is stored.
  ReadPreferencesUseCase get readPreferences =>
      ref.read(readPreferencesProvider);

  /// Writes a choice back.
  WritePreferencesUseCase get writePreferences =>
      ref.read(writePreferencesProvider);

  /// The first read of the store, while it is out.
  Future<void>? _loading;

  @override
  PreferencesValueObject build() {
    // The defaults first and the file after: the window has to draw before
    // anything has been read, and the read is a disk trip.
    _loading = Future<void>.microtask(_load);
    return PreferencesValueObject.defaults;
  }

  /// Done once what the machine holds has replaced the defaults.
  ///
  /// What the commands' gate waits on: a command asked while the window is
  /// still opening is judged by the stored mode, not by the default one.
  Future<void> get loaded => _loading ?? Future<void>.value();

  /// Has [mode] say who approves git and `gh` from now on
  /// (`docs/product/git-workflow/approvals/doc.md`).
  void chooseGitApprovals(GitApprovalModeEnum mode) =>
      _apply(state.copyWith(gitApprovals: mode));

  /// Draws [choice] from now on.
  void chooseTheme(ThemeChoiceEnum choice) =>
      _apply(state.copyWith(theme: choice));

  /// Speaks [language] from now on; the window reads it as its locale.
  void chooseLanguage(LanguageEnum language) =>
      _apply(state.copyWith(language: language));

  /// Shows the formatting bar, or puts it away.
  void toggleFormattingBar() =>
      _apply(state.copyWith(showingFormattingBar: !state.showingFormattingBar));

  /// Puts [chosen] on screen, then in the store.
  void _apply(PreferencesValueObject chosen) {
    state = chosen;
    unawaited(_write(chosen));
  }

  /// Writes [chosen], then tells the file's tab, if one is open, that the
  /// file changed under it.
  Future<void> _write(PreferencesValueObject chosen) async {
    final Result<void, AppFailure> written = await writePreferences.write(
      chosen,
    );
    if (!ref.mounted || written is! Success<void, AppFailure>) {
      return;
    }
    // Only its own tab: the same slot can hold `git-approvals.json`, which
    // this write did not touch.
    final SpaceRelativePathValueObject? held = ref
        .read(spaceSessionProvider)
        ?.preferencesFile;
    if (held != null && held != approvalsFile) {
      await ref.read(editorProvider.notifier).preferencesFileChanged();
    }
  }

  /// Opens the file behind the popover in a tab of the space that is open;
  /// nothing on Home, which has no tabs.
  ///
  /// What is in force is written first unless the tab is already open, so a
  /// machine that never chose anything still finds its three preferences in
  /// the file (`docs/product/preferences/where-it-is-stored/doc.md`).
  Future<void> openFile() => _openAppFile(
    ref.read(preferencesFileProvider),
    () => writePreferences.write(state),
  );

  /// Opens `git-approvals.json` the same way, in the same tab: the list of
  /// what may run unasked, every command the app can run listed first
  /// (`docs/product/git-workflow/approvals/doc.md`).
  Future<void> openApprovalsFile() =>
      _openAppFile(approvalsFile, () => ref.read(seedApprovalsProvider).seed());

  /// Where `git-approvals.json` is, relative to the folder the preferences
  /// file is kept in: beside it, under the name the product gives it.
  static final SpaceRelativePathValueObject approvalsFile =
      SpaceRelativePathValueObject(ApprovalsRepository.fileName);

  /// Puts [file], one of the app's own, in the tab after the documents',
  /// [prepare]d first unless that tab already holds it.
  ///
  /// **One such tab at a time**: opening the other file takes its place —
  /// unless it holds edits nobody saved, which are shown instead of lost.
  Future<void> _openAppFile(
    SpaceRelativePathValueObject file,
    Future<Result<void, AppFailure>> Function() prepare,
  ) async {
    final SpaceSessionState? session = ref.read(spaceSessionProvider);
    if (session == null) {
      return;
    }
    final SpaceSessionNotifier opening = ref.read(
      spaceSessionProvider.notifier,
    );
    final SpaceRelativePathValueObject? held = session.preferencesFile;
    if (held != null && held != file && _hasUnsaved(held)) {
      opening.openPreferencesFile(held);
      return;
    }
    if (held != file) {
      await prepare();
      if (!ref.mounted) {
        return;
      }
    }
    opening.openPreferencesFile(file);
  }

  /// Whether the app's file [held] by the tab has edits the disk does not,
  /// on screen or behind another tab.
  bool _hasUnsaved(SpaceRelativePathValueObject held) {
    final DocumentTab tab = DocumentTab.preferences(held);
    if (ref.read(heldBuffersProvider)[tab]?.isDirty ?? false) {
      return true;
    }
    return ref.exists(editorProvider) &&
        switch (ref.read(editorProvider)) {
          final EditorReady open => open.isDirty && open.tab == tab,
          _ => false,
        };
  }

  /// Reads the store again — what saving the file by hand applies.
  Future<void> reload() => _load();

  /// Replaces the defaults with what the machine holds.
  Future<void> _load() async {
    final PreferencesValueObject stored = await readPreferences.read();
    if (!ref.mounted) {
      return;
    }
    state = stored;
  }
}
