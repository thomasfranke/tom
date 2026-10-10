/// What happened to a file, as a letter in a tinted box.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_ui/tom_ui.dart';

/// A file's state as a letter on a tinted square, never the tint alone
/// (`docs/design/visual-language/README.md`).
///
/// The letters are the domain's alphabet, not git's: git's `U` means
/// unmerged, so an untracked file is `N`.
///
/// Outside `screens/` because the changes column and the file tree both draw
/// it, and out of `tom_ui` because it names [FileStateEnum] and that package
/// depends on nothing ([Decision 26](../../../../../docs/technical/decisions/026-the-look-is-a-package.md)).
class FileStateMarkWidget extends StatelessWidget {
  /// Creates the mark for [state].
  const FileStateMarkWidget({
    required this.state,
    this.isBare = false,
    super.key,
  });

  /// What happened to the file.
  final FileStateEnum state;

  /// Whether to draw the letter without its square — the tree's shape, where
  /// the row's own highlight is the only fill.
  final bool isBare;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<FileStateEnum>('state', state))
      ..add(DiagnosticsProperty<bool>('isBare', isBare));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    final Color ink = _inkOf(colors);
    final String word = _wordOf(context.l10n);
    return isBare
        ? DiffMarkWidget.bare(letter: _letters[state]!, ink: ink, tooltip: word)
        : DiffMarkWidget(letter: _letters[state]!, ink: ink, tooltip: word);
  }

  /// What the letter stands for, in the window's language.
  String _wordOf(AppLocalizations l10n) => switch (state) {
    FileStateEnum.modified => l10n.fileStateModified,
    FileStateEnum.added => l10n.fileStateAdded,
    FileStateEnum.deleted => l10n.fileStateDeleted,
    FileStateEnum.renamed => l10n.fileStateRenamed,
    FileStateEnum.untracked => l10n.fileStateUntracked,
    FileStateEnum.conflicted => l10n.fileStateConflicted,
  };

  /// The role this state is drawn in.
  ///
  /// Three roles for six states: the palette names appeared, went and
  /// changed, and the letter tells the rest apart.
  Color _inkOf(TomColors colors) => switch (state) {
    FileStateEnum.added || FileStateEnum.untracked => colors.added,
    FileStateEnum.deleted => colors.removed,
    FileStateEnum.modified || FileStateEnum.renamed => colors.modified,
    // A conflict is the one thing here that cannot be committed as it stands.
    FileStateEnum.conflicted => colors.removed,
  };

  static const Map<FileStateEnum, String> _letters = <FileStateEnum, String>{
    FileStateEnum.modified: 'M',
    FileStateEnum.added: 'A',
    FileStateEnum.deleted: 'D',
    FileStateEnum.renamed: 'R',
    FileStateEnum.untracked: 'N',
    FileStateEnum.conflicted: 'C',
  };
}
