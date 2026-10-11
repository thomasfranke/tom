/// [PreferencesRepositoryImpl] over the real settings file on a real disk:
/// what the store proves about JSON, proven here about the preferences in it.
library;

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late Directory tempDir;
  late String path;

  /// A repository of its own over the one file, as a second run of the app
  /// would build it.
  PreferencesRepositoryImpl repository() => PreferencesRepositoryImpl(
    source: PreferencesDataSource(
      settings: JsonFileSettingsImpl(
        filesystem: const DartIoFilesystemImpl(),
        path: path,
      ),
    ),
  );

  RecentSpacesRepositoryImpl recents() => RecentSpacesRepositoryImpl(
    recents: RecentSpacesDataSource(
      settings: JsonFileSettingsImpl(
        filesystem: const DartIoFilesystemImpl(),
        path: path,
      ),
    ),
    observability: const _Silent(),
  );

  void put(String text) => File(path)
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(text);

  Map<String, Object?> onDisk() =>
      jsonDecode(File(path).readAsStringSync()) as Map<String, Object?>;

  /// Runs `chmod`, and puts [restore] back when the test ends so the
  /// temporary folder can be removed.
  void chmod(String mode, String target, {required String restore}) {
    Process.runSync('chmod', <String>[mode, target]);
    addTearDown(() => Process.runSync('chmod', <String>[restore, target]));
  }

  const PreferencesValueObject chosen = PreferencesValueObject(
    theme: ThemeChoiceEnum.dark,
    language: LanguageEnum.portuguese,
    showingFormattingBar: false,
    gitApprovals: GitApprovalModeEnum.semi,
    // Unticked: the default is on, and a stored false is the choice.
    checkingForUpdates: false,
  );

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('tom_preferences_');
    // A folder with a space, as `Application Support` has.
    path = '${tempDir.path}/Application Support/tom/preferences.json';
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  const String posixOnly = 'permissions are POSIX here';

  group('a first run', () {
    test('reads the defaults, and makes no file to do it', () async {
      expect(await repository().read(), PreferencesValueObject.defaults);
      expect(File(path).existsSync(), isFalse);
      expect(File(path).parent.existsSync(), isFalse);
    });

    test('the first choice makes the file and its folders', () async {
      expect(
        await repository().write(chosen),
        isA<Success<void, AppFailure>>(),
      );

      expect(File(path).existsSync(), isTrue);
    });
  });

  group('what was chosen', () {
    test('is read back by a second repository over the same file', () async {
      await repository().write(chosen);

      expect(await repository().read(), chosen);
    });

    test('is an object a person can read and edit, under one key', () async {
      await repository().write(chosen);

      expect(onDisk(), <String, Object?>{
        'app.preferences': <String, Object?>{
          'theme': 'dark',
          'language': 'portuguese',
          'showingFormattingBar': false,
          'gitApprovals': 'semi',
          'checkingForUpdates': false,
        },
      });
      // Indented, one value to a line — the file opens in a tab.
      expect(File(path).readAsStringSync(), contains('\n    "theme": "dark"'));
    });

    test('a later choice replaces the earlier one whole', () async {
      await repository().write(chosen);
      await repository().write(PreferencesValueObject.defaults);

      expect(await repository().read(), PreferencesValueObject.defaults);
      expect(
        (onDisk()['app.preferences']! as Map<String, Object?>)['theme'],
        'system',
      );
    });

    for (final ThemeChoiceEnum theme in ThemeChoiceEnum.values) {
      for (final LanguageEnum language in LanguageEnum.values) {
        for (final GitApprovalModeEnum mode in GitApprovalModeEnum.values) {
          test('${theme.name} · ${language.name} · ${mode.name} survives '
              'the file', () async {
            final PreferencesValueObject preferences = PreferencesValueObject(
              theme: theme,
              language: language,
              gitApprovals: mode,
            );

            await repository().write(preferences);

            expect(await repository().read(), preferences);
          });
        }
      }
    }
  });

  group('the file is shared', () {
    final SpaceEntity space = SpaceEntity(
      root: '/work/notes',
      repositoryRoot: '/work/notes',
      name: 'notes',
    );

    test('a choice keeps the recent spaces', () async {
      await recents().remember(space);

      await repository().write(chosen);

      expect(onDisk().keys, <String>['spaces.recent', 'app.preferences']);
      final Result<List<RecentSpaceEntity>, Never> listed = await recents()
          .list();
      expect(
        (listed as Success<List<RecentSpaceEntity>, Never>).value.single.root,
        '/work/notes',
      );
    });

    test('and a space remembered keeps the choice', () async {
      await repository().write(chosen);

      await recents().remember(space);

      expect(await repository().read(), chosen);
    });

    test('a key this build does not know is kept through a write', () async {
      put('{"someday.feature": {"on": true}, "app.preferences": {}}');

      await repository().write(chosen);

      expect(onDisk()['someday.feature'], <String, Object?>{'on': true});
    });
  });

  group('a file somebody edited by hand', () {
    test('one value is enough: the rest are the defaults', () async {
      put('{"app.preferences": {"theme": "light"}}');

      expect(
        await repository().read(),
        const PreferencesValueObject(theme: ThemeChoiceEnum.light),
      );
    });

    test('a language this build no longer speaks is the machine\'s', () async {
      put('{"app.preferences": {"theme": "dark", "language": "spanish"}}');

      expect(
        await repository().read(),
        const PreferencesValueObject(theme: ThemeChoiceEnum.dark),
      );
    });

    test('values of the wrong type are the defaults, one by one', () async {
      put(
        '{"app.preferences": {"theme": 3, "language": ["portuguese"], '
        '"showingFormattingBar": "no", "gitApprovals": null}}',
      );

      expect(await repository().read(), PreferencesValueObject.defaults);
    });

    test('a wrong value beside a right one costs only itself', () async {
      put(
        '{"app.preferences": {"theme": "sepia", "language": "portuguese", '
        '"showingFormattingBar": false, "gitApprovals": "strictest"}}',
      );

      expect(
        await repository().read(),
        const PreferencesValueObject(
          language: LanguageEnum.portuguese,
          showingFormattingBar: false,
        ),
      );
    });

    test('preferences that are not an object are the defaults', () async {
      for (final String held in <String>['"dark"', '42', 'true', 'null']) {
        put('{"app.preferences": $held}');

        expect(
          await repository().read(),
          PreferencesValueObject.defaults,
          reason: held,
        );
      }
    });

    test('a value in other casing is not guessed at', () async {
      put('{"app.preferences": {"theme": "Dark"}}');

      expect(await repository().read(), PreferencesValueObject.defaults);
    });
  });

  group('the shape an older version wrote', () {
    test(
      'an object escaped inside a string reads as the preferences',
      () async {
        put(
          jsonEncode(<String, Object?>{
            'app.preferences': jsonEncode(<String, Object?>{
              'theme': 'dark',
              'language': 'portuguese',
              'showingFormattingBar': false,
            }),
          }),
        );

        expect(
          await repository().read(),
          const PreferencesValueObject(
            theme: ThemeChoiceEnum.dark,
            language: LanguageEnum.portuguese,
            showingFormattingBar: false,
          ),
        );
      },
    );

    test('and the next choice writes it in today\'s', () async {
      put(
        jsonEncode(<String, Object?>{
          'app.preferences': jsonEncode(<String, Object?>{'theme': 'dark'}),
          'spaces.recent': jsonEncode(<Object?>[
            <String, Object?>{
              'root': '/work/notes',
              'name': 'notes',
              'lastOpened': '2026-09-01T10:00:00.000Z',
            },
          ]),
        }),
      );

      await repository().write(chosen);

      expect(onDisk()['app.preferences'], isA<Map<String, Object?>>());
      expect(onDisk()['spaces.recent'], isA<List<Object?>>());
      expect(File(path).readAsStringSync(), isNot(contains(r'\"')));
    });
  });

  group('a file that cannot be trusted', () {
    const List<String> broken = <String>[
      '{"app.preferences": {"theme": "dark"',
      'not json at all',
      '["app.preferences"]',
      '"app.preferences"',
    ];

    for (final String text in broken) {
      test('`$text` reads as the defaults, refuses the write, and is left '
          'exactly as it was', () async {
        put(text);

        expect(await repository().read(), PreferencesValueObject.defaults);
        final Result<void, AppFailure> written = await repository().write(
          chosen,
        );

        expect(
          written,
          isA<Failure<void, AppFailure>>().having(
            (Failure<void, AppFailure> failed) => failed.failure,
            'failure',
            isA<SettingsUnavailable>(),
          ),
        );
        expect(File(path).readAsStringSync(), text);
        expect(File(path).parent.listSync(), hasLength(1));
      });
    }

    test('bytes that are not text read as the defaults and are never '
        'written over', () async {
      File(path)
        ..parent.createSync(recursive: true)
        ..writeAsBytesSync(const <int>[0xff, 0xfe, 0x7b, 0x7d]);

      expect(await repository().read(), PreferencesValueObject.defaults);
      expect(
        await repository().write(chosen),
        isA<Failure<void, AppFailure>>(),
      );
      expect(File(path).readAsBytesSync(), const <int>[0xff, 0xfe, 0x7b, 0x7d]);
    });

    test('an empty file is a first run', () async {
      put('');

      expect(await repository().read(), PreferencesValueObject.defaults);
      expect(
        await repository().write(chosen),
        isA<Success<void, AppFailure>>(),
      );
      expect(await repository().read(), chosen);
    });

    test('a folder where the file should be is the defaults and a refusal, '
        'the folder kept', () async {
      Directory(path).createSync(recursive: true);
      File('$path/inside.txt').writeAsStringSync('kept');

      expect(await repository().read(), PreferencesValueObject.defaults);
      expect(
        await repository().write(chosen),
        isA<Failure<void, AppFailure>>(),
      );
      expect(File('$path/inside.txt').readAsStringSync(), 'kept');
    });
  });

  group('a disk that refuses', () {
    test(
      'a file that cannot be read is the defaults, and is not written over',
      () async {
        await repository().write(chosen);
        final String before = File(path).readAsStringSync();
        chmod('000', path, restore: '644');

        expect(await repository().read(), PreferencesValueObject.defaults);
        expect(
          await repository().write(PreferencesValueObject.defaults),
          isA<Failure<void, AppFailure>>(),
        );

        Process.runSync('chmod', <String>['644', path]);
        expect(File(path).readAsStringSync(), before);
      },
      skip: Platform.isWindows ? posixOnly : false,
    );

    test('a folder that cannot be written to keeps the choice it had, and no '
        'temporary beside it', () async {
      await repository().write(chosen);
      final String folder = File(path).parent.path;
      chmod('555', folder, restore: '755');

      expect(
        await repository().write(PreferencesValueObject.defaults),
        isA<Failure<void, AppFailure>>().having(
          (Failure<void, AppFailure> failed) => failed.failure,
          'failure',
          isA<SettingsUnavailable>(),
        ),
      );
      expect(await repository().read(), chosen);
      expect(Directory(folder).listSync(), hasLength(1));
    }, skip: Platform.isWindows ? posixOnly : false);

    test('a first choice with nowhere to make the folder is a failure, not a '
        'throw', () async {
      chmod('555', tempDir.path, restore: '755');

      expect(
        await repository().write(chosen),
        isA<Failure<void, AppFailure>>(),
      );
      expect(await repository().read(), PreferencesValueObject.defaults);
    }, skip: Platform.isWindows ? posixOnly : false);
  });
}

/// Records nothing: this file is about the preferences, and the recent list
/// is only its neighbour in the file.
final class _Silent implements Observability {
  const _Silent();

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async {}
}
