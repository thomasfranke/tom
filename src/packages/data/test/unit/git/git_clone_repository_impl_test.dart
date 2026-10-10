/// [GitCloneRepositoryImpl] against a recorded [GitClient], because a real
/// git cannot refuse credentials on demand.
library;

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late _Cloner client;
  late _Disk disk;
  late List<String> foldersAsked;
  late GitCloneRepositoryImpl repository;

  setUp(() {
    client = _Cloner();
    disk = _Disk();
    foldersAsked = <String>[];
    repository = GitCloneRepositoryImpl(
      git: GitCloneDataSource(
        gitClientFor: (String folder) {
          foldersAsked.add(folder);
          return client;
        },
        filesystem: disk,
      ),
    );
  });

  Future<Result<void, GitFailure>> clone({
    void Function(CloneProgressValueObject progress)? onProgress,
  }) => repository.clone(
    url: 'https://example.com/docs.git',
    destination: '/tmp/docs',
    onProgress: onProgress,
  );

  test('runs on the client of the folder it fills', () async {
    await clone();

    expect(foldersAsked, <String>['/tmp/docs']);
    expect(client.url, 'https://example.com/docs.git');
  });

  test('passes on the lines that are progress, and only those', () async {
    client.lines = <String>[
      "Cloning into '/tmp/docs'...",
      'Receiving objects:  50% (1/2)',
      'warning: something nobody waits for',
    ];
    final List<CloneProgressValueObject> heard = <CloneProgressValueObject>[];

    await clone(onProgress: heard.add);

    expect(heard, const <CloneProgressValueObject>[
      CloneProgressValueObject(stage: CloneStageEnum.starting),
      CloneProgressValueObject(stage: CloneStageEnum.receiving, percent: 50),
    ]);
  });

  test('asks git for no lines when nobody listens', () async {
    await clone();

    expect(client.listened, isFalse);
  });

  group('the three failures the doc names', () {
    Future<GitFailure> failingWith(GitClientFailure failure) async {
      client.failure = failure;
      return (await clone() as Failure<void, GitFailure>).failure;
    }

    test('an address with nothing there', () async {
      expect(
        await failingWith(const GitClientRemoteNotFound('does not exist')),
        isA<GitRemoteNotFound>(),
      );
    });

    test('credentials the user does not have', () async {
      expect(
        await failingWith(const GitClientAuthenticationFailed('denied')),
        isA<GitAuthenticationFailed>(),
      );
    });

    test('no network', () async {
      expect(
        await failingWith(const GitClientNetworkUnavailable('dns')),
        isA<GitNetworkUnavailable>(),
      );
    });
  });

  test('a taken folder keeps its path', () async {
    client.failure = const GitClientDestinationTaken('/tmp/docs');

    final GitFailure failure =
        (await clone() as Failure<void, GitFailure>).failure;

    expect(failure, isA<GitCloneDestinationTaken>());
    expect((failure as GitCloneDestinationTaken).path, '/tmp/docs');
  });

  test('the machine words travel as the cause', () async {
    const GitClientFailure reported = GitClientRemoteNotFound('fatal: ...');
    client.failure = reported;

    final GitFailure failure =
        (await clone() as Failure<void, GitFailure>).failure;

    expect(failure.cause, reported);
  });

  group('a clone that fails leaves nothing behind', () {
    setUp(
      () => client.failure = const GitClientTimedOut(
        'git clone',
        Duration(minutes: 2),
      ),
    );

    test('removes the folder when it was not there before', () async {
      await clone();

      expect(disk.deleted, <String>['/tmp/docs']);
    });

    test('empties a folder that was empty before, and keeps it', () async {
      disk
        ..types['/tmp/docs'] = FilesystemEntryTypeEnum.directory
        ..listings.addAll(<List<String>>[
          <String>[],
          <String>['/tmp/docs/.git', '/tmp/docs/index.md'],
        ]);

      await clone();

      expect(disk.deleted, <String>['/tmp/docs/.git', '/tmp/docs/index.md']);
    });

    test('touches a folder that already held something not at all', () async {
      disk
        ..types['/tmp/docs'] = FilesystemEntryTypeEnum.directory
        ..listings.add(<String>['/tmp/docs/notes.md']);
      client.failure = const GitClientDestinationTaken('/tmp/docs');

      await clone();

      expect(disk.deleted, isEmpty);
    });

    test('touches a file of that name not at all', () async {
      disk.types['/tmp/docs'] = FilesystemEntryTypeEnum.file;

      await clone();

      expect(disk.deleted, isEmpty);
    });

    test('touches nothing when the machine will not say', () async {
      disk.typeFailure = const FilesystemAccessDenied('/tmp/docs');

      await clone();

      expect(disk.deleted, isEmpty);
    });

    test('answers with the clone\'s failure, not the removal\'s', () async {
      disk.deleteFailure = const FilesystemAccessDenied('/tmp/docs');

      expect(
        (await clone() as Failure<void, GitFailure>).failure,
        isA<GitTimedOut>(),
      );
    });
  });

  test('a clone that works removes nothing', () async {
    await clone();

    expect(disk.deleted, isEmpty);
  });

  test('a refused clone is a refusal, not a clone that broke', () async {
    client.failure = const GitClientCommandDenied('git clone');

    expect(
      (await clone() as Failure<void, GitFailure>).failure,
      isA<GitCommandDenied>(),
    );
  });
}

/// A [Filesystem] holding one destination, which records what is removed.
final class _Disk implements Filesystem {
  /// What is at each path; a path not here holds nothing.
  final Map<String, FilesystemEntryTypeEnum> types =
      <String, FilesystemEntryTypeEnum>{};

  /// What each listing answers, in turn.
  final List<List<String>> listings = <List<String>>[];

  /// What looking at a path fails with, or null to answer.
  FilesystemFailure? typeFailure;

  /// What a removal fails with, or null to succeed.
  FilesystemFailure? deleteFailure;

  final List<String> deleted = <String>[];

  @override
  Future<Result<FilesystemEntryTypeEnum?, FilesystemFailure>> entryTypeOf(
    String path,
  ) async {
    final FilesystemFailure? failure = typeFailure;
    return failure == null
        ? Success<FilesystemEntryTypeEnum?, FilesystemFailure>(types[path])
        : Failure<FilesystemEntryTypeEnum?, FilesystemFailure>(failure);
  }

  @override
  Future<Result<List<FilesystemEntryDto>, FilesystemFailure>> listDirectory(
    String path, {
    bool recursive = false,
  }) async =>
      Success<List<FilesystemEntryDto>, FilesystemFailure>(<FilesystemEntryDto>[
        for (final String entry in listings.removeAt(0))
          FilesystemEntryDto(path: entry, type: FilesystemEntryTypeEnum.file),
      ]);

  @override
  Future<Result<void, FilesystemFailure>> delete(String path) async {
    deleted.add(path);
    final FilesystemFailure? failure = deleteFailure;
    return failure == null
        ? const Success<void, FilesystemFailure>(null)
        : Failure<void, FilesystemFailure>(failure);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A [GitClient] that answers `clone` and refuses every other question.
final class _Cloner implements GitClient {
  /// What git is taken to print while cloning.
  List<String> lines = <String>[];

  /// What the clone fails with, or null to succeed.
  GitClientFailure? failure;

  String? url;
  bool listened = false;

  @override
  Future<Result<void, GitClientFailure>> clone(
    String url, {
    void Function(String line)? onProgress,
  }) async {
    this.url = url;
    listened = onProgress != null;
    lines.forEach(onProgress ?? (String _) {});
    final GitClientFailure? pending = failure;
    return pending == null
        ? const Success<void, GitClientFailure>(null)
        : Failure<void, GitClientFailure>(pending);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
