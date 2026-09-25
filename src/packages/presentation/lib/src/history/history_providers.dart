/// What the history panel is wired from, declared where it lives.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';

part 'history_providers.g.dart';

/// Reads the commits that touched one document.
///
/// Declared here and overridden by the composition root, which is how every
/// use case reaches this package.
@riverpod
ReadFileHistoryUseCase readFileHistory(Ref ref) => throw StateError(
  'readFileHistoryProvider has no default. The composition root overrides '
  'it — see runTom() in tom_desktop.',
);
