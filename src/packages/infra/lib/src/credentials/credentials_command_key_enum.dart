/// Every git and `gh` command the credentials capability can run, by name.
library;

import 'package:tom_core/tom_core.dart';

/// What [Credentials](credentials.dart) asks of `gh` and git, each as the
/// program receives it ([Decision 38](../../../../../../docs/technical/decisions/038-a-command-waits-at-a-gate-in-tom-core.md)).
///
/// `ssh` is not here: what waits at the gate is git and `gh`, and its
/// greeting touches neither the repository nor GitHub's API.
enum CredentialsCommandKeyEnum implements CommandKey {
  /// Every account `gh` holds for a host.
  ghAccounts('gh auth status --hostname <host> --json hosts'),

  /// The same, from a `gh` older than `--json`.
  ghAccountsAsText('gh auth status --hostname <host>'),

  /// The token `gh` holds for a login.
  ghToken('gh auth token --hostname <host> --user <login>'),

  /// What git's credential helper holds for a host.
  gitCredential('git -c credential.interactive=false credential fill');

  const CredentialsCommandKeyEnum(this.template);

  @override
  final String template;

  /// Every one of them reads.
  @override
  bool get isWrite => false;
}
