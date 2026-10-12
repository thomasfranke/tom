/// What each platform calls its file manager, in the menus that open it.
library;

import 'dart:io';

import 'package:tom_desktop/l10n/l10n.dart';

/// The explorer menu's last row: the verb follows the platform
/// (`docs/product/navigation/file-tree/explorer-menu/doc.md`).
String revealLabel(AppLocalizations l10n, [String? operatingSystem]) =>
    switch (operatingSystem ?? Platform.operatingSystem) {
      'macos' => l10n.revealInFinder,
      'windows' => l10n.revealInExplorer,
      _ => l10n.revealInFiles,
    };

/// The git menu's third row, naming the same program
/// (`docs/product/git-workflow/git-menu/doc.md`).
String openRepositoryLabel(AppLocalizations l10n, [String? operatingSystem]) =>
    switch (operatingSystem ?? Platform.operatingSystem) {
      'macos' => l10n.openRepositoryInFinder,
      'windows' => l10n.openRepositoryInExplorer,
      _ => l10n.openRepositoryInFiles,
    };
