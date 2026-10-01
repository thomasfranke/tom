/// Preferences, over the settings store.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/src/preferences/preferences_data_source.dart';
import 'package:tom_data/src/preferences/preferences_dto.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

/// [PreferencesRepository] over a [PreferencesDataSource].
///
/// **A read cannot fail**: a store that refused or a file somebody broke
/// answers the defaults, because refusing to start over a preference file
/// would be worse than starting in the wrong theme.
final class PreferencesRepositoryImpl implements PreferencesRepository {
  /// Creates the repository over [source].
  const PreferencesRepositoryImpl({required this.source});

  /// Where the object is read and written.
  final PreferencesDataSource source;

  @override
  Future<PreferencesValueObject> read() async => switch (await source.read()) {
    Success<PreferencesDto, SettingsFailure>(value: final PreferencesDto row) =>
      row.toValueObject(),
    Failure<PreferencesDto, SettingsFailure>() =>
      PreferencesValueObject.defaults,
  };

  @override
  Future<Result<void, AppFailure>> write(
    PreferencesValueObject preferences,
  ) async => switch (await source.write(PreferencesDto.of(preferences))) {
    Success<void, SettingsFailure>() => const Success<void, AppFailure>(null),
    Failure<void, SettingsFailure>(failure: final SettingsFailure failure) =>
      Failure<void, AppFailure>(failure),
  };
}
