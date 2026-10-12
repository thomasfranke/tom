/// What the changes panel is wired from, declared where the panel lives.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';

part 'changes_providers.g.dart';

/// Reads where the repository stands.
///
/// Declared here and overridden by the composition root, which is how every
/// use case reaches this package.
@riverpod
ReadGitStatusUseCase readGitStatus(Ref ref) => throw StateError(
  'readGitStatusProvider has no default. The composition root overrides it '
  '— see runTom() in tom_desktop.',
);

/// Moves whole files in and out of the index.
@riverpod
StageChangesUseCase stageChanges(Ref ref) => throw StateError(
  'stageChangesProvider has no default. The composition root overrides it '
  '— see runTom() in tom_desktop.',
);

/// Records the index as a commit.
@riverpod
CommitChangesUseCase commitChanges(Ref ref) => throw StateError(
  'commitChangesProvider has no default. The composition root overrides it '
  '— see runTom() in tom_desktop.',
);

/// Whether a pull stopped mid-merge, read from git rather than remembered.
///
/// Here rather than beside the pull that caused it: it is read with the
/// status, by `GitReadingNotifier`, after everything that writes.
@riverpod
ReadMergeStateUseCase readMergeState(Ref ref) => throw StateError(
  'readMergeStateProvider has no default. The composition root overrides it '
  '— see runTom() in tom_desktop.',
);

/// Puts every tracked file back as the last commit has it, from the git
/// column's menu.
@riverpod
DiscardAllChangesUseCase discardAllChanges(Ref ref) => throw StateError(
  'discardAllChangesProvider has no default. The composition root overrides '
  'it — see runTom() in tom_desktop.',
);

/// Puts one file of the changes list back, from the ↶ at the end of its row.
@riverpod
DiscardChangeUseCase discardChange(Ref ref) => throw StateError(
  'discardChangeProvider has no default. The composition root overrides it '
  '— see runTom() in tom_desktop.',
);

/// Opens the platform's terminal at the repository's root, from the git
/// column's menu (`docs/product/git-workflow/git-menu/doc.md`).
@riverpod
OpenTerminalUseCase openTerminal(Ref ref) => throw StateError(
  'openTerminalProvider has no default. The composition root overrides it '
  '— see runTom() in tom_desktop.',
);
