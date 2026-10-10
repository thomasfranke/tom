/// The branch each recent row names.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/commands/command_action_enum.dart';
import 'package:tom_presentation/src/commands/command_scope.dart';
import 'package:tom_presentation/src/home/home_providers.dart';

part 'recent_branch.g.dart';

/// The branch [recent] was left on, or null when there is none to name
/// (`docs/product/home/recent-spaces/doc.md`).
///
/// One per row and disposed with it, so coming back to Home asks git again
/// rather than showing the branch a space was on the last time Home was up.
/// Never retried: a branch git could not name in time is a row without one.
@Riverpod(retry: _never)
Future<BranchNameValueObject?> recentBranch(
  Ref ref,
  RecentSpaceEntity recent,
) async {
  final Result<BranchNameValueObject?, AppFailure> read =
      await CommandScope.run(
        CommandActionEnum.readRecentBranch,
        () => ref.read(readRecentBranchProvider).read(recent),
      );
  // A row without its branch is still a row; the use case already
  // reported what threw.
  return switch (read) {
    Success<BranchNameValueObject?, AppFailure>(
      :final BranchNameValueObject? value,
    ) =>
      value,
    Failure<BranchNameValueObject?, AppFailure>() => null,
  };
}

Duration? _never(int retryCount, Object error) => null;
