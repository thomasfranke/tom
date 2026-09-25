/// What the remote actions are wired from, declared where they live.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';

part 'remote_providers.g.dart';

/// Updates the remote-tracking branches, touching no file on disk.
///
/// Declared here and overridden by the composition root, which is how every
/// use case reaches this package.
@riverpod
FetchRemoteUseCase fetchRemote(Ref ref) => throw StateError(
  'fetchRemoteProvider has no default. The composition root overrides it '
  '— see runTom() in tom_desktop.',
);

/// Brings the remote's commits into the current branch.
@riverpod
PullRemoteUseCase pullRemote(Ref ref) => throw StateError(
  'pullRemoteProvider has no default. The composition root overrides it '
  '— see runTom() in tom_desktop.',
);

/// Publishes the current branch's commits.
@riverpod
PushRemoteUseCase pushRemote(Ref ref) => throw StateError(
  'pushRemoteProvider has no default. The composition root overrides it '
  '— see runTom() in tom_desktop.',
);
