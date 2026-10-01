import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late _Settings settings;
  late PreferencesRepositoryImpl repository;

  setUp(() {
    settings = _Settings();
    repository = PreferencesRepositoryImpl(
      source: PreferencesDataSource(settings: settings),
    );
  });

  test('a machine that has never been asked holds the defaults', () async {
    expect(await repository.read(), PreferencesValueObject.defaults);
  });

  test('what was written comes back', () async {
    const PreferencesValueObject chosen = PreferencesValueObject(
      theme: ThemeChoiceEnum.dark,
      language: LanguageEnum.portuguese,
      showingFormattingBar: false,
    );

    await repository.write(chosen);

    expect(await repository.read(), chosen);
  });

  test('it is one JSON object, in names a reader can follow', () async {
    // The point of keeping it as JSON at all: a settings format a user can
    // read is one a user will want to see.
    await repository.write(
      const PreferencesValueObject(theme: ThemeChoiceEnum.light),
    );

    expect(
      settings.stored[PreferencesDataSource.key],
      contains('"theme":"light"'),
    );
  });

  test('a key the file does not carry is the default, silently', () async {
    settings.stored[PreferencesDataSource.key] = '{"theme":"dark"}';

    final PreferencesValueObject read = await repository.read();

    expect(read.theme, ThemeChoiceEnum.dark);
    expect(read.language, LanguageEnum.english);
    expect(read.showingFormattingBar, isTrue);
  });

  test('a value the app cannot use falls back rather than refusing', () async {
    // Editing the file by hand is supported, not protected.
    settings.stored[PreferencesDataSource.key] =
        '{"theme":"sepia","language":42,"showingFormattingBar":"yes"}';

    expect(await repository.read(), PreferencesValueObject.defaults);
  });

  test('a file that is not JSON at all is the defaults too', () async {
    settings.stored[PreferencesDataSource.key] = 'not json {';

    expect(await repository.read(), PreferencesValueObject.defaults);
  });

  test('a store that refuses to read is the defaults, never an error', () {
    // Refusing to start over a preference file would be worse than starting
    // in the wrong theme.
    settings.refuses = true;

    expect(repository.read(), completion(PreferencesValueObject.defaults));
  });

  test('a store that refuses to write says so, because a choice is lost', () {
    settings.refuses = true;

    expect(
      repository.write(PreferencesValueObject.defaults),
      completion(isA<Failure<void, AppFailure>>()),
    );
  });
}

/// A settings store in memory, refusing everything when a test says so.
final class _Settings implements Settings {
  final Map<String, String> stored = <String, String>{};
  bool refuses = false;

  @override
  Future<Result<String?, SettingsFailure>> read(String key) async => refuses
      ? const Failure<String?, SettingsFailure>(
          SettingsUnavailable('no store'),
        )
      : Success<String?, SettingsFailure>(stored[key]);

  @override
  Future<Result<void, SettingsFailure>> write(String key, String value) async {
    if (refuses) {
      return const Failure<void, SettingsFailure>(
        SettingsUnavailable('no store'),
      );
    }
    stored[key] = value;
    return const Success<void, SettingsFailure>(null);
  }

  @override
  Future<Result<void, SettingsFailure>> remove(String key) async {
    stored.remove(key);
    return const Success<void, SettingsFailure>(null);
  }
}
