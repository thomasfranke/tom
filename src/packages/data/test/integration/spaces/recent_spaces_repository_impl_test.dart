/// [RecentSpacesRepositoryImpl] over the real settings file on a real disk:
/// the list Home draws, through the JSON a person could open.
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
  late _Recorded recorded;

  /// A repository of its own over the one file, as a second run of the app
  /// would build it.
  RecentSpacesRepositoryImpl repository() => RecentSpacesRepositoryImpl(
    recents: RecentSpacesDataSource(
      settings: JsonFileSettingsImpl(
        filesystem: const DartIoFilesystemImpl(),
        path: path,
      ),
    ),
    observability: recorded,
  );

  SpaceEntity space(String root) => SpaceEntity(
    root: root,
    repositoryRoot: root,
    name: SpaceEntity.nameOfFolder(root),
  );

  Future<List<String>> roots() async => <String>[
    for (final RecentSpaceEntity recent
        in ((await repository().list())
                as Success<List<RecentSpaceEntity>, Never>)
            .value)
      recent.root,
  ];

  /// Remembers [root] a moment after the last one, so two openings are never
  /// the same instant on a fast machine.
  Future<void> remember(String root) async {
    await Future<void>.delayed(const Duration(milliseconds: 2));
    await repository().remember(space(root));
  }

  void put(String text) => File(path)
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(text);

  Map<String, Object?> onDisk() =>
      jsonDecode(File(path).readAsStringSync()) as Map<String, Object?>;

  List<Object?> rowsOnDisk() => onDisk()['spaces.recent']! as List<Object?>;

  Map<String, Object?> row(String root, String lastOpened) => <String, Object?>{
    'root': root,
    'name': SpaceEntity.nameOfFolder(root),
    'lastOpened': lastOpened,
  };

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('tom_recent_spaces_');
    path = '${tempDir.path}/Application Support/tom/preferences.json';
    recorded = _Recorded();
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  group('a first run', () {
    test('lists nothing, makes no file and records nothing', () async {
      expect(await roots(), isEmpty);
      expect(File(path).existsSync(), isFalse);
      expect(recorded.failures, isEmpty);
    });

    test('forgetting a space nobody opened is not a failure', () async {
      expect(
        await repository().forget('/work/never'),
        isA<Success<void, Never>>(),
      );
      expect(await roots(), isEmpty);
      expect(recorded.failures, isEmpty);
    });
  });

  group('remembering', () {
    test('writes a row a person can read: root, name and an instant', () async {
      await remember('/work/release notes/ação');

      final Map<String, Object?> written =
          rowsOnDisk().single! as Map<String, Object?>;
      expect(written.keys, <String>['root', 'name', 'lastOpened']);
      expect(written['root'], '/work/release notes/ação');
      expect(written['name'], 'ação');
      expect(DateTime.parse(written['lastOpened']! as String).isUtc, isTrue);
      // The accent as itself, not as an escape.
      expect(File(path).readAsStringSync(), contains('ação'));
    });

    test('the latest opened is first, from a second repository', () async {
      await remember('/work/one');
      await remember('/work/two');
      await remember('/work/three');

      expect(await roots(), <String>['/work/three', '/work/two', '/work/one']);
    });

    test('opening a space again moves its row to the front and does not '
        'repeat it', () async {
      await remember('/work/one');
      await remember('/work/two');
      await remember('/work/one');

      expect(await roots(), <String>['/work/one', '/work/two']);
      expect(rowsOnDisk(), hasLength(2));
    });

    test('the eleventh space pushes the oldest off the file', () async {
      for (int index = 1; index <= 11; index++) {
        await remember('/work/space-$index');
      }

      expect(rowsOnDisk(), hasLength(10));
      expect(await roots(), <String>[
        for (int index = 11; index >= 2; index--) '/work/space-$index',
      ]);
      expect(File(path).readAsStringSync(), isNot(contains('"/work/space-1"')));
    });

    test(
      'a root differing only by a trailing letter is another space',
      () async {
        await remember('/work/notes');
        await remember('/work/notes2');

        expect(await roots(), <String>['/work/notes2', '/work/notes']);
      },
    );
  });

  group('forgetting', () {
    test('takes the row off the disk and keeps the others in order', () async {
      await remember('/work/one');
      await remember('/work/two');
      await remember('/work/three');

      expect(
        await repository().forget('/work/two'),
        isA<Success<void, Never>>(),
      );

      expect(await roots(), <String>['/work/three', '/work/one']);
      expect(File(path).readAsStringSync(), isNot(contains('/work/two')));
    });

    test('the last one leaves an empty list, not a missing key', () async {
      await remember('/work/one');

      await repository().forget('/work/one');

      expect(onDisk()['spaces.recent'], isEmpty);
      expect(await roots(), isEmpty);
    });

    test('a root that is not in the list changes nothing', () async {
      await remember('/work/one');
      final List<Object?> before = rowsOnDisk();

      await repository().forget('/work/ONE');

      expect(rowsOnDisk(), before);
    });
  });

  group('the file is shared', () {
    test('remembering and forgetting keep the preferences', () async {
      put('{"app.preferences": {"theme": "dark"}}');

      await remember('/work/one');
      await repository().forget('/work/one');

      expect(onDisk()['app.preferences'], <String, Object?>{'theme': 'dark'});
    });
  });

  group('a file somebody edited by hand', () {
    test('a row with a bad date, a bare string, a number and a row missing '
        'its name cost themselves, and the good rows stay', () async {
      put(
        jsonEncode(<String, Object?>{
          'spaces.recent': <Object?>[
            row('/work/good-old', '2026-09-01T10:00:00.000Z'),
            row('/work/bad-date', 'last tuesday'),
            '/work/bare',
            42,
            null,
            <String, Object?>{
              'root': '/work/no-name',
              'lastOpened': '2026-09-03T10:00:00.000Z',
            },
            row('/work/good-new', '2026-09-02T10:00:00.000Z'),
          ],
        }),
      );

      expect(await roots(), <String>['/work/good-new', '/work/good-old']);
      expect(recorded.failures, isEmpty);
    });

    test('rows out of order on disk are listed latest first', () async {
      put(
        jsonEncode(<String, Object?>{
          'spaces.recent': <Object?>[
            row('/work/january', '2026-01-01T00:00:00.000Z'),
            row('/work/march', '2026-03-01T00:00:00.000Z'),
            row('/work/february', '2026-02-01T00:00:00.000Z'),
          ],
        }),
      );

      expect(await roots(), <String>[
        '/work/march',
        '/work/february',
        '/work/january',
      ]);
    });

    test('an instant written with an offset is the same instant', () async {
      put(
        jsonEncode(<String, Object?>{
          'spaces.recent': <Object?>[
            row('/work/lisbon', '2026-09-01T10:00:00.000+01:00'),
          ],
        }),
      );

      final Result<List<RecentSpaceEntity>, Never> listed = await repository()
          .list();

      expect(
        (listed as Success<List<RecentSpaceEntity>, Never>).value.single,
        RecentSpaceEntity(
          root: '/work/lisbon',
          name: 'lisbon',
          lastOpened: DateTime.utc(2026, 9, 1, 9),
        ),
      );
    });

    test('a list that is not a list is an empty one', () async {
      put('{"spaces.recent": {"root": "/work/one"}}');

      expect(await roots(), isEmpty);
      expect(recorded.failures, isEmpty);
    });

    test('more than ten rows on disk are all listed, and the next opening '
        'trims the file to ten', () async {
      put(
        jsonEncode(<String, Object?>{
          'spaces.recent': <Object?>[
            for (int day = 1; day <= 12; day++)
              row(
                '/work/day-$day',
                DateTime.utc(2026, 9, day).toIso8601String(),
              ),
          ],
        }),
      );

      expect(await roots(), hasLength(12));

      await remember('/work/today');

      expect(rowsOnDisk(), hasLength(10));
      expect((await roots()).first, '/work/today');
      expect(await roots(), isNot(contains('/work/day-3')));
    });
  });

  group('the shape an older version wrote', () {
    test('a list escaped inside a string reads as the list', () async {
      put(
        jsonEncode(<String, Object?>{
          'spaces.recent': jsonEncode(<Object?>[
            row('/work/notes', '2026-09-01T10:00:00.000Z'),
          ]),
        }),
      );

      expect(await roots(), <String>['/work/notes']);
    });

    test('and the next opening writes it in today\'s', () async {
      put(
        jsonEncode(<String, Object?>{
          'spaces.recent': jsonEncode(<Object?>[
            row('/work/notes', '2026-09-01T10:00:00.000Z'),
          ]),
        }),
      );

      await remember('/work/other');

      expect(rowsOnDisk(), hasLength(2));
      expect(await roots(), <String>['/work/other', '/work/notes']);
    });
  });

  group('a file that cannot be trusted', () {
    for (final String text in <String>[
      '{"spaces.recent": [',
      'not json at all',
      '[]',
    ]) {
      test('`$text` lists nothing, is never written over, and the refusal '
          'reaches the diagnostics', () async {
        put(text);

        expect(await roots(), isEmpty);
        expect(
          await repository().remember(space('/work/one')),
          isA<Success<void, Never>>(),
        );
        expect(
          await repository().forget('/work/one'),
          isA<Success<void, Never>>(),
        );

        expect(File(path).readAsStringSync(), text);
        expect(File(path).parent.listSync(), hasLength(1));
        expect(recorded.failures, isNotEmpty);
        expect(recorded.failures, everyElement(isA<SettingsUnavailable>()));
        expect(recorded.layers.toSet(), <String>{'data'});
      });
    }

    test(
      'a file that cannot be read lists nothing, says so to the diagnostics, '
      'and keeps what it held',
      () async {
        await remember('/work/one');
        final String before = File(path).readAsStringSync();
        Process.runSync('chmod', <String>['000', path]);
        addTearDown(() => Process.runSync('chmod', <String>['644', path]));

        expect(await roots(), isEmpty);
        await repository().remember(space('/work/two'));

        expect(recorded.failures, isNotEmpty);
        Process.runSync('chmod', <String>['644', path]);
        expect(File(path).readAsStringSync(), before);
      },
      skip: Platform.isWindows ? 'permissions are POSIX here' : false,
    );

    test('a folder that cannot be written to keeps the list it had, and the '
        'refused write reaches the diagnostics', () async {
      await remember('/work/one');
      final String folder = File(path).parent.path;
      Process.runSync('chmod', <String>['555', folder]);
      addTearDown(() => Process.runSync('chmod', <String>['755', folder]));

      expect(
        await repository().remember(space('/work/two')),
        isA<Success<void, Never>>(),
      );

      expect(await roots(), <String>['/work/one']);
      expect(recorded.failures.single, isA<SettingsUnavailable>());
      expect(Directory(folder).listSync(), hasLength(1));
    }, skip: Platform.isWindows ? 'permissions are POSIX here' : false);
  });
}

/// The diagnostics port, writing down what it was handed: ours to implement,
/// and the one place a broken store is ever said.
final class _Recorded implements Observability {
  final List<Object> failures = <Object>[];
  final List<String> layers = <String>[];

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async {
    failures.add(error);
    layers.add(layer);
  }
}
