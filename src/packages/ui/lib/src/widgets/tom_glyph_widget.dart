/// The icon set: Font Awesome Free's solid glyphs, from the vendored face.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_ui/src/theme/tom_fonts.dart';

/// Which glyph of the set to draw.
///
/// Grows a glyph at a time, as the boards ask; each one is a glyph of Font
/// Awesome Free 6 Solid — whose name each dartdoc gives — called after what
/// it does here (`docs/design/components/icons.md`).
enum TomGlyphEnum {
  /// `folder`: picking one.
  folder,

  /// `link`: a URL.
  link,

  /// `arrow-up`: publishing.
  push,

  /// `arrow-down`: bringing back.
  pull,

  /// `arrows-rotate`: asking what is there — not an arrow one way, because
  /// a fetch writes nothing to disk.
  fetch,

  /// `rotate-left`: taking the last thing back.
  undo,

  /// `rotate-right`.
  redo,

  /// `heading`.
  heading,

  /// `bold`.
  bold,

  /// `italic`.
  italic,

  /// `strikethrough`.
  strikethrough,

  /// `list-ul`.
  list,

  /// `list-ol`.
  orderedList,

  /// `list-check`.
  taskList,

  /// `quote-left`.
  quote,

  /// `code`.
  code,

  /// `table`.
  table,

  /// `minus`: a horizontal rule — and a permission nobody could read.
  rule,

  /// `image`.
  image,

  /// `superscript`: a footnote's raised mark.
  footnote,

  /// `triangle-exclamation`: an alert block.
  alert,

  /// `gear`: the one symbol for settings nobody has to learn.
  preferences,

  /// `ellipsis`: what a row too narrow for its last group collapses into.
  more,

  /// `chevron-down`: what it opens is open.
  chevronDown,

  /// `chevron-right`: what it opens is closed.
  chevronRight,

  /// `xmark`: closing, forgetting, dismissing.
  close,

  /// `circle-xmark`: emptying a field.
  clear,

  /// `check`.
  check,

  /// `right-left`: replacing one thing with another.
  replace,

  /// `code-branch`: a branch.
  branch,

  /// `folder-open`: a folder whose contents are shown.
  folderOpen,

  /// `file-lines`: a document.
  file,

  /// `plus`: making something new.
  plus,

  /// `ellipsis-vertical`: a column's own menu.
  menu,

  /// `magnifying-glass`: finding.
  search,

  /// `house`: the opening screen, which is the way out of a space.
  home,

  /// `terminal`: where a `git` command is typed.
  terminal,

  /// `user`: a person nobody has named yet.
  person,

  /// `arrow-up-right-from-square`: a page that opens outside the app.
  external,

  /// `copy`: putting a line on the clipboard.
  copy,

  /// `arrow-rotate-left`: putting one file back as git has it — not
  /// [undo]'s `rotate-left`, which takes back an edit.
  discard,
}

/// One glyph of the set, in a box of [size].
///
/// A glyph is a character of a vendored face, the way the three IBM Plex
/// faces are, so the set costs no package and nothing is fetched at
/// runtime (`docs/technical/stack/fonts.md`).
class TomGlyphWidget extends StatelessWidget {
  /// Creates [glyph] in [color], in a box of [size], filled unless
  /// [outline].
  const TomGlyphWidget({
    required this.glyph,
    required this.color,
    this.size = defaultSize,
    this.outline = false,
    super.key,
  });

  /// The size beside a label: a step under the text's cap height reads as
  /// the same weight as a 13 word.
  static const double defaultSize = 14;

  /// The line an [outline] is drawn with, the top bar's house and gear on
  /// the 1b boards.
  static const double outlineStroke = 1.25;

  /// Which one.
  final TomGlyphEnum glyph;

  /// The ink, which is the host control's colour and never its own.
  final Color color;

  /// The box, which the glyph fills at its tallest.
  final double size;

  /// Whether the glyph is stroked rather than filled.
  ///
  /// The same Solid glyph with its edge painted, not a second set: Font
  /// Awesome Free has no regular house or gear (Decision 32, revised).
  final bool outline;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<TomGlyphEnum>('glyph', glyph))
      ..add(ColorProperty('color', color))
      ..add(DoubleProperty('size', size))
      ..add(FlagProperty('outline', value: outline, ifTrue: 'outline'));
  }

  @override
  Widget build(BuildContext context) {
    final IconData icon = _icons[glyph]!;
    if (!outline) {
      return Icon(icon, size: size, color: color);
    }
    // What `Icon` builds, with a stroke for the fill: `Icon` takes a colour
    // and never a paint.
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: Center(
          child: RichText(
            overflow: TextOverflow.visible,
            textDirection: Directionality.of(context),
            text: TextSpan(
              text: String.fromCharCode(icon.codePoint),
              style: TextStyle(
                inherit: false,
                fontSize: size,
                fontFamily: icon.fontFamily,
                package: icon.fontPackage,
                height: 1,
                leadingDistribution: TextLeadingDistribution.even,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = outlineStroke
                  ..strokeJoin = StrokeJoin.round
                  ..color = color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One `IconData` per glyph, built once and constant so a release build can
/// still shake the face down to what is used.
const Map<TomGlyphEnum, IconData> _icons = <TomGlyphEnum, IconData>{
  TomGlyphEnum.folder: IconData(
    0xf07b,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
  TomGlyphEnum.link: IconData(
    0xf0c1,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
  TomGlyphEnum.push: IconData(
    0xf062,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
  TomGlyphEnum.pull: IconData(
    0xf063,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
  TomGlyphEnum.fetch: IconData(
    0xf021,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
  TomGlyphEnum.undo: IconData(
    0xf2ea,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
  TomGlyphEnum.redo: IconData(
    0xf2f9,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
  TomGlyphEnum.heading: IconData(
    0xf1dc,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
  TomGlyphEnum.bold: IconData(
    0xf032,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
  TomGlyphEnum.italic: IconData(
    0xf033,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
  TomGlyphEnum.strikethrough: IconData(
    0xf0cc,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
  TomGlyphEnum.list: IconData(
    0xf0ca,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
  TomGlyphEnum.orderedList: IconData(
    0xf0cb,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
  TomGlyphEnum.taskList: IconData(
    0xf0ae,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
  TomGlyphEnum.quote: IconData(
    0xf10d,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
  TomGlyphEnum.code: IconData(
    0xf121,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
  TomGlyphEnum.table: IconData(
    0xf0ce,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
  TomGlyphEnum.rule: IconData(
    0xf068,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
  TomGlyphEnum.image: IconData(
    0xf03e,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
  TomGlyphEnum.footnote: IconData(
    0xf12b,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
  TomGlyphEnum.alert: IconData(
    0xf071,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
  TomGlyphEnum.preferences: IconData(
    0xf013,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
  TomGlyphEnum.more: IconData(
    0xf141,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
  TomGlyphEnum.chevronDown: IconData(
    0xf078,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
  TomGlyphEnum.chevronRight: IconData(
    0xf054,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
  TomGlyphEnum.close: IconData(
    0xf00d,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
  TomGlyphEnum.clear: IconData(
    0xf057,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
  TomGlyphEnum.check: IconData(
    0xf00c,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
  TomGlyphEnum.replace: IconData(
    0xf362,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
  TomGlyphEnum.branch: IconData(
    0xf126,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
  TomGlyphEnum.folderOpen: IconData(
    0xf07c,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
  TomGlyphEnum.file: IconData(
    0xf15c,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
  TomGlyphEnum.plus: IconData(
    0x2b,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
  TomGlyphEnum.menu: IconData(
    0xf142,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
  TomGlyphEnum.search: IconData(
    0xf002,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
  TomGlyphEnum.terminal: IconData(
    0xf120,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
  TomGlyphEnum.home: IconData(
    0xf015,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
  TomGlyphEnum.person: IconData(
    0xf007,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
  TomGlyphEnum.external: IconData(
    0xf08e,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
  TomGlyphEnum.copy: IconData(
    0xf0c5,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
  TomGlyphEnum.discard: IconData(
    0xf0e2,
    fontFamily: TomFonts.icons,
    fontPackage: TomFonts.iconsPackage,
  ),
};
