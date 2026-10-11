/// The line diff of a file that is not markdown, following its buffer.
library;

import 'dart:async';

// `select` lives in the runtime package, not in `riverpod_annotation`.
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/commands/command_action_enum.dart';
import 'package:tom_presentation/src/commands/command_scope.dart';
import 'package:tom_presentation/src/editor/editor_notifier.dart';
import 'package:tom_presentation/src/editor/editor_providers.dart';
import 'package:tom_presentation/src/editor/editor_state.dart';
import 'package:tom_presentation/src/spaces/space_session.dart';
import 'package:tom_presentation/src/spaces/space_session_notifier.dart';

part 'line_diff_notifier.g.dart';

/// What the base is, and when it was last read: either changing re-marks the
/// buffer without it changing.
typedef _Measure = ({DiffBaseValueObject? base, GitStatusValueObject? git});

/// What the text buffer on screen changed against the documents' base, or
/// null when there is nothing to mark
/// (`docs/product/git-workflow/commit/opening-a-change/doc.md`).
///
/// The preview's twin for a file with no page: it listens to the editor, so
/// a keystroke waits as the preview's does. **The `Diff` chip is not read**:
/// a text tab has no chip to turn the marks back on with.
@riverpod
class LineDiffNotifier extends _$LineDiffNotifier {
  /// How long the last keystroke waits before the lines are compared.
  static const Duration settle = Duration(milliseconds: 120);

  /// Compares a buffer against a revision of its file, line by line.
  DiffLinesUseCase get diffLines => ref.read(diffLinesProvider);

  Timer? _scheduled;

  /// The base's text as git gave it, so typing asks git once.
  final BaseContentCache _baseContent = BaseContentCache();

  /// Which comparison is the current one, so a slow one cannot land after a
  /// newer one has already answered.
  int _generation = 0;

  @override
  LineDiffValueObject? build() {
    ref
      ..onDispose(() => _scheduled?.cancel())
      ..listen<_Measure>(
        spaceSessionProvider.select(
          (SpaceSessionState? session) =>
              (base: session?.comparingAgainst, git: session?.git),
        ),
        (_Measure? _, _Measure _) {
          _baseContent.clear();
          _compareNow();
        },
      )
      ..listen<EditorState>(editorProvider, _follow);
    if (_comparable(ref.read(editorProvider)) case final EditorReady ready) {
      // Scheduled, not awaited: `build` answers synchronously.
      unawaited(Future<void>.microtask(() => _compare(ready)));
    }
    return null;
  }

  /// Follows the editor: a keystroke waits [settle], another file is
  /// compared at once, and anything that is not a text buffer clears.
  void _follow(EditorState? previous, EditorState next) {
    final EditorReady? ready = _comparable(next);
    if (ready == null) {
      _scheduled?.cancel();
      ++_generation;
      state = null;
      return;
    }
    final bool sameFile = previous is EditorReady && previous.tab == ready.tab;
    if (sameFile && previous.source == ready.source) {
      return;
    }
    _scheduled?.cancel();
    if (sameFile) {
      _scheduled = Timer(settle, () => unawaited(_compare(ready)));
      return;
    }
    state = null;
    unawaited(_compare(ready));
  }

  /// Compares the buffer on screen again, because the base moved.
  void _compareNow() {
    if (_comparable(ref.read(editorProvider)) case final EditorReady ready) {
      _scheduled?.cancel();
      unawaited(_compare(ready));
    }
  }

  /// The buffer when it is one this diff is about: text that is not
  /// markdown, still on disk, in a repository, not the preferences file.
  EditorReady? _comparable(EditorState editor) {
    final SpaceSessionState? session = ref.read(spaceSessionProvider);
    return switch (editor) {
      EditorReady(
        isPreferences: false,
        isDraft: false,
        isBinary: false,
        isDeleted: false,
        isRendered: false,
      )
          when session != null &&
              session.space.hasRepository &&
              session.readingVersion == null =>
        editor,
      _ => null,
    };
  }

  /// Asks what [ready]'s buffer changed against the base — where the branch
  /// left the one it came from, or `HEAD` — and publishes it; a comparison
  /// that fails leaves the lines unmarked rather than saying so.
  Future<void> _compare(EditorReady ready) async {
    final int generation = ++_generation;
    final SpaceSessionState? session = ref.read(spaceSessionProvider);
    if (session == null) {
      return;
    }
    final Result<LineDiffValueObject, AppFailure> diffed =
        await CommandScope.run(
          CommandActionEnum.readVersion,
          () => diffLines.diff(
            // A file outside the space carries git's own path.
            space: ready.isOutside
                ? session.space.repositorySpace ?? session.space
                : session.space,
            after: ready.saved.copyWith(content: ready.source),
            revision:
                session.comparingAgainst?.forkPoint.value ??
                DiffDocumentUseCase.head,
            cache: _baseContent,
            // What git said is new is not asked about (it has no `HEAD` text).
            status: session.git,
          ),
        );
    if (!ref.mounted || generation != _generation) {
      return;
    }
    state = switch (diffed) {
      Success<LineDiffValueObject, AppFailure>(
        value: final LineDiffValueObject diff,
      ) =>
        diff,
      Failure<LineDiffValueObject, AppFailure>() => null,
    };
  }
}
