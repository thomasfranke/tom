/// What the branch switcher is wired from, declared where it lives.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';

part 'branches_providers.g.dart';

/// Lists the repository's local branches.
///
/// Declared here and **overridden by the composition root**: this package
/// names the use cases it needs and cannot see that a process answers them.
@riverpod
ListBranchesUseCase listBranches(Ref ref) => throw StateError(
  'listBranchesProvider has no default. The composition root overrides it '
  '— see runTom() in tom_desktop.',
);

/// Moves `HEAD` onto a branch, or starts one and moves onto that.
@riverpod
SwitchBranchUseCase switchBranch(Ref ref) => throw StateError(
  'switchBranchProvider has no default. The composition root overrides it '
  '— see runTom() in tom_desktop.',
);
