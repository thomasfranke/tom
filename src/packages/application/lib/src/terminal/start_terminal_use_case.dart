/// Starting the Terminal tab's shell.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// The person's own shell, at the root of the space's repository — where
/// `git` answers for the whole of it, whichever folder the space is — or at
/// the space's own folder when it has none
/// (`docs/product/workspace/terminal/doc.md`).
final class StartTerminalUseCase with UseCase {
  /// Creates the use case.
  const StartTerminalUseCase({
    required this.terminals,
    required this.observability,
  });

  /// Where shells come from.
  final TerminalRepository terminals;

  @override
  final Observability observability;

  /// Starts a shell for [space] on a screen of [size].
  Future<Result<TerminalSessionPort, AppFailure>> start(
    SpaceEntity space,
    TerminalSizeValueObject size,
  ) => guard(() => terminals.start(space.repositoryRoot ?? space.root, size));
}
