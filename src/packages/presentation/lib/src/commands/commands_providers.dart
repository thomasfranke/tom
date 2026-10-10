/// What approving commands is wired from, declared where the list lives.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';

part 'commands_providers.g.dart';

/// Reads which commands `git-approvals.json` allows.
///
/// Declared here and overridden by the composition root, which is how every
/// use case reaches this package.
@riverpod
ReadApprovalsUseCase readApprovals(Ref ref) => throw StateError(
  'readApprovalsProvider has no default. The composition root overrides it '
  '— see runTom() in tom_desktop.',
);

/// Writes `true` beside one command's key.
@riverpod
AllowCommandUseCase allowCommand(Ref ref) => throw StateError(
  'allowCommandProvider has no default. The composition root overrides it '
  '— see runTom() in tom_desktop.',
);

/// Lists every command the app can run in the file, before it is opened.
@riverpod
SeedApprovalsUseCase seedApprovals(Ref ref) => throw StateError(
  'seedApprovalsProvider has no default. The composition root overrides it '
  '— see runTom() in tom_desktop.',
);
