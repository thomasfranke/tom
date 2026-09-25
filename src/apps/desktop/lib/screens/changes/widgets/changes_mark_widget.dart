/// What happened to a file, as a letter in a tinted box.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_ui/tom_ui.dart';

/// A file's state as a letter on a tinted square, never the tint alone
/// (`docs/technical/design/visual-language.md`).
///
/// The letters are the domain's alphabet, not git's: git's `U` means
/// unmerged, so an untracked file is `N`.
class ChangesMarkWidget extends StatelessWidget {
  /// Creates the mark for [state].
  const ChangesMarkWidget({required this.state, super.key});

  /// What happened to the file.
  final FileStateEnum state;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<FileStateEnum>('state', state));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    final (Color ink, Color fill) = _rolesOf(colors);
    return DiffMarkWidget(
      letter: _letters[state]!,
      ink: ink,
      fill: fill,
      tooltip: _words[state]!,
    );
  }

  /// The pair of roles this state is drawn in.
  ///
  /// Three roles for six states: the palette names appeared, went and
  /// changed, and the letter tells the rest apart.
  (Color, Color) _rolesOf(TomColors colors) => switch (state) {
    FileStateEnum.added ||
    FileStateEnum.untracked => (colors.added, colors.addedSoft),
    FileStateEnum.deleted => (colors.removed, colors.removedSoft),
    FileStateEnum.modified ||
    FileStateEnum.renamed => (colors.modified, colors.modifiedSoft),
    // A conflict is the one thing here that cannot be committed as it stands.
    FileStateEnum.conflicted => (colors.removed, colors.removedSoft),
  };

  static const Map<FileStateEnum, String> _letters = <FileStateEnum, String>{
    FileStateEnum.modified: 'M',
    FileStateEnum.added: 'A',
    FileStateEnum.deleted: 'D',
    FileStateEnum.renamed: 'R',
    FileStateEnum.untracked: 'N',
    FileStateEnum.conflicted: 'C',
  };

  static const Map<FileStateEnum, String> _words = <FileStateEnum, String>{
    FileStateEnum.modified: 'Modified',
    FileStateEnum.added: 'Added',
    FileStateEnum.deleted: 'Deleted',
    FileStateEnum.renamed: 'Renamed',
    FileStateEnum.untracked: 'New — git has never been told about it',
    FileStateEnum.conflicted: 'Conflicted — resolve it before committing',
  };
}
