/// Whether git waits for the person before it answers.
library;

import 'package:riverpod/riverpod.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/preferences/preferences_notifier.dart';

/// Whether the chosen mode makes a git command wait for a yes — Semi-automatic
/// and Manual — so what only decorates the window, or can be shown from the
/// disk, must not stand behind it
/// (`docs/product/git-workflow/approvals/doc.md`).
///
/// False where no preferences are wired, and once [ref] is disposed.
Future<bool> gitAsksFirst(Ref ref) async {
  if (!ref.exists(preferencesProvider)) {
    return false;
  }
  await ref.read(preferencesProvider.notifier).loaded;
  return ref.mounted &&
      ref.read(preferencesProvider).gitApprovals !=
          GitApprovalModeEnum.automatic;
}
