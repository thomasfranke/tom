/// What preferences are wired from, declared where they live.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_domain/tom_domain.dart';

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

/// Where the preferences file is, relative to the folder the composition
/// root keeps it in — the path the editor reads it at, and its tab's name.
@riverpod
SpaceRelativePathValueObject preferencesFile(Ref ref) => throw StateError(
  'preferencesFileProvider has no default. The composition root overrides '
  'it — see runTom() in tom_desktop.',
);
