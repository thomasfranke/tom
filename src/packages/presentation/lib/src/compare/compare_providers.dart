/// What the diff's base is wired from, declared where it is read.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';

part 'compare_providers.g.dart';

/// Reads the branch the one checked out came from.
///
/// Declared here and overridden by the composition root, which is how every
/// use case reaches this package.
@riverpod
ReadDiffBaseUseCase readDiffBase(Ref ref) => throw StateError(
  'readDiffBaseProvider has no default. The composition root overrides it '
  '— see runTom() in tom_desktop.',
);
