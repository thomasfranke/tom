/// What the source pane draws beside and behind its lines.
library;

// `select` lives in the runtime package, not in `riverpod_annotation`.
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/editor/editor_mark_enum.dart';
import 'package:tom_presentation/src/editor/editor_mark_span.dart';
import 'package:tom_presentation/src/editor/editor_notifier.dart';
import 'package:tom_presentation/src/editor/editor_state.dart';
import 'package:tom_presentation/src/editor/line_diff_notifier.dart';
import 'package:tom_presentation/src/preview/preview_notifier.dart';
import 'package:tom_presentation/src/preview/preview_state.dart';
import 'package:tom_presentation/src/spaces/space_session.dart';
import 'package:tom_presentation/src/spaces/space_session_notifier.dart';

part 'editor_marks.g.dart';

/// A reading turned into line numbers and asked by line.
///
/// Lines rather than offsets or blocks, because the source pane draws a
/// gutter beside numbered lines and has nothing else to hang a mark on.
final class EditorMarks {
  const EditorMarks._(this.spans);

  /// Nothing to mark, or nothing has been read yet.
  const EditorMarks.none() : spans = const <EditorMarkSpan>[];

  /// The lines [regions] cover, counted in [source].
  ///
  /// **The two sides are tinted and the markers are not.** Both carry the
  /// same tint: `removed` would say your work is leaving and `added` would
  /// say theirs has arrived, and neither is true until somebody chooses
  /// (`docs/product/editor/conflicted-document/doc.md`).
  factory EditorMarks.ofConflicts(
    String source,
    List<ConflictRegionValueObject> regions,
  ) {
    if (regions.isEmpty) {
      return const EditorMarks.none();
    }
    final List<EditorMarkSpan> spans = <EditorMarkSpan>[];
    // One pass over the text for all of them: the scanner hands the regions
    // back in the order they appear, so the count never has to go back.
    int line = 0;
    int at = 0;
    for (final ConflictRegionValueObject region in regions) {
      while (at < region.start && at < source.length) {
        if (source.codeUnitAt(at) == 0x0A) {
          line++;
        }
        at++;
      }
      // The `<<<<<<<` line carries the letter, and the sides under it carry
      // the tint; `=======` and `>>>>>>>` carry neither.
      spans.add(EditorMarkSpan.letter(line, EditorMarkEnum.conflicted));
      final int current = _linesIn(region.current);
      final int incoming = _linesIn(region.incoming);
      if (current > 0) {
        spans.add(
          EditorMarkSpan.tint(
            from: line + 1,
            to: line + current,
            mark: EditorMarkEnum.modified,
          ),
        );
      }
      if (incoming > 0) {
        // Past the side above it and past the `=======` between them.
        final int after = line + current + 2;
        spans.add(
          EditorMarkSpan.tint(
            from: after,
            to: after + incoming - 1,
            mark: EditorMarkEnum.modified,
          ),
        );
      }
    }
    return EditorMarks._(spans);
  }

  /// Every block [diff] calls changed, over the lines it covers.
  ///
  /// **A removal is a seam on the line that closed over it** — it is not in
  /// the buffer, so it has no lines to tint and no line to letter
  /// (`docs/product/diff/rendered-diff/how-it-is-drawn/doc.md`).
  factory EditorMarks.ofDiff(DocumentDiffValueObject diff) {
    final List<EditorMarkSpan> spans = <EditorMarkSpan>[];
    int closedOver = 0;
    for (final DiffBlockValueObject block in diff.blocks) {
      switch (block) {
        case DiffBlockUnchanged(block: final BlockValueObject kept):
          closedOver = kept.endLine + 1;
        case DiffBlockAdded(block: final BlockValueObject arrived):
          spans.add(
            EditorMarkSpan.block(
              from: arrived.startLine,
              to: arrived.endLine,
              mark: EditorMarkEnum.added,
            ),
          );
          closedOver = arrived.endLine + 1;
        case DiffBlockModified(after: final BlockValueObject rewritten):
          spans.add(
            EditorMarkSpan.block(
              from: rewritten.startLine,
              to: rewritten.endLine,
              mark: EditorMarkEnum.modified,
            ),
          );
          closedOver = rewritten.endLine + 1;
        case DiffBlockRemoved():
          spans.add(EditorMarkSpan.seam(closedOver));
      }
    }
    return spans.isEmpty ? const EditorMarks.none() : EditorMarks._(spans);
  }

  /// Every run [diff] calls changed — the same letters, bands and seams a
  /// block's diff draws, a line being the unit for a file with no page.
  factory EditorMarks.ofLines(LineDiffValueObject diff) => diff.isUnchanged
      ? const EditorMarks.none()
      : EditorMarks._(<EditorMarkSpan>[
          for (final LineRunValueObject run in diff.runs)
            switch (run) {
              LineRunAdded(:final int from, :final int to) =>
                EditorMarkSpan.block(
                  from: from,
                  to: to,
                  mark: EditorMarkEnum.added,
                ),
              LineRunModified(:final int from, :final int to) =>
                EditorMarkSpan.block(
                  from: from,
                  to: to,
                  mark: EditorMarkEnum.modified,
                ),
              LineRunRemoved(:final int at) => EditorMarkSpan.seam(at),
            },
        ]);

  /// Every line of [source] removed: a deleted file's last version, in the
  /// source pane (`docs/product/git-workflow/commit/opening-a-change/doc.md`).
  factory EditorMarks.ofDeleted(String source) {
    final int lines = LineDifferService.linesOf(source).length;
    return lines == 0
        ? const EditorMarks.none()
        : EditorMarks._(<EditorMarkSpan>[
            EditorMarkSpan.block(
              from: 0,
              to: lines - 1,
              mark: EditorMarkEnum.removed,
            ),
          ]);
  }

  /// Every stretch, in the order the document has them.
  final List<EditorMarkSpan> spans;

  /// Whether there is nothing to draw.
  bool get isEmpty => spans.isEmpty;

  /// What the line at [line] is marked as, or null.
  ///
  /// The **letter**, so only where a span begins: a mark on every line of a
  /// block would be the same fact five times.
  EditorMarkEnum? at(int line) {
    for (final EditorMarkSpan span in spans) {
      if (span.letters && span.from == line) {
        return span.mark;
      }
    }
    return null;
  }

  /// What the line at [line] is tinted with, or null.
  EditorMarkEnum? bandAt(int line) {
    for (final EditorMarkSpan span in spans) {
      if (span.holds(line)) {
        return span.mark;
      }
    }
    return null;
  }

  /// Whether a removed block used to sit above [line].
  bool seamAbove(int line) =>
      spans.any((EditorMarkSpan span) => span.isSeam && span.from == line);

  /// How many lines [text] occupies; nothing at all is no lines.
  static int _linesIn(String text) =>
      text.isEmpty ? 0 : '\n'.allMatches(text).length + 1;

  /// Compared by the spans it holds, because a provider that answers a new
  /// object for the same reading would rebuild the pane on every keystroke.
  @override
  bool operator ==(Object other) =>
      other is EditorMarks &&
      other.spans.length == spans.length &&
      List<int>.generate(
        spans.length,
        (int at) => at,
      ).every((int at) => other.spans[at] == spans[at]);

  @override
  int get hashCode => Object.hashAll(spans);
}

/// What the gutter draws beside the open document, and what tints it.
///
/// **The conflict comes first and wins**, which is the rule the preview
/// already follows: while a marker is on screen the diff is not asked for at
/// all. Conflicts are read from the text and offered only while git says the
/// document is conflicted, so a `<<<<<<<` typed into a document *about*
/// merging stays text (`docs/product/editor/conflicted-document/doc.md`).
///
/// A document's diff is the preview's, not a second comparison: one reading,
/// both panes. A file that is not markdown has no preview, so its lines are
/// compared on their own ([LineDiffNotifier]).
@riverpod
EditorMarks editorMarks(Ref ref) {
  final bool conflicted = ref.watch(
    spaceSessionProvider.select(
      // A pull request draft is never the conflicted document under it.
      (SpaceSessionState? session) =>
          session != null &&
          session.pullRequest == null &&
          session.isConflicted(session.openDocument),
    ),
  );
  if (conflicted) {
    // The buffer, not the file: a choice taken in the preview rewrites the
    // document where it is being typed, and the marks have to follow it.
    final String source = ref.watch(editorProvider.select(_sourceOf));
    return EditorMarks.ofConflicts(
      source,
      const ConflictScannerService().scan(source),
    );
  }
  // A deleted file is all removed, a binary one holds no lines, and a text
  // file has no preview to take a diff from: its lines are compared instead.
  final _Holding holding = ref.watch(editorProvider.select(_holdingOf));
  switch (holding) {
    case _Holding.deleted:
      return EditorMarks.ofDeleted(ref.watch(editorProvider.select(_sourceOf)));
    case _Holding.nothing:
      return const EditorMarks.none();
    case _Holding.text:
      final LineDiffValueObject? lines = ref.watch(lineDiffProvider);
      return lines == null
          ? const EditorMarks.none()
          : EditorMarks.ofLines(lines);
    case _Holding.document:
      final DocumentDiffValueObject? diff = ref.watch(
        previewProvider.select(_diffOf),
      );
      return diff == null ? const EditorMarks.none() : EditorMarks.ofDiff(diff);
  }
}

/// Where a buffer's marks come from.
enum _Holding { document, text, deleted, nothing }

/// Where [state]'s marks come from: the preview for a document — or no
/// buffer, whose preview has none — the line diff for other text.
_Holding _holdingOf(EditorState state) => switch (state) {
  EditorReady(isBinary: true) ||
  EditorReady(isPreferences: true) => _Holding.nothing,
  EditorReady(isDeleted: true) => _Holding.deleted,
  EditorReady(isRendered: false) => _Holding.text,
  _ => _Holding.document,
};

/// What the editor is holding, or nothing when no document is open.
String _sourceOf(EditorState state) => switch (state) {
  EditorReady(source: final String source) => source,
  _ => '',
};

/// The diff the preview is drawing, or null when it is drawing none.
DocumentDiffValueObject? _diffOf(PreviewState state) => switch (state) {
  PreviewReady(diff: final DocumentDiffValueObject? diff) =>
    (diff?.isUnchanged ?? true) ? null : diff,
  _ => null,
};
