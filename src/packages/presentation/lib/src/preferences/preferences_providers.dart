/// What preferences are wired from, declared where they live.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';

part 'preferences_providers.g.dart';

/// Reads what the machine remembers.
///
/// Declared here and overridden by the composition root, which is how every
/// use case reaches this package.
@riverpod
ReadPreferencesUseCase readPreferences(Ref ref) => throw StateError(
  'readPreferencesProvider has no default. The composition root overrides '
  'it — see runTom() in tom_desktop.',
);

/// Writes a choice back.
@riverpod
WritePreferencesUseCase writePreferences(Ref ref) => throw StateError(
  'writePreferencesProvider has no default. The composition root overrides '
  'it — see runTom() in tom_desktop.',
);
