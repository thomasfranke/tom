/// What is wrong with the link to the remote, when something is.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// The four states that earn a line at the foot of the git column
/// (`docs/product/git-workflow/push-pull/when-the-link-is-broken/doc.md`).
///
/// A healthy link has none; the same line then says where the branch stands
/// against its upstream, and any of these replaces that. The screen words it.
enum LinkStateEnum {
  /// The remote's host could not be reached.
  noNetwork(isPressable: false),

  /// The remote refused the credentials git offered.
  credentialsRefused(isPressable: false),

  /// There is no remote to talk to.
  noRemote(isPressable: false),

  /// The remote did not answer in time — the one where trying again is the
  /// remedy, so the buttons stay live.
  timedOut(isPressable: true);

  const LinkStateEnum({required this.isPressable});

  /// Whether `Push`, `Fetch` and `Pull` stay available.
  final bool isPressable;

  /// The state [failure] says the link is in, or null when it says nothing
  /// about the link.
  static LinkStateEnum? of(AppFailure failure) => switch (failure) {
    GitNetworkUnavailable() => LinkStateEnum.noNetwork,
    GitAuthenticationFailed() => LinkStateEnum.credentialsRefused,
    GitNoRemote() => LinkStateEnum.noRemote,
    GitTimedOut() => LinkStateEnum.timedOut,
    _ => null,
  };
}
