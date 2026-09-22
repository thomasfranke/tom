/// The explorer: the space's folders and files, as a tree.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/theme/tom_colors.dart';
import 'package:tom_desktop/theme/tom_metrics.dart';
import 'package:tom_desktop/widgets/milestone_chip.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

/// What the design fixes about this panel.
///
/// The `explorer` component of the visual design, which every screen with a
/// space open places — that is what keeps the tree identical across all of
/// them. Type and radii come from
/// [components.md](../../../../../../docs/technical/design/components.md).
///
/// Every vertical number is measured from the top of the panel, which is
/// where the design measures from: the shell is what puts it under the top
/// bar.
abstract final class _Design {
  /// Caption baseline box, and the search field under it.
  static const double captionTop = 18;
  static const double searchTop = 48;
  static const double searchWidth = 148;
  static const double searchHeight = 28;

  /// The milestone chip beside the search field.
  static const double chipLeft = TomMetrics.padTight + 158;

  /// Where the first row sits, and the pitch between rows.
  static const double rowsTop = 108;
  static const double rowPitch = 34;

  /// The row's own box: inset from both edges, and shorter than the pitch.
  static const double rowHeight = 26;
  static const double rowInset = 12;

  /// One level of nesting, and how far left of its label a chevron sits.
  static const double indent = 16;
  static const double chevronOffset = 12;

  /// Where a row's text starts, at the top level.
  static const double labelLeft = TomMetrics.pad;

  /// Corner radius: a row, and the search field.
  static const double radius = 6;

  /// Type sizes, from the table.
  static const double caption = 10;
  static const double placeholder = 12;
  static const double row = 13;
  static const double chevron = 9;
}

/// The file tree, and the search field that will sit above it in M2.
///
/// Registered by `CoreModule` through the same `PanelDescriptor` a
/// stranger's module would use, and it draws its own caption because the
/// shell draws no panel chrome.
///
/// **It shows everything the space holds** and opens only markdown
/// (`docs/product/navigation/file-tree/doc.md`). Hiding `.git/` is not this
/// widget's doing — the walk never descends into it, so there is nothing
/// here to filter.
///
/// A humble widget: what a click means and which document is open live in
/// [FileTreeNotifier] and the session, so everything here is layout.
class FileTreePanel extends ConsumerWidget {
  /// Creates the panel.
  const FileTreePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FileTreeState state = ref.watch(fileTreeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Each gap is written as the subtraction of two of the design's own
        // numbers: arithmetic on screen cannot drift from the drawing
        // quietly, and a result typed by hand can.
        const SizedBox(height: _Design.captionTop),
        const _Caption(),
        const SizedBox(
          height:
              _Design.searchTop - _Design.captionTop - _Design.caption * 1.4,
        ),
        const _Search(),
        const SizedBox(
          height: _Design.rowsTop - _Design.searchTop - _Design.searchHeight,
        ),
        Expanded(child: _Body(state: state)),
      ],
    );
  }
}

/// What the panel is called, in the design's own words.
class _Caption extends StatelessWidget {
  const _Caption();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: TomMetrics.pad),
    child: Text(
      'EXPLORER',
      style: TextStyle(
        fontSize: _Design.caption,
        height: 1.4,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w600,
        color: TomColors.of(context).textMuted,
      ),
    ),
  );
}

/// Full-text search, which arrives in M2.
///
/// On screen and disabled rather than absent, the way Home draws cloning: the
/// design puts it here, and a control that appears later moves everything
/// under it. The chip beside it is what says *later*.
class _Search extends StatelessWidget {
  const _Search();

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: TomMetrics.padTight),
      child: Row(
        children: <Widget>[
          Tooltip(
            message: 'Searching the space arrives in M2',
            child: Container(
              width: _Design.searchWidth,
              height: _Design.searchHeight,
              padding: const EdgeInsets.only(left: 12),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: colors.surfaceSunken,
                border: Border.all(color: colors.border),
                borderRadius: BorderRadius.circular(_Design.radius),
              ),
              child: Text(
                'Search',
                style: TextStyle(
                  fontSize: _Design.placeholder,
                  height: 1.4,
                  color: colors.textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: _Design.chipLeft - TomMetrics.padTight - _Design.searchWidth,
          ),
          // Centred on the field rather than put at the design's own y,
          // which is a pixel off centre anyway.
          const MilestoneChip(label: 'M2'),
        ],
      ),
    );
  }
}

/// The tree itself, or the one line that explains why there is none.
class _Body extends ConsumerWidget {
  const _Body({required this.state});

  /// What the file tree is showing.
  final FileTreeState state;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<FileTreeState>('state', state));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => switch (state) {
    // Nothing at all with no space open: the shell only shows with one, so
    // an explanation here would be for a state nobody reaches.
    FileTreeInitial() => const SizedBox.shrink(),
    FileTreeLoading() => const _Note('Reading the folder…'),
    FileTreeFailed(failure: final AppFailure failure) => _Note(
      _explain(failure),
    ),
    final FileTreeReady ready => _Rows(rows: ready.rows),
  };

  /// What to say about a folder that could not be read.
  ///
  /// Only the space's own folder gets here; one unreadable folder inside it
  /// costs that folder, not the tree. The catch-all is because this switches
  /// over [AppFailure] itself, and silence would be worse than a vague line.
  static String _explain(AppFailure failure) => switch (failure) {
    SpaceFolderMissing() => 'This folder is no longer there.',
    SpaceAccessDenied() => 'TOM is not allowed to read this folder.',
    _ => 'This folder could not be read.',
  };
}

/// A line of prose where the tree would be.
class _Note extends StatelessWidget {
  const _Note(this.text);

  /// What it says.
  final String text;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('text', text));
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: TomMetrics.pad),
    child: Text(
      text,
      style: TextStyle(
        fontSize: _Design.placeholder,
        height: 1.5,
        color: TomColors.of(context).textMuted,
      ),
    ),
  );
}

/// Every visible row, scrolling as one.
class _Rows extends ConsumerWidget {
  const _Rows({required this.rows});

  /// What to draw, top-level first.
  final List<FileTreeRow> rows;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<FileTreeRow>('rows', rows));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (rows.isEmpty) {
      return const _Note('This folder holds nothing yet.');
    }
    final SpaceRelativePathValueObject? open = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.openDocument,
      ),
    );
    return ListView.builder(
      // The design's pitch, and what lets the list build lazily: a space
      // with a thousand documents lays out the dozen rows on screen.
      itemExtent: _Design.rowPitch,
      itemCount: rows.length,
      itemBuilder: (BuildContext context, int index) =>
          _Row(row: rows[index], isOpen: rows[index].entry.path == open),
    );
  }
}

/// One entry, as the design draws it.
class _Row extends ConsumerWidget {
  const _Row({required this.row, required this.isOpen});

  /// What this row shows.
  final FileTreeRow row;

  /// Whether this is the document the window is showing.
  final bool isOpen;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<FileTreeRow>('row', row))
      ..add(DiagnosticsProperty<bool>('isOpen', isOpen));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    final double labelLeft = _Design.labelLeft + row.depth * _Design.indent;
    // The open document takes the accent, which marks the current thing and
    // nothing else. A file the editor cannot open is muted *and* has no
    // hover: colour is never the only signal.
    final bool isOpenable = row.isFolder || row.entry.isDocument;
    final Color color = switch ((isOpen, row.isFolder, isOpenable)) {
      (true, _, _) => colors.accent,
      (false, true, _) => colors.textPrimary,
      (false, false, true) => colors.textSecondary,
      (false, false, false) => colors.textMuted,
    };
    final Widget content = Stack(
      children: <Widget>[
        if (isOpen)
          Positioned(
            left: _Design.rowInset,
            right: _Design.rowInset,
            top: 0,
            height: _Design.rowHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.accentSoft,
                borderRadius: BorderRadius.circular(_Design.radius),
              ),
            ),
          ),
        if (row.isFolder)
          _Centred(
            left: labelLeft - _Design.chevronOffset,
            child: Text(
              row.isExpanded ? '▾' : '▸',
              style: _rowText(size: _Design.chevron, color: colors.textMuted),
            ),
          ),
        _Centred(
          left: labelLeft,
          right: _Design.rowInset,
          child: Text(
            row.entry.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _rowText(
              size: _Design.row,
              color: color,
              weight: isOpen
                  ? FontWeight.w600
                  : (row.isFolder ? FontWeight.w500 : FontWeight.w400),
            ),
          ),
        ),
      ],
    );
    if (!isOpenable) {
      return content;
    }
    return InkWell(
      onTap: () => ref.read(fileTreeProvider.notifier).activate(row.entry),
      child: content,
    );
  }
}

/// One thing in a row, centred on the row's own box.
///
/// The design gives each row's text an absolute y, and placing it there
/// draws it low: Flutter splits a line's extra leading in proportion to the
/// font's ascent and descent, and the ascent is much the larger.
///
/// The drawing means *centred*, so centring is what this does — it lands on
/// the design's number and survives a change of interface font.
class _Centred extends StatelessWidget {
  const _Centred({required this.left, required this.child, this.right});

  /// Where it starts, from the panel's edge.
  final double left;

  /// Where it must stop, or null to take what it needs.
  final double? right;

  /// What to centre.
  final Widget child;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('left', left))
      ..add(DoubleProperty('right', right));
  }

  @override
  Widget build(BuildContext context) => Positioned(
    left: left,
    right: right,
    top: 0,
    height: _Design.rowHeight,
    child: Align(alignment: Alignment.centerLeft, child: child),
  );
}

/// The row's type, centred on its own line.
///
/// `even` leading is the whole point: by default the extra space of a 1.4
/// line goes mostly above the glyphs, which is what made a row read as
/// sitting low inside the open document's pill.
TextStyle _rowText({
  required double size,
  required Color color,
  FontWeight weight = FontWeight.w400,
}) => TextStyle(
  fontSize: size,
  height: 1.4,
  leadingDistribution: TextLeadingDistribution.even,
  fontWeight: weight,
  color: color,
);
