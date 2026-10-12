/// Which way commits are being moved.
library;

import 'package:tom_presentation/src/commands/command_action_enum.dart';

/// Fetch, pull or push — the three, and no combined "sync", which would be
/// one name for three different risks
/// (`docs/product/git-workflow/push-pull/the-controls/doc.md`).
enum RemoteActionEnum {
  /// Ask the remote what it has, and change no file on disk.
  fetch,

  /// Bring the remote's commits into this branch — the one that writes.
  pull,

  /// Publish this branch's commits.
  push;

  /// What its commands are called in the commands panel, and waited on as.
  CommandActionEnum get command => switch (this) {
    fetch => CommandActionEnum.fetch,
    pull => CommandActionEnum.pull,
    push => CommandActionEnum.push,
  };
}
