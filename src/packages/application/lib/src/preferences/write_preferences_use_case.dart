/// Putting a choice back where it is remembered.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// The whole object written back, every time one preference changes.
///
/// The whole object rather than one key, because the store keeps them as one
/// JSON object and a partial write would have to read it first — which is
/// what the caller already did (`docs/product/preferences/where-it-is-stored/doc.md`).
final class WritePreferencesUseCase with UseCase {
  /// Creates the use case.
  const WritePreferencesUseCase({
    required this.preferences,
    required this.observability,
  });

  /// Where they are kept.
  final PreferencesRepository preferences;

  @override
  final Observability observability;

  /// Stores [chosen].
  Future<Result<void, AppFailure>> write(PreferencesValueObject chosen) =>
      guard(() => preferences.write(chosen));
}
