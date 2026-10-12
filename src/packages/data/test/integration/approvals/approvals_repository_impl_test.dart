/// [ApprovalsRepositoryImpl] against a real file, because what matters is
/// what a person finds when they open it — and what survives their typing.
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
  late File file;
  late ApprovalsRepositoryImpl repository;

  // In the order a capability declares them, which is the order they are
  // listed in.
  const List<String> keys = <String>[
    'git status --porcelain=v2 --branch --untracked-files=all -z',
    'git restore --staged -- <files>',
    'git restore --worktree -- <file>',
    'git push',
  ];

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('tom_approvals_');
    file = File('${tempDir.path}/app/git-approvals.json');
    repository = ApprovalsRepositoryImpl(
      source: ApprovalsDataSource(
        filesystem: const DartIoFilesystemImpl(),
        path: file.path,
      ),
      keys: keys,
    );
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  Map<String, Object?> held() =>
      jsonDecode(file.readAsStringSync()) as Map<String, Object?>;

  group('reading', () {
    test('no file allows nothing, and makes none', () async {
      final ApprovalsValueObject read = await repository.read();

      expect(read.allowed, isEmpty);
      expect(read.allows('git push'), isFalse);
      expect(file.existsSync(), isFalse);
    });

    test('only a literal true allows', () async {
      file
        ..parent.createSync(recursive: true)
        ..writeAsStringSync(
          '{"git push": true, "git fetch": false, "git pull --no-rebase": '
          '"yes", "git status": 1, "git commit --message <message>": null}',
        );

      final ApprovalsValueObject read = await repository.read();

      expect(read.allows('git push'), isTrue);
      expect(read.allows('git fetch'), isFalse);
      expect(read.allows('git pull --no-rebase'), isFalse);
      expect(read.allows('git status'), isFalse);
      expect(read.allows('git commit --message <message>'), isFalse);
      expect(read.allows('git merge --abort'), isFalse, reason: 'not held');
    });

    test('a file that is not a JSON object allows nothing, silently', () async {
      file.parent.createSync(recursive: true);
      for (final String broken in <String>['{"git push": tr', '[true]', '']) {
        file.writeAsStringSync(broken);

        expect((await repository.read()).allows('git push'), isFalse);
      }
    });
  });

  group('seeding', () {
    test('lists every command the app can run, each false', () async {
      final Result<void, AppFailure> seeded = await repository.seed();

      expect(seeded, isA<Success<void, AppFailure>>());
      expect(held(), <String, Object?>{
        for (final String key in keys) key: false,
      });
      expect(held().keys.toList(), keys, reason: 'in the order given');
    });

    test('is plain JSON, one key to a line, for a person to edit', () async {
      await repository.seed();

      expect(
        file.readAsLinesSync()[1],
        '  "git status --porcelain=v2 --branch --untracked-files=all -z": '
        'false,',
      );
    });

    test('never touches a key that is already there', () async {
      file
        ..parent.createSync(recursive: true)
        ..writeAsStringSync(
          '{"git push": true, "git something --old": true, '
          '"git restore --worktree -- <file>": "typed by hand"}',
        );

      await repository.seed();

      expect(held()['git push'], isTrue);
      expect(held()['git something --old'], isTrue, reason: 'unknown, kept');
      expect(held()['git restore --worktree -- <file>'], 'typed by hand');
      expect(held()['git restore --staged -- <files>'], isFalse);
      expect(
        held().keys.take(3),
        <String>[
          'git push',
          'git something --old',
          'git restore --worktree -- <file>',
        ],
        reason: 'what was there keeps its place; the rest follow',
      );
    });

    test('a file already complete is not written again', () async {
      await repository.seed();
      final DateTime written = file.lastModifiedSync();
      final String text = file.readAsStringSync();
      file.setLastModifiedSync(DateTime.utc(2020));

      await repository.seed();

      expect(file.lastModifiedSync().isBefore(written), isTrue);
      expect(file.readAsStringSync(), text);
    });

    test('a file that is not a JSON object is left as it is', () async {
      file
        ..parent.createSync(recursive: true)
        ..writeAsStringSync('{"git push": tr');

      final Result<void, AppFailure> seeded = await repository.seed();

      expect(seeded, isA<Failure<void, AppFailure>>());
      expect(file.readAsStringSync(), '{"git push": tr');
    });
  });

  group('allowing one command', () {
    test('writes true beside its key and leaves every other', () async {
      await repository.seed();

      await repository.write('git push', allowed: true);

      expect(held(), <String, Object?>{
        for (final String key in keys) key: key == 'git push',
      });
      expect((await repository.read()).allows('git push'), isTrue);
    });

    test('with no file yet, makes one holding that key', () async {
      await repository.write('git push', allowed: true);

      expect(held(), <String, Object?>{'git push': true});
    });

    test('flags are part of the key: one restore is not the other', () async {
      await repository.write('git restore --staged -- <files>', allowed: true);

      final ApprovalsValueObject read = await repository.read();
      expect(read.allows('git restore --staged -- <files>'), isTrue);
      expect(read.allows('git restore --worktree -- <file>'), isFalse);
    });

    test('can be taken back', () async {
      await repository.write('git push', allowed: true);
      await repository.write('git push', allowed: false);

      expect((await repository.read()).allows('git push'), isFalse);
    });

    test('never writes over a file somebody broke', () async {
      file
        ..parent.createSync(recursive: true)
        ..writeAsStringSync('not json at all');

      final Result<void, AppFailure> written = await repository.write(
        'git push',
        allowed: true,
      );

      expect(written, isA<Failure<void, AppFailure>>());
      expect(file.readAsStringSync(), 'not json at all');
    });
  });
}
