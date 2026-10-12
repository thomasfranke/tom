/// [ApprovalsRepositoryImpl] and its source over a filesystem that holds one
/// file in memory — what the file does on a real disk is the integration
/// test's.
library;

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  const String path = '/app/git-approvals.json';
  const List<String> keys = <String>['git push', 'git fetch'];
  late _OneFile disk;
  late ApprovalsRepositoryImpl repository;

  setUp(() {
    disk = _OneFile();
    repository = ApprovalsRepositoryImpl(
      source: ApprovalsDataSource(filesystem: disk, path: path),
      keys: keys,
    );
  });

  group('reading', () {
    test('no file allows nothing', () async {
      expect((await repository.read()).allowed, isEmpty);
      expect(disk.writes, isEmpty);
    });

    test('only a literal true allows', () async {
      disk.text = '{"git push": true, "git fetch": "yes", "git pull": 1}';

      final ApprovalsValueObject read = await repository.read();

      expect(read.allows('git push'), isTrue);
      expect(read.allows('git fetch'), isFalse);
      expect(read.allows('git pull'), isFalse);
    });

    test('a file that is not JSON allows nothing', () async {
      disk.text = '{ not json';

      expect((await repository.read()).allowed, isEmpty);
    });

    test('a JSON value that is not an object allows nothing', () async {
      disk.text = '[true]';

      expect((await repository.read()).allowed, isEmpty);
    });

    test('a disk that refuses allows nothing', () async {
      disk.failure = const FilesystemAccessDenied(path);

      expect((await repository.read()).allowed, isEmpty);
    });
  });

  group('writing', () {
    test('a key is written into a file that does not exist yet', () async {
      final Result<void, AppFailure> result = await repository.write(
        'git push',
        allowed: true,
      );

      expect(result, isA<Success<void, AppFailure>>());
      expect(disk.writes.single, '{\n  "git push": true\n}');
    });

    test('what the person typed beside the key is kept', () async {
      disk.text = '{"note": "mine", "git push": false}';

      await repository.write('git push', allowed: true);

      expect(disk.writes.single, contains('"note": "mine"'));
      expect(disk.writes.single, contains('"git push": true'));
    });

    test('an answer already in the file writes nothing', () async {
      disk.text = '{\n  "git push": true\n}';

      final Result<void, AppFailure> result = await repository.write(
        'git push',
        allowed: true,
      );

      expect(result, isA<Success<void, AppFailure>>());
      expect(disk.writes, isEmpty);
    });

    test('an empty file is a file with nothing in it', () async {
      disk.text = '  \n';

      await repository.write('git push', allowed: false);

      expect(disk.writes.single, contains('"git push": false'));
    });

    test('a file that is not an object is left as it is', () async {
      disk.text = '[1, 2]';

      final Result<void, AppFailure> result = await repository.write(
        'git push',
        allowed: true,
      );

      expect(
        (result as Failure<void, AppFailure>).failure,
        isA<FilesystemOperationFailed>().having(
          (FilesystemOperationFailed f) => f.path,
          'path',
          path,
        ),
      );
      expect(disk.writes, isEmpty);
    });

    test('a disk that refuses the read fails the write', () async {
      disk.failure = const FilesystemAccessDenied(path);

      final Result<void, AppFailure> result = await repository.write(
        'git push',
        allowed: true,
      );

      expect(
        (result as Failure<void, AppFailure>).failure,
        isA<FilesystemAccessDenied>(),
      );
    });

    test('a refused write comes back as it was refused', () async {
      disk.writeFailure = const FilesystemAccessDenied(path);

      final Result<void, AppFailure> result = await repository.write(
        'git push',
        allowed: true,
      );

      expect(
        (result as Failure<void, AppFailure>).failure,
        isA<FilesystemAccessDenied>(),
      );
    });
  });

  group('seeding', () {
    test('every key starts false, in the order listed', () async {
      await repository.seed();

      expect(
        disk.writes.single,
        '{\n  "git push": false,\n  "git fetch": false\n}',
      );
    });

    test('an answer already given is kept', () async {
      disk.text = '{"git push": true}';

      await repository.seed();

      expect(disk.writes.single, contains('"git push": true'));
      expect(disk.writes.single, contains('"git fetch": false'));
    });

    test('a file already complete is not touched', () async {
      disk.text = '{"git push": true, "git fetch": false}';

      await repository.seed();

      expect(disk.writes, isEmpty);
    });
  });
}

/// A filesystem of one file, [text], null while nobody has written it.
final class _OneFile implements Filesystem {
  String? text;
  FilesystemFailure? failure;
  FilesystemFailure? writeFailure;
  final List<String> writes = <String>[];

  @override
  Future<Result<String, FilesystemFailure>> readFile(String path) async {
    final FilesystemFailure? refused = failure;
    if (refused != null) {
      return Failure<String, FilesystemFailure>(refused);
    }
    final String? held = text;
    return held == null
        ? Failure<String, FilesystemFailure>(FilesystemEntryNotFound(path))
        : Success<String, FilesystemFailure>(held);
  }

  @override
  Future<Result<void, FilesystemFailure>> writeFile(
    String path,
    String content,
  ) async {
    final FilesystemFailure? refused = writeFailure;
    if (refused != null) {
      return Failure<void, FilesystemFailure>(refused);
    }
    writes.add(content);
    text = content;
    return const Success<void, FilesystemFailure>(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
