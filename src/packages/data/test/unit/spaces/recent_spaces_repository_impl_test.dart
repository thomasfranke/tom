/// [RecentSpacesRepositoryImpl] against a settings store in memory.
///
/// Unit, not integration: what this class does is decide a shape and survive
/// what it finds. The capability's own tests already prove a file survives a
/// restart; these prove a list survives a text someone else wrote.
library;

import 'dart:convert';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  late _Settings settings;
  late RecentSpacesRepositoryImpl repository;

  SpaceEntity spaceAt(String root, {String? name}) => SpaceEntity(
    root: root,
    repositoryRoot: root,
    name: name ?? SpaceEntity.nameOfFolder(root),
  );

  /// What [result] holds, or a failure of the test if it did not succeed.
  T valueOf<T, F extends AppFailure>(Result<T, F> result) => switch (result) {
    Success<T, F>(value: final T value) => value,
    Failure<T, F>(failure: final F failure) => throw StateError(
      'expected a success, got $failure',
    ),
  };

  Future<List<String>> roots() async => valueOf(
    await repository.list(),
  ).map((RecentSpaceEntity recent) => recent.root).toList();

  setUp(() {
    settings = _Settings();
    repository = RecentSpacesRepositoryImpl(settings: settings);
  });

  group('the first run', () {
    test('the list is empty, not a failure', () async {
      expect(valueOf(await repository.list()), isEmpty);
    });

    test('forgetting something never remembered succeeds', () async {
      expect(
        await repository.forget('/nowhere'),
        isA<Success<void, SettingsFailure>>(),
      );
    });
  });

  group('remembering', () {
    test('a space appears in the list', () async {
      await repository.remember(spaceAt('/code/app'));

      final List<RecentSpaceEntity> recents = valueOf(await repository.list());
      expect(recents.single.root, '/code/app');
      expect(recents.single.name, 'app');
    });

    test('the newest is first', () async {
      await repository.remember(spaceAt('/a'));
      await repository.remember(spaceAt('/b'));

      expect(await roots(), <String>['/b', '/a']);
    });

    test('opening one again moves it, and does not duplicate it', () async {
      // A space is identified by its folder.
      await repository.remember(spaceAt('/a'));
      await repository.remember(spaceAt('/b'));
      await repository.remember(spaceAt('/a'));

      expect(await roots(), <String>['/a', '/b']);
    });

    test('the name is whatever it was called then', () async {
      await repository.remember(spaceAt('/code/app/docs', name: 'The Docs'));

      expect(valueOf(await repository.list()).single.name, 'The Docs');
    });

    test('the list stops growing', () async {
      // Not a product rule; a default, and it is enforced on write.
      for (int i = 0; i < 15; i++) {
        await repository.remember(spaceAt('/space$i'));
      }

      expect(valueOf(await repository.list()), hasLength(10));
      expect((await roots()).first, '/space14');
    });
  });

  group('forgetting', () {
    setUp(() async {
      await repository.remember(spaceAt('/a'));
      await repository.remember(spaceAt('/b'));
    });

    test('takes one row and keeps the rest', () async {
      await repository.forget('/a');

      expect(await roots(), <String>['/b']);
    });

    test('is by folder, so a name cannot forget the wrong space', () async {
      await repository.forget('b');

      expect(await roots(), <String>['/b', '/a']);
    });
  });

  group('a stored list someone else wrote', () {
    test('nonsense is an empty list, not a crash', () async {
      settings.values['spaces.recent'] = 'this is not json';

      expect(valueOf(await repository.list()), isEmpty);
    });

    test('a JSON object rather than a list is empty too', () async {
      settings.values['spaces.recent'] = '{"root": "/a"}';

      expect(valueOf(await repository.list()), isEmpty);
    });

    test('one bad row does not cost the good ones', () async {
      // Total, like every other parser in this package.
      settings.values['spaces.recent'] = jsonEncode(<Object?>[
        <String, Object?>{
          'root': '/a',
          'name': 'a',
          'lastOpened': 'not a date',
        },
        <String, Object?>{'root': 42, 'name': 'b', 'lastOpened': '2026-09-01Z'},
        'a bare string',
        <String, Object?>{
          'root': '/good',
          'name': 'good',
          'lastOpened': '2026-09-01T00:00:00Z',
        },
      ]);

      expect(await roots(), <String>['/good']);
    });

    test('rows out of order are sorted, newest first', () async {
      settings.values['spaces.recent'] = jsonEncode(<Object?>[
        <String, Object?>{
          'root': '/older',
          'name': 'older',
          'lastOpened': '2026-01-01T00:00:00Z',
        },
        <String, Object?>{
          'root': '/newer',
          'name': 'newer',
          'lastOpened': '2026-09-01T00:00:00Z',
        },
      ]);

      expect(await roots(), <String>['/newer', '/older']);
    });
  });

  group('a store that is broken', () {
    setUp(() => settings.broken = true);

    test('reading answers an empty list rather than a failure', () async {
      // What a broken store costs is the list, not the session.
      expect(valueOf(await repository.list()), isEmpty);
    });

    test('remembering reports success anyway', () async {
      expect(
        await repository.remember(spaceAt('/code/app')),
        isA<Success<void, SettingsFailure>>(),
      );
    });

    test('forgetting reports success anyway', () async {
      expect(
        await repository.forget('/code/app'),
        isA<Success<void, SettingsFailure>>(),
      );
    });
  });
}

/// A [Settings] that keeps values in a map, and can be made to fail.
final class _Settings implements Settings {
  final Map<String, String> values = <String, String>{};
  bool broken = false;

  @override
  Future<Result<String?, SettingsFailure>> read(String key) async => broken
      ? const Failure<String?, SettingsFailure>(SettingsUnavailable('broken'))
      : Success<String?, SettingsFailure>(values[key]);

  @override
  Future<Result<void, SettingsFailure>> write(String key, String value) async {
    if (broken) {
      return const Failure<void, SettingsFailure>(
        SettingsUnavailable('broken'),
      );
    }
    values[key] = value;
    return const Success<void, SettingsFailure>(null);
  }

  @override
  Future<Result<void, SettingsFailure>> remove(String key) async {
    if (broken) {
      return const Failure<void, SettingsFailure>(
        SettingsUnavailable('broken'),
      );
    }
    values.remove(key);
    return const Success<void, SettingsFailure>(null);
  }
}
