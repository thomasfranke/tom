/// [ApprovalsRepositoryImpl] where the disk refuses or a second writer is
/// there: a folder that cannot be written to, a file that cannot be read,
/// two repositories over one file — on a real disk.
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

  const List<String> keys = <String>['git fetch', 'git push'];

  /// A repository of its own over the one file, as a second window would
  /// build it.
  ApprovalsRepositoryImpl repository() => ApprovalsRepositoryImpl(
    source: ApprovalsDataSource(
      filesystem: const DartIoFilesystemImpl(),
      path: file.path,
    ),
    keys: keys,
  );

  Map<String, Object?> held() =>
      jsonDecode(file.readAsStringSync()) as Map<String, Object?>;

  /// Runs `chmod`, and puts [restore] back when the test ends so the
  /// temporary folder can be removed.
  void chmod(String mode, String path, {required String restore}) {
    Process.runSync('chmod', <String>[mode, path]);
    addTearDown(() => Process.runSync('chmod', <String>[restore, path]));
  }

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('tom_approvals_refusals_');
    // A folder with a space, as `Application Support` has.
    file = File('${tempDir.path}/Application Support/tom/git-approvals.json');
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  const String posixOnly = 'permissions are POSIX here';

  group('a disk that refuses', () {
    test('a folder that cannot be written to keeps what was allowed, and no '
        'temporary beside it', () async {
      await repository().seed();
      await repository().write('git fetch', allowed: true);
      final String before = file.readAsStringSync();
      chmod('555', file.parent.path, restore: '755');

      expect(
        await repository().write('git push', allowed: true),
        isA<Failure<void, AppFailure>>().having(
          (Failure<void, AppFailure> failed) => failed.failure,
          'failure',
          isA<FilesystemAccessDenied>(),
        ),
      );

      expect(file.readAsStringSync(), before);
      expect(file.parent.listSync(), hasLength(1));
      final ApprovalsValueObject read = await repository().read();
      expect(read.allows('git fetch'), isTrue);
      expect(read.allows('git push'), isFalse);
    }, skip: Platform.isWindows ? posixOnly : false);

    test('a file that cannot be read allows nothing, refuses a change, and is '
        'left as it was', () async {
      await repository().write('git push', allowed: true);
      final String before = file.readAsStringSync();
      chmod('000', file.path, restore: '644');

      expect((await repository().read()).allows('git push'), isFalse);
      expect(
        await repository().write('git fetch', allowed: true),
        isA<Failure<void, AppFailure>>(),
      );
      expect(await repository().seed(), isA<Failure<void, AppFailure>>());

      Process.runSync('chmod', <String>['644', file.path]);
      expect(file.readAsStringSync(), before);
    }, skip: Platform.isWindows ? posixOnly : false);

    test('a first seed with nowhere to make the folder is a failure, not a '
        'throw', () async {
      chmod('555', tempDir.path, restore: '755');

      expect(await repository().seed(), isA<Failure<void, AppFailure>>());
      expect((await repository().read()).allowed, isEmpty);
    }, skip: Platform.isWindows ? posixOnly : false);

    test('a folder where the file should be allows nothing, and is '
        'kept', () async {
      Directory(file.path).createSync(recursive: true);
      File('${file.path}/inside.txt').writeAsStringSync('kept');

      expect((await repository().read()).allowed, isEmpty);
      expect(
        await repository().write('git push', allowed: true),
        isA<Failure<void, AppFailure>>(),
      );
      expect(File('${file.path}/inside.txt').readAsStringSync(), 'kept');
    });

    test('bytes that are not text allow nothing and are never written '
        'over', () async {
      file
        ..parent.createSync(recursive: true)
        ..writeAsBytesSync(const <int>[0xff, 0xfe, 0x7b, 0x7d]);

      expect((await repository().read()).allowed, isEmpty);
      expect(
        await repository().write('git push', allowed: true),
        isA<Failure<void, AppFailure>>(),
      );
      expect(file.readAsBytesSync(), const <int>[0xff, 0xfe, 0x7b, 0x7d]);
    });
  });

  group('two repositories over one file', () {
    test('one after the other, each sees and keeps what the other '
        'allowed', () async {
      final ApprovalsRepositoryImpl first = repository();
      final ApprovalsRepositoryImpl second = repository();

      await first.write('git fetch', allowed: true);
      await second.write('git push', allowed: true);
      await first.write('git pull --no-rebase', allowed: true);

      expect(held(), <String, Object?>{
        'git fetch': true,
        'git push': true,
        'git pull --no-rebase': true,
      });
      expect((await second.read()).allows('git fetch'), isTrue);
    });

    test('at the same instant, the file is still whole and readable — the '
        'last write wins and nothing is left beside it', () async {
      await repository().seed();

      await Future.wait(<Future<Result<void, AppFailure>>>[
        for (int index = 0; index < 20; index++)
          repository().write('git command-$index', allowed: true),
      ]);

      // Two windows are not supported: which keys survive is not promised.
      // What is: a JSON object, the seeded keys kept, and no temporary.
      final Map<String, Object?> after = held();
      expect(after.keys, containsAll(keys));
      expect(
        after.keys.where((String key) => key.startsWith('git command-')),
        isNotEmpty,
      );
      expect(file.parent.listSync(), hasLength(1));
    });
  });

  group('a key as a person would find it', () {
    test('with an accent, quotes and a path with a space is one key, '
        'written as itself', () async {
      const String key =
          'git commit --message "revisão — ação" -- '
          '<release notes/ação.md>';

      await repository().write(key, allowed: true);

      expect((await repository().read()).allows(key), isTrue);
      expect(held().keys.single, key);
      // The accent as itself, not as an escape.
      expect(file.readAsStringSync(), contains('revisão'));
    });
  });
}
