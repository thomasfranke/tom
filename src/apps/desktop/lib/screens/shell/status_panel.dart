/// The status bar's content: where the space is, and what is open in it.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// What the status bar says: git's state at the left, the open document's
/// at the right.
///
/// The space's path left the strip when the breadcrumb took it over; what is
/// here is what the 1b boards draw, and each item is absent while there is
/// nothing to read it from.
class StatusPanel extends ConsumerWidget {
  /// Creates the panel.
  const StatusPanel({super.key});

  /// Between two items.
  static const double _gap = 16;

  /// A glyph beside an item's words, and the gap after it.
  static const double _glyph = 10;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SpaceSessionState? session = ref.watch(spaceSessionProvider);
    final TomColors colors = TomColors.of(context);
    final TextStyle read = TextStyle(
      fontSize: 11,
      height: 1.3,
      color: colors.textSecondary,
    );
    final TextStyle aside = read.copyWith(color: colors.textMuted);
    final AppLocalizations l10n = context.l10n;
    if (session == null) {
      return Text(l10n.commonNoSpaceOpenStatus, style: read);
    }
    final EditorState editor = ref.watch(editorProvider);
    final GitStatusValueObject? git = session.git;
    final ({int line, int column})? caret = editor.caret;
    final int changes = git?.entries.length ?? 0;
    return Row(
      children: <Widget>[
        if (git != null) ...<Widget>[
          _ItemWidget(
            glyph: TomGlyphEnum.branch,
            ink: colors.textSecondary,
            label: _branch(l10n, git),
            style: read,
          ),
          const SizedBox(width: _gap),
          _ItemWidget(
            glyph: TomGlyphEnum.push,
            ink: colors.textMuted,
            label: '${git.ahead}',
            style: aside,
          ),
          const SizedBox(width: 6),
          _ItemWidget(
            glyph: TomGlyphEnum.pull,
            ink: colors.textMuted,
            label: '${git.behind}',
            style: aside,
          ),
          if (changes > 0) ...<Widget>[
            const SizedBox(width: _gap),
            _DotWidget(colour: colors.modified),
            const SizedBox(width: 6),
            Text(l10n.shellChanges(changes), style: read),
          ],
        ],
        const Spacer(),
        if (editor case EditorReady(
          :final bool isSaving,
          :final bool isBinary,
        )) ...<Widget>[
          // A binary file has no lines and no encoding to name.
          if (!isBinary) ...<Widget>[
            if (caret != null)
              Text(l10n.shellCaret(caret.line, caret.column), style: aside),
            const SizedBox(width: _gap),
            Text('UTF-8', style: aside),
            const SizedBox(width: _gap),
          ],
          Text(
            isBinary
                ? l10n.shellKindBinary
                : kindLabelOf(l10n, editor.kind ?? FileKindEnum.markdown),
            style: aside,
          ),
          const SizedBox(width: _gap),
          // Neither saved nor unsaved: nothing typed reaches this buffer.
          if (editor.isReadOnly)
            Text(l10n.shellReadOnly, style: aside)
          else if (editor.isDirty)
            // Unsaved is said in its colour and without the check: a check
            // beside it would say the opposite of the word.
            Text(
              isSaving ? l10n.shellSaving : l10n.commonUnsaved,
              style: aside.copyWith(color: colors.modified),
            )
          else
            _ItemWidget(
              glyph: TomGlyphEnum.check,
              ink: colors.textMuted,
              label: l10n.shellSaved,
              style: aside,
            ),
        ],
      ],
    );
  }

  /// The branch in the status bar's words: a detached `HEAD` is named, since
  /// it is a state to get out of rather than a missing value.
  static String _branch(AppLocalizations l10n, GitStatusValueObject git) =>
      switch (git) {
        GitStatusValueObject(isDetached: true) => l10n.commonDetachedHead,
        GitStatusValueObject(branch: final BranchNameValueObject branch) =>
          branch.value,
        _ => l10n.commonNoBranch,
      };
}

/// What the status bar calls [kind], read off the file's extension
/// (`docs/product/git-workflow/commit/opening-a-change/doc.md`).
String kindLabelOf(AppLocalizations l10n, FileKindEnum kind) => switch (kind) {
  FileKindEnum.markdown => l10n.shellKindMarkdown,
  FileKindEnum.json => l10n.shellKindJson,
  FileKindEnum.yaml => l10n.shellKindYaml,
  FileKindEnum.toml => l10n.shellKindToml,
  FileKindEnum.xml => l10n.shellKindXml,
  FileKindEnum.html => l10n.shellKindHtml,
  FileKindEnum.css => l10n.shellKindCss,
  FileKindEnum.javascript => l10n.shellKindJavaScript,
  FileKindEnum.typescript => l10n.shellKindTypeScript,
  FileKindEnum.dart => l10n.shellKindDart,
  FileKindEnum.python => l10n.shellKindPython,
  FileKindEnum.shell => l10n.shellKindShell,
  FileKindEnum.plainText => l10n.shellKindPlainText,
};

/// A glyph and the words after it.
class _ItemWidget extends StatelessWidget {
  const _ItemWidget({
    required this.glyph,
    required this.ink,
    required this.label,
    required this.style,
  });

  final TomGlyphEnum glyph;
  final Color ink;
  final String label;
  final TextStyle style;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<TomGlyphEnum>('glyph', glyph))
      ..add(ColorProperty('ink', ink))
      ..add(StringProperty('label', label))
      ..add(DiagnosticsProperty<TextStyle>('style', style));
  }

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      TomGlyphWidget(glyph: glyph, color: ink, size: StatusPanel._glyph),
      const SizedBox(width: 4),
      Text(label, style: style),
    ],
  );
}

/// The dot before the count of changes, in the role a change wears.
class _DotWidget extends StatelessWidget {
  const _DotWidget({required this.colour});

  final Color colour;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('colour', colour));
  }

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 6,
    child: DecoratedBox(
      decoration: BoxDecoration(color: colour, shape: BoxShape.circle),
    ),
  );
}
