/// The formatting bar: seventeen buttons, in five groups.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/editor/editor_history.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// One button of the bar, or the rule between two groups.
///
/// A record rather than a class: the bar is a list, and every entry is a
/// glyph, a word and a command.
typedef ToolbarEntry = ({
  TomGlyphEnum? glyph,
  String? letter,
  String word,
  FormatCommandEnum? command,
});

/// Everything the preview renders, in the order somebody reaches for it
/// (`docs/product/editor/formatting-shortcuts/doc.md`).
///
/// At the screen's top level rather than in its `widgets/`, because the row
/// that mounts it is the shell's: a screen's `widgets/` are readable from
/// that screen only, and this is the editor's control drawn elsewhere.
///
/// **Seventeen**, because a button for four of the cases teaches that the
/// other cases are not supported. None is ever dropped: the set needs 632
/// points and a row with the git column open has 598, so the **last group
/// collapses into a `⋯`** rather than scrolling out of reach, which keeps
/// the thirteen that stay at the x every board draws them at.
class EditorToolbarWidget extends ConsumerWidget {
  /// Creates the bar.
  const EditorToolbarWidget({super.key});

  /// Row edge to the first button.
  static const double inset = 24;

  /// Between two buttons of one group.
  static const double gap = 4;

  /// The last button of a group to the rule.
  static const double beforeRule = 12;

  /// The rule to the first button of the next group; the boards draw it
  /// nearer the group it closes than the one it opens.
  static const double afterRule = 8;

  /// The rule itself, a hairline as tall as a letter.
  static const double ruleWidth = 1;

  /// How tall that hairline is.
  static const double ruleHeight = 16;

  /// One group's width: its buttons and the gaps between them.
  static double widthOfGroup(List<ToolbarEntry> group) =>
      group.length * TomToolbarButtonWidget.size + (group.length - 1) * gap;

  /// What separates one group from the next.
  static const double betweenGroups = beforeRule + ruleWidth + afterRule;

  /// What the whole set needs, [inset] included.
  static double get widthOfAll => widthOfFirst(groups.length);

  /// What the first [count] groups need, plus the `⋯` when some are left.
  ///
  /// The `⋯` takes one button's room and the rule before it, which is why a
  /// row that cannot hold the last group is not thereby able to hold four.
  static double widthOfFirst(int count) {
    final bool whole = count == groups.length;
    final double shown = groups
        .take(count)
        .map(widthOfGroup)
        .fold(0, (double a, double b) => a + b);
    final int rules = whole ? count - 1 : count;
    return inset +
        shown +
        betweenGroups * rules +
        (whole ? 0 : TomToolbarButtonWidget.size);
  }

  /// How many groups a row [room] wide can draw before the `⋯`.
  ///
  /// **Always from the end**, so the groups that stay keep the x every board
  /// draws them at; never fewer than none, because the `⋯` is what says the
  /// rest exist.
  static int groupsFitting(double room) {
    for (int count = groups.length; count > 0; count--) {
      if (widthOfFirst(count) <= room) {
        return count;
      }
    }
    return 0;
  }

  /// The five groups, in the order the boards draw them.
  ///
  /// Undo and redo are a group of their own and first, because they are
  /// always available and formatting is not — so the first group is told
  /// apart by more than its position.
  static const List<List<ToolbarEntry>> groups = <List<ToolbarEntry>>[
    <ToolbarEntry>[
      (glyph: TomGlyphEnum.undo, letter: null, word: 'Undo', command: null),
      (glyph: TomGlyphEnum.redo, letter: null, word: 'Redo', command: null),
    ],
    <ToolbarEntry>[
      (
        glyph: TomGlyphEnum.heading,
        letter: null,
        word: 'Heading',
        command: FormatCommandEnum.heading,
      ),
      // `B` and `I` are letterforms, not icons: a letter everywhere else
      // would be a worse icon than itself.
      (glyph: null, letter: 'B', word: 'Bold', command: FormatCommandEnum.bold),
      (
        glyph: null,
        letter: 'I',
        word: 'Italic',
        command: FormatCommandEnum.italic,
      ),
      (
        glyph: TomGlyphEnum.strikethrough,
        letter: null,
        word: 'Strikethrough',
        command: FormatCommandEnum.strikethrough,
      ),
    ],
    <ToolbarEntry>[
      (
        glyph: TomGlyphEnum.list,
        letter: null,
        word: 'List',
        command: FormatCommandEnum.list,
      ),
      (
        glyph: TomGlyphEnum.orderedList,
        letter: null,
        word: 'Ordered list',
        command: FormatCommandEnum.orderedList,
      ),
      (
        glyph: TomGlyphEnum.taskList,
        letter: null,
        word: 'Task list',
        command: FormatCommandEnum.taskList,
      ),
      (
        glyph: TomGlyphEnum.quote,
        letter: null,
        word: 'Quote',
        command: FormatCommandEnum.quote,
      ),
    ],
    <ToolbarEntry>[
      (
        glyph: TomGlyphEnum.code,
        letter: null,
        word: 'Code',
        command: FormatCommandEnum.code,
      ),
      (
        glyph: TomGlyphEnum.table,
        letter: null,
        word: 'Table',
        command: FormatCommandEnum.table,
      ),
      (
        glyph: TomGlyphEnum.rule,
        letter: null,
        word: 'Rule',
        command: FormatCommandEnum.rule,
      ),
    ],
    <ToolbarEntry>[
      (
        glyph: TomGlyphEnum.link,
        letter: null,
        word: 'Link',
        command: FormatCommandEnum.link,
      ),
      (
        glyph: TomGlyphEnum.image,
        letter: null,
        word: 'Image',
        command: FormatCommandEnum.image,
      ),
      (
        glyph: TomGlyphEnum.footnote,
        letter: null,
        word: 'Footnote',
        command: FormatCommandEnum.footnote,
      ),
      (
        glyph: TomGlyphEnum.alert,
        letter: null,
        word: 'Alert',
        command: FormatCommandEnum.alert,
      ),
    ],
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // **What the preference hides is the tools, not half of them** — undo
    // and redo go with the rest, and the row itself stays because it is
    // also where the view is chosen
    // (`docs/product/preferences/what-it-holds/doc.md`).
    final bool showing = ref.watch(
      preferencesProvider.select(
        (PreferencesValueObject it) => it.showingFormattingBar,
      ),
    );
    if (!showing) {
      return const SizedBox.shrink();
    }
    // A document open is what the buttons act on; with none, they are drawn
    // and dim rather than taken away.
    final bool editable = ref.watch(
      editorProvider.select((EditorState state) => state is EditorReady),
    );
    // Undo and redo are the editor's own, reached through the context the
    // pane leaves here: one history, the same one ⌘Z walks
    // ([EditorHistory]).
    final EditorHistory? history = EditorHistoryScope.of(context);
    final TomColors colors = TomColors.of(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints room) {
        final int count = groupsFitting(room.maxWidth);
        final bool whole = count == groups.length;
        final List<List<ToolbarEntry>> shown = groups.take(count).toList();
        final List<ToolbarEntry> hidden = <ToolbarEntry>[
          for (final List<ToolbarEntry> group in groups.skip(count)) ...group,
        ];
        return Padding(
          padding: const EdgeInsets.only(left: inset),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final (int index, List<ToolbarEntry> group)
                  in shown.indexed) ...<Widget>[
                _buttons(group, ref, history, editable: editable),
                if (index < shown.length - 1 || !whole) ...<Widget>[
                  const SizedBox(width: beforeRule),
                  SizedBox(
                    width: ruleWidth,
                    height: ruleHeight,
                    child: ColoredBox(color: colors.border),
                  ),
                  const SizedBox(width: afterRule),
                ],
              ],
              if (!whole)
                _OverflowWidget(
                  group: hidden,
                  history: history,
                  editable: editable,
                ),
            ],
          ),
        );
      },
    );
  }

  /// One group, drawn as the boards draw it.
  static Widget _buttons(
    List<ToolbarEntry> group,
    WidgetRef ref,
    EditorHistory? history, {
    required bool editable,
  }) => Row(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      for (final (int at, ToolbarEntry entry) in group.indexed) ...<Widget>[
        if (at > 0) const SizedBox(width: gap),
        TomToolbarButtonWidget(
          glyph: entry.glyph,
          letter: entry.letter,
          tooltip: entry.word,
          onPressed: _pressingIn(entry, ref, history, editable),
        ),
      ],
    ],
  );

  /// What [entry] does, or null while it cannot do it.
  ///
  /// **Undo and redo are always available** and formatting is not, which is
  /// what tells the first group apart from the rest — so they answer to the
  /// history rather than to whether a document is open
  /// (`docs/product/editor/formatting-shortcuts/doc.md`).
  static VoidCallback? _pressingIn(
    ToolbarEntry entry,
    WidgetRef ref,
    EditorHistory? history,
    bool editable,
  ) {
    if (entry.command case final FormatCommandEnum command) {
      return editable
          ? () => ref.read(editorProvider.notifier).format(command)
          : null;
    }
    if (!(history?.isReachable ?? false)) {
      return null;
    }
    return entry.glyph == TomGlyphEnum.undo ? history!.undo : history!.redo;
  }
}

/// What a narrow row cannot hold, behind one button.
///
/// **It opens as a strip, not as a menu**: what is inside are the same
/// toolbar buttons at the same size, so nobody has to learn a second shape
/// for `Link` depending on how wide the window is.
///
/// One group at the width this was designed for; the rules between groups
/// are not redrawn inside, because a narrower window than that is a
/// degradation rather than a layout anybody chose.
class _OverflowWidget extends ConsumerStatefulWidget {
  const _OverflowWidget({
    required this.group,
    required this.history,
    required this.editable,
  });

  final List<ToolbarEntry> group;
  final EditorHistory? history;
  final bool editable;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IterableProperty<ToolbarEntry>('group', group))
      ..add(DiagnosticsProperty<EditorHistory?>('history', history))
      ..add(DiagnosticsProperty<bool>('editable', editable));
  }

  @override
  ConsumerState<_OverflowWidget> createState() => _OverflowWidgetState();
}

class _OverflowWidgetState extends ConsumerState<_OverflowWidget> {
  final GlobalKey _button = GlobalKey();
  final OverlayPortalController _portal = OverlayPortalController();

  /// The button and the strip are one region, so pressing the button while
  /// it is open closes it instead of dismissing and reopening.
  final Object _group = Object();

  bool _isOpen = false;

  void _toggle() {
    setState(() => _isOpen = !_isOpen);
    _isOpen ? _portal.show() : _portal.hide();
  }

  void _close() {
    if (!_isOpen) {
      return;
    }
    setState(() => _isOpen = false);
    _portal.hide();
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: _strip,
      child: TapRegion(
        groupId: _group,
        child: Tooltip(
          message: 'More formatting',
          child: SizedBox.square(
            key: _button,
            dimension: TomToolbarButtonWidget.size,
            child: Material(
              color: colors.surfaceRaised,
              borderRadius: BorderRadius.circular(TomMetrics.radius),
              child: InkWell(
                onTap: _toggle,
                borderRadius: BorderRadius.circular(TomMetrics.radius),
                child: Center(
                  child: TomGlyphWidget(
                    glyph: TomGlyphEnum.more,
                    // Lit while it is open: the way to close it must be
                    // visible, the same reading as the preferences gear.
                    color: _isOpen ? colors.accent : colors.textSecondary,
                    size: TomToolbarButtonWidget.glyphSize,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The four buttons, under the one that hid them.
  ///
  /// Measured rather than followed, for the reason the preferences popover
  /// carries: a `CompositedTransformFollower` cannot hand a paint transform
  /// to what lays out inside it, and the row does not scroll any more.
  Widget _strip(BuildContext context) {
    final RenderBox? button =
        _button.currentContext?.findRenderObject() as RenderBox?;
    if (button == null) {
      return const SizedBox.shrink();
    }
    final Offset corner = button.localToGlobal(Offset(0, button.size.height));
    final TomColors colors = TomColors.of(context);
    return Stack(
      children: <Widget>[
        Positioned(
          left: corner.dx,
          top: corner.dy + EditorToolbarWidget.gap,
          child: TapRegion(
            groupId: _group,
            onTapOutside: (PointerDownEvent _) => _close(),
            child: Material(
              color: colors.surfaceRaised,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: colors.border),
                borderRadius: BorderRadius.circular(TomMetrics.radius),
              ),
              child: Padding(
                padding: const EdgeInsets.all(EditorToolbarWidget.gap),
                child: EditorToolbarWidget._buttons(
                  widget.group,
                  ref,
                  widget.history,
                  editable: widget.editable,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
